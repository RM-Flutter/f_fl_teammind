# Team Mind (Flutter)

Team Mind is the employee and manager app for the RightMind HR platform. It covers attendance (fingerprint/punch in by GPS, QR, Wi‑Fi, Bluetooth or NFC), leave and other requests, approvals, payroll, tasks, reports, notifications and a set of free services (CV builder, smart business card, vacation calculator). It runs on Android, iOS and the web from one codebase.

- Package name: `app_test` (imports look like `package:app_test/...`)
- App id: `com.rightminddev.rmemp`
- Backend: the RightMind Laravel platform (the `rightmind` repo). Each customer company is a separate tenant domain.

## Getting started

Requirements: Flutter stable with Dart `^3.5.2`. Android `minSdk` is 24.

```bash
flutter pub get
flutter run                 # pick a device
flutter run -d chrome       # web
flutter build apk --release
flutter build ios --release
flutter build web
```

Firebase is already configured: `lib/firebase_options.dart` and `firebase.json` for mobile, and inline options in `lib/main.dart` for the web. Sentry and Talker handle logging and monitoring.

### Which backend does the app talk to?

The base URL is decided at runtime, not at build time:

- On first launch the splash screen calls `DomainSelectionService.checkAndSelectDomain`. It asks the user for their company domain and checks it by calling `start_app`.
- A valid domain is saved in SharedPreferences under `custom_domain`.
- If nothing is saved, the app uses the default `https://emplive.r-m.dev` (`AppConstants._defaultBase`). All API calls go to `<base>/api`.
- The login screen can reset the domain choice.

## How the app is organised

```
lib/
  main.dart        startup: error handlers, localization, cache, Firebase, Hive, providers
  app.dart         MaterialApp.router, theme, ScreenUtil, Dio and push-notification init
  core/            shared infrastructure (networking, settings, routing, widgets, services)
  features/        one folder per business feature (home, requests, fingerprint, payrolls, ...)
assets/
  json/lang/       en.json / ar.json translations (easy_localization)
  json/routes.json maps backend route keys to app routes (deep links, notifications, popups)
  models/          facenet.tflite (on-device face verification)
  fonts, images, icons
```

Start with these docs:

- [lib/core/README.md](lib/core/README.md): app infrastructure and the startup flow
- [lib/features/README.md](lib/features/README.md): index of all features
- Each folder under `lib/core/` and `lib/features/` has its own `README.md` describing what it does and how.

## Key concepts in brief

- **State management**: mostly `provider` (`ChangeNotifier` controllers called `*Controller`, `*ViewModel` or `*Provider`). `approvables_details` uses `flutter_bloc` (a Cubit).
- **Routing**: `go_router`. Every path is prefixed with `/:lang` (`en` or `ar`). Routes are in `lib/core/routing/app_router.dart` (`AppRoutes` enum).
- **Settings-driven UI**: on startup the app calls `rm_users/v1/start_app`, which returns general settings (`USG`), user settings (`US1`) and user2 settings (`US2`). They are cached as JSON in SharedPreferences and decide which features, menus, request types, fingerprint methods, security checks and branding colors the user sees.
- **Offline attendance**: punches made without internet are stored locally and uploaded when the connection comes back.
- **Localization**: English and Arabic (RTL). Use `AppStrings.xxx.tr()`.

## Helper scripts at the repo root

These are one-off refactoring helpers. The app does not need them to build or run.

| Script | Purpose |
|---|---|
| `organize_services.sh`, `cleanup_services.sh`, `rename_script.sh`, `rename_widgets.sh` | Moves and renames under `lib/features/services` |
| `parse_router.py`, `parse_router2.py` | Read `app_router.dart` to list routes |
| `deduplicate_json.py` | Removes duplicate keys from `assets/json/lang/*.json` |
| `replace_overtime_logic.py` | One-off rewrite of the overtime controller |
| `update_versions.py` | Copies resolved versions from `pubspec.lock` into `pubspec.yaml` |

## External references

- API docs: https://rightmind.apidog.io/
- Product and spec docs are linked in `docs.txt`.
