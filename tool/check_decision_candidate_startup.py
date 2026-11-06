"""Run candidate HTTP readiness on an on-host temporary restored Raysto DB.

No production data leaves AWS. No production service, environment or symlink
changes. Serverless role disables restored future calls; provider credentials
are not supplied. Only sanitized acceptance metadata is returned.
"""
import base64
import json
from pathlib import Path
import subprocess
import uuid,re
from decision_upload import upload

ROOT=Path(__file__).resolve().parents[1]
KEY=Path(r'C:\Users\fabat\Desktop\Awhar\modernapp\v1\awhar_backend\new-key-awhar.pem')
HOST='ubuntu@13.51.45.215'
artifact=json.loads((ROOT/'docs/impact-innovation/backend-artifact.json').read_text(encoding='utf-8'))
run=uuid.uuid4().hex[:12]
remote='/home/ubuntu/raysto-upload/'+Path(artifact['artifact']).name
upload(ROOT/artifact['artifact'],remote)
payload=base64.b64encode(json.dumps({**artifact,'run':run,'archive':remote}).encode()).decode()
source=r'''
import base64,hashlib,json,os,secrets,shutil,socket,subprocess,tarfile,time,urllib.request
from pathlib import Path
from datetime import datetime,timezone
assert os.geteuid()==0
os.umask(0o077)
c=json.loads(base64.b64decode('PAYLOAD'));run=c['run']
assert len(run)==12 and all(x in '0123456789abcdef' for x in run)
database='raysto_decision_startup_'+run
role=database
base=Path('/opt/raysto')/('startup-'+run)
archive=Path(c['archive']);assert archive.parent==Path('/home/ubuntu/raysto-upload') and archive.name.startswith('raysto-backend-') and archive.name.endswith('.tar.gz')
assert hashlib.sha256(archive.read_bytes()).hexdigest()==c['sha256']
assert not base.exists();base.mkdir(mode=0o750)
dump=base/'backup.dump';process=None;created=False;role_created=False
def pg(*args,data=None):return subprocess.check_output(['runuser','-u','postgres','--',*args],input=data,stderr=subprocess.PIPE)
def sql(text,db=database):return pg('psql','-d',db,'-At','-v','ON_ERROR_STOP=1',data=text.encode()).decode().strip()
def baseline():
 return [subprocess.check_output(['systemctl','show','awhar-server','-p','MainPID','--value']).decode().strip(),
  hashlib.sha256(Path('/etc/nginx/sites-available/awhar.com').read_bytes()).hexdigest(),
  str(Path('/opt/raysto/current').resolve()),
  subprocess.check_output(['systemctl','show','raysto','-p','MainPID','--value']).decode().strip()]
before=baseline();stage='backup'
try:
 with dump.open('xb') as output:subprocess.run(['runuser','-u','postgres','--','pg_dump','-Fc','raysto_production'],stdout=output,stderr=subprocess.PIPE,check=True)
 password=secrets.token_hex(32)
 stage='isolated-role';sql('CREATE ROLE '+role+" LOGIN PASSWORD '"+password+"';",db='postgres');role_created=True
 pg('createdb','--owner='+role,database);created=True
 stage='restore';pg('pg_restore','-d',database,'--no-owner','--no-acl','--role='+role,'--exit-on-error',data=dump.read_bytes())
 stage='extract'
 if c.get('artifactKind')=='binary-delta':
  previous=Path('/opt/raysto/current').resolve();assert previous.name==c['baseRelease']
  manifest=subprocess.check_output(['/bin/sh','-c','find lib migrations -type f -exec sha256sum {} + | LC_ALL=C sort'],cwd=previous)
  assert hashlib.sha256(manifest).hexdigest()==c['reusedLibrariesAndMigrationsSha256']
  for name in ['lib','migrations']:shutil.copytree(previous/name,base/name)
 with tarfile.open(archive) as tar:
  for m in tar.getmembers():
   target=(base/m.name).resolve()
   assert not m.issym() and not m.islnk() and base in target.parents
   assert Path(m.name).parts[0] in {'bin','lib','migrations'}
  tar.extractall(base,filter='data')
 stage='migrations'
 migrations=['20261105161345704','20261105193140136']
 current_migration=sql("SELECT version FROM serverpod_migrations WHERE module='raysto'")
 for m in migrations:
  if m>current_migration:sql('SET ROLE '+role+';\n'+(base/'migrations'/m/'migration.sql').read_text())
 (base/'config').mkdir();(base/'web').mkdir()
 sockets=[];ports=[]
 for _ in range(3):
  s=socket.socket();s.bind(('127.0.0.1',0));sockets.append(s);ports.append(s.getsockname()[1])
 config={'apiServer':{'port':ports[0],'publicHost':'localhost','publicPort':ports[0],'publicScheme':'http'},
  'insightsServer':{'port':ports[1],'publicHost':'localhost','publicPort':ports[1],'publicScheme':'http'},
  'webServer':{'port':ports[2],'publicHost':'localhost','publicPort':ports[2],'publicScheme':'http'},
  'database':{'host':'127.0.0.1','port':5432,'name':database,'user':role,'requireSsl':False,'maxConnectionCount':3},
  'sessionLogs':{'persistentEnabled':False,'consoleEnabled':True},'futureCallExecutionEnabled':False}
 (base/'config/production.yaml').write_text(json.dumps(config))
 for folder,dirs,files in os.walk(base):
  os.chmod(folder,0o750);shutil.chown(folder,user='root',group='raysto')
  for name in files:
   p=Path(folder)/name
   if p==dump:continue
   p.chmod(0o750 if p in [base/'bin/server',base/'lib/paypal-mcp/node'] else 0o640);shutil.chown(p,user='root',group='raysto')
 env={'PATH':'/usr/bin:/bin','SERVERPOD_PASSWORD_database':password,
  'SERVERPOD_PASSWORD_serviceSecret':secrets.token_hex(32),'SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey':secrets.token_hex(64),
  'SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper':secrets.token_hex(32),
  'RAYSTO_PLATFORM_WORKER_ENABLED':'false','RAYSTO_NOTIFICATIONS_ENABLED':'false','RAYSTO_PLATFORM_V2_ENABLED':'false'}
 for s in sockets:s.close()
 stage='candidate-startup'
 with (base/'startup.log').open('wb') as log:
  process=subprocess.Popen(['/usr/sbin/runuser','-u','raysto','--',str(base/'bin/server'),'--mode=production','--role=serverless','--server-id=isolated-startup','--logging=normal'],cwd=base,env=env,stdout=log,stderr=subprocess.STDOUT)
  for _ in range(45):
   if process.poll() is not None:raise RuntimeError('Candidate exited')
   try:
    with urllib.request.urlopen('http://127.0.0.1:'+str(ports[2])+'/ready',timeout=2) as r:ready=json.load(r)
    if ready.get('status')=='ready':break
   except Exception:pass
   time.sleep(1)
  else:raise RuntimeError('Readiness timeout')
 assert baseline()==before
 result={'checkedAtUtc':datetime.now(timezone.utc).isoformat(),'status':'passed','artifactSha256':c['sha256'],
  'sourceRelease':Path(before[2]).name,'scope':'Candidate HTTP readiness on isolated on-host restored and migrated database',
  'databaseConnected':True,'backgroundJobsDisabled':True,'providerCredentialsSupplied':False,
  'productionChanged':False,'dataExported':False,'servicesUnchanged':True,'authenticationAndProviderAcceptance':'separate gates'}
 print(json.dumps(result))
except Exception as e:
 print(json.dumps({'status':'failed','stage':stage,'errorType':type(e).__name__,'productionChanged':False,'dataExported':False}))
finally:
 if process and process.poll() is None:
  process.terminate()
  try:process.wait(timeout=15)
  except subprocess.TimeoutExpired:process.kill();process.wait(timeout=5)
 if created:pg('dropdb','--force',database)
 if role_created:sql('DROP ROLE '+role+';',db='postgres')
 assert base.parent==Path('/opt/raysto') and base.name=='startup-'+run
 shutil.rmtree(base)
 # Retain the verified public artifact for deployment or a harness retry.
'''.replace('PAYLOAD',payload)
result=subprocess.run(['ssh','-i',str(KEY),'-o','BatchMode=yes',HOST,'sudo python3 -'],input=source.encode(),capture_output=True)
if result.returncode:
 detail=result.stderr.decode(errors='replace')
 print(json.dumps({'status':'harness-failed','remoteLines':re.findall(r'File "<stdin>", line (\d+)',detail),'errorType':re.findall(r'(?:^|\n)([A-Za-z]+Error):',detail),'safeReport':result.stdout.decode() if result.stdout.strip().startswith(b'{') else None}))
 raise SystemExit('Isolated startup execution failed; no production data returned.')
report=json.loads(result.stdout.decode())
(ROOT/'docs/impact-innovation/restored-startup.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
if report['status']!='passed':raise SystemExit(1)
