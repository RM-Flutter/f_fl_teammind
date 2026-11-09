# lib/core/services

App-level services. Most are `abstract class` with static methods. `AppConfigService` and `ConnectionService` are `ChangeNotifier`s provided in `main.dart`.

## Config, settings and tenant

| File | What it does / how |
|---|---|
| `app_config_service.dart` | `AppConfigService` (ChangeNotifier). It wraps SharedPreferences for auth and app state: `token`, `isLogin`, `language`, refresh-token data, device info, app name and version, and the stored settings by `SettingsType`. Key members: `setAuthenticationStatusWithToken(...)` (login), `resetConfig()` (logout, which keeps `dateWatchScreen`), and `hasCompletedSplash` (read by the router). |
| `settings_service.dart` | `AppSettingsService`. `initializeGeneralSettings(settingType: SettingsType.startupSettings)` posts to `rm_users/v1/start_app`. The body carries the `needed` blocks, the `last_update_date_*` stamps, the token, the device id, and the FCM token when it changed. The response is stored as `USG`/`US1`/`US2`. A block returned with `status: false` means "unchanged", so the cached copy stays. Other methods refresh only the user settings, look up the request rules and titles per screen, and detect the country from the IP. |
| `domain_selection_service.dart` | Tenant domain picker. The file contains a commented-out older version; the active class is the second one. `checkAndSelectDomain` does the following: if `domain_selected` is already set it does nothing; otherwise it shows a dialog, cleans the input to a bare domain, validates it by calling `start_app` on it, saves `custom_domain` plus a `domains_list` history, sets `from_domain_selection` so the FCM token is re-sent, and re-initialises `DioHelper`. `resetDomainSelection()` is used from the login screen. |
| `dynamic_app_config_service.dart` | Reads branding (logo, login background, colors, teammind profile) from the cached `USG` and memoises it. Call `clearCache()` after new settings arrive. |
| `app_theme_service.dart` | Builds the light/dark `ThemeData` (fonts depend on language: Poppins or Cairo/Montserrat-Arabic). |
| `localization_service.dart` | Language helpers on top of easy_localization |
| `update_app.dart` | Shows the store update prompt when settings require a newer version |

## Networking

See [backend_services/README.md](backend_services/README.md). `requests_services.dart` maps request status and type strings and enums to labels and icons for request lists. `crud_operation.dart` (`CrudOperationService`) wraps the backend's generic entity endpoints (`/{slug}/entities-operations`), which blogs, notifications and comments use.

## Connectivity and offline

| File | What it does / how |
|---|---|
| `internet_check.dart` | `ConnectionService` (ChangeNotifier). It listens to `connectivity_plus`, confirms that the internet really works (`_hasRealInternet`), and debounces changes. When the connection drops it shows the overlay. When it comes back it hides the overlay and calls `onConnectionRestored`, which the splash screen uses to resume. It does nothing while the user is on an offline screen. |
| `offline_overlay_service.dart` | Shows or hides the global "you are offline" overlay. It can be hidden temporarily. |
| `connections_service.dart` | Older connectivity helper |
| `db_hive_service.dart` | Hive storage for saved fingerprints (alternative to SharedPreferences) |

## Attendance and fingerprint security

| File | What it does / how |
|---|---|
| `fingerprint_service.dart` | API side of punching. It has `addQRCodeFingerprint`, `addGPSFingerprint`, `addCustomGPSFingerprint`, `addBluetoothFingerprint`, `addWifiFingerprint` and `addNFCFingerprint`, which post to `rm_fingerprint/v1/add_fingerprint(s)`, and `getFingerprint(s)`. A failed or offline punch is saved to SharedPreferences `fingerPrints`. `uploadFingerprintsInOnlineMood` uploads that queue. Fake-GPS and offline GPS-timestamp results are merged into the note report. |
| `fingerprint_security_runner.dart` | `FingerprintSecurityRunner.runAllChecks(...)` runs every check in order (developer mode, root/jailbreak via the `com.rightminddev.rmemp/secure` method channel, fake GPS, VPN, time drift, GPS vs network location, offline GPS timestamp) at the level set in `AppConstants`. It returns a `FingerprintSecurityResult`: either blocked with the failing mandatory key, or allowed with the optional failures. |
| `location_service.dart` | Permissions, current position and mock-location detection (geolocator / location) |
| `vpn_detection_service.dart`, `time_drift_service.dart` | VPN detection and device clock vs server time (default tolerance 60 s) |
| `device_info_service.dart`, `device_mac_address_service.dart` | `DeviceInformationService.initializeAndSetDeviceInfo` builds a stable device unique id and stores it in `AppConfigService.deviceInformation`. It is sent with auth and fingerprint calls. |

The user-facing punch flow (method dispatch, face liveness and verification) lives in `core/widgets/main_app_fab_widget/` and is documented there.

## Notifications

| File | What it does / how |
|---|---|
| `notification_service.dart` | `NotificationService.init(context)`, called from `app.dart`. It requests permission, creates the local-notification channels, shows foreground FCM messages as local notifications, and handles taps from the background or terminated state (`onMessageOpenedApp`, `getInitialMessage`). |
| `fcm_token.service.dart` | Gets the FCM token at app start with retries, listens to `onTokenRefresh`, and caches `fcm_token`. `start_app` sends it when it differs from `last_sent_fcm_token`. |
| [notification_service/](notification_service/README.md) | Local notifications, check-in reminders, timeout dialogs |
| `general_listener.dart` | `GeneralListener`. It shows server-defined popups (`USG.popups`) for the current screen and resolves backend route keys to app routes through `assets/json/routes.json` (`analyzeRoute`). It also handles notification taps. |

## Logging and errors

| File | Purpose |
|---|---|
| `talker_service.dart` | `TalkerLoggerService`: app logger plus the Dio logger interceptor |
| `sentry_serivce.dart` | Sentry setup and capture helpers |
| `telegram_error_service.dart` | Sends critical errors to a Telegram channel |

## Other helpers

`alert_service/` (`AlertsService.success/error/...` and custom dialogs, see [alert_service/README.md](alert_service/README.md)), `bookmark_service.dart` (local bookmarks in SharedPreferences, shown on home), `birthday_checker_service.dart`, `date_service.dart`, `validation_service.dart`, `string_helpers_service.dart`, `image_file_picker_service.dart`, `pdf_service.dart`, `sound_recorder_service.dart` (voice comments), `url_launcher_service.dart`, `static_cache_service.dart` (in-memory key/value), `layout_service.dart` (`LayoutService.sizeClassOf`: compact < 600, medium < 1024, expanded; also `contentMaxWidth` and `listColumns`. Decide layout from the width only), `restart_app.dart`, `app_info_service.dart`, and the web/io stubs `dart_html_stub.dart`, `dart_io_*.dart`, `universal_file.dart`.
