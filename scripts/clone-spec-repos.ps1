# Clone (or update) every openEHR specifications-* repo side by side into one workspace root.
# Usage: .\scripts\clone-spec-repos.ps1 [-Workspace <dir>]   (default: the openehr-spec folder this repo sits in)
param([string]$Workspace = (Join-Path $PSScriptRoot "..\.."))
$ErrorActionPreference = "Stop"
$repos = "AA_GLOBAL","AM","BASE","CDS","CNF","INTG","ITS","ITS-BMM","ITS-JSON","ITS-REST","ITS-XML","LANG","PROC","QUERY","RM","SM","TERM","UML"
New-Item -ItemType Directory -Force $Workspace | Out-Null
foreach ($c in $repos) {
  $r = "specifications-$c"; $p = Join-Path $Workspace $r
  if (Test-Path (Join-Path $p ".git")) { Write-Host "update  $r"; git -C $p pull -q --ff-only }
  else { Write-Host "clone   $r"; git clone -q "https://github.com/openEHR/$r.git" $p }
}
Write-Host "done: $((Get-ChildItem $Workspace -Directory -Filter 'specifications-*').Count) repos in $Workspace"
