# offline

The screen the splash screen opens when there is no internet. Employees can still punch.

- `views/offline_screen.dart`: offline home. It offers a QR or GPS punch and lists the cached punches.
- `controller/offline_controller.dart`: `OfflineController`. `initialize`, `loadFingerprintsFromPreferences` (SharedPreferences `fingerPrints`), `deleteOfflineFingerprintAt`, and `gps()` for the current location.
- `views/widgets/finger_print_offline_card.dart`: card for one cached punch.
- `data/local_data/offline_local_data_source.dart`: local data source interface.

Offline punches are stored by `MainAppFabService` / `FingerprintService`. They are uploaded when the user is online again (`FingerprintService.uploadFingerprintsInOnlineMood`). While the user stays on this screen, `ConnectionService` does not navigate away by itself. A retry button returns to the splash screen.
