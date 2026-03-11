param(
  [string]$FlutterPath,
  [string]$DartPath
)

. "$PSScriptRoot/common.ps1"

$repoRoot = Get-RepoRoot
$flutterExe = Resolve-FlutterExe -FlutterPath $FlutterPath
$dartExe = Resolve-DartExe -DartPath $DartPath -FlutterExe $flutterExe

Invoke-CheckedCommand `
  -WorkingDirectory (Join-Path $repoRoot "apps/mobile") `
  -Executable $flutterExe `
  -Arguments @("test") `
  -Description "apps/mobile flutter test"

foreach ($relativePath in @("server/api", "packages/shared_models", "packages/shared_utils")) {
  Invoke-CheckedCommand `
    -WorkingDirectory (Join-Path $repoRoot $relativePath) `
    -Executable $dartExe `
    -Arguments @("test") `
    -Description "$relativePath dart test"
}
