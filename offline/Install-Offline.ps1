param([string]$PythonExe)
$ErrorActionPreference = 'Stop'
$offlineRoot = $PSScriptRoot
$nodeRoot = Join-Path $offlineRoot 'runtime/node-v22.23.3-win-x64'
if (-not (Test-Path "$nodeRoot/node.exe")) {
    Expand-Archive -LiteralPath "$offlineRoot/installers/node-v22.23.3-win-x64.zip" -DestinationPath "$offlineRoot/runtime" -Force
}
$nodeExe = Join-Path $nodeRoot 'node.exe'
$npmCli = Join-Path $nodeRoot 'node_modules/npm/bin/npm-cli.js'
$env:PATH = $nodeRoot + ';' + $env:PATH
$env:npm_config_offline = 'true'
$env:npm_config_update_notifier = 'false'
$env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = '1'
foreach ($projectName in @('app','browser-tools')) {
    if (-not (Test-Path (Join-Path $offlineRoot "$projectName/package-lock.json"))) { continue }
    Push-Location (Join-Path $offlineRoot $projectName)
    try {
        & $nodeExe $npmCli ci --offline --cache "$offlineRoot/npm-cache" --no-audit --no-fund
        if ($LASTEXITCODE -ne 0) { throw "Offline npm install failed: $projectName" }
    } finally { Pop-Location }
}
New-Item -ItemType Directory -Force "$offlineRoot/tools" | Out-Null
if ((Test-Path "$offlineRoot/installers/oss-cad-suite-windows-x64-20261013.tgz") -and -not (Test-Path "$offlineRoot/tools/oss-cad-suite/bin/yosys.exe")) {
    tar.exe -xzf "$offlineRoot/installers/oss-cad-suite-windows-x64-20261013.tgz" -C "$offlineRoot/tools"
    if ($LASTEXITCODE -ne 0) { throw 'RTL toolchain extraction failed.' }
}
foreach ($tool in @(
    @{File='github-mcp-server_Windows_x86_64.zip'; Directory='github-mcp'},
    @{File='PowerShell-7.6.7-win-x64.zip'; Directory='powershell'},
    @{File='gh_2.102.0_windows_amd64.zip'; Directory='gh'}
)) {
    if ((Test-Path "$offlineRoot/installers/$($tool.File)") -and -not (Test-Path "$offlineRoot/tools/$($tool.Directory)")) {
        Expand-Archive -LiteralPath "$offlineRoot/installers/$($tool.File)" -DestinationPath "$offlineRoot/tools/$($tool.Directory)" -Force
    }
}
if (Test-Path "$offlineRoot/python-wheels") {
if (-not $PythonExe) {
    $pythonCommand = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($pythonCommand) { $PythonExe = $pythonCommand.Source }
}
if (-not $PythonExe) { throw 'Install Python 3.11 using the included installer, then rerun with -PythonExe <python.exe>.' }
$pythonAbi = & $PythonExe -c 'import sys; print(str(sys.version_info.major) + chr(46) + str(sys.version_info.minor))'
if ($pythonAbi -ne '3.11') { throw 'The included native wheels require Python 3.11 x64. Select it with -PythonExe.' }
$pythonEnvironment = [System.IO.Path]::GetFullPath((Join-Path $offlineRoot 'python-env'))
if (-not $pythonEnvironment.StartsWith($offlineRoot.TrimEnd('\') + '\',[System.StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected Python environment path.' }
# Recreate this disposable environment: venv launchers from another computer are not portable.
& $PythonExe -m venv --clear $pythonEnvironment
if ($LASTEXITCODE -ne 0) { throw 'Python environment creation failed.' }
& "$offlineRoot/python-env/Scripts/python.exe" -m pip install --no-index --find-links "$offlineRoot/python-wheels" cocotb python-docx python-pptx openpyxl pillow pypdf pymupdf lxml numpy
if ($LASTEXITCODE -ne 0) { throw 'Offline Python installation failed.' }
}
Write-Host 'Offline dependencies installed. Run Start-Offline.cmd. No accounts or plugins were enabled.'
