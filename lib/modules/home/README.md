# home

The dashboard (`/:lang`).

## Files
- `views/home_screen.dart`: `HomeScreen`. It has an app bar (user, notifications icon) and a body of reorderable sections.
- `view_models/home.viewmodel.dart`: `HomeViewModel` (global provider).
- `models/home_widget_type.dart`: `HomeWidgetType` enum (`myRequests`, `myTeamRequests`, `otherDepartmentRequests`, `allCompanyRequests`, `notifications`). The user's order is cached, and `getDefaultOrder()` gives the default.
- `views/widgets/`:
  - `page_header_widgets/`: `HomeAppbarWidget`, `NotificationIcon`.
  - `page_body_widgets/`: `RequestsWidget`, `MyTasksList`, `ActionsList`, `NotificationsSection`.
  - `reorderable_widget_item.dart`, `bookmark_list_widget.dart` (saved bookmarks), `webview_offers.dart` (server offers popup), `loading/` (shimmers).
- `views/sample_api_screen.dart`, `views/items_api_screen.dart`: dev and demo screens for API calls (`AppRoutes.sampleApiScreen` / `itemsApiScreen`).
- `lib_code.txt`: a scratch file, not code.

## How it works
`initializeHomeScreen(context, need)`:
1. Calls `AppSettingsService.getUserSettingsAndUpdateTheStoredSettings(allData: true, need:)`, which refreshes `US1`/`US2` (and `USG` if needed).
2. Decodes `US1` into `UserSettingConst.userSettings` (`UserSettingsModel`) and `US2` into `userSettings2` (`UserSettings2Model`).
3. `_getAllUserRequests` loads page 1 of each request list through `RequestsServices.getRequestsByTypeDependsOnUserPrivileges`. `mine` is always loaded. `myTeam`, `otherDepartment` and `allCompany` are loaded only when the user's settings allow them, for example `isManagerIn`.
4. `_preloadProfileImage` caches the avatar, which face verification also uses. The birthday check (`BirthdayChecker`) is currently commented out.
