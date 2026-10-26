param(
  [ValidateSet('dependencies','generate','migration','test','start','analyze')]
  [string]$Action = 'test'
)
$ErrorActionPreference = 'Stop'
$raystoRoot = Split-Path -Parent $PSScriptRoot
$raystoDart = Join-Path $raystoRoot '.tooling/dart-sdk/bin/dart.exe'
if (-not (Test-Path -LiteralPath $raystoDart)) {
  $raystoDart = (Get-Command dart -ErrorAction Stop).Source
}
$env:PATH = (Split-Path -Parent $raystoDart) + ';' + $env:PATH
$raystoServer = Join-Path $PSScriptRoot 'raysto/raysto_server'
$raystoTooling = Join-Path $PSScriptRoot 'tooling'
Push-Location $raystoServer
try {
  switch ($Action) {
    'dependencies' {
      & $raystoDart pub get --directory $raystoTooling
      if ($LASTEXITCODE -ne 0) { throw 'Tool dependencies failed.' }
      & $raystoDart pub get
    }
    { $_ -in 'generate','migration' } {
      $raystoCommand = if ($Action -eq 'migration') { 'create-migration' } else { 'generate' }
      # Run the pinned CLI from its tooling workspace without global activation.
      $raystoPackages = Get-Content (Join-Path $raystoTooling '.dart_tool/package_config.json') -Raw | ConvertFrom-Json
      $raystoCli = $raystoPackages.packages | Where-Object { $_.name -eq 'serverpod_cli' }
      $raystoCliRoot = ([Uri]$raystoCli.rootUri).LocalPath
      & $raystoDart "--packages=$raystoTooling/.dart_tool/package_config.json" (Join-Path $raystoCliRoot 'bin/serverpod_cli.dart') --no-analytics --no-interactive $raystoCommand
    }
    'test' { & $raystoDart test --concurrency=1 }
    'analyze' { & $raystoDart analyze }
    'start' {
      if (-not $env:FIREBASE_PROJECT_ID) {
        $raystoFirebase = Get-Content (Join-Path $raystoRoot '.firebaserc') -Raw | ConvertFrom-Json
        $env:FIREBASE_PROJECT_ID = $raystoFirebase.projects.default
      }
      if (-not $env:RAYSTO_FIREBASE_ENABLED) { $env:RAYSTO_FIREBASE_ENABLED = 'true' }
      & $raystoDart run bin/main.dart --apply-migrations
    }
  }
  if ($LASTEXITCODE -ne 0) { throw "Backend $Action failed (exit $LASTEXITCODE)." }
} finally { Pop-Location }
