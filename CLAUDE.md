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

## Project structure rules (where code goes)

Follow the existing structure as it is. Do not reorganize folders, rename existing ones or invent new top-level folders. Before adding code, read the target folder's `README.md` and copy what its neighbours do.

**`lib/core/`: shared, feature-agnostic code. Core must never import from `lib/features/`** (the router and `main.dart` providers are the only exceptions).

| What | Where |
|---|---|
| Sizes, gaps, Figma dimensions | `core/constants/app_sizes.dart` (`AppSizes`) |
| Colors (incl. server-driven branding) | `core/constants/app_colors.dart` (`AppColors`, via `DynamicAppConfigService`) |
| Translation keys | `core/constants/app_strings.dart` + `assets/json/lang/en.json` and `ar.json` (always both) |
| Asset paths, cache keys, other constants | `core/constants/app_images.dart`, `cache_constants.dart`, `app_constants.dart` |
| Theme (inputs, cards, app bar, text) | `core/services/app_theme_service.dart` |
| Text styles | `core/utils/app_styles.dart` |
| Screen-size checks | `core/services/layout_service.dart` (`LayoutService.isPhoneLayout`, `isMobile`, ...) |
| Models used by more than one feature | `core/models/` (settings models in `core/models/settings/`) |
| App-wide services (network, settings, location, notifications, security) | `core/services/` (one `abstract class` with static methods, or a `ChangeNotifier` if it holds state) |
| API endpoints with names | `EndpointsNames` in `core/models/endpoint_model.dart` + a case in `core/services/backend_services/get_endpoint_service.dart` |
| Reusable widgets | `core/widgets/` (one widget per file; a folder when it has sub-parts, e.g. `comments/`) |
| Low-level UI helpers (scaffold, dropdown, shimmer) | `core/utils/` |
| Routes | `AppRoutes` enum + `GoRoute` in `core/routing/app_router.dart` |

**Styling rule:** never create a new file for styling or sizes. New design values become tokens in `AppSizes` / `AppColors` / `AppThemeService` / `AppStyles`, so they are shared across the app. Prefer changing the theme over per-widget overrides.

**`lib/features/<feature>/`: one folder per business feature, `snake_case`.** New code uses this layout (the dominant one in the repo):

```
<feature>/
  controllers/        ChangeNotifier view models: <name>_controller.dart
  data/
    models/           <name>_model.dart   (fromJson / toJson)
    repos/            <name>_repo.dart    (API calls; abstract class with static methods)
  views/
    <name>_screen.dart
    widgets/          <name>_widget.dart  (pieces used only by this feature)
  shared/             models/widgets reused by several sub-features of this feature
```

- **Big features** are split into sub-feature folders, each with the same layout inside, for example `requests/add`, `requests/details`, `payrolls/payroll_list`, `authentication/login`. Add new screens to an existing sub-feature, or create a new sub-feature folder next to them.
- **Existing features keep their own names.** Some use `controller/`, `repo/`, `services/`, `models/` at the root, or `data/remote_data/`. When editing one, match that feature's existing names; don't rename folders to the new layout.
- **The `more/` tab** holds small screens as sub-folders (`more/<screen>/`). A new small "More" screen goes there. Anything with its own domain logic gets its own feature folder.
- **Repos call the API** through `DioHelper` (relative path, e.g. `/emp_requests/v1/task`) or `DioApiService` + `EndpointServices`. Never hardcode a host; the base URL comes from `AppConstants.baseUrl`.
- **Providers:**
  - App-wide controllers (needed across screens or by notifications) are registered in `main.dart`'s `MultiProvider`.
  - Screen-only controllers are created with `ChangeNotifierProvider` in the screen or its `GoRoute`.
- **Cross-feature imports:** importing another feature's models or widgets is allowed but keep it to a minimum. If two features need the same thing, move it to `core/`.
- **Files and classes:**
  - Files are `snake_case`, with suffixes `_screen`, `_controller`, `_widget`, `_model`, `_repo`.
  - Classes are `PascalCase`: `XScreen`, `XController` (older code also uses `XViewModel` / `XProvider`), `XModel`, `XRepo`.
- **Platform-specific code** uses conditional imports with `*_stub.dart` / `*_web_impl.dart` next to the main file, plus `PlatformIs` checks.
- **Docs:**
  - When you add or change a feature or a core folder, update that folder's `README.md`.
  - A new feature folder gets its own `README.md` and a row in `lib/features/README.md`.

## Conventions

- Strings: add a key to `assets/json/lang/en.json` and `ar.json` and a constant in `core/constants/app_strings.dart`, then use `AppStrings.key.tr()`. The UI must work RTL.
- Colors and sizes: use `AppColors`, `AppSizes` and the `AppThemeService` theme. Branding colors and logos can come from server settings (`DynamicAppConfigService`).
- Alerts and toasts: use `AlertsService` (`core/services/alert_service`).
- Reuse widgets in `core/widgets` (buttons, text fields, bottom sheets, searchable dropdowns, filters, comments, approvable cards) before you build new ones.
- Web-only and mobile-only code is split with conditional imports and stubs (`*_stub.dart`, `*_web_impl.dart`, `PlatformIs`). Keep that pattern when you add platform APIs.
- Code comments and debug logs are often in Arabic. That is expected.
- `features/tracking` runs on dummy data (`TrackingDummyData`) and has no backend calls yet.
