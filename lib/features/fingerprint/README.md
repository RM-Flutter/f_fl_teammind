# fingerprint

The "Fingerprint" tab: the user's attendance log. The punch action itself is the FAB in `core/widgets/main_app_fab_widget`.

| Path | Role |
|---|---|
| `controller/fingerprint_controller.dart` | `FingerprintViewModel`. `initializeFingerprintScreen` loads punches from `rm_fingerprint/v1/get_fingerprints` (by date). `loadFingerprintsFromPreferences` reads punches cached offline (`fingerPrints`). `addFingerPrints` / `buildFormData` upload them to `rm_fingerprint/v1/add_fingerprints`. `deleteOfflineFingerprintAt` removes one from the queue. |
| `data/repo/fingerprint_repo.dart` | API calls for the above |
| `data/models/fingerprint_model.dart` | `FingerPrintModel` and `FingerDateTime` |
| `views/finger_print_screen.dart` | Day list of punches (cards from `core/widgets/finger_print`) |
| `views/widgets/offline/` | List of punches waiting to upload (`fingerPrintOffline` route) |

Managers view team punches through `more/team_fingerprint`.
