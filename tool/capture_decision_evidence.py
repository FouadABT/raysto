"""Record hashes and actual local validation output, never infer provider success."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
from datetime import datetime, timezone

root=Path(__file__).resolve().parents[1]
folder=root/'docs/impact-innovation'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
paths=subprocess.check_output(['git','ls-files','--cached','--others','--exclude-standard'],cwd=root,text=True).splitlines()
prefixes=('backend/raysto/','lib/','assets/','android/','ios/','web/src/','web/public/')
exact={'pubspec.yaml','pubspec.lock','analysis_options.yaml','web/package.json','web/package-lock.json','web/next.config.ts','web/tsconfig.json','web/next-env.d.ts'}
files={p:digest(root/p) for p in sorted(set(paths)) if (p.startswith(prefixes) or p in exact) and (root/p).is_file()}
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
changed=set(subprocess.check_output(['git','diff','--name-only','HEAD'],cwd=root,text=True).splitlines())
untracked=set(subprocess.check_output(['git','ls-files','--others','--exclude-standard'],cwd=root,text=True).splitlines())
source_dirty=bool((changed|untracked)&set(files))
source={'sourceCommit':None if source_dirty else head,'baseCommit':head,
 'kind':'integrated-working-tree' if source_dirty else 'committed-candidate','submissionCommit':None,'submissionTag':None,
 'excluded':'Unrelated inspiration and video drafts, private configuration, generated build outputs, research observations',
 'files':files}
source['sha256']=hashlib.sha256(json.dumps(files,sort_keys=True,separators=(',',':')).encode()).hexdigest()
(folder/'candidate-source.json').write_text(json.dumps(source,indent=2)+'\n',encoding='utf-8')
checks=[
 ('backend-regression','decision-backend-full.log','All tests passed!',r'\+(\d+): All tests passed!'),
 ('backend-finance-targeted','decision-backend-verified.log','All tests passed!',r'\+(\d+): All tests passed!'),
 ('backend-analysis','decision-backend-analysis-recheck.log','No issues found!',None),
 ('backend-ai-delivery-patch','decision-ai-delivery-tests.log','All tests passed!',r'\+(\d+): All tests passed!'),
 ('backend-ai-delivery-analysis','decision-ai-delivery-analysis.log','No issues found!',None),
 ('backend-final-boundaries-and-finance','decision-ai-boundary-final-tests.log','All tests passed!',r'\+(\d+): All tests passed!'),
 ('backend-final-analysis','decision-ai-boundary-final-analysis.log','No issues found!',None),
 ('native-regression-before-final-navigation-labels','decision-native-full.log','All tests passed!',r'\+(\d+): All tests passed!'),
 ('native-final-targeted','decision-native-candidate-recheck.log','All tests passed!',r'\+(\d+): All tests passed!'),
 ('native-analysis','decision-native-analysis-candidate.log','No issues found!',None),
 ('native-build','decision-android-build-candidate.log','Built build',None),
 ('web-regression-before-final-menu-entry','decision-web-full.log','fail 0',r'pass (\d+)'),
 ('web-final-targeted','decision-web-final-targeted.log','fail 0',r'pass (\d+)'),
 ('web-live-scope-regression','decision-studio-scope-tests.log','fail 0',r'pass (\d+)'),
 ('web-build','decision-web-build-verified.log','(Static)',None),
 ('web-browser','decision-browser-final.log','5 passed',r'(\d+) passed'),
 ('web-browser-final','decision-browser-candidate.log','5 passed',r'(\d+) passed'),
 ('backend-linux-build','decision-backend-build-retry.log','DONE 44.3s',None),
 ('backend-linux-patch-build','decision-backend-dev4-build.log','naming to docker.io/library/raysto-backend:0.17.0-dev.4-ec2 done',None),
 ('backend-final-linux-build','decision-backend-dev5-final-build.log','unpacking to docker.io/library/raysto-backend:0.17.0-dev.5-ec2 6.1s done',None),
 ('console-final-linux-build','decision-console-dev5-final-build.log','sending tarball',None),
]
results=[]
for ident,log,marker,pattern in checks:
 p=root/'.tooling/test-tmp'/log
 text=p.read_text(encoding='utf-8-sig',errors='replace') if p.exists() else ''
 count=re.search(pattern,text) if pattern else None
 results.append({'id':ident,'status':'passed' if marker in text else 'pending-or-failed',
  'log':str(p.relative_to(root)).replace('\\','/'),'logSha256':digest(p) if p.exists() else None,
  'count':int(count[1]) if count else None})
report={'recordedAtUtc':datetime.now(timezone.utc).isoformat(),'sourceSha256':source['sha256'],
 'sourceInventory':'docs/impact-innovation/candidate-source.json','checks':results,
 'failedAttemptsRetained':[
  {'log':'.tooling/test-tmp/decision-backend-build.log','cause':'Docker BuildKit missing-job error; clean retry built successfully'},
  {'log':'.tooling/test-tmp/decision-native-candidate-tests.log','cause':'Test scrolled text but not the complete button at 320px; corrected scrolling and reran'},
  {'log':'.tooling/test-tmp/decision-backend-final.log','cause':'Missing test import and transient timeout; corrected import and separate/final focused reruns retained'},
  {'log':'.tooling/test-tmp/decision-web-build-candidate.log','cause':'Unnecessary Json cast on typed ingredient lines; removed cast and production build passed'},
  {'log':'.tooling/test-tmp/decision-live-studio-diagnostic.log','cause':'Rolling summary timestamps invalidated the unchanged analysis scope; fixed in console dev.4'},
  {'log':'.tooling/test-tmp/decision-live-studio-explanation.log','cause':'Opening Studio text chunks lacked message identifiers; fixed and visibly verified in console dev.5'}],
 'ownersConfirmed':0,'ownerObservations':0,'actualModelEvaluation':'See dated actual-model reports and internal response review; no owner observations',
 'integratedSandboxAcceptance':'See integrated-sandbox-dev5.json; actual Sandbox execution with explicit sample restaurant activity, legacy accounting limitations retained',
 'physicalDeviceReview':'deferred by user on 2026-11-06','publicDeployment':'Development candidate; see component deployment records',
 'restoredSchema':json.loads((folder/'restored-schema.json').read_text(encoding='utf-8'))}
for name in ['backend-artifact','console-artifact','restored-startup','backend-deployment','console-deployment','backend-patch-deployment','actual-model-baseline-review','actual-model-dev4-review','actual-model-review','actual-model-task-review','integrated-sandbox-dev5','live-studio-acceptance']:
 if (folder/(name+'.json')).exists():report[name]=json.loads((folder/(name+'.json')).read_text(encoding='utf-8'))
apk=root/'build/release-017/raysto-0.17.0-dev.3+2203-arm64.apk'
if apk.exists():report['android']={'version':'0.17.0-dev.3+2203','artifact':str(apk.relative_to(root)).replace('\\','/'),'sha256':digest(apk),'bytes':apk.stat().st_size,'signing':'existing-development-key'}
(folder/'candidate-evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'sourceSha256':source['sha256'],'sourceFiles':len(files),'checks':[(r['id'],r['status'],r['count']) for r in results]},indent=2))
