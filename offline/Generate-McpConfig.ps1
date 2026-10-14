$ErrorActionPreference = 'Stop'
$offlineRoot = $PSScriptRoot
$nodeLiteral = (Join-Path $offlineRoot 'runtime/node-v22.23.3-win-x64/node.exe') | ConvertTo-Json -Compress
$playwrightLiteral = (Join-Path $offlineRoot 'browser-tools/node_modules/@playwright/mcp/cli.js') | ConvertTo-Json -Compress
$chromiumLiteral = (Join-Path $offlineRoot 'browsers/chromium-1247/chrome-win64/chrome.exe') | ConvertTo-Json -Compress
$githubLiteral = (Join-Path $offlineRoot 'tools/github-mcp/github-mcp-server.exe') | ConvertTo-Json -Compress
$example = @"
# Generated example only; not automatically enabled.
- id: mcp-github-offline-tools
  name: '@deepseek-ai/dsh-mcp-client'
  config:
    serverName: github
    transport: stdio
    command: $githubLiteral
    args: ['stdio', '--read-only']
    env:
      GITHUB_PERSONAL_ACCESS_TOKEN: !!js process.env.GITHUB_MCP_TOKEN
- id: mcp-playwright-offline-tools
  name: '@deepseek-ai/dsh-mcp-client'
  config:
    serverName: browser
    transport: stdio
    command: $nodeLiteral
    args: [$playwrightLiteral, '--browser', 'chromium', '--headless', '--executable-path', $chromiumLiteral]
"@
Set-Content -LiteralPath "$offlineRoot/mcp.generated.local.yml" -Value $example -Encoding UTF8
Write-Host 'Created mcp.generated.local.yml; review it before adding it to your profile.'
