import gzip,hashlib,json,shutil,subprocess,tarfile
from pathlib import Path
root=Path(__file__).resolve().parents[1];folder=root/'docs/impact-innovation'
archive=root/'dist/raysto-ops-0.17.0-dev.5-linux.tar';out=archive.with_suffix('.tar.gz')
assert not out.exists()
with tarfile.open(archive) as tar:
 for m in tar.getmembers():
  p=Path(m.name);assert not p.is_absolute() and '..' not in p.parts and not m.issym() and not m.islnk()
  assert p.name not in {'.env','.env.local','.env.production','passwords.yaml'}
with archive.open('rb') as src,gzip.open(out,'wb') as dst:shutil.copyfileobj(src,dst)
old=folder/'console-artifact.json';saved=folder/'console-artifact-dev4.json';assert not saved.exists();saved.write_bytes(old.read_bytes())
record={'version':'0.17.0-dev.5','sourceCommit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'artifact':out.relative_to(root).as_posix(),'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'bytes':out.stat().st_size,'configIncluded':False}
old.write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8');print(json.dumps(record))
