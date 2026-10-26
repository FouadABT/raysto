"""Emit reviewable contracts and reference docs from authored models/registry.
Does not run a server, tests, provider requests or database migrations.
"""
from pathlib import Path
import json, re

ROOT=Path(__file__).resolve().parents[2]
SERVER=ROOT/'backend/raysto/raysto_server'
OUT=ROOT/'docs/backend-v2'
SDK=ROOT/'backend/sdk/typescript'
OUT.mkdir(parents=True,exist_ok=True);SDK.mkdir(parents=True,exist_ok=True)
registry=(SERVER/'lib/src/platform/platform.dart').read_text(encoding='utf-8')
commands=dict((name,(module,method)) for name,module,method in re.findall(r"'([a-zA-Z.]+)': (\w+)\.(\w+)",registry))
queries=sorted(set(re.findall(r"case '([^']+)':",(SERVER/'lib/src/platform/queries.dart').read_text(encoding='utf-8')))|{'discovery','storefront','table.resolve','availability'})
typed={'quote.create':'CreateQuote','order.submit':'SubmitOrder','visit.start':'StartVisit','payment.allocate':'AllocatePayment','payment.refund':'RequestRefund'}
schemas={}
dictionary=['# Data dictionary','', 'Generated from authored `.spy.yaml` models. Money is integer minor units; dates are UTC. JSON fields are validated by the owning domain module. PostgreSQL owns business state.','']
for path in sorted((SERVER/'lib/src/models/platform').glob('*.spy.yaml')):
    source=path.read_text(encoding='utf-8');name=re.search(r'^class: (.+)$',source,re.M).group(1)
    table=re.search(r'^table: (.+)$',source,re.M)
    fields=re.search(r'^fields:\n(.*?)(?=^indexes:|\Z)',source,re.M|re.S)
    properties={};required=[];dictionary.extend([f'## {name}', '', f"Table: `{table.group(1)}`" if table else 'Transport model.','', '| Field | Type |','|---|---|'])
    if fields:
      for field,raw in re.findall(r'^  (\w+): (.+)$',fields.group(1),re.M):
        kind=raw.split(',')[0];nullable=kind.endswith('?');kind=kind.rstrip('?')
        schema={'type':{'int':'integer','double':'number','bool':'boolean','String':'string','DateTime':'string'}.get(kind,'array' if kind.startswith('List<') else 'object')}
        if nullable:schema['type']=[schema['type'],'null']
        else:required.append(field)
        if kind=='DateTime':schema['format']='date-time'
        if kind.startswith('List<'):schema['items']={'type':'string' if 'String' in kind else 'object'}
        if field=='requestKey':schema.update(minLength=16,maxLength=100,pattern='^[A-Za-z0-9_-]+$')
        if field.endswith('Json'):schema.update(contentMediaType='application/json',description='JSON-encoded object or array validated by the domain command.')
        properties[field]=schema;dictionary.append(f'| `{field}` | `{raw}` |')
    schemas[name]={'type':'object','properties':properties,'required':required,'additionalProperties':False}
    dictionary.append('')
schemas['Error']={'type':'object','required':['error'],'properties':{'error':{'type':'object','required':['code','requestId'],'properties':{'code':{'type':'string'},'message':{'type':'string'},'requestId':{'type':'string'},'retryable':{'type':'boolean'},'fieldErrors':{'type':'array','items':{'type':'object'}}}}}}
schemas['Result']={'type':'object','required':['requestId','data'],'properties':{'requestId':{'type':'string'},'data':{'type':'object','additionalProperties':True}}}
paths={}
for command in sorted(set(commands)|set(typed)):
    model=typed.get(command,'PlatformCommand')
    paths['/commands/'+command]={'post':{'operationId':command.replace('.','_'),'summary':command,'tags':[command.split('.')[0]],'security':[{'backendBearer':[],'firebaseProof':[]}],
      'requestBody':{'required':True,'content':{'application/json':{'schema':{'$ref':'#/components/schemas/'+model}}}},
      'responses':{'200':{'description':'Command result. Provider operations may remain pending.','content':{'application/json':{'schema':{'$ref':'#/components/schemas/Result'}}}},'default':{'description':'Stable domain error; reuse the request key for safe retries.','content':{'application/json':{'schema':{'$ref':'#/components/schemas/Error'}}}}}}}
for query in queries:
    paths['/queries/'+query]={'get':{'operationId':'query_'+query.replace('.','_'),'summary':query,'security':[] if query in {'discovery','storefront','table.resolve'} else [{'backendBearer':[],'firebaseProof':[]}],
      'parameters':[{'name':name,'in':'query','required':False,'schema':{'type':kind}} for name,kind in [('restaurantId','integer'),('id','integer'),('cursor','integer'),('limit','integer'),('q','string'),('qr','string'),('mode','string'),('from','string'),('until','string'),('report','string'),('staff','boolean'),('visitId','integer')]],
      'responses':{'200':{'description':'Authorized projection; cursor pagination, at most 100 rows.','content':{'application/json':{'schema':{'$ref':'#/components/schemas/Result'}}}}}}}
paths['/events']={'get':{'operationId':'events','summary':'Authorized restaurant invalidations; refresh snapshots after each event.','security':[{'backendBearer':[],'firebaseProof':[]}],'parameters':[{'name':'restaurantId','in':'query','required':True,'schema':{'type':'integer'}},{'name':'after','in':'query','schema':{'type':'integer','minimum':0}}],'responses':{'200':{'description':'24-second bounded SSE stream. Reconnect using last cursor.','content':{'text/event-stream':{'schema':{'type':'string'}}}}}}}
paths['/media/{id}/content']={'put':{'operationId':'uploadContent','parameters':[{'name':'id','in':'path','required':True,'schema':{'type':'integer'}}],'security':[{'backendBearer':[],'firebaseProof':[]}],'requestBody':{'required':True,'content':{'application/octet-stream':{'schema':{'type':'string','format':'binary','maxLength':8388608}}}},'responses':{'200':{'description':'Private upload quarantined for validation.'}}}}
paths['/media/{id}']={'get':{'operationId':'readMedia','parameters':[{'name':'id','in':'path','required':True,'schema':{'type':'integer'}}],'responses':{'200':{'description':'Approved image or authorized private file. Exports expire after 24 hours.'}}}}
for suffix in ['paypal-platform','paypal-billing']:
    paths['/webhooks/'+suffix]={'post':{'operationId':'webhook_'+suffix.replace('-','_'),'description':'PayPal signature headers required; signature verified before durable inbox insertion.','requestBody':{'required':True,'content':{'application/json':{'schema':{'type':'object'}}}},'responses':{'200':{'description':'Durably received, processing asynchronous.'}}}}
for provider,field in [('firebase','firebaseIdToken'),('guest','appCheckToken')]:
    paths['/auth/'+provider]={'post':{'operationId':'authenticate_'+provider,'security':[],'requestBody':{'required':True,'content':{'application/json':{'schema':{'type':'object','required':[field],'properties':{field:{'type':'string','maxLength':16000}},'additionalProperties':False}}}},'responses':{'200':{'description':'Verified Serverpod AuthSuccess envelope.'}}}}
for operations in paths.values():
    for operation in operations.values():
        if operation.get('security')==[{'backendBearer':[],'firebaseProof':[]}]:operation['security'].append({'backendBearer':[],'appCheck':[]})
        if operation.get('operationId')=='query_availability':operation['security']=[]
        if operation.get('operationId','').startswith('query_'):
            operation['parameters'] += [{'name':n,'in':'query','schema':{'type':t}} for n,t in [('startsAt','string'),('partySize','integer'),('orderId','integer'),('latitude','number'),('longitude','number'),('openNow','boolean')]]
spec={'openapi':'3.1.0','info':{'title':'Raysto platform API','version':'2.0.0','description':'Registered clients send both a Serverpod bearer token and current Firebase ID token. Guests send bearer + App Check. See release evidence for enabled providers and verified workflows.'},'servers':[{'url':'https://api.rays.to/api/v2','description':'Raysto AWS mobile integration environment; payments remain Sandbox.'}],'paths':paths,'components':{'schemas':{k:v for k,v in schemas.items() if k in set(typed.values())|{'PlatformCommand','Result','Error'}},'securitySchemes':{'backendBearer':{'type':'http','scheme':'bearer'},'firebaseProof':{'type':'apiKey','in':'header','name':'X-Raysto-Firebase-Token'},'appCheck':{'type':'apiKey','in':'header','name':'X-Firebase-AppCheck'}}}}
(OUT/'openapi.json').write_text(json.dumps(spec,indent=2)+'\n',encoding='utf-8')
(OUT/'data-dictionary.md').write_text('\n'.join(dictionary),encoding='utf-8')
trace=['# Capability and implementation index','','Generated command/query inventory. Each command uses shared authorization, SQL transactions and idempotency. External side effects are reconciled separately.','', '| Operation | Service | REST path |','|---|---|---|']
for c,(module,method) in sorted(commands.items()):trace.append(f'| `{c}` | `{module}.{method}` | `/api/v2/commands/{c}` |')
for c,model in typed.items():trace.append(f'| `{c}` | Typed `{model}` | `/api/v2/commands/{c}` |')
trace+=['','Read queries: '+', '.join(f'`{q}`' for q in queries)+'.','','Schemas are in [data-dictionary.md](data-dictionary.md); release limitations and deferred gates are in [README.md](README.md).']
(OUT/'capability-index.md').write_text('\n'.join(trace)+'\n',encoding='utf-8')
ts=['// Generated by backend/tools/export_platform_contracts.py. Do not hand-edit.','export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };']
for name in ['PlatformCommand',*typed.values()]:
    schema=schemas[name];ts.append(f'export interface {name} '+'{')
    for field,prop in schema['properties'].items():
        types=prop['type'] if isinstance(prop['type'],list) else [prop['type']];kind=' | '.join({'integer':'number','number':'number','string':'string','boolean':'boolean','null':'null','array':'string[]','object':'Record<string, Json>'}[t] for t in types)
        ts.append(f'  {field}{"?" if field not in schema["required"] else ""}: {kind};')
    ts.append('}')
ts.append('export type CommandName = '+' | '.join(json.dumps(c) for c in sorted(commands))+';')
ts.append('export type QueryName = '+' | '.join(json.dumps(q) for q in queries)+';')
ts.append('''export interface Credentials { bearer: string; firebaseIdToken?: string; appCheck?: string }
export interface ApiError { code: string; requestId: string; message?: string; retryable?: boolean; fieldErrors?: Json[] }
export class RaystoApiError extends Error { constructor(public readonly detail: ApiError, public readonly status: number) { super(detail.message ?? detail.code); } }
export class RaystoClient {
  constructor(private readonly base: string, private readonly credentials: () => Promise<Credentials>) {
    const u = new URL(base); if (u.protocol !== 'https:' && u.hostname !== 'localhost') throw new Error('HTTPS required');
  }
  private async headers(): Promise<Record<string, string>> {
    const c = await this.credentials(); return { Authorization: `Bearer ${c.bearer}`, ...(c.firebaseIdToken ? {'X-Raysto-Firebase-Token': c.firebaseIdToken} : {}), ...(c.appCheck ? {'X-Firebase-AppCheck': c.appCheck} : {}) };
  }
  private async call<T>(path: string, body?: unknown): Promise<T> {
    const response = await fetch(this.base.replace(/\\/$/, '') + path, {method: body === undefined ? 'GET' : 'POST', headers: {...await this.headers(), 'Content-Type':'application/json'}, body: body === undefined ? undefined : JSON.stringify(body), signal: AbortSignal.timeout(35000)});
    const value = await response.json(); if (!response.ok) throw new RaystoApiError(value.error ?? {code:'transport_error', requestId:''},response.status); return value.data as T;
  }
  // Transport timeouts never imply payment failure. Reuse the original requestKey.
  command<T extends Json = Json>(name: CommandName, input: PlatformCommand): Promise<T> { return this.call('/commands/'+name,input); }
  query<T extends Json = Json>(name: QueryName, params: Record<string,string|number|boolean> = {}): Promise<T> { const q = new URLSearchParams(Object.entries(params).map(([k,v])=>[k,String(v)])); return this.call('/queries/'+name+'?'+q); }
''')
for command,model in typed.items():ts.append(f"  {model[0].lower()+model[1:]}<T extends Json = Json>(input: {model}): Promise<T> {{ return this.call('/commands/{command}',input); }}")
ts.append('''  async uploadContent(mediaId: number, bytes: Uint8Array): Promise<Json> {
    const response = await fetch(this.base.replace(/\\/$/, '')+`/media/${mediaId}/content`,{method:'PUT',headers:await this.headers(),body:new Blob([bytes as BlobPart]),signal:AbortSignal.timeout(60000)});
    const value=await response.json();if(!response.ok)throw new RaystoApiError(value.error,response.status);return value;
  }
  async events(restaurantId: number, after: number, signal: AbortSignal): Promise<ReadableStream<Uint8Array>> {
    const response=await fetch(this.base.replace(/\\/$/, '')+`/events?restaurantId=${restaurantId}&after=${after}`,{headers:await this.headers(),signal});
    if(!response.ok||!response.body)throw new RaystoApiError({code:'stream_unavailable',requestId:''},response.status);return response.body;
  }
}
''')
(SDK/'raysto-client.ts').write_text('\n'.join(ts),encoding='utf-8')
(SDK/'tsconfig.json').write_text(json.dumps({'compilerOptions':{'target':'ES2022','module':'ESNext','lib':['ES2022','DOM'],'strict':True,'noEmit':True},'include':['raysto-client.ts']},indent=2),encoding='utf-8')
print(f'Exported {len(commands)+len(typed)} command paths, {len(queries)} queries, {len(schemas)-2} source models and TypeScript client.')
