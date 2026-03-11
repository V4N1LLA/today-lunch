Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
  return Split-Path -Path $PSScriptRoot -Parent
}

function Resolve-FlutterExe {
  param(
    [string]$FlutterPath
  )

  if ($FlutterPath) {
    if (-not (Test-Path $FlutterPath)) {
      throw "Flutter executable not found at '$FlutterPath'."
    }

    return (Resolve-Path $FlutterPath).Path
  }

  $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
  if ($flutterCommand) {
    return $flutterCommand.Source
  }

  if ($env:FLUTTER_ROOT) {
    $candidate = Join-Path $env:FLUTTER_ROOT "bin/flutter.bat"
    if (Test-Path $candidate) {
      return $candidate
    }
  }

  $repoCandidate = Join-Path (Get-RepoRoot) "tools/flutter/bin/flutter.bat"
  if (Test-Path $repoCandidate) {
    return $repoCandidate
  }

  throw "Flutter executable not found. Add Flutter to PATH or pass -FlutterPath."
}

function Resolve-DartExe {
  param(
    [string]$DartPath,
    [string]$FlutterExe
  )

  if ($DartPath) {
    if (-not (Test-Path $DartPath)) {
      throw "Dart executable not found at '$DartPath'."
    }

    return (Resolve-Path $DartPath).Path
  }

  $dartCommand = Get-Command dart -ErrorAction SilentlyContinue
  if ($dartCommand) {
    return $dartCommand.Source
  }

  if ($env:DART_SDK) {
    $sdkCandidate = Join-Path $env:DART_SDK "bin/dart.exe"
    if (Test-Path $sdkCandidate) {
      return $sdkCandidate
    }

    if (Test-Path $env:DART_SDK) {
      return (Resolve-Path $env:DART_SDK).Path
    }
  }

  if ($FlutterExe) {
    $flutterBinDirectory = Split-Path -Path $FlutterExe -Parent
    $bundledDart = Join-Path $flutterBinDirectory "cache/dart-sdk/bin/dart.exe"
    if (Test-Path $bundledDart) {
      return $bundledDart
    }
  }

  $repoCandidate = Join-Path (Get-RepoRoot) "tools/flutter/bin/cache/dart-sdk/bin/dart.exe"
  if (Test-Path $repoCandidate) {
    return $repoCandidate
  }

  throw "Dart executable not found. Add Dart to PATH or pass -DartPath."
}

function Invoke-CheckedCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string]$WorkingDirectory,
    [Parameter(Mandatory = $true)]
    [string]$Executable,
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments,
    [Parameter(Mandatory = $true)]
    [string]$Description
  )

  Write-Host "==> $Description"
  Push-Location $WorkingDirectory
  try {
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
      throw "Command failed with exit code ${LASTEXITCODE}: $Executable $($Arguments -join ' ')"
    }
  } finally {
    Pop-Location
  }
}
