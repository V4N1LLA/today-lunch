param(
  [string]$FlutterPath,
  [string]$DartPath,
  [switch]$UseMelos
)

. "$PSScriptRoot/common.ps1"

$repoRoot = Get-RepoRoot
$flutterExe = Resolve-FlutterExe -FlutterPath $FlutterPath
$dartExe = Resolve-DartExe -DartPath $DartPath -FlutterExe $flutterExe

Invoke-CheckedCommand `
  -WorkingDirectory $repoRoot `
  -Executable $dartExe `
  -Arguments @("pub", "get") `
  -Description "Root dart pub get"

if ($UseMelos) {
  Write-Host "==> Attempting dart run melos bootstrap"
  Push-Location $repoRoot
  try {
    & $dartExe "run" "melos" "bootstrap"
    if ($LASTEXITCODE -eq 0) {
      exit 0
    }

    Write-Warning "dart run melos bootstrap failed with exit code $LASTEXITCODE."
  } finally {
    Pop-Location
  }
}

Write-Host "==> Running package-level pub get"

Invoke-CheckedCommand `
  -WorkingDirectory (Join-Path $repoRoot "apps/mobile") `
  -Executable $flutterExe `
  -Arguments @("pub", "get") `
  -Description "apps/mobile flutter pub get"

foreach ($relativePath in @("server/api", "packages/shared_models", "packages/shared_utils")) {
  Invoke-CheckedCommand `
    -WorkingDirectory (Join-Path $repoRoot $relativePath) `
    -Executable $dartExe `
    -Arguments @("pub", "get") `
    -Description "$relativePath dart pub get"
}
