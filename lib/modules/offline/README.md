# offline

The screen shown when there is no connection (`/:lang/offline-screen`). Normally `general_services/offline_overlay.service.dart` shows it as an **overlay**, and the router does not redirect to it.

## Files
- `views/offline_screen.dart`: `OfflineScreen`. A "no internet" message, the list of punches saved offline, and buttons that start an offline punch through `MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod`.
- `view_models/offline_viewmodel.dart`: `OfflineViewModel` (plain class, not a ChangeNotifier).

## How it works
- `initialize(ctx)` loads the offline punches (`loadFingerprintsFromPreferences`, from SharedPreferences `fingerPrints`).
- `deleteOfflineFingerprintAt(index)` removes one saved punch. `gps()` reads the location with the `location` plugin for an offline GPS punch.
- Offline punches go through `FingerprintService.add*Fingerprint`, which detects that the device is offline and saves to Hive and prefs. They are uploaded later from `fingerprint/views/finger_print_offilen.dart` (see `modules/fingerprint/README.md`).
- The splash screen and the router avoid navigating away while this screen is active.
