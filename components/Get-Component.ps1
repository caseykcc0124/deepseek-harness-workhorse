param(
    [string[]]$Name = @('core'),
    [string]$Destination = (Join-Path $PSScriptRoot '../../offline-materials'),
    [switch]$List
)
$ErrorActionPreference = 'Stop'
$catalog = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'catalog.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($List) {
    $catalog.components | Select-Object id,label,@{Name='MiB';Expression={[math]::Round($_.bytes / 1MB,1)}},dependencies
    return
}
$selected = @{}
function Add-SelectedComponent([string]$ComponentId) {
    $component = $catalog.components | Where-Object id -EQ $ComponentId | Select-Object -First 1
    if (-not $component) { throw "Unknown component: $ComponentId. Run with -List." }
    if ($selected.ContainsKey($ComponentId)) { return }
    foreach ($requiredId in $component.dependencies) { Add-SelectedComponent $requiredId }
    $selected[$ComponentId] = $component
}
foreach ($requestedName in $Name) {
    if ($requestedName -eq 'all') { foreach ($component in $catalog.components) { Add-SelectedComponent $component.id } }
    else { Add-SelectedComponent $requestedName }
}
$destinationRoot = [System.IO.Path]::GetFullPath($Destination)
New-Item -ItemType Directory -Force $destinationRoot | Out-Null
$cacheRoot = Join-Path $destinationRoot '.component-downloads'
New-Item -ItemType Directory -Force $cacheRoot | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$statePath = Join-Path $destinationRoot 'components-installed.json'
$state = @{}
if (Test-Path $statePath) {
    foreach ($entry in (Get-Content $statePath -Raw | ConvertFrom-Json)) { $state[$entry.id] = $entry }
}
foreach ($component in ($selected.Values | Sort-Object @{Expression={if ($_.id -eq 'core') {0} else {1}}},id)) {
    $localFile = Join-Path $cacheRoot $component.file
    if ((Test-Path $localFile) -and (Get-FileHash $localFile -Algorithm SHA256).Hash.ToLowerInvariant() -ne $component.sha256) {
        throw "Cached checksum mismatch: $($component.file). Remove that file and retry."
    }
    if (-not (Test-Path $localFile)) {
        Write-Host "Downloading $($component.id) ($([math]::Round($component.bytes / 1MB,1)) MiB)..."
        $partialFile = $localFile + '.part'
        Invoke-WebRequest -Uri $component.url -OutFile $partialFile -UseBasicParsing
        if ((Get-FileHash $partialFile -Algorithm SHA256).Hash.ToLowerInvariant() -ne $component.sha256) { throw "Downloaded checksum mismatch: $($component.id)" }
        Move-Item -LiteralPath $partialFile -Destination $localFile
    }
    if ($component.kind -eq 'zip') {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($localFile)
        try {
            foreach ($entry in $archive.Entries) {
                $resolvedEntry = [System.IO.Path]::GetFullPath((Join-Path $destinationRoot $entry.FullName))
                if (-not $resolvedEntry.StartsWith($destinationRoot.TrimEnd('\') + '\',[System.StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe archive path.' }
            }
        } finally { $archive.Dispose() }
        Expand-Archive -LiteralPath $localFile -DestinationPath $destinationRoot -Force
    } else {
        $targetFile = [System.IO.Path]::GetFullPath((Join-Path $destinationRoot $component.destination))
        if (-not $targetFile.StartsWith($destinationRoot.TrimEnd('\') + '\',[System.StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe target path.' }
        New-Item -ItemType Directory -Force (Split-Path $targetFile) | Out-Null
        Copy-Item -LiteralPath $localFile -Destination $targetFile -Force
    }
    $state[$component.id] = @{id=$component.id;sha256=$component.sha256;release=$catalog.release;status='downloaded_not_enabled'}
    @($state.Values) | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statePath -Encoding UTF8
    Write-Host "Ready: $($component.id). No plugin or account enabled."
}
Write-Host "Materials: $destinationRoot. Copy this folder to the offline computer, then run Install-Offline.ps1 if present."
