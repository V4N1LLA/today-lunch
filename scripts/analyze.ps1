param(
  [string]$FlutterPath,
  [string]$DartPath
)

. "$PSScriptRoot/common.ps1"

$repoRoot = Get-RepoRoot
$flutterExe = Resolve-FlutterExe -FlutterPath $FlutterPath
$dartExe = Resolve-DartExe -DartPath $DartPath -FlutterExe $flutterExe

Invoke-CheckedCommand `
  -WorkingDirectory $repoRoot `
  -Executable $dartExe `
  -Arguments @("analyze") `
  -Description "dart analyze"
