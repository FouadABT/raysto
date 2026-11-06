param([string[]]$Tests = @('test/unit', 'test/integration'))
$ErrorActionPreference = 'Stop'
$raystoRoot = Split-Path $PSScriptRoot -Parent
$raystoSdk = Join-Path $raystoRoot '.tooling/dart-sdk/bin/dart.exe'
$raystoServer = Join-Path $raystoRoot 'backend/raysto/raysto_server'
$raystoPackageConfig = Join-Path $raystoRoot 'backend/raysto/.dart_tool/package_config.json'
if (!(Test-Path -LiteralPath $raystoSdk) -or !(Test-Path -LiteralPath $raystoPackageConfig)) {
  throw 'The project SDK or resolved workspace dependencies are unavailable. Restore the project tooling first.'
}
$raystoPackageData = Get-Content -LiteralPath $raystoPackageConfig -Raw | ConvertFrom-Json
$raystoTestPackage = $raystoPackageData.packages | Where-Object name -eq 'test'
if (!$raystoTestPackage) { throw 'Resolve the backend workspace test dependency first.' }
$raystoTestRoot = [Uri]::new([Uri]::new($raystoPackageConfig), [string]$raystoTestPackage.rootUri)
$raystoTestMain = Join-Path $raystoTestRoot.LocalPath 'bin/test.dart'
if (!(Test-Path -LiteralPath $raystoTestMain)) { throw 'The resolved test package has no executable entry point.' }
# These are synthetic rates for fake-model fixtures, not current provider prices.
# Keep the test-only feature flags in this process; deployment flags stay off.
$raystoTestEnvironment = @{
  RAYSTO_AI_INPUT_USD_PER_MILLION='0.75'
  RAYSTO_AI_OUTPUT_USD_PER_MILLION='3.75'
  RAYSTO_ASSISTANT_ENABLED='true'
  RAYSTO_ROOMS_ENABLED='true'
  RAYSTO_OPERATIONS_ENABLED='true'
}
$raystoPrevious = @{}
foreach($raystoName in $raystoTestEnvironment.Keys) {
  $raystoPrevious[$raystoName] = [Environment]::GetEnvironmentVariable($raystoName, 'Process')
  [Environment]::SetEnvironmentVariable($raystoName, $raystoTestEnvironment[$raystoName], 'Process')
}
Push-Location $raystoServer
try {
  & $raystoSdk "--packages=$raystoPackageConfig" $raystoTestMain @Tests --reporter expanded --concurrency=1 --timeout 3m
  $raystoResult = $LASTEXITCODE
} finally {
  Pop-Location
  foreach($raystoName in $raystoTestEnvironment.Keys) {
    [Environment]::SetEnvironmentVariable($raystoName, $raystoPrevious[$raystoName], 'Process')
  }
}
exit $raystoResult
