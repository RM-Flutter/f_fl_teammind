# main_layout

The shell around the main tabs.

- `views/main_layout_screen.dart`: `MainLayoutScreen` is the `ShellRoute` builder in `app_router.dart`. It renders the current tab, the bottom navigation bar and the centre `MainAppFabWidget` (the punch button, see `core/widgets/main_app_fab_widget`).
- `controllers/main_controller.dart`: `MainLayoutController` (app-wide provider). It keeps `currentPage` (`NavbarPages`: home, requests, fingerprint, page/notifications, more). `onItemTapped` navigates with `goNamed` to the matching route, and `getCurrentMainPage` returns the screen widget.

The router sets the highlighted tab from the URL (`getNavbarPage`), so deep links highlight the right tab.
