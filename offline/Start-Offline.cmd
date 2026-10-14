@echo off
cd /d "%~dp0"
set "PLAYWRIGHT_BROWSERS_PATH=%~dp0browsers"
set "VERILATOR_ROOT=%~dp0tools\oss-cad-suite\share\verilator"
set "PSModulePath=%~dp0powershell-modules;%PSModulePath%"
set "PATH=%~dp0runtime\node-v22.23.3-win-x64;%~dp0python-env\Scripts;%~dp0tools\github-mcp;%~dp0tools\powershell;%~dp0tools\gh\bin;%~dp0tools\oss-cad-suite\bin;%~dp0tools\oss-cad-suite\lib;%PATH%"
"%~dp0runtime\node-v22.23.3-win-x64\node.exe" "%~dp0app\scripts\start.mjs" %*
pause
