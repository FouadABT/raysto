"""Package the Linux owner-workspace candidate; exclude private config and credentials."""
import gzip, hashlib, json, re, shutil, subprocess, tarfile
from pathlib import Path

root=Path(__file__).resolve().parents[1]
folder=root/'docs/design-experience'
version='0.17.0-dev.6'
archive=root/f'dist/raysto-ops-{version}-linux.tar'
output=archive.with_suffix('.tar.gz')
assert not output.exists()
assert not subprocess.check_output(['git','diff','HEAD','--','web/src','web/next.config.ts','web/package.json','web/package-lock.json'],cwd=root)
source=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
env=dict(line.split('=',1) for line in (root/'.tooling/design-console.env').read_text(encoding='utf-8').splitlines() if '=' in line and not line.startswith('#'))
assert env['NEXT_PUBLIC_RAYSTO_FINANCE_017']=='on' and env['NEXT_PUBLIC_RAYSTO_STUDIO']=='on'
assert env['RAYSTO_OPS_ONLY']=='true'
assert not env.get('NEXT_PUBLIC_RAYSTO_JUDGE_BUYER_PASSWORD','').strip('"\'')
accounts=json.loads((root/'backend/.secrets/judge-accounts.json').read_text(encoding='utf-8'))
owner=accounts['users']['owner']
private_values=[owner['email'],owner['password']]
buyer=(root/'backend/.secrets/paypal-sandbox-buyers.txt').read_text(encoding='utf-8')
private_values.extend(m.group(1) for m in re.finditer(r'(?:Email|Password):\s*(\S+)',buyer,re.I))
private_bytes=[value.encode() for value in private_values if value]
with tarfile.open(archive) as tar:
 for member in tar.getmembers():
  path=Path(member.name)
  assert not member.issym() and not member.islnk() and not path.is_absolute() and '..' not in path.parts
  assert not any(part.startswith('.env') or part in {'.secrets','passwords.yaml'} or part.endswith(('.pem','.key')) for part in path.parts)
  if member.isfile():
   data=tar.extractfile(member).read()
   assert not any(secret in data for secret in private_bytes),'Private review or buyer credential found; artifact cannot be published.'
with archive.open('rb') as source_file,gzip.open(output,'wb') as target:shutil.copyfileobj(source_file,target)
record={'version':version,'sourceCommit':source,'artifact':output.relative_to(root).as_posix(),'sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'bytes':output.stat().st_size,
 'configIncluded':False,'privateCredentialScan':'passed','featureFlags':{'finance017':True,'studio':True,'connectedOnly':True},
 'android':{'version':env['NEXT_PUBLIC_RAYSTO_APK_VERSION'],'url':env['NEXT_PUBLIC_RAYSTO_APK_URL'],'sha256':env['NEXT_PUBLIC_RAYSTO_APK_SHA256'],'physicalDeviceAccepted':False}}
(folder/'console-artifact.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
print(json.dumps(record))
