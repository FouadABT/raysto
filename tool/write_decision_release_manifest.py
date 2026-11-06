"""Maintain the exact compatible development release, without asserting open gates."""
import json
from pathlib import Path
from datetime import datetime,timezone
root=Path(__file__).resolve().parents[1];folder=root/'docs/impact-innovation'
def read(name):return json.loads((folder/(name+'.json')).read_text(encoding='utf-8'))
backend=read('backend-artifact');backend_deploy=read('backend-patch-deployment');console=read('console-artifact');console_deploy=read('console-deployment');evidence=read('candidate-evidence')
assert backend_deploy['artifactSha256']==backend['sha256']
assert console_deploy['artifactSha256']==console['sha256']
assert console_deploy['sourceCommit']==console['sourceCommit']
studio=read('live-studio-acceptance')
assert studio['status']=='passed' and studio.get('visibleExplanation') is True
assert studio['backendSource']==backend_deploy['sourceCommit'] and studio['consoleSource']==console_deploy['sourceCommit']
target=root/'docs/release-0.17-manifest.json';prior=root/'docs/release-0.17-dev2-checkpoint.json'
if not prior.exists():prior.write_bytes(target.read_bytes())
manifest={'release':'Raysto 0.17 — Hackathon Edition','status':'development-candidate-with-open-acceptance-gates','recordedAtUtc':datetime.now(timezone.utc).isoformat(),
 'baselineCommit':'44a3a78','submissionCommit':None,'submissionTag':None,
 'backend':{**backend,'sourceCommit':backend_deploy['sourceCommit'],'deployedRelease':backend_deploy['release'],'deployed':True,'artifactBase':'docs/impact-innovation/backend-artifact-dev4.json'},
 'console':{**console,'packageVersion':'0.1.0','deployedRelease':console_deploy['release'],'deployed':console_deploy['artifactSha256']==console['sha256']},
 'android':{**evidence['android'],'sourceCommit':'f5fb637c4b2202ac52b9f70ef711015f8a5a00a1','abi':'arm64-v8a','physicalDeviceAccepted':False,'physicalReview':'Explicitly deferred by Fouad on 6 November 2026'},
 'migrations':['20261105161345704','20261105193140136'],'paymentEnvironment':'sandbox','judgeCurrency':'USD','agStudioVersion':'3.0.0','validatedModelVersion':'gemini-3.6-flash',
 'enabledCapabilities':['one-dish-investigation','confirmed-receipt-costing','immutable-price-comparisons','bounded-AI-challenges','reviewed-price-publication','decision-and-outcome-evidence','Studio-custom-widgets-and-agent-harness','native-owner-workspace'],
 'featureFlags':{'finance017':True,'pricing':True,'pricingAgent':True,'studioAi':True,'guidedJudgeStory':False},
 'validation':evidence['checks'],'evidenceIndex':'docs/impact-innovation/candidate-evidence.json','sandboxEvidence':['docs/impact-innovation/integrated-sandbox-dev5.json'],
 'modelEvaluation':'docs/impact-innovation/actual-model-review.json','ownersConfirmed':0,
 'limitations':['Development build, not an accepted or tagged submission release.','Physical Android review explicitly deferred; APK uses the existing development key.','No consenting restaurant owners confirmed; no owner-impact, adoption or profit-improvement claim.','First-attempt AI task delivery 12/14; a network-failed task was recovered read-only, bringing valid model results to 13/14. The 90% first-attempt target is not met.','The current sample venue remains on legacy recorded-transactions basis; reviewed accounting cutover, complete earned-revenue history and seven-day business observations are unavailable.','Complete repeatable public judge fixture, cold reviewer acceptance and private-owner persistent-layout demonstration remain open.','AG Studio licensing through the end of judging remains unresolved.','Actual uncertain-provider recovery/refund acceptance on this exact combination remains separate from scripted regression coverage.','Presentation work is excluded from this workstream.']}
target.write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps({'backend':backend['version'],'console':console['version'],'consoleMatchesDeployment':manifest['console']['deployed'],'android':manifest['android']['version'],'submissionTag':None}))
