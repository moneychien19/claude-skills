$ErrorActionPreference = 'Stop'

$skillsSrc = Join-Path $PSScriptRoot "..\skills"
$skillsDest = Join-Path $HOME ".claude\skills"

New-Item -ItemType Directory -Force -Path $skillsDest | Out-Null

$installed = 0
$updated = 0

Get-ChildItem -Path $skillsSrc -Filter "*.md" | ForEach-Object {
    $name = $_.BaseName
    $destDir = Join-Path $skillsDest $name

    if (Test-Path $destDir) {
        $action = "updated"
        $updated++
    } else {
        $action = "installed"
        $installed++
    }

    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    Copy-Item -Path $_.FullName -Destination (Join-Path $destDir "SKILL.md") -Force
    Write-Host "[$action] $name"
}

Write-Host ""
Write-Host "Done. $installed installed, $updated updated -> $skillsDest"
