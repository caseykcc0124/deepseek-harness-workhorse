param(
    [ValidateSet('List','Add','Remove','Restore')][string]$Action = 'List',
    [string]$Package,
    [string]$OfflineRoot,
    [switch]$Offline,
    [string]$StoreDirectory,
    [string]$ProfileHome
)
$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
if ($OfflineRoot) {
    $materialRoot = [System.IO.Path]::GetFullPath($OfflineRoot)
    $applicationRoot = Join-Path $materialRoot 'app'
    $nodeExe = Join-Path $materialRoot 'runtime/node-v22.23.3-win-x64/node.exe'
} else {
    $applicationRoot = $repositoryRoot
    $nodeExe = Join-Path $repositoryRoot '.runtime/node_modules/node/bin/node.exe'
    if (-not (Test-Path $nodeExe)) { $nodeExe = (Get-Command node.exe -ErrorAction Stop).Source }
}
$cli = Join-Path $applicationRoot 'node_modules/@deepseek-ai/dsh/lib/bin.js'
if (-not (Test-Path $cli)) { throw 'Install Harness first. See docs/INSTALL.md.' }
if (-not (Test-Path $nodeExe)) { throw 'Node runtime missing. Run the installation script first.' }
$env:DSH_HOME = if ($ProfileHome) { [System.IO.Path]::GetFullPath($ProfileHome) } else { Join-Path $applicationRoot '.dsh-home' }
$env:PATH = (Split-Path $nodeExe) + ';' + (Join-Path $applicationRoot 'node_modules/.bin') + ';' + $env:PATH
$commandArguments = switch ($Action) {
    'List' { @('list','--depth','0') }
    'Add' { if (-not $Package) { throw '-Package is required for Add.' }; @('add',$Package) }
    'Remove' { if (-not $Package) { throw '-Package is required for Remove.' }; @('remove',$Package) }
    'Restore' { @('install') }
}
if ($Offline -and $Action -in @('Add','Restore')) { $commandArguments += '--offline' }
if ($StoreDirectory -and $Action -ne 'List') { $commandArguments += @('--store-dir',[System.IO.Path]::GetFullPath($StoreDirectory)) }
Write-Host "Profile: web; DSH_HOME: $env:DSH_HOME"
& $nodeExe $cli plugin --profile web @commandArguments
if ($LASTEXITCODE -ne 0) { throw 'Plugin operation failed. Keep the diagnostics and see docs/PLUGINS.md.' }
