"""Deploy only the judge-first console; preserve backend, APK, runtime and Awhar."""
import base64,json,subprocess,tarfile,sys
from pathlib import Path
from decision_upload import upload
ROOT=Path(__file__).resolve().parents[1]
KEY=Path(r'C:\Users\fabat\Desktop\Awhar\modernapp\v1\awhar_backend\new-key-awhar.pem')
folder=ROOT/'docs/judge-dashboard'
a=json.loads((folder/'console-artifact.json').read_text(encoding='utf-8'))
baseline=json.loads((folder/'compatibility-baseline.json').read_text(encoding='utf-8'))
compat=json.loads((folder/'live-compatibility.json').read_text(encoding='utf-8'))
assert all(compat[k] for k in ['managerAuthenticated','existingMenuReadable','invalidSessionRejected'])
remote='/home/ubuntu/raysto-upload/'+Path(a['artifact']).name
with tarfile.open(ROOT/a['artifact']) as task_tar:
 a['expandedBytes']=sum(m.size for m in task_tar.getmembers() if m.isfile())
 a['archiveEntries']=len(task_tar.getmembers())
a['diskReserveBytes']=1024*1024*1024
a['pinnedApkBytes']=baseline['android']['bytes']
preflight=base64.b64encode(json.dumps({**a,'archive':remote}).encode()).decode()
preflight_script=r'''
from pathlib import Path
import base64,json,shutil,os,subprocess
c=json.loads(base64.b64decode('PREFLIGHT'))
root=Path('/opt/raysto/ops/releases');previous=Path('/opt/raysto/ops/current').resolve()
apk_bytes=sum(p.stat().st_size for p in (previous/'public/downloads').glob('*.apk') if p.is_file())+c['pinnedApkBytes']
required=c['expandedBytes']+apk_bytes+c['diskReserveBytes']+128*1024*1024
if not Path(c['archive']).exists():required+=2*c['bytes']
free=shutil.disk_usage(root).free;v=os.statvfs(root)
mem=int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024
assert free>=required,'Insufficient disk headroom: retain at least 1 GiB after extraction'
assert v.f_favail>c['archiveEntries']+10000,'Insufficient free inodes'
assert mem>=256*1024*1024,'Insufficient memory headroom'
assert subprocess.run(['systemctl','is-active','--quiet','awhar-server']).returncode==0,'Awhar is not active; do not deploy'
assert subprocess.run(['pg_ctlcluster','16','main','status'],capture_output=True).returncode==0,'Shared PostgreSQL is offline; do not deploy'
print(json.dumps({'freeBytes':free,'requiredBytes':required,'memoryAvailableBytes':mem,'diskReserveBytes':c['diskReserveBytes']}))
'''.replace('PREFLIGHT',preflight)
preflight_result=subprocess.run(['ssh','-i',str(KEY),'-o','BatchMode=yes','ubuntu@13.51.45.215','sudo python3 -'],input=preflight_script.encode(),capture_output=True)
if preflight_result.returncode:
 (ROOT/'.tooling/test-tmp/judge-dashboard-preflight-stderr.log').write_bytes(preflight_result.stderr)
 raise SystemExit('Resource preflight stopped before upload or activation.')
(folder/'resource-preflight.json').write_text(preflight_result.stdout.decode(),encoding='utf-8')
if '--preflight-only' in sys.argv:
 print(preflight_result.stdout.decode().strip())
 raise SystemExit(0)
upload(ROOT/a['artifact'],remote)
payload=base64.b64encode(json.dumps({**a,'archive':remote,'backendRelease':baseline['backend']['deployedRelease'],'backendArtifactSha256':baseline['backend']['sha256']}).encode()).decode()
script=r'''
from pathlib import Path
import base64,hashlib,json,os,shutil,subprocess,tarfile,time
from datetime import datetime,timezone
def sha_file(path):
 with open(path,'rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
assert os.geteuid()==0;os.umask(0o077)
c=json.loads(base64.b64decode('PAYLOAD'));archive=Path(c['archive']);assert archive.parent==Path('/home/ubuntu/raysto-upload')
assert sha_file(archive)==c['sha256']
assert c['version']=='0.17.0-dev.9'
assert str(Path('/opt/raysto/current').resolve())==c['backendRelease']
assert json.loads((Path(c['backendRelease'])/'source.json').read_text())['artifactSha256']==c['backendArtifactSha256']
current=Path('/opt/raysto/ops/current');previous=current.resolve(strict=True);release=Path('/opt/raysto/ops/releases/0.17.0-dev.9-20261107')
assert previous.parent==release.parent and previous.name=='0.17.0-dev.7-20261107' and not release.exists()
def run(*args):return subprocess.check_output(args,stderr=subprocess.PIPE).decode().strip()
def baseline():return [run('systemctl','show','awhar-server','-p','MainPID','--value'),hashlib.sha256(Path('/etc/nginx/sites-available/awhar.com').read_bytes()).hexdigest()]
before=baseline();runtime=Path('/etc/raysto/runtime.env');old=runtime.read_bytes();switched=False
backendPid=run('systemctl','show','raysto','-p','MainPID','--value')
apk=Path('/opt/raysto/downloads/raysto-before-ai-motion-'+c['android']['sha256']+'.apk')
assert apk.resolve().is_relative_to(Path('/opt/raysto/downloads'))
apk_name='raysto-0.17.0-dev.7-2204-arm64.apk'
assert apk.is_file()
assert sha_file(apk)==c['android']['sha256']
downloads=Path('/opt/raysto/downloads');assert downloads.resolve().is_relative_to(Path('/opt/raysto'))
latest=downloads/'raysto.apk';priorApkHash=sha_file(latest)
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
 required=c['expandedBytes']+sum(p.stat().st_size for p in (previous/'public/downloads').glob('*.apk') if p.is_file())+apk.stat().st_size+c['diskReserveBytes']+128*1024*1024
 assert shutil.disk_usage(release.parent).free>=required,'Insufficient disk headroom before extraction'
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
 public_downloads=release/'public/downloads';public_downloads.mkdir(exist_ok=True)
 for prior in (previous/'public/downloads').glob('*.apk'):
  assert prior.is_file() and not prior.is_symlink() and prior.resolve().is_relative_to(previous/'public/downloads')
  shutil.copyfile(prior,public_downloads/prior.name)
  os.chmod(public_downloads/prior.name,0o640);shutil.chown(public_downloads/prior.name,user="root",group="raysto")
 shutil.copyfile(apk,public_downloads/apk_name)
 os.chmod(public_downloads,0o750);shutil.chown(public_downloads,user='root',group='raysto')
 os.chmod(public_downloads/apk_name,0o640);shutil.chown(public_downloads/apk_name,user='root',group='raysto')
 cache=release/'.next/cache';cache.mkdir(exist_ok=True);shutil.chown(cache,user='raysto',group='raysto')
 flags={k:'true' for k in ['RAYSTO_FINANCE_017_ENABLED','RAYSTO_PRICING_ENABLED','RAYSTO_STUDIO_AI_ENABLED','RAYSTO_AGENT_PRICING_ENABLED']}
 values=dict(l.split('=',1) for l in old.decode().splitlines() if '=' in l and not l.startswith('#'))
 assert all(values.get(k)==v for k,v in flags.items())
 health('http://127.0.0.1:18082/ready')
 switched=True;activate(release)
 for url in ['http://127.0.0.1:13100/ops','https://ops.rays.to/ops','https://rays.to/']:health(url)
 health(c['android']['url'])
 assert sha_file(public_downloads/apk_name)==c['android']['sha256']
 assert baseline()==before
 assert runtime.read_bytes()==old and run('systemctl','show','raysto','-p','MainPID','--value')==backendPid
 result={'checkedAtUtc':datetime.now(timezone.utc).isoformat(),'status':'development-candidate-deployed','release':str(release),'previous':str(previous),
  'sourceCommit':c['sourceCommit'],'artifactSha256':c['sha256'],'featureFlags':flags,'judgeStoryEnabled':False,'awharUnchanged':True,
  'android':c['android'],'priorApkSha256':priorApkHash,'backendRelease':c['backendRelease'],'backendArtifactSha256':c['backendArtifactSha256'],'backendUnchanged':True,'runtimeUnchanged':True,'apkUnchanged':hashlib.sha256(latest.read_bytes()).hexdigest()==priorApkHash,'globalApkNotWritten':True,'globalApkAfterSha256':hashlib.sha256(latest.read_bytes()).hexdigest(),'acceptance':'Web UI candidate; owner-pilot and physical Android gates remain open'}
 Path('/var/backups/raysto/judge-dashboard-017-console.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(result))
except Exception:
 if switched:activate(previous)
 raise
'''.replace('PAYLOAD',payload)
r=subprocess.run(['ssh','-i',str(KEY),'-o','BatchMode=yes','ubuntu@13.51.45.215','sudo python3 -'],input=script.encode(),capture_output=True)
if r.returncode:
 (ROOT/'.tooling/test-tmp/judge-dashboard-promotion-stderr.log').write_bytes(r.stderr)
 raise SystemExit('Console promotion stopped; diagnostic stderr is saved locally and previous activation is preserved.')
report=json.loads(r.stdout.decode());(folder/'console-deployment.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
