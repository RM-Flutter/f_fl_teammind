# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor, …) and humans working in this repository.

## Overview

**TeamMind** (Dart package `rmemp`, app id `com.rightminddev.rmemp`) is the employee mobile/web app of the **RightMind** platform. It is a Flutter client for the RightMind Laravel backend (`/var/www/html/rightmind`, packages under `packages/rm/*`). Main features: attendance ("fingerprint") with face verification and anti-spoofing, HR requests and approvals, payroll, rewards and penalties, evaluations, tasks, complaints, notifications, profiles, and a set of "free services" (CV builder, smart business card, vacation calculator…) that work without logging in.

- Flutter, Dart SDK `^3.11`. Targets: Android, iOS, web (desktop folders exist but are not maintained).
- Languages: Arabic + English (RTL aware). Most inline comments are in Arabic.
- **Each module and shared layer has a `README.md`. Read it before you work there** (see [Docs index](#docs-index)).

## Commands

```bash
flutter pub get
flutter run                       # device / emulator
flutter run -d chrome             # web
flutter build apk --release | flutter build appbundle | flutter build ios | flutter build web
flutter analyze                   # lints: flutter_lints (use_build_context_synchronously is ignored)
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

There is no `test/` directory, so there are no automated tests.

## Architecture

### Layers in `lib/`

| Folder | Role |
|---|---|
| `main.dart` / `app.dart` | Bootstrap: Firebase, EasyLocalization, SharedPreferences (`CacheHelper`), Hive, global `MultiProvider`, `MaterialApp.router`. |
| `routing/` | `go_router` config (`app_router.dart`): the `AppRoutes` enum, the auth/visitor/package redirect guard, the bottom-nav `ShellRoute`. |
| `modules/<feature>/` | Feature modules, usually split into `models/ services/ view_models/ views/ (widgets/)`. |
| `services/` | Cross-module API services (fingerprint, requests, generic CRUD). |
| `controller/` | Shared `ChangeNotifier` controllers used by several modules (requests and complaints, tasks, filters, devices, evaluations). |
| `general_services/` | App infrastructure: API clients, config and settings, domain selection, package gating, notifications, location, device info, alerts, theming, error reporting. |
| `common_modules_widgets/` | Shared widgets, including the **punch-in FAB** (`main_app_fab_widget/`, the attendance and face-recognition engine) and comments. |
| `models/` | Shared models + `models/settings/` (general, user and user2 settings). |
| `constants/` | `AppConstants` (base URL, fingerprint security flags), `AppStrings` (translation keys), `AppColors`, `AppImages`, `AppSizes`, `GeneralListener` (deep links). |
| `utils/` | Generic UI helpers: base page, shimmer, dropdowns, animated FAB, error handling. |
| `platform/` | `PlatformIs` (web/android/ios checks). |

### State management

`provider` + `ChangeNotifier` view models. Global providers are registered in `main.dart` (`AppConfigService`, `MainScreenViewModel`, `HomeViewModel`, `BlogProviderModel`, `DeviceControllerProvider`, `CommentProvider`, `NotificationProviderModel`, `RequestController`, `ConnectionService`). Screen-level view models are created with `ChangeNotifierProvider(create: …)` inside the screen. `flutter_bloc` is a dependency but it is not the main pattern. Do not introduce it.

### Backend and API calls

- **Base URL**: `AppConstants.baseUrl` = `<base>/api`. `base` is the tenant domain the user picked (`CacheHelper "custom_domain"`), otherwise `_defaultBase` (`https://lab.r-m.dev`). This is the client side of RightMind multi-tenancy: each company has its own domain. See `general_services/domain_selection.service.dart`.
- **Two styles of API calls exist. Use the one the surrounding code uses:**
  1. `DioApiService().get/post/postWithFormData…<T>(url, …, dataKey:, context:)` returns `OperationResult<T>` (`success`, `data`, `message`, `errors`). The URL comes from the registry `EndpointServices.getApiEndpoint(EndpointsNames.x).url` (`general_services/backend_services/get_endpoint.service.dart`). This client handles 401 (clears the token and goes to login), token refresh from responses, and CORS errors on web.
  2. `DioHelper.getData/postData/putData/deleteData/postFormData(url: "/emp_requests/v1/...", query:, data:, context:)` uses a **relative path** on the Dio `baseUrl` and returns a raw `Response`. It is used by `controller/*` and many newer view models.
- Every request sends `Authorization: Bearer <token>`, a `lang` header and `device-unique-id`.
- Backend API prefixes map to RightMind packages: `rm_users`, `rm_general`, `rm_fingerprint`, `emp_requests`, `emp_reports`, `rm_payroll`, `rm_evaluation`, `rm_page`, `rm_postcontrol`, `rm_taxonomy`, `rm_social`, `rm_pointsys`, `rm_notification`, `rm_ecommarce`. Generic entity CRUD uses `/<slug>/entities-operations[/<id>/comments]` (the RightMind `EntitiesOperationsHelper`).
- `general_services/backend_services/api_service/http_api_service/` is an older `http`-based client. Do not use it for new code.

### Startup and settings flow

1. `main()`: Firebase, localization, prefs, Hive, records the app-open time, then `runApp`.
2. The router starts at `/:lang/splash-screen`. `OnboardingViewModel.initializeSplashScreen` initializes `AppConfigService` (token and login state in SharedPreferences), device info, FCM and domain selection, then calls **`start_app`** (`AppSettingsService.initializeGeneralSettings`).
3. `start_app` returns three settings blobs, cached as JSON strings in SharedPreferences:
   - `USG`: general and company settings (packages, features/onboarding, colors, logo, fingerprint security checks…)
   - `US1`: user settings (profile, birth date, permissions…)
   - `US2`: user2 settings (balances / request types, …)
   Each blob carries a `last_update_date` (`gDate`, `s1Date`, `s2Date`) so that the server only sends changes. Read them through `UserSettingConst.userSettings/userSettings2`, `GeneralSettingsModel`, `DynamicAppConfigService` (branding) and `UsgPackagesService`.
4. Splash then goes to onboarding (when `USG.features` has slides newer than `dateWatchScreen`), login, or home.

### Package gating

`UsgPackagesService.isPackageActive(slug)` reads `USG.packages[{slug,is_active}]`. The slugs are `emp-requests`, `fingerprint-sys`, `emp-payroll`, `emp-evaluation` and `emp-reports`. A missing package means active. The router redirect sends disabled package routes back to home, and the nav bar hides them. Gate any new package-specific UI the same way. `_testingOverrides` in that file lets you force a package on or off locally. Do not commit it enabled.

### Routing rules

- Every path starts with `/:lang/…`. Navigate with `context.goNamed(AppRoutes.x.name, pathParameters: {'lang': context.locale.languageCode, …})`.
- To add a screen: add a value to the `AppRoutes` enum, add a `GoRoute` (inside the `ShellRoute` if it should show the bottom nav), and add a path fragment to `allowedForVisitor` if logged-out users may open it.
- The bottom nav (`NavbarPages`: home, requests, fingerprint, notifications ("page"), more) is derived from the current path in `getNavbarPage`.
- Push-notification and server links are resolved by `GeneralListener.linksAction`: `rm_browser:<url>` opens an external browser, `rm_webview:<url>` opens the in-app webview, and any other value is mapped through `assets/json/routes.json` (backend route → frontend route).

### Localization and UI

- Keys live in `constants/app_strings.dart` (`AppStrings.x.tr()`), with translations in `assets/json/lang/{en,ar}.json`. Add a new string to all three.
- Colors: `AppColors`, which can be overridden by the server through `DynamicAppConfigService` (colors and logo from `USG`). Sizes: `AppSizes`. Fonts: Poppins (en), Montserrat-Arabic (ar).
- Alerts and toasts: `general_services/alert_service/alerts.service.dart` (`AlertsService`).

### Native code

`MethodChannel('com.rightminddev.rmemp/secure')` is implemented in `android/.../MainActivity.kt` and `ios/Runner/AppDelegate.swift`. Its methods are `enableSecureFlag`/`disableSecureFlag` (screenshot protection), `isDeveloperModeEnabled`, `isDeviceRooted`, `getAndroidId`, `isAppBatteryOptimized` and `openDataUsageSettings`. Every method needs both an Android and an iOS implementation.

### Web specifics

There are conditional imports and stubs for web, for example `*_stub.dart`, `dart_html_stub.dart`, `conditional_imports/` and the TFLite stub. Face recognition is not supported on web. When you use a `dart:io` or mobile-only plugin, guard it with `kIsWeb`/`PlatformIs` and keep the stub pattern.

### Error reporting

`sentry_flutter` (`general_services/sentry_service.dart`) and `TelegramErrorService`. The router calls `TelegramErrorService.setCurrentScreen` on navigation.

## Conventions

- Match the existing file style: `*.viewmodel.dart`, `*.service.dart`, `*.widget.dart`, `*.model.dart`, and feature folders under `modules/`.
- Services are `abstract class XService { static Future<OperationResult<…>> … }`. View models extend `ChangeNotifier` and expose `isLoading`-style flags.
- Pass a `BuildContext` to API calls, because both clients read `AppConfigService` from it.
- Keep backend field names as the backend sends them (snake_case JSON). Models have hand-written `fromJson`.
- Do not hard-code the domain. Always build URLs from `AppConstants.baseUrl` or relative `DioHelper` paths.

## Docs index

| Area | Doc |
|---|---|
| Infrastructure services | [lib/general_services/README.md](lib/general_services/README.md) |
| Cross-module API services | [lib/services/README.md](lib/services/README.md) |
| Shared controllers | [lib/controller/README.md](lib/controller/README.md) |
| Shared widgets + punch-in engine | [lib/common_modules_widgets/README.md](lib/common_modules_widgets/README.md) |
| Authentication | [lib/modules/authentication/README.md](lib/modules/authentication/README.md) |
| Splash and onboarding | [lib/modules/splash_and_onboarding/README.md](lib/modules/splash_and_onboarding/README.md) |
| Main screen (bottom nav shell) | [lib/modules/main_screen/README.md](lib/modules/main_screen/README.md) |
| Home | [lib/modules/home/README.md](lib/modules/home/README.md) |
| Fingerprint (attendance) | [lib/modules/fingerprint/README.md](lib/modules/fingerprint/README.md) |
| Offline | [lib/modules/offline/README.md](lib/modules/offline/README.md) |
| Requests | [lib/modules/requests/README.md](lib/modules/requests/README.md) |
| Complaints | [lib/modules/complain_screen/README.md](lib/modules/complain_screen/README.md) |
| Tasks | [lib/modules/tasks/README.md](lib/modules/tasks/README.md) |
| Payrolls | [lib/modules/payrolls/README.md](lib/modules/payrolls/README.md) |
| Rewards and penalties | [lib/modules/rewards_and_penalties/README.md](lib/modules/rewards_and_penalties/README.md) |
| Evaluation | [lib/modules/evaluation/README.md](lib/modules/evaluation/README.md) |
| Employee profiles (directory) | [lib/modules/profiles/README.md](lib/modules/profiles/README.md) |
| Personal profile | [lib/modules/personal_profile/README.md](lib/modules/personal_profile/README.md) |
| General (company structure) | [lib/modules/general/README.md](lib/modules/general/README.md) |
| More (settings, notifications, blog, pages) | [lib/modules/more/README.md](lib/modules/more/README.md) |
| Generic pages | [lib/modules/pages/README.md](lib/modules/pages/README.md) |
| Free services (visitor) | [lib/modules/free_services/README.md](lib/modules/free_services/README.md) |
