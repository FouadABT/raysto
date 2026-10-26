"""Validate generated schema and supplements only on the dedicated local test container."""
import pathlib, subprocess
root=pathlib.Path(__file__).resolve().parents[1]
container='raysto-backend-postgres'; database='raysto_release_090_check'
def docker(*args, **kwargs): return subprocess.run(['docker', 'exec','-i',container,*args],check=True,**kwargs)
docker('createdb','-U','raysto',database)
try:
 for file in [root/'backend/raysto/raysto_server/migrations/20261025162915326/definition.sql',
              root/'backend/operations/platform-v2-constraints.sql',root/'backend/operations/platform-v2-backfill.sql']:
  with file.open('rb') as src:
   docker('psql','-U','raysto','-d',database,'-v','ON_ERROR_STOP=1',stdin=src,stdout=subprocess.DEVNULL)
 print('Generated schema, tenant constraints and payment backfill passed on the isolated Raysto database.')
finally:
 docker('dropdb','-U','raysto',database)
