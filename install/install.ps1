$ErrorActionPreference = 'Stop'

$repo   = "moneychien19/claude-skills"
$branch = "main"
$skillsDest = Join-Path $HOME ".claude\skills"

# $PSScriptRoot is empty when run via iex. In that case, download from GitHub.
$tmpDir = $null
if ($PSScriptRoot) {
    $skillsSrc = Join-Path $PSScriptRoot "..\skills"
} else {
    Write-Host "Downloading skills from GitHub ($repo@$branch)..."
    $tmpDir = Join-Path $env:TEMP "claude-skills-$(Get-Random)"
    New-Item -ItemType Directory -Path $tmpDir | Out-Null

    $tarPath = Join-Path $tmpDir "skills.tar.gz"
    Invoke-WebRequest -Uri "https://api.github.com/repos/$repo/tarball/$branch" -OutFile $tarPath
    tar -xzf $tarPath -C $tmpDir --strip-components=1
    $skillsSrc = Join-Path $tmpDir "skills"
}

try {
    New-Item -ItemType Directory -Force -Path $skillsDest | Out-Null

    $installed = 0
    $updated   = 0

    Get-ChildItem -Path $skillsSrc -Filter "*.md" | ForEach-Object {
        $name    = $_.BaseName
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
} finally {
    if ($tmpDir -and (Test-Path $tmpDir)) {
        Remove-Item -Recurse -Force $tmpDir
    }
}
