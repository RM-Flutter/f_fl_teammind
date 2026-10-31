# general_services

App-wide infrastructure. Most of these are `abstract class` / static helpers. `AppConfigService` and `ConnectionService` are `ChangeNotifier`s, registered globally in `main.dart`.

## Backend clients: `backend_services/`

| File | What it does |
|---|---|
| `backend_services_interface.dart` | `BackEndServicesInterface`: the get/post/put/patch/delete/postWithFormData/postFile contract. Each method returns `OperationResult<T>`. |
| `api_service/dio_api_service/dio_api.service.dart` | `DioApiService`: the main implementation. `_handleResponse` maps status codes. On **401** it clears the token and login flag on `AppConfigService` and calls `goNamed(login)`. It detects CORS errors on web. It updates the token when a response carries a new `token`. `dataKey` picks the field from the JSON body, and `allData: true` returns the whole body. |
| `api_service/dio_api_service/dio.dart` | `DioHelper`: a static `Dio` with `baseUrl = AppConstants.baseUrl`, a `PrettyDioLogger` interceptor and a connection-reset retry interceptor. It provides `getData/postData/putData/patchData/deleteData/postFormData/downloadData*` with **relative URLs**, which return a raw `Response`. Every call adds the `Authorization`, `lang` and `device-unique-id` headers. `DioHelper.initail(context)` must run again after the domain changes, and `hardResetDio` rebuilds the client. |
| `api_service/dio_api_service/shared.dart` | `CacheHelper`: static wrapper over `SharedPreferences` (`getString/setString/getBool/deleteData/clear`). It is the app's key/value store. |
| `api_service_helpers.dart` | `ApiServiceHelpers.parseResponse`: turns the backend JSON (`status`, `message`, `data`, `errors`) into `OperationResult`. |
| `get_endpoint.service.dart` | `EndpointServices.getApiEndpoint(EndpointsNames.x)`: the URL registry. The enum is in `models/endpoint.model.dart`. |
| `api_service/http_api_service/` | Legacy `http` client. Do not use it in new code. |

## Config, settings and tenancy

| File | What it does |
|---|---|
| `app_config.service.dart` | `AppConfigService` (ChangeNotifier): persisted session state in SharedPreferences, covering `token`, `isLogin`, `language`, refresh token and expiry dates, device info, app name/version/build, and cached general/user/user2 settings. It provides `setAuthenticationStatusWithToken`, `clearToken`, `setIsLogin` and the logout confirmation. |
| `settings.service.dart` | `AppSettingsService`. `initializeGeneralSettings(settingType: startupSettings)` POSTs **`rm_users/v1/start_app`** with `needed: [general_settings,user_settings,user2_settings,check_auth]`, the last update dates, the FCM token (only when it changed) and `device_id`. It caches the results as `USG`/`US1`/`US2` JSON with dates `gDate`/`s1Date`/`s2Date`, stores `update_url`, and replaces the token if the server rotated it. `getUserSettingsAndUpdateTheStoredSettings` refreshes the same data later, for example on home. It also does IP to country lookup for phone fields. |
| `domain_selection.service.dart` | `DomainSelectionService.checkAndSelectDomain`: on first launch it asks for the company domain, normalizes it (strips scheme, `www.` and `webapp.`), checks it by calling `start_app` on that domain, saves it as `custom_domain` (with a list of saved domains) and re-inits `DioHelper`. An empty or cancelled entry falls back to the default domain. |
| `usg_packages.service.dart` | `UsgPackagesService`: package gating from `USG.packages` (`isRequestsActive`, `isFingerprintActive`, `isPayrollActive`, `isEvaluationActive`, `isReportsActive`). Call `clearCache()` after `USG` changes. |
| `dynamic_app_config.service.dart` | `DynamicAppConfigService`: server-driven branding (logo, login background, color map from the `USG` teammind profile). |
| `app_theme.service.dart`, `layout.service.dart`, `localization.service.dart` | Theme (light/dark from `AppColors`), responsive helpers and locale helpers. |
| `app_info.service.dart`, `device_info.service.dart`, `device_mac_address.service.dart` | Package info, device identity (`deviceUniqueId` is sent as the `device-unique-id` header and `device_id`), platform and OS info. |

## Notifications

| File | What it does |
|---|---|
| `fcm_token.service.dart` | `FcmTokenService`: gets and caches the FCM token (`fcm_token`). On web it asks for permission on the first user tap (see `app.dart`). |
| `notification_service.dart` | `NotificationService.init` plus the background handler. It shows local notifications and routes taps through `GeneralListener.linksAction`. |
| `notification_service/notification.service.dart` | `PushNotificationService`: foreground message handling after login. |
| `notification_service/timeout_message.service.dart` | Timed and scheduled message helpers. |
| `battery_optimization_prompt.service.dart` | Asks the user to exempt the app from Android battery optimization (native `isAppBatteryOptimized`). |

## Connectivity and offline

| File | What it does |
|---|---|
| `connections.service.dart` | `ConnectionsService.isOnline()` and the `ConnectionService` ChangeNotifier. |
| `offline_overlay.service.dart` | Shows or hides an offline overlay **instead of** redirecting routes. |
| `db_hive.service.dart` | `DBHiveService.saveFingerprint/clearSavedFingerprints`: the Hive store for punches captured offline. |
| `static_cache.service.dart` | `StaticCacheManager` for cached network images. |

## Device, security and media

| File | What it does |
|---|---|
| `location.service.dart` | GPS (`geolocator`/`location`) plus `compareGPSWithNetworkLocation`, used by the anti-fake-GPS checks. |
| `wifi_data.service.dart` | Current WiFi SSID/BSSID for WiFi punches. |
| `screen_auth_protection_service/` | `LocalAuthenticationService` (biometrics through `local_auth`) and `ScreenProtectionService` (biometric gate for sensitive screens). |
| `prevent_screenshot_screenrecording.service.dart` | Uses native `enableSecureFlag`/`disableSecureFlag`. |
| `image_file_picker.service.dart`, `pdf.service.dart`, `sound*.service.dart`, `url_launcher.service.dart` | Pickers, PDF generation and viewing, audio record and play, opening links. |

## UI and helpers

`alert_service/` (`AlertsService`: toasts, confirm dialogs, custom alerts), `popup_offers_view.dart` (server popups and offers), `birthday_checker.service.dart`, `bookmark.service.dart`, `date.service.dart`, `sorting.service.dart`, `string_helpers.service.dart`, `validation_service.dart`, `model_helpers.service.dart`, `print_large_data.service.dart`.

## Error reporting

`sentry_service.dart` (Sentry) and `telegram_error_service.dart` (sends errors to Telegram and tracks the current screen, which the router sets).

## Web stubs

`dart_html_stub.dart`, `dart_io_stub.dart`, `conditional_imports/` (`change_url_strategy.service.dart` gives path URLs on web) and `dio_adapter_reset_stub.dart`. Keep the conditional-import pattern when you add platform-specific code.
