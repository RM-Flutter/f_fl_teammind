# lib/core/routing

All navigation uses `go_router`.

| File | Purpose |
|---|---|
| `app_router.dart` | `AppRoutes` enum (one value per named route), `rootNavigatorKey`, and `goRouter(context)`, which builds the full route tree (~100 `GoRoute`s) |
| `app_router_transitions.dart` | Shared page transition builders |
| `not_found/` | `NotFoundScreen` and an empty placeholder used by `errorBuilder` |

## How it works

- **Language prefix**: every path is `/:lang/...`. `redirect` reads `lang` and calls `context.setLocale`. Always pass `pathParameters: {'lang': context.locale.languageCode}` when you navigate.
- **Initial location**: `/<lang>/splash-screen`.
- **Redirect rules**, in order:
  1. The splash screen is never redirected.
  2. Until `AppConfigService.hasCompletedSplash` is true, any other route goes to the splash screen (offline routes are exempt).
  3. A logged-in user who opens login goes to the splash screen, or to `webviewMainData` when an `update_url` is cached (a forced profile update).
  4. A logged-out user can only open the visitor allow-list: splash, offline, no-access, onboarding, login, free services, CV, smart card, vacation calculator, personality test, about. Anything else goes to `/login-screen`.
- **Shell**: the main tabs are children of a `ShellRoute` that renders `MainLayoutScreen` (bottom nav and the fingerprint FAB). `getNavbarPage` maps the current path to the highlighted tab. Detail screens are pushed on `rootNavigatorKey` above the shell.
- **Route extras**: complex arguments go through `state.extra` (often a `Map<String, dynamic>`). Ids and types go in path parameters, for example `approvableDetails` takes `:type/:id`.
- `refreshListenable` is empty on purpose. Connectivity changes are handled by an overlay, not by redirects.

## Adding a screen

1. Add a value to `AppRoutes`.
2. Add a `GoRoute(name: AppRoutes.x.name, path: 'x', builder: ...)` under the right parent (inside the shell if the bottom bar should stay visible).
3. If logged-out users must reach it, add its path segment to `allowedForVisitor`.
4. If a backend deep link or notification should open it, map it in `assets/json/routes.json`.
