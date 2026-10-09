# Pull the upstream skill/MCP repos tracked as submodules under external/.
# Usage: .\scripts\pull-skills.ps1 [-Latest]
param([switch]$Latest)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
if ($Latest) { git submodule update --init --remote --recursive; Write-Host "submodules moved to upstream HEAD; review and commit the pointer bump" }
else { git submodule update --init --recursive }
git submodule status
