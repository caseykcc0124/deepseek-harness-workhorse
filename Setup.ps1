$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$npmCommand = (Get-Command npm.cmd -ErrorAction Stop).Source
$npmCli = Join-Path (Split-Path $npmCommand) 'node_modules/npm/bin/npm-cli.js'
if (-not (Test-Path $npmCli)) { throw 'Install the official Node.js distribution, including npm, first.' }
$nodeCommand = (Get-Command node.exe -ErrorAction Stop).Source
$installedVersion = [version]((& $nodeCommand --version).TrimStart('v'))
if ($installedVersion -lt [version]'22.19.0') {
    & $nodeCommand $npmCli install --prefix .runtime node@22.23.3 --no-audit --no-fund
    if ($LASTEXITCODE -ne 0) { throw 'Standalone Node installation failed.' }
    $nodeCommand = Join-Path $PSScriptRoot '.runtime/node_modules/node/bin/node.exe'
}
$env:PATH = (Split-Path $nodeCommand) + ';' + $env:PATH
& $nodeCommand $npmCli ci --no-audit --no-fund
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
& $nodeCommand --test scripts/patch-locale.test.mjs
if ($LASTEXITCODE -ne 0) { throw 'Localization checks failed.' }
& $nodeCommand scripts/download-plugins.mjs
if ($LASTEXITCODE -ne 0) { throw 'Plugin download failed.' }
Write-Host 'Setup complete. Run Start.cmd. Optional plugins were downloaded, not enabled.'
