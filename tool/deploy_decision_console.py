"""Enable the verified decision APIs and matching Linux console, with rollback."""
import base64,json,subprocess
from pathlib import Path
from decision_upload import upload
ROOT=Path(__file__).resolve().parents[1]
KEY=Path(r'C:\Users\fabat\Desktop\Awhar\modernapp\v1\awhar_backend\new-key-awhar.pem')
folder=ROOT/'docs/impact-innovation'
a=json.loads((folder/'console-artifact.json').read_text(encoding='utf-8'))
compat=json.loads((folder/'deployed-compatibility.json').read_text(encoding='utf-8'))
assert all(compat[k] for k in ['managerAuthenticated','existingMenuReadable','invalidSessionRejected','financeInitiallyDisabled'])
remote='/home/ubuntu/raysto-upload/'+Path(a['artifact']).name
upload(ROOT/a['artifact'],remote)
payload=base64.b64encode(json.dumps({**a,'archive':remote}).encode()).decode()
script=r'''
from pathlib import Path
import base64,hashlib,json,os,shutil,subprocess,tarfile,time
from datetime import datetime,timezone
assert os.geteuid()==0;os.umask(0o077)
c=json.loads(base64.b64decode('PAYLOAD'));archive=Path(c['archive']);assert archive.parent==Path('/home/ubuntu/raysto-upload')
assert hashlib.sha256(archive.read_bytes()).hexdigest()==c['sha256']
assert c['version']=='0.17.0-dev.5'
assert Path('/opt/raysto/current').resolve().name=='0.17.0-dev.5-20261106'
current=Path('/opt/raysto/ops/current');previous=current.resolve(strict=True);release=Path('/opt/raysto/ops/releases/0.17.0-dev.5-20261106')
assert previous.parent==release.parent and not release.exists()
def run(*args):return subprocess.check_output(args,stderr=subprocess.PIPE).decode().strip()
def baseline():return [run('systemctl','show','awhar-server','-p','MainPID','--value'),hashlib.sha256(Path('/etc/nginx/sites-available/awhar.com').read_bytes()).hexdigest()]
before=baseline();runtime=Path('/etc/raysto/runtime.env');old=runtime.read_bytes();switched=False
backendPid=run('systemctl','show','raysto','-p','MainPID','--value')
def activate(target):
 link=Path('/opt/raysto/ops/current.decision');assert not link.exists() and not link.is_symlink();link.symlink_to(target);os.replace(link,current)
 subprocess.run(['systemctl','restart','raysto-ops'],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
def health(url):
 for _ in range(40):
  try:
   if run('curl','-sS','--max-time','5','-o','/dev/null','-w','%{http_code}',url)=='200':return
  except Exception:pass
  time.sleep(1)
 raise RuntimeError('HTTP readiness failed')
try:
 release.mkdir(mode=0o750)
 with tarfile.open(archive) as tar:
  for m in tar.getmembers():
   assert not m.issym() and not m.islnk() and (release/m.name).resolve().is_relative_to(release)
   assert Path(m.name).name not in {'.env','.env.local','.env.production','passwords.yaml'}
  tar.extractall(release,filter='data')
 for folder,dirs,files in os.walk(release):
  os.chmod(folder,0o750);shutil.chown(folder,user='root',group='raysto')
  for f in files:
   p=Path(folder)/f;p.chmod(0o750 if p==release/'node' else 0o640);shutil.chown(p,user='root',group='raysto')
 cache=release/'.next/cache';cache.mkdir(exist_ok=True);shutil.chown(cache,user='raysto',group='raysto')
 flags={k:'true' for k in ['RAYSTO_FINANCE_017_ENABLED','RAYSTO_PRICING_ENABLED','RAYSTO_STUDIO_AI_ENABLED','RAYSTO_AGENT_PRICING_ENABLED']}
 values=dict(l.split('=',1) for l in old.decode().splitlines() if '=' in l and not l.startswith('#'))
 assert all(values.get(k)==v for k,v in flags.items())
 health('http://127.0.0.1:18082/ready')
 switched=True;activate(release)
 for url in ['http://127.0.0.1:13100/ops','https://ops.rays.to/ops','https://rays.to/']:health(url)
 assert baseline()==before
 assert runtime.read_bytes()==old and run('systemctl','show','raysto','-p','MainPID','--value')==backendPid
 result={'checkedAtUtc':datetime.now(timezone.utc).isoformat(),'status':'development-candidate-deployed','release':str(release),'previous':str(previous),
  'sourceCommit':c['sourceCommit'],'artifactSha256':c['sha256'],'featureFlags':flags,'judgeStoryEnabled':False,'awharUnchanged':True,
  'acceptance':'Actual model, integrated provider and device gates remain separate'}
 Path('/var/backups/raysto/decision-017-console.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(result))
except Exception:
 if switched:activate(previous)
 raise
'''.replace('PAYLOAD',payload)
r=subprocess.run(['ssh','-i',str(KEY),'-o','BatchMode=yes','ubuntu@13.51.45.215','sudo python3 -'],input=script.encode(),capture_output=True)
if r.returncode:raise SystemExit('Console promotion failed; inspect the bounded Raysto rollback and service state.')
report=json.loads(r.stdout.decode());(folder/'console-deployment.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
