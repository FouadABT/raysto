$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$env:RAYSTO_ROOMS_ENABLED = 'true'
$env:RAYSTO_ASSISTANT_ENABLED = 'true'
$env:RAYSTO_OPERATIONS_ENABLED = 'true'
$env:RAYSTO_AI_INPUT_USD_PER_MILLION = '1.65'
$env:RAYSTO_AI_OUTPUT_USD_PER_MILLION = '8.25'
Push-Location (Join-Path $root 'backend/raysto/raysto_server')
try {
  & (Join-Path $root '.tooling/dart-sdk/bin/dart.exe') test test/integration/conversation_domain_test.dart test/unit/equal_shares_test.dart test/unit/paypal_mcp_test.dart --concurrency=1
  if ($LASTEXITCODE -ne 0) { throw 'Conversation verification failed.' }
} finally { Pop-Location }
