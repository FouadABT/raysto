"""Promote the verified Raysto development binary with new features OFF.
Only Raysto's release, database migrations and service are changed.
Existing private configuration remains on AWS. Automatic binary rollback
does not reverse additive migrations or erase provider evidence.
"""
import base64
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[1]
KEY=Path(r'C:\Users\fabat\Desktop\Awhar\modernapp\v1\awhar_backend\new-key-awhar.pem')
HOST='ubuntu@13.51.45.215'
folder=ROOT/'docs/impact-innovation'
artifact=json.loads((folder/'backend-artifact.json').read_text(encoding='utf-8'))
startup=json.loads((folder/'restored-startup.json').read_text(encoding='utf-8'))
assert startup['status']=='passed' and startup['artifactSha256']==artifact['sha256']
source=json.loads((folder/'candidate-source.json').read_text(encoding='utf-8'))
assert source['sourceCommit'] and source['kind']=='committed-candidate'
assert 'All tests passed!' in (ROOT/'.tooling/test-tmp/decision-backend-full.log').read_text(encoding='utf-8-sig')
remote='/home/ubuntu/raysto-upload/'+Path(artifact['artifact']).name
subprocess.run(['scp','-i',str(KEY),'-o','BatchMode=yes',str(ROOT/artifact['artifact']),HOST+':'+remote],check=True)
payload=base64.b64encode(json.dumps({'archive':remote,'sha256':artifact['sha256'],'sourceCommit':source['sourceCommit']}).encode()).decode()
script=r'''
import base64,hashlib,json,os,shutil,subprocess,tarfile,time,urllib.request
from pathlib import Path
from datetime import datetime,timezone
assert os.geteuid()==0
os.umask(0o077)
c=json.loads(base64.b64decode('PAYLOAD'))
archive=Path(c['archive']);assert archive.parent==Path('/home/ubuntu/raysto-upload')
assert hashlib.sha256(archive.read_bytes()).hexdigest()==c['sha256']
current=Path('/opt/raysto/current');previous=current.resolve(strict=True)
release=Path('/opt/raysto/releases/0.17.0-dev.3-20261106')
assert previous.parent==release.parent and not release.exists()
def run(*args):return subprocess.check_output(args,stderr=subprocess.PIPE).decode().strip()
def sql(q):return run('runuser','-u','postgres','--','psql','-d','raysto_production','-Atc',q)
def baseline():return [run('systemctl','show','awhar-server','-p','MainPID','--value'),hashlib.sha256(Path('/etc/nginx/sites-available/awhar.com').read_bytes()).hexdigest()]
before=baseline();runtime=Path('/etc/raysto/runtime.env');old=runtime.read_bytes();switched=False
def activate(target):
 link=Path('/opt/raysto/current.decision');assert not link.exists() and not link.is_symlink()
 link.symlink_to(target);os.replace(link,current)
 subprocess.run(['systemctl','restart','raysto'],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
def ready():
 for _ in range(45):
  try:
   with urllib.request.urlopen('http://127.0.0.1:18082/ready',timeout=3) as r:v=json.load(r)
   if v.get('status')=='ready':return v
  except Exception:pass
  time.sleep(1)
 raise RuntimeError('Readiness failed')
stage='backup'
try:
 subprocess.run(['/opt/raysto/deploy/backup.sh'],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
 backup=Path('/var/backups/raysto/runtime-before-decision-017.env');assert not backup.exists();backup.write_bytes(old);backup.chmod(0o600)
 stage='extract';release.mkdir(mode=0o750)
 for d in ['config','web','operations']:
  if (previous/d).exists():shutil.copytree(previous/d,release/d)
  else:(release/d).mkdir()
 with tarfile.open(archive) as tar:
  for m in tar.getmembers():
   assert not m.issym() and not m.islnk() and Path(m.name).parts[0] in {'bin','lib','migrations'}
   assert release in (release/m.name).resolve().parents
  tar.extractall(release,filter='data')
 for folder,dirs,files in os.walk(release):
  os.chmod(folder,0o750);shutil.chown(folder,user='root',group='raysto')
  for name in files:
   p=Path(folder)/name;p.chmod(0o750 if p in [release/'bin/server',release/'lib/paypal-mcp/node'] else 0o640);shutil.chown(p,user='root',group='raysto')
 stage='migrate'
 with Path('/var/backups/raysto/decision-017-migration.log').open('wb') as log:
  migration=subprocess.run(['/opt/raysto/deploy/migrate.sh',str(release)],stdout=log,stderr=subprocess.STDOUT)
 version=sql("SELECT version FROM serverpod_migrations WHERE module='raysto'")
 assert version=='20261105193140136','Migration version mismatch'
 assert sql("SELECT count(*) FROM information_schema.columns WHERE table_name='raysto_stock_movement' AND column_name='purchaseUnit'")=='1'
 assert sql("SELECT count(*) FROM pg_indexes WHERE indexname='finance_record_key'")=='1'
 if migration.returncode:raise RuntimeError('Migration CLI needs review before activation')
 stage='feature-switches-off'
 flags={k:'false' for k in ['RAYSTO_FINANCE_017_ENABLED','RAYSTO_PRICING_ENABLED','RAYSTO_STUDIO_AI_ENABLED','RAYSTO_JUDGE_STORY_017_ENABLED']}
 lines=[l for l in old.decode().splitlines() if l.split('=',1)[0] not in flags]
 runtime.write_text('\n'.join(lines+[k+'='+v for k,v in flags.items()])+'\n');runtime.chmod(0o600)
 stage='activate';switched=True;activate(release);status=ready()
 assert json.loads(run('curl','-fsS','--max-time','15','https://api.rays.to/ready'))['status']=='ready'
 assert baseline()==before,'Unrelated service baseline changed'
 result={'checkedAtUtc':datetime.now(timezone.utc).isoformat(),'status':'deployed-features-off','release':str(release),'previous':str(previous),
  'sourceCommit':c['sourceCommit'],'artifactSha256':c['sha256'],'migration':version,'migrationExitCode':migration.returncode,
  'ready':status,'featureFlags':flags,'awharUnchanged':True,'providerAcceptance':'not established','productionDataExported':False}
 (release/'source.json').write_text(json.dumps(result,indent=2)+'\n');shutil.chown(release/'source.json',user='root',group='raysto');(release/'source.json').chmod(0o640)
 Path('/var/backups/raysto/decision-017-deployment.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(result))
except Exception as e:
 runtime.write_bytes(old);runtime.chmod(0o600)
 if switched:activate(previous);ready()
 print(json.dumps({'status':'not-promoted','stage':stage,'errorType':type(e).__name__,
  'migration':sql("SELECT version FROM serverpod_migrations WHERE module='raysto'"),'activeRelease':str(current.resolve()),'awharUnchanged':baseline()==before,'productionDataExported':False}))
'''.replace('PAYLOAD',payload)
r=subprocess.run(['ssh','-i',str(KEY),'-o','BatchMode=yes',HOST,'sudo python3 -'],input=script.encode(),capture_output=True)
if r.returncode:raise SystemExit('Deployment command failed; inspect on-host Raysto-only state.')
report=json.loads(r.stdout.decode());(folder/'backend-deployment.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
if report['status']!='deployed-features-off':raise SystemExit(1)
