"""Resume the staged candidate only after verifying all schema warnings in SQL."""
import base64,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
KEY=Path(r'C:\Users\fabat\Desktop\Awhar\modernapp\v1\awhar_backend\new-key-awhar.pem')
folder=ROOT/'docs/impact-innovation'
artifact=json.loads((folder/'backend-artifact.json').read_text(encoding='utf-8'))
source=json.loads((folder/'candidate-source.json').read_text(encoding='utf-8'))
payload=base64.b64encode(json.dumps({'artifactSha256':artifact['sha256'],'sourceCommit':source['sourceCommit'],
 'binarySha256':hashlib.sha256((ROOT/'.tooling/raysto-backend-0.17.0-dev.3/bin/server').read_bytes()).hexdigest()}).encode()).decode()
script=r'''
from pathlib import Path
import base64,hashlib,json,os,re,subprocess,time,urllib.request
from datetime import datetime,timezone
assert os.geteuid()==0;os.umask(0o077)
c=json.loads(base64.b64decode('PAYLOAD'))
release=Path('/opt/raysto/releases/0.17.0-dev.3-20261106');current=Path('/opt/raysto/current');previous=current.resolve()
assert previous==Path('/opt/raysto/releases/0.16.1-20261104')
assert hashlib.sha256((release/'bin/server').read_bytes()).hexdigest()==c['binarySha256']
def run(*args):return subprocess.check_output(args,stderr=subprocess.PIPE).decode().strip()
def sql(q):return run('runuser','-u','postgres','--','psql','-d','raysto_production','-Atc',q)
assert sql("SELECT version FROM serverpod_migrations WHERE module='raysto'")=='20261105193140136'
log=Path('/var/backups/raysto/decision-017-migration.log').read_text()
assert not re.search(r'(^|\n)(ERROR|FATAL|Unhandled exception)',log,re.I)
warnings=re.findall(r'Missing (Index|Foreign key) "([A-Za-z0-9_]+)"',log)
assert len(warnings)==50 and log.count(' - Missing ')==50
for kind,name in warnings:
 q=("SELECT count(*) FROM pg_index i JOIN pg_class c ON c.oid=i.indexrelid WHERE i.indisvalid AND c.relname='"+name+"'") if kind=='Index' else ("SELECT count(*) FROM pg_constraint WHERE convalidated AND contype='f' AND conname='"+name+"'")
 assert sql(q)=='1'
def baseline():return [run('systemctl','show','awhar-server','-p','MainPID','--value'),hashlib.sha256(Path('/etc/nginx/sites-available/awhar.com').read_bytes()).hexdigest()]
before=baseline();runtime=Path('/etc/raysto/runtime.env');old=runtime.read_bytes()
flags={k:'false' for k in ['RAYSTO_FINANCE_017_ENABLED','RAYSTO_PRICING_ENABLED','RAYSTO_STUDIO_AI_ENABLED','RAYSTO_JUDGE_STORY_017_ENABLED']}
def activate(target):
 link=Path('/opt/raysto/current.decision');assert not link.exists() and not link.is_symlink();link.symlink_to(target);os.replace(link,current)
 subprocess.run(['systemctl','restart','raysto'],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
def ready():
 for _ in range(45):
  try:
   with urllib.request.urlopen('http://127.0.0.1:18082/ready',timeout=3) as r:result=json.load(r)
   if result.get('status')=='ready':return result
  except Exception:pass
  time.sleep(1)
 raise RuntimeError('Readiness failed')
try:
 lines=[l for l in old.decode().splitlines() if l.split('=',1)[0] not in flags]
 runtime.write_text('\n'.join(lines+[k+'='+v for k,v in flags.items()])+'\n');runtime.chmod(0o600)
 activate(release);status=ready()
 assert json.loads(run('curl','-fsS','--max-time','15','https://api.rays.to/ready'))['status']=='ready'
 assert baseline()==before
 result={'checkedAtUtc':datetime.now(timezone.utc).isoformat(),'status':'deployed-features-off','release':str(release),'previous':str(previous),
  **c,'migration':'20261105193140136','migrationExitCode':1,'schemaWarningReview':{'reported':50,'presentAndValid':50,'constraintsRemoved':0},
  'ready':status,'featureFlags':flags,'awharUnchanged':True,'productionDataExported':False,'providerAcceptance':'not established'}
 (release/'source.json').write_text(json.dumps(result,indent=2)+'\n');os.chmod(release/'source.json',0o640)
 Path('/var/backups/raysto/decision-017-deployment.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(result))
except Exception:
 runtime.write_bytes(old);runtime.chmod(0o600);activate(previous);ready();raise
'''.replace('PAYLOAD',payload)
r=subprocess.run(['ssh','-i',str(KEY),'-o','BatchMode=yes','ubuntu@13.51.45.215','sudo python3 -'],input=script.encode(),capture_output=True)
if r.returncode:
 import re
 detail=r.stderr.decode(errors='replace')
 print(json.dumps({'status':'promotion-error','remoteLines':re.findall(r'File "<stdin>", line (\d+)',detail),
  'errorType':re.findall(r'(?:^|\n)([A-Za-z]+Error):',detail)}))
 raise SystemExit('Candidate promotion failed; inspect on-host Raysto-only state.')
report=json.loads(r.stdout.decode())
(folder/'backend-deployment.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
