# lib/core/widgets/main_app_fab_widget

The fingerprint (punch in/out) button in the middle of the bottom bar, plus everything that runs when the user presses it. This is the most important flow in the app.

| File | Role |
|---|---|
| `main_app_fab.widget.dart` | `MainAppFabWidget`. It reads `US1` (`UserSettingsModel`) to find the **fingerprint methods allowed** for this user (only `allowedFingerprintTypes`, the backend type => true/false map). It shows a single action, or a chooser when several methods are allowed. |
| `main_app_fab.service.dart` | `MainAppFabService`: the punch flow (below) |
| `widgets/liveness_challenge_camera_widget.dart` | Camera screen that asks for random liveness challenges (blink an eye, close both eyes, tilt or turn the head, smile) and checks them with ML Kit face detection |
| `widgets/qrcode_Scanner_view_widget.dart` | QR scanner for `fp_scan` |
| `tflite_wrapper.dart`, `tflite_flutter_mobile.dart`, `tflite_flutter_stub.dart` | Conditional import, so TFLite is only loaded on mobile |

## How a punch works

1. **Entry**: `getFingerprintActionMethodDependsOnFingerprintMethod(context, fingerprintMethod)`.
2. **Refresh the security levels** from the cached settings (`AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks`).
3. **Device security gate** (`_ensureDeviceSecurityForFingerprint`): developer mode and root/jailbreak checks block the punch when their level is mandatory.
4. **Dispatch by method**. The web always uses GPS.
   - `fp_scan` → `addFingerprintUsingQrCode`: scan the office QR code to get a secret key
   - `fp_navigate` / `custom_fp_navigate` → `addFingerprintUsingGPS`: current location, sent to the server for geofence validation
   - `fp_wifi` → `addFingerprintUsingWiFi`: scan the connected or nearby SSID/BSSID
   - `fp_bluetooth` → `addFingerprintUsingBluetooth`: scan for the registered beacon or device
   - `fp_nfc` → `addFingerprintUsingNFC`: read the NFC tag
   - `fp_machine`: not implemented
5. **Location and network checks** (`FingerprintSecurityRunner.runAllChecks`): fake GPS, VPN, time drift, GPS vs network location, and the offline GPS timestamp. A failing mandatory check blocks the punch. A failing optional check is added to the note report.
6. **Face step**, when `AppConstants.showFaceVerifyForFingerprint` is on (`captureEmployeeFaceAndVerify`):
   - records a short front-camera video and extracts frames
   - picks the sharpest frame with a large enough face (`_minFaceCoverage`, `_minSharpness`)
   - runs the liveness challenges
   - compares a FaceNet embedding (`assets/models/facenet.tflite`) with the profile photo by cosine similarity (threshold `_minProfileSimilarity = 0.4`)
   - the face image is uploaded only when `fingerprintUploadFaceImageToBackend` is on
7. **Submit** through `FingerprintService.addXxxFingerprint(...)` (`rm_fingerprint/v1/add_fingerprint(s)`). The request carries the device id, coordinates, the note report (liveness results, optional failures) and any files.
8. **Offline**: when there is no connection the punch is cached (`_cacheFingerprint` → SharedPreferences `fingerPrints`, with files converted by `filePickerResultToCacheableMap`). It is uploaded later (`FingerprintService.uploadFingerprintsInOnlineMood`) and is visible on the offline screen.
9. **Result**: a success or failure alert. When `fpScanSteps` is on, a step-by-step report dialog is also shown.

Native root and jailbreak detection uses the method channel `com.rightminddev.rmemp/secure`, implemented in the Android and iOS host code.
