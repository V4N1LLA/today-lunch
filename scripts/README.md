# Scripts

Workspace helper scripts for local setup and validation.

## Available scripts

- `bootstrap.ps1`: resolves Dart/Flutter, runs root `dart pub get`, then performs package-level `pub get` by default. Use `-UseMelos` only when you want to retry `dart run melos bootstrap`.
- `analyze.ps1`: runs `dart analyze` from the workspace root.
- `test.ps1`: runs the current mobile, server, and shared package test suites.

## Usage

```powershell
.\scripts\bootstrap.ps1
.\scripts\analyze.ps1
.\scripts\test.ps1
```

Each script accepts optional `-FlutterPath` and `-DartPath` overrides when the SDK is not on `PATH`.
