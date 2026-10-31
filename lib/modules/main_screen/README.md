# main_screen

The shell with the bottom navigation bar that wraps every route inside the `ShellRoute` in `routing/app_router.dart`.

## Files
- `views/main_screen.dart`: `MainScreen(currentNavPage, child)`. Renders the routed `child`, the bottom nav and the punch-in FAB (`common_modules_widgets/main_app_fab_widget`).
- `views/widgets/general_bottom_navigation_bar.dart`, `custom_bottom_nav_item.widget.dart`: the nav bar UI.
- `view_models/main_viewmodel.dart`: `MainScreenViewModel` (global provider).

## How it works
- The router computes the active tab from the path with `getNavbarPage` (`NavbarPages`: `home`, `requests`, `fingerprint`, `page` (notifications), `more`).
- `getCurrentMainPage` maps a tab to a screen: `HomeScreen`, `RequestsScreen`, `FingerprintScreen`, `NotificationScreen`, `MoreScreen`.
- `onItemTapped` navigates with `goNamed`. Tabs for disabled packages (`UsgPackagesService.isRequestsActive` / `isFingerprintActive`) are hidden.
