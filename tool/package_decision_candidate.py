"""Package only reviewed executable/library/migration paths; no credentials."""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

root=Path(__file__).resolve().parents[1]
version='0.17.0-dev.3'
image='raysto-backend:'+version+'-ec2'
out=root/'.tooling'/('raysto-backend-'+version)
out.mkdir(exist_ok=False)
container=subprocess.check_output(['docker','--context','desktop-linux','create',image],text=True).strip()
try:
    for directory in ['bin','lib','migrations']:
        subprocess.run(['docker','--context','desktop-linux','cp',container+':/app/'+directory,str(out/directory)],check=True)
finally:
    subprocess.run(['docker','--context','desktop-linux','rm',container],check=True,stdout=subprocess.DEVNULL)
archive=root/'dist'/('raysto-backend-'+version+'-linux-amd64.tar.gz')
archive.parent.mkdir(exist_ok=True)
assert not archive.exists(),'Preserve earlier artifact'
with tarfile.open(archive,'w:gz') as tar:
    for file in sorted(out.rglob('*')):
        if not file.is_file():continue
        relative=file.relative_to(out)
        assert not file.is_symlink()
        assert not any(p.startswith('.env') or p in {'passwords.yaml','.secrets'} or p.endswith(('.pem','.key')) for p in relative.parts),relative
        tar.add(file,arcname=relative.as_posix(),recursive=False)
record={'version':version,'artifact':str(archive.relative_to(root)).replace('\\','/'),'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'bytes':archive.stat().st_size,'image':image,'configIncluded':False}
(root/'docs/impact-innovation/backend-artifact.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
print(json.dumps(record))
