# Runbook

## Local startup

1. Ensure Flutter and Dart are available through `PATH`, `FLUTTER_ROOT`, or explicit script arguments.
2. Run `.\scripts\bootstrap.ps1`
3. Run `.\scripts\analyze.ps1`
4. Run `.\scripts\test.ps1`
5. Start the API with `dart run server/api/bin/server.dart`
6. Verify the API with `Invoke-WebRequest http://localhost:8080/health`
7. Start the app from `apps/mobile` with `flutter run`
8. Confirm the home screen shows `Server OK` and the API version

## Notes

- The current Windows environment can fail on `melos bootstrap` with a UTF-8 decode exception.
- `.\scripts\bootstrap.ps1` uses package-level `pub get` by default. Use `-UseMelos` only when you explicitly want to retry the melos path.
