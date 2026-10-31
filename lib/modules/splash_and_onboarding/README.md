# splash_and_onboarding

The app's startup orchestrator and the onboarding slides.

## Files
- `views/splash_screen.dart`: `SplashScreen`, the initial route `/:lang/splash-screen`. It shows the logo and runs `OnboardingViewModel.initializeSplashScreen`.
- `views/onboarding_screen.dart`: `OnBoardingScreen`, slides with next and skip.
- `view_models/splash_onboarding.viewmodel.dart`: `OnboardingViewModel`.
- `models/onboarding_model/onboarding.model.dart`.

## How the splash decides where to go (`initializeSplashScreen`)
1. `_initializeAppServices`: precaches the logo, runs `AppConfigService.init()`, sets `apiURL = AppConstants.baseUrl` and stores the app name, version, build and package.
2. `DeviceInformationService.initializeAndSetDeviceInfo`. Domain selection on first launch (`DomainSelectionService.checkAndSelectDomain`) is started from `splash_screen.dart`, not from the view model.
3. Loads settings through `start_app` (`AppSettingsService.initializeGeneralSettings`). See `general_services/README.md`.
4. If the app was opened from a notification (`initialNotification` in the cache), routes it through `GeneralListener.linksAction`.
5. **Logged in**: inits `PushNotificationService` and goes to home.
6. **Not logged in**: reads `USG.features` (the onboarding slides) and `features.date`. Onboarding is shown if `dateWatchScreen` is empty or older than that date, and only if the slides are valid (`_isOnboardingItemValid`). Slide images are precached (`_precacheImages`). Otherwise it goes to login.
7. It never navigates while the offline screen is showing. On error it falls back to home (if logged in) or login.

`OnBoardingScreen` writes `dateWatchScreen` = now, so the slides stay hidden until the server's `features.date` is newer. `goNext` and `skip` then go to login, or to home when a session exists.
