# home

The home dashboard after login.

| Path | Role |
|---|---|
| `controllers/home_controller.dart` | `HomeController` (app-wide provider). `initializeHomeScreen(context, need)` refreshes the settings (`start_app`), loads `/emp_requests/v1/home` and the user's requests, and pre-loads the profile image. |
| `views/home_screen.dart` | Builds the dashboard from configurable widgets |
| `data/models/home_widget_type.dart` | `HomeWidgetType`: `bookmarks`, `myRequests`, `myTasks`, `myTeamRequests`, `otherDepartmentRequests`, `allCompanyRequests`, `notifications`. The order is cached (`toJson`/`fromJson`); `getDefaultOrder()` is the default. |
| `data/models/*_request_model.dart` | Models for the team, other-department and all-company request lists |
| `views/widgets/page_header_widgets/` | App bar with avatar (→ personal profile) and notification bell |
| `views/widgets/page_body_widgets/` | "My requests" cards (→ request details), a management response sheet for managers (`ManagementResponseViewModal.sendManagerAction`), and the notifications section |
| `views/widgets/bookmark_list_widget.dart` | Local bookmarks (`BookmarkService`) |
| `views/widgets/loading/` | Shimmers |

Manager-only widgets (team, other-department and all-company requests) depend on `US1.is_manager_in` and the related settings.
