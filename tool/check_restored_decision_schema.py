"""Validate an isolated Raysto restore on AWS; never transfer production data.
Only migration SQL travels to the host. Only hashes/counts/status return.
Production is read by pg_dump; no services or other databases change.
"""
import base64
import json
from pathlib import Path
import subprocess
import uuid

ROOT=Path(__file__).resolve().parents[1]
KEY=Path(r'C:\Users\fabat\Desktop\Awhar\modernapp\v1\awhar_backend\new-key-awhar.pem')
HOST='ubuntu@13.51.45.215'
migrations=['20261105161345704','20261105193140136']
payload={'run':uuid.uuid4().hex[:12], 'migrations':{m:(ROOT/'backend/raysto/raysto_server/migrations'/m/'migration.sql').read_text(encoding='utf-8') for m in migrations}}
encoded=base64.b64encode(json.dumps(payload).encode()).decode()
source="""
import base64,hashlib,json,os,subprocess
from pathlib import Path
from datetime import datetime,timezone
config=json.loads(base64.b64decode('PAYLOAD'))
run=config['run'];assert len(run)==12 and all(c in '0123456789abcdef' for c in run)
database='raysto_decision_restore_'+run
dump=Path('/tmp/raysto-decision-backup-'+run+'.dump')
os.umask(0o077)
def pg(*args,data=None):
 return subprocess.check_output(['sudo','-u','postgres',*args],input=data,stderr=subprocess.PIPE)
def sql(text):
 return pg('psql','-d',database,'-At','-v','ON_ERROR_STOP=1',data=text.encode()).decode().strip()
created=False;stage='backup'
try:
 with dump.open('xb') as output:
  subprocess.run(['sudo','-u','postgres','pg_dump','-Fc','raysto_production'],stdout=output,stderr=subprocess.PIPE,check=True)
 digest=hashlib.sha256(dump.read_bytes()).hexdigest()
 stage='create-isolated-database';pg('createdb',database);created=True
 stage='restore'
 pg('pg_restore','-d',database,'--no-owner','--no-acl','--exit-on-error',data=dump.read_bytes())
 tables=['raysto_stock_movement','raysto_order','raysto_payment_capture','raysto_bill']
 def snapshot():
  return {t:sql("SELECT count(*) || ':' || md5(coalesce(string_agg((to_jsonb(t)-'purchaseUnit')::text,'' ORDER BY id),'')) FROM "+t+" t;") for t in tables}
 stage='baseline-record-fingerprints';before=snapshot()
 for name,text in config['migrations'].items():
  stage='migration-'+name;sql(text)
 stage='verify-record-preservation'
 assert snapshot()==before,'Existing records changed'
 assert sql("SELECT count(*) FROM information_schema.columns WHERE table_name='raysto_stock_movement' AND column_name='purchaseUnit';")=='1'
 assert sql("SELECT count(*) FROM pg_indexes WHERE indexname='finance_record_key';")=='1'
 print(json.dumps({'checkedAtUtc':datetime.now(timezone.utc).isoformat(),'status':'passed',
  'sourceRelease':'0.16.1-20261104','backupSha256':digest,'migrations':list(config['migrations']),
  'preservedRecords':before,'productionChanged':False,'dataExported':False,
  'scope':'Isolated temporary Raysto database on the existing AWS host; additive migrations and record preservation',
  'applicationStartup':'Not established by this schema check'}))
except Exception as error:
 print(json.dumps({'status':'failed','stage':stage,'errorType':type(error).__name__,
  'detail': 'relation_missing' if b'does not exist' in getattr(error,'stderr',b'') else 'inspect_on_host',
  'productionChanged':False,'dataExported':False}))
finally:
 if created:
  assert database=='raysto_decision_restore_'+run
  pg('dropdb',database)
 assert dump.parent==Path('/tmp') and dump.name=='raysto-decision-backup-'+run+'.dump'
 dump.unlink(missing_ok=True)
""".replace('PAYLOAD',encoded)
result=subprocess.run(['ssh','-i',str(KEY),'-o','BatchMode=yes','-o','ConnectTimeout=15',HOST,'python3 -'],input=source.encode(),capture_output=True)
if result.returncode:
    raise SystemExit('Restored-copy check failed; no production data returned. Inspect the bounded private execution error on the host.')
report=json.loads(result.stdout.decode())
if report.get('status')!='passed':
    raise SystemExit(json.dumps(report))
(ROOT/'docs/impact-innovation/restored-schema.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('PASS: on-host isolated restore, additive migrations and unchanged records; no production data exported.')
