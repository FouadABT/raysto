"""Deploy an ABI/schema-compatible Raysto-only patch; preserve flags and data."""
import base64,json,subprocess
from pathlib import Path
from decision_upload import upload
root=Path(__file__).resolve().parents[1];folder=root/'docs/design-experience'
key=Path(r'C:\Users\fabat\Desktop\Awhar\modernapp\v1\awhar_backend\new-key-awhar.pem')
host='ubuntu@13.51.45.215'
artifact=json.loads((folder/'backend-artifact.json').read_text(encoding='utf-8'))
startup=json.loads((folder/'restored-startup.json').read_text(encoding='utf-8'))
assert artifact['version']=='0.17.0-dev.6' and startup['status']=='passed' and startup['artifactSha256']==artifact['sha256']
assert 'All tests passed!' in (root/'.tooling/test-tmp/design-http-query-tests.log').read_text(encoding='utf-8-sig')
assert 'No issues found!' in (root/'.tooling/test-tmp/design-backend-analysis.log').read_text(encoding='utf-8-sig')
source=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
assert not subprocess.check_output(['git','diff','HEAD','--','backend/raysto/'],cwd=root)
remote='/home/ubuntu/raysto-upload/'+Path(artifact['artifact']).name
upload(root/artifact['artifact'],remote)
payload=base64.b64encode(json.dumps({**artifact,'archive':remote,'sourceCommit':source}).encode()).decode()
script=r'''
import base64,hashlib,json,os,shutil,subprocess,tarfile,time,urllib.request
from pathlib import Path
from datetime import datetime,timezone
assert os.geteuid()==0;os.umask(0o077)
c=json.loads(base64.b64decode('PAYLOAD'))
archive=Path(c['archive']);assert archive.parent==Path('/home/ubuntu/raysto-upload')
assert hashlib.sha256(archive.read_bytes()).hexdigest()==c['sha256']
current=Path('/opt/raysto/current');previous=current.resolve(strict=True)
release=Path('/opt/raysto/releases/0.17.0-dev.6-20261106')
assert previous==Path('/opt/raysto/releases/0.17.0-dev.5-20261106') and not release.exists()
def run(*args):return subprocess.check_output(args,stderr=subprocess.PIPE).decode().strip()
def baseline():return [run('systemctl','show','awhar-server','-p','MainPID','--value'),hashlib.sha256(Path('/etc/nginx/sites-available/awhar.com').read_bytes()).hexdigest(),hashlib.sha256(Path('/etc/raysto/runtime.env').read_bytes()).hexdigest()]
before=baseline();switched=False
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
 subprocess.run(['/opt/raysto/deploy/backup.sh'],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
 release.mkdir(mode=0o750)
 for d in ['config','web','operations']:
  if (previous/d).exists():shutil.copytree(previous/d,release/d)
  else:(release/d).mkdir()
 if c.get('artifactKind')=='binary-delta':
  assert previous.name==c['baseRelease']
  manifest=subprocess.check_output(['/bin/sh','-c','find lib migrations -type f -exec sha256sum {} + | LC_ALL=C sort'],cwd=previous)
  assert hashlib.sha256(manifest).hexdigest()==c['reusedLibrariesAndMigrationsSha256']
  for name in ['lib','migrations']:shutil.copytree(previous/name,release/name)
 with tarfile.open(archive) as tar:
  for m in tar.getmembers():
   assert not m.issym() and not m.islnk() and Path(m.name).parts[0] in {'bin','lib','migrations'}
   assert release in (release/m.name).resolve().parents
  tar.extractall(release,filter='data')
 assert hashlib.sha256((release/'bin/server').read_bytes()).hexdigest()==c['binarySha256']
 for p in (release/'migrations').rglob('*'):
  if p.is_file():assert p.read_bytes()==(previous/p.relative_to(release)).read_bytes(),'Schema change is not permitted in this patch'
 for folder,dirs,files in os.walk(release):
  os.chmod(folder,0o750);shutil.chown(folder,user='root',group='raysto')
  for name in files:
   p=Path(folder)/name;p.chmod(0o750 if p in [release/'bin/server',release/'lib/paypal-mcp/node'] else 0o640);shutil.chown(p,user='root',group='raysto')
 switched=True;activate(release);status=ready()
 assert json.loads(run('curl','-fsS','--max-time','15','https://api.rays.to/ready'))['status']=='ready'
 assert baseline()==before
 result={'checkedAtUtc':datetime.now(timezone.utc).isoformat(),'status':'deployed','version':c['version'],'release':str(release),'previous':str(previous),'sourceCommit':c['sourceCommit'],'artifactSha256':c['sha256'],'binarySha256':c['binarySha256'],'ready':status,'schemaChanged':False,'featureFlagsAndBudgetsUnchanged':True,'awharUnchanged':True,'productionDataExported':False}
 (release/'source.json').write_text(json.dumps(result,indent=2)+'\n');os.chmod(release/'source.json',0o640);shutil.chown(release/'source.json',user='root',group='raysto')
 print(json.dumps(result))
except Exception:
 if switched:activate(previous);ready()
 raise
'''.replace('PAYLOAD',payload)
r=subprocess.run(['ssh','-i',str(key),'-o','BatchMode=yes',host,'sudo python3 -'],input=script.encode(),capture_output=True)
if r.returncode:raise SystemExit('Raysto patch failed; inspect on-host state. Automatic rollback attempted if activated.')
report=json.loads(r.stdout.decode());(folder/'backend-deployment.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
