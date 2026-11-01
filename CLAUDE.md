# CLAUDE.md

This file guides Claude Code (claude.ai/code) when it works in this repository.

## Overview

Team Mind is a Flutter app for Android, iOS and the web. Employees and managers of companies on the RightMind HR platform use it for attendance, requests and approvals, payroll, tasks, reports and notifications. The backend is the RightMind Laravel multi-tenant platform (separate repo). Every company is its own domain.

- Dart package name: `app_test`. Always import as `package:app_test/...`.
- App id / method-channel prefix: `com.rightminddev.rmemp`.
- Read the `README.md` in the folder you are about to change. Every folder under `lib/core/` and `lib/features/` has one.

## Commands

```bash
flutter pub get
flutter run [-d chrome]
flutter analyze            # flutter_lints 3.0.0; use_build_context_synchronously is ignored
flutter build apk|ios|web
```

There is no `test/` directory and there are no automated tests.

## Architecture essentials

- **Startup** (`lib/main.dart`): global error handlers → EasyLocalization → `CacheHelper.init()` (SharedPreferences) → fingerprint security levels loaded from cache → FCM token service → local notifications → Firebase → Hive → `AppConfigService.init()` → `MultiProvider` with the app-wide controllers → `MyApp` (`lib/app.dart`).
- **Router** (`lib/core/routing/app_router.dart`): one big `go_router` config. Paths start with `/:lang`. Navigate by name with `context.goNamed(AppRoutes.x.name, pathParameters: {'lang': context.locale.languageCode})`. The global `redirect` sends everything to the splash screen until `AppConfigService.hasCompletedSplash` is true. Logged-out users only reach a visitor allow-list (login, onboarding, free services). The main tabs (home, requests, fingerprint, notifications, more) live inside a `ShellRoute` that wraps `MainLayoutScreen`.
- **Splash decides where to go** (`features/splash_and_onboarding`): connectivity check → domain selection → device info → `start_app` → route to home, onboarding, login, the free-services home (role `personal`), the no-access screen, or the offline screen.
- **Networking**: two layers that coexist.
  - `DioHelper` (`core/services/backend_services/api_service/dio_api_service/dio.dart`): static Dio with the base URL, `lang`/`X-App-Type` headers, logging, an interceptor for `INSTANCE_SUSPENDED` / `LICENCE_ACCESS_DENIED`, and a retry on connection reset. Many feature repos call `DioHelper.getData/postData/...` with paths like `/emp_requests/v1/...`.
  - `DioApiService` (implements `BackEndServicesInterface`): returns `OperationResult<T>` and handles 401 by clearing auth. URLs usually come from `EndpointServices.getApiEndpoint(EndpointsNames.x)` in `get_endpoint_service.dart`.
  - The base URL is `AppConstants.baseUrl` = `<custom_domain or https://emplive.r-m.dev>/api`. Never hardcode a host.
- **Settings and feature flags**: `AppSettingsService.initializeGeneralSettings` posts to `rm_users/v1/start_app` and caches the JSON in SharedPreferences under `USG` (general), `US1` (user) and `US2` (user2). The `gDate`/`s1Date`/`s2Date` timestamps make updates incremental. Much of the UI reads these caches directly with `json.decode(CacheHelper.getString("US1"))`: `is_manager_in`, `role`, `has_employee_profile`, request types, fingerprint method, popups, colors. `CacheConsts` and `UserSettingConst` keep decoded copies.
- **State**: `provider` + `ChangeNotifier` throughout. App-wide providers are registered in `main.dart`. Feature-local ones are created in the router or the screen. `approvables_details` is the only Cubit (`flutter_bloc`).
- **Attendance** is the core feature. `MainAppFabService.getFingerprintActionMethodDependsOnFingerprintMethod` (`core/widgets/main_app_fab_widget/main_app_fab.service.dart`) runs the device security checks (`FingerprintSecurityRunner`) and then dispatches on the method: `fp_scan` QR, `fp_navigate` GPS, `fp_wifi`, `fp_bluetooth` or `fp_nfc`. The web always uses GPS. Optional face liveness and verification run on-device with ML Kit and `assets/models/facenet.tflite`. Each check level (mandatory, optional or disabled) comes from the server's fingerprint security checks. Offline punches are stored in SharedPreferences (`fingerPrints`) and uploaded later.
- **Approvals**: a generic approval-system UI (`features/approvables_details`) handles every approvable type through `/approval-system/v1/{type}/...`. Types include `employee_requests`, `overtime`, `salary_advance`, `employee_expense_claims` and `shift_change_requests`.

## Conventions

- Strings: add a key to `assets/json/lang/en.json` and `ar.json` and a constant in `core/constants/app_strings.dart`, then use `AppStrings.key.tr()`. The UI must work RTL.
- Colors and sizes: use `AppColors`, `AppSizes` and the `AppThemeService` theme. Branding colors and logos can come from server settings (`DynamicAppConfigService`).
- Alerts and toasts: use `AlertsService` (`core/services/alert_service`).
- Reuse widgets in `core/widgets` (buttons, text fields, bottom sheets, searchable dropdowns, filters, comments, approvable cards) before you build new ones.
- Web-only and mobile-only code is split with conditional imports and stubs (`*_stub.dart`, `*_web_impl.dart`, `PlatformIs`). Keep that pattern when you add platform APIs.
- Code comments and debug logs are often in Arabic. That is expected.
- `features/tracking` runs on dummy data (`TrackingDummyData`) and has no backend calls yet.
