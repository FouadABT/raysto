"""Package the Linux patch inside its container; never copy private config."""
import hashlib,json,subprocess,tarfile
from pathlib import Path
root=Path(__file__).resolve().parents[1]
version='0.17.0-dev.4'
image='raysto-backend:'+version+'-ec2'
archive=root/'dist'/('raysto-backend-'+version+'-linux-amd64.tar.gz')
assert not archive.exists()
with archive.open('xb') as output:
 subprocess.run(['docker','--context','desktop-linux','run','--rm','--entrypoint','/bin/tar',image,'-czf','-','bin','lib','migrations'],stdout=output,check=True)
with tarfile.open(archive) as tar:
 for m in tar.getmembers():
  p=Path(m.name)
  assert not m.issym() and not m.islnk() and not p.is_absolute() and '..' not in p.parts
  assert p.parts[0] in {'bin','lib','migrations'}
  assert not any(x.startswith('.env') or x in {'.secrets','passwords.yaml'} or x.endswith(('.key','.pem')) for x in p.parts)
 binary=hashlib.sha256(tar.extractfile('bin/server').read()).hexdigest()
record={'version':version,'artifact':archive.relative_to(root).as_posix(),'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'binarySha256':binary,'bytes':archive.stat().st_size,'image':image,'configIncluded':False}
folder=root/'docs/impact-innovation'
old=folder/'backend-artifact.json'; preserved=folder/'backend-artifact-dev3.json'
assert not preserved.exists();preserved.write_bytes(old.read_bytes())
old.write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
print(json.dumps(record))
