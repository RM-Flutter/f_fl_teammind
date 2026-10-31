# common_modules_widgets

Widgets shared across modules, plus the **punch-in (attendance) engine**.

## `main_app_fab_widget/`: punch-in FAB and attendance engine

The main floating action button (`main_app_fab.widget.dart`) appears on the main shell. It starts an attendance punch through the method configured for the employee. The logic lives in `main_app_fab.service.dart` (about 2,900 lines, class `MainFabServices`, static).

### Entry point
`getFingerprintActionMethodDependsOnFingerprintMethod(context, fingerprintMethod:)` switches on the method string from the user settings:

| Method | Handler | Then calls |
|---|---|---|
| QR code | `addFingerprintUsingQrCode` (opens `widgets/qrcode_Scanner_view.widget.dart`, `mobile_scanner`) | `FingerprintService.addQRCodeFingerprint` |
| GPS | `addFingerprintUsingGPS` (`getCurrentLocation`) | `addGPSFingerprint` / `addCustomGPSFingerprint` |
| WiFi | `addFingerprintUsingWiFi` (`wifi_scan` / `network_info_plus`) | `addWifiFingerprint` |
| Bluetooth | `addFingerprintUsingBluetooth` (`flutter_blue_plus` scan) | `addBluetoothFingerprint` |
| NFC | `addFingerprintUsingNFC` (`nfc_manager`) | `addNFCFingerprint` |
| Machine | not implemented in the app | |

### Device security checks, run before any punch
These use the native channel `com.rightminddev.rmemp/secure`:
- **Developer mode**: blocks the punch when `blockFingerprintOnDeveloperMode` is on.
- **Root or jailbreak**: blocks when `fingerprintBlockOnRootOrJailbreak` is on.
- **Fake GPS**: checked in `FingerprintService`.

A failed check shows `_showSecurityErrorDialog`.

### Face verification: `captureEmployeeFaceAndVerify(context)`
Not available on web. Steps:
1. Requests camera and microphone permissions.
2. When `fingerprintFaceProfileVerificationEnabled` is on, loads **MobileFaceNet** (`assets/models/mobilefacenet.tflite`, 112×112 input, 192-D embedding) through `tflite_flutter`. On iOS, if the model fails to load, the flow continues with image capture only.
3. **Liveness**: when `fingerprintLivenessChallengesEnabled` is on, opens `widgets/liveness_challenge_camera.widget.dart`, which runs random ML Kit challenges (blink left or right eye, close both eyes, smile, turn or tilt the head) and returns `LivenessChallengeReport`s. With liveness off, it captures a single frame instead.
4. Each frame is analysed with `google_mlkit_face_detection`. Thresholds: face coverage at least 0.08, sharpness at least 7.0, smile probability at least 0.7. The best frame is chosen with `_scoreFrame`.
5. **Profile match**: downloads and caches the employee's profile image, embeds both faces, and compares them with cosine similarity. The frame is rejected if similarity is below `_minProfileSimilarity` (0.4).
6. Returns `_CapturedFaceData` (the image file, which is compressed and uploaded when `fingerprintUploadFaceImageToBackend` is on, plus the reports). The reports are turned into the `noteReport` that is sent as the fingerprint `note`.

The `AppConstants.fingerprint*` flags come from `USG` and gate each step. `fpScanSteps` shows a debug report of the liveness steps.

`tflite_wrapper.dart`, `tflite_flutter_mobile.dart` and `tflite_flutter_stub.dart` are a conditional import, so the web build compiles without TFLite.

## `comments/`
Comments thread UI, used for requests, complaints and notifications:
- `logic/view_model.dart`: `CommentProvider`, a global provider. It GETs and POSTs `/<slug>/entities-operations/<id>/comments` through `DioHelper`.
- `comments_widget.dart` and `list_comments.dart` render the thread (text, images, voice).
- `send_comment_widget.dart` is the input box, with file, image and voice (`record_service.dart`) attachments.

## `bookmark_widgets/`
`bookmark_button.widget.dart`: bookmarks a screen or item. It uses `general_services/bookmark.service.dart`, and the bookmarks are shown in the home bookmark list.

## Other shared widgets

| File | Purpose |
|---|---|
| `webview_wrapper.dart` / `webview_wrapper_mobile.dart` | A webview (`webview_flutter`) with a web fallback. Used for `rm_webview:` links, evaluations and company structure. |
| `request_card.widget.dart`, `notification_card.widget.dart`, `vocation_list.widget.dart` | Cards for lists of requests, notifications and leave balances. |
| `app_bar_with_bookmark.widget.dart`, `template_page.widget.dart`, `loading_page.widget.dart` | Page scaffolding. |
| `button_widget.dart`, `custom_elevated_button.widget.dart`, `custom_floating_action_button.widget.dart`, `custom_alert_dialog_with_two_buttons.dart` | Buttons and dialogs. |
| `cached_network_image_widget.dart`, `dynamic_image_widget.dart` | Images, including network or asset selection from server config. |
| `language_dropdown_button.widget.dart` | AR/EN switcher. |
| `payrolls_and_penalties_and_rewards_loading_screens.widget.dart` | Shimmer loaders. |
