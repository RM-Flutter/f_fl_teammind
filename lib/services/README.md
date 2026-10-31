# services

Cross-module API services. They are static `abstract class`es that call `DioApiService` with URLs from `EndpointServices`, and they return `OperationResult<T>`.

## `fingerprint_service.dart`: `FingerprintService`

Attendance ("fingerprint") submission and history. The UI that collects the data is in `common_modules_widgets/main_app_fab_widget/` (punch-in FAB).

**Submit methods.** Each one POSTs multipart to `rm_fingerprint/v1/add_fingerprint`, with `type`, `data` (JSON string), `finger_day` (`yyyy-MM-dd HH:mm:ss`), an optional `note` (security report) and `files` (face image):

| Method | `type` | `data` |
|---|---|---|
| `addQRCodeFingerprint` | `fp_scan` | scanned QR payload |
| `addGPSFingerprint` | `fp_navigate` | `{lat, long}` |
| `addCustomGPSFingerprint` | `custom_fp_navigate` | custom location |
| `addBluetoothFingerprint` | `fp_bluetooth` | device id(s) |
| `addWifiFingerprint` | `fp_wifi` | SSID/BSSID |
| `addNFCFingerprint` | `fp_nfc` | tag id |

**How it works:**
- **Online** (`ConnectionsService.isOnline()`): it sends right away. When `AppConstants.fingerprintSendNoteReportToApi` is on, it merges a security `note`, built from `_checkFakeGPS` (mock-location detection) and `LocationService.compareGPSWithNetworkLocation`, into the request.
- **Offline**: it adds `_verifyGPSTimestampOffline` (flags a device clock that differs from GPS time by more than about 2 minutes), saves the body with `DBHiveService.saveFingerprint`, and mirrors it (with the image as base64) to SharedPreferences `fingerPrints` and `AppConstants.fingerPrints` for display. The offline screen later uploads the batch through `rm_fingerprint/v1/add_fingerprints` (`FingerprintViewModel.addFingerPrints`).
- **History**: `getFingerprints` (`rm_fingerprint/v1/get_fingerprints`, with date range and employee filters) and `getFingerprint(id)`.
- The security behaviour is controlled by static flags in `AppConstants` (`fingerprintBlockOnFakeGps`, `fingerprintVerifyGpsNetworkComparison`, `fingerprintVerifyGpsTimestampOffline`, …). `AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks()` overrides them from `USG`.

## `requests.services.dart`: `RequestsServices`

Employee HR requests (leave, permissions, …), backed by the `emp_requests` package.

- The main entry point is `getRequestsByTypeDependsOnUserPrivileges(reqType:, page:)`.
- `GetRequestsTypes { mine, myTeam, otherDepartment, allCompany }` maps to the query `type=my_requests|team_requests|other_departments|...` on `emp_requests/v1/my_requests`.
- Status strings: `waiting`, `waiting_cancel`, `waiting_seen`, `seen`, `approved`, `canceled`, `refused`.
- Endpoints: `my_requests`, `my_request`, `create_new_request` (`empAddRequest`, JSON or form data with attachments), `action` (manager approve/refuse), `ask_remember`, `ask_ignore`, `balance/<empId>`, and `emp_reports/v1/summary_report`.

## `crud_operation.service.dart`

A generic list/show/create/update/delete helper for RightMind entity endpoints (`/<slug>/entities-operations`).
