$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ProjectDir "..\..")
$SourceRenderer = Join-Path $RepoRoot "Sources\SplatWallpaperEngine\Renderer"
$TargetRenderer = Join-Path $ProjectDir "Renderer"

if (!(Test-Path $SourceRenderer)) {
    throw "Renderer source not found: $SourceRenderer"
}

if (Test-Path $TargetRenderer) {
    Remove-Item $TargetRenderer -Recurse -Force
}

Copy-Item $SourceRenderer $TargetRenderer -Recurse
Write-Host "Copied renderer assets to $TargetRenderer"
