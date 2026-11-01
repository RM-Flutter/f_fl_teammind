# lib/core

This folder holds the infrastructure that every feature shares: networking, settings and cache, routing, theming, platform helpers, reusable widgets and the attendance (fingerprint) engine. Feature code lives in `lib/features/`. The rule is that `core` never imports from a feature. A few exceptions exist, for example the router and some providers, because they have to wire screens together.

| Folder | What it holds |
|---|---|
| [constants/](constants/README.md) | Colors, sizes, images, strings (translation keys), cache keys, fingerprint security levels, the base URL |
| [models/](models/README.md) | Shared data models: settings, `OperationResult`, endpoints, notifications, requests |
| [routing/](routing/README.md) | The `go_router` config, the `AppRoutes` enum, transitions and the not-found screen |
| [services/](services/README.md) | App services: config, settings, networking, connectivity, fingerprint security, location, device info, notifications, logging |
| [utils/](utils/README.md) | Low-level UI helpers: base scaffold, custom dropdown, expandable FAB, shimmer, global error handler, styles |
| [widgets/](widgets/README.md) | Reusable widgets: buttons, inputs, bottom sheets, comments, bookmarks, approvable cards and the main fingerprint FAB |
| `platform/` | `PlatformIs` plus `universal_platform_{vm,web}.dart`, a platform check that is safe on the web (do not use `dart:io` `Platform` directly) |
| `helpers/` | `package_helper.dart`: reads package info |

## Startup flow (how the core pieces fit together)

1. **`main.dart`** registers the global error handlers (`utils/error_handling`). It then initialises EasyLocalization, `CacheHelper` (SharedPreferences), the fingerprint security levels (`AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks`), FCM tokens, local notifications, Firebase, Hive and `AppConfigService`. Finally it mounts a `MultiProvider` with the app-wide controllers.
2. **`app.dart`** initialises `DioHelper` and `NotificationService`, builds the `GoRouter`, and renders `MaterialApp.router` inside `ScreenUtilInit` (design size 375×812) with the theme from `AppThemeService`.
3. The **router** starts at `/:lang/splash-screen`. Its `redirect` keeps the user on the splash screen until `AppConfigService.hasCompletedSplash` is true.
4. The **splash screen** (`features/splash_and_onboarding`) does the following:
   - checks connectivity (`ConnectionService`)
   - asks for or validates the company domain (`DomainSelectionService`)
   - collects device info (`DeviceInformationService`)
   - calls `start_app` through `AppSettingsService.initializeGeneralSettings`, which caches `USG`, `US1` and `US2`
   - loads the home data, then navigates
5. While the app is running, `ConnectionService` shows or hides the offline overlay (`OfflineOverlayService`) and resumes initialisation when the connection comes back. `DioHelper`'s interceptor redirects to the suspended or licence-denied screen whenever the backend returns those error codes.

## Cached settings: the source of most UI decisions

| SharedPreferences key | Content | Written by |
|---|---|---|
| `USG` | General (company) settings: features, request types, holidays, popups, branding, fingerprint security checks | `AppSettingsService` |
| `US1` | User settings: roles, `is_manager_in`, `has_employee_profile`, employee data | `AppSettingsService` |
| `US2` | User2 settings: shifts and working hours (used by the check-in reminders) | `AppSettingsService` |
| `gDate` / `s1Date` / `s2Date` | `last_update_date` of each block, sent back so the server returns only changed blocks | `AppSettingsService` |
| `custom_domain` | Selected tenant base URL | `DomainSelectionService` |
| `token`, `is_login`, ... | Auth state | `AppConfigService` |
| `fingerPrints` | Offline punches waiting for upload | `FingerprintService` / `MainAppFabService` |
| `lang` | Current language, sent as the `lang` header | `app.dart`, language settings |
