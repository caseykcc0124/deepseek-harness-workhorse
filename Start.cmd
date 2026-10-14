@echo off
cd /d "%~dp0"
if exist ".runtime\node_modules\node\bin\node.exe" (
  ".runtime\node_modules\node\bin\node.exe" scripts\start.mjs %*
) else (
  node scripts\start.mjs %*
)
pause
