"""Binary-only patch, allowed only when every library/migration is unchanged."""
import hashlib,json,subprocess,tarfile
from pathlib import Path
root=Path(__file__).resolve().parents[1];folder=root/'docs/design-experience'
version='0.17.0-dev.6';image='raysto-backend:'+version+'-ec2'
old=json.loads((root/'docs/impact-innovation/backend-artifact.json').read_text(encoding='utf-8'));assert old['version']=='0.17.0-dev.5'
def manifest(name):
 return subprocess.check_output(['docker','--context','desktop-linux','run','--rm','--entrypoint','/bin/sh',name,'-c','find lib migrations -type f -exec sha256sum {} + | LC_ALL=C sort'])
before=manifest(old['image']);after=manifest(image);assert before==after,'Full artifact required for changed dependencies'
archive=root/'dist'/('raysto-backend-'+version+'-binary-linux-amd64.tar.gz');assert not archive.exists()
with archive.open('xb') as output:subprocess.run(['docker','--context','desktop-linux','run','--rm','--entrypoint','/bin/tar',image,'-czf','-','bin'],stdout=output,check=True)
with tarfile.open(archive) as tar:
 for m in tar.getmembers():assert Path(m.name).parts[0]=='bin' and not m.issym() and not m.islnk() and '..' not in Path(m.name).parts
 binary=hashlib.sha256(tar.extractfile('bin/server').read()).hexdigest()
record={'version':version,'artifact':archive.relative_to(root).as_posix(),'artifactKind':'binary-delta','baseRelease':'0.17.0-dev.5-20261106','reusedLibrariesAndMigrationsSha256':hashlib.sha256(after).hexdigest(),'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'binarySha256':binary,'bytes':archive.stat().st_size,'image':image,'configIncluded':False}
preserved=folder/'backend-artifact-baseline.json';assert not preserved.exists();preserved.write_text(json.dumps(old,indent=2)+'\n',encoding='utf-8')
(folder/'backend-artifact.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8');print(json.dumps(record))
