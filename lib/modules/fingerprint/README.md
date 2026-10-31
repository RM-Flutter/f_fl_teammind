# fingerprint

Attendance ("fingerprint" = a punch in or out) history screens. Gated by the `fingerprint-sys` package (`UsgPackagesService.isFingerprintActive`).

**The punch itself is not here.** It is in `common_modules_widgets/main_app_fab_widget/` (methods, face and liveness checks, security checks) and `services/fingerprint_service.dart` (API and offline storage). Read both READMEs.

## Files
- `views/fingerprint_screen.dart`: `FingerprintScreen` (bottom-nav tab `/:lang/fingerprint`). The user's punches by day, with a date filter.
- `views/finger_print_view_screen.dart`: `FingerPrintViewScreen` (`more/fingerprintView/:id/:name`). Punches of another employee, opened from the team fingerprint screen in More (`more/views/team_fingerprint`).
- `views/finger_print_offilen.dart`: `FingerprintOfflineScreen` (`fingerprint/fingerprint-offline`). Lists punches saved offline and has the button that uploads them.
- `views/widgets/`: `FingerprintCard`, `FingerprintCardOffiline`, `FingerprintDetailsModalSheet` (punch details: time, method, location), loading shimmer.
- `view_models/fingerprint.viewmodel.dart`: `FingerprintViewModel`.

## How it works
- `initializeFingerprintScreen` runs `_getEmployeeFingerprints`, which calls `FingerprintService.getFingerprints` (`rm_fingerprint/v1/get_fingerprints`) for the selected date range and employee.
- Offline punches: `loadFingerprintsFromPreferences` reads SharedPreferences `fingerPrints` into `AppConstants.fingerPrints`. `deleteOfflineFingerprintAt(i)` removes one.
- Upload: `addFingerPrints(context, AppConstants.fingerPrints)` builds multipart `FormData` (`buildFormData`, with face images compressed by `_compressImageIfNeeded` at quality 72) and POSTs `DioHelper` `/rm_fingerprint/v1/add_fingerprints`. When it succeeds, the local cache is cleared.
