# main_layout

The shell around the main tabs.

- `views/main_layout_screen.dart`: `MainLayoutScreen` is the `ShellRoute` builder in `app_router.dart`. It renders the current tab, the bottom navigation bar and the centre `MainAppFabWidget` (the punch button, see `core/widgets/main_app_fab_widget`).
- `controllers/main_controller.dart`: `MainLayoutController` (app-wide provider). It keeps `currentPage` (`NavbarPages`: home, requests, fingerprint, page/notifications, more). `onItemTapped` navigates with `goNamed` to the matching route, and `getCurrentMainPage` returns the screen widget.

The router sets the highlighted tab from the URL (`getNavbarPage`), so deep links highlight the right tab.

## Window sizes

On expanded windows (width >= 1024: tablet landscape, desktop, web) the bottom bar is replaced by a side `NavigationRail` with the same tabs (`MainLayoutScreen`). Compact and medium keep the bottom bar. `app.dart` only scales `.w/.h/.sp` on phones (design size 375x812); on bigger windows they return the number as written.
