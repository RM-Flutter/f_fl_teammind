# splash_and_onboarding

Decides where the app goes at launch and shows the onboarding slides.

| File | Role |
|---|---|
| `views/splash_screen.dart` | Runs the startup sequence (below) |
| `controller/splash_onboarding_controller.dart` | `OnboardingController`: `initializeSplashScreen`, onboarding slides from settings, `goNext`/`skip`, image precache, deep-link route matching (`analyzeRoute` with `assets/json/routes.json`) |
| `data/repo/splash_repo.dart` | Loads `routes.json` and clears the stored initial notification payload |
| `views/onboarding_screen.dart` | Slides from `USG.features.items`. When the API sends none, three local fallback images are used. |
| `views/no_access_screen.dart` | Shown when the user has no employee profile (`US1.has_employee_profile == false`) |
| `views/suspended_screen.dart` | `SuspendedScreen` for `INSTANCE_SUSPENDED` / `LICENCE_ACCESS_DENIED`. The Dio interceptor routes here. |

## Startup sequence (`SplashScreen`)

1. **Offline** (`ConnectionService` says no internet, also after a re-check):
   - try domain selection anyway
   - load device info and the cached `USG` (so the fingerprint security levels apply)
   - go to `offlineScreen`
   - `ConnectionService.onConnectionRestored` restarts the sequence once the connection is back
2. **Online**:
   - `DomainSelectionService.checkAndSelectDomain` (first run: ask for the company domain)
   - `DeviceInformationService.initializeAndSetDeviceInfo`
   - `HomeController.initializeHomeScreen`, which calls `start_app` and caches the settings
   - `OnboardingController.initializeSplashScreen`
3. **Routing decision** (`initializeSplashScreen`):
   - not logged in: show onboarding if there are slides and the `dateWatchScreen` cache is missing or older than `USG.features.date`; otherwise go to login
   - logged in: show onboarding (same date rule) or go to the main route. `role` contains `personal` → `freeServicesHome`. `has_employee_profile == false` → `noAccess`. Otherwise → `home`.
   - `AppConfigService.hasCompletedSplash` is set, which unlocks the router redirect
