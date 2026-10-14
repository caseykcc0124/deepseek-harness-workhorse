$offlineRoot = $PSScriptRoot
$suiteRoot = Join-Path $offlineRoot 'tools/oss-cad-suite'
if (Test-Path "$suiteRoot/environment.ps1") { . "$suiteRoot/environment.ps1" }
$env:VERILATOR_ROOT = Join-Path $suiteRoot 'share/verilator'
$env:PLAYWRIGHT_BROWSERS_PATH = Join-Path $offlineRoot 'browsers'
$env:PSModulePath = (Join-Path $offlineRoot 'powershell-modules') + ';' + $env:PSModulePath
$env:PATH = @(
    (Join-Path $offlineRoot 'runtime/node-v22.23.3-win-x64'),
    (Join-Path $offlineRoot 'python-env/Scripts'),
    (Join-Path $offlineRoot 'app/node_modules/.bin'),
    (Join-Path $offlineRoot 'tools/github-mcp'),
    (Join-Path $offlineRoot 'tools/powershell'),
    (Join-Path $offlineRoot 'tools/gh/bin'),
    $env:PATH
) -join ';'
Write-Host 'Portable environment ready. Use verilator_bin.exe for native Windows lint.'
