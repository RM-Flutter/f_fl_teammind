# more

The "More" tab (`more_screen.dart`) and the smaller screens it opens. `MoreScreen` builds its menu from the cached `US1`/`USG` settings. Manager entries (team fingerprints, team today status, incoming requests, employees, reports, ...) only appear when `US1.is_manager_in` is not empty or the matching feature is enabled. The menu also links to the TeamMind assistant (`features/assistant`) and to features that live in their own folders: payrolls, tasks, evaluation, complaints, overtime, salary advance, expense claims, shifts, daily reports, reports, commissions, cv_hub, points and personal profile.

## Sub-folders

| Folder | What it does / how |
|---|---|
| `notifications/` | In-app notifications (also the bottom "page" tab). `NotificationProviderModel` (app-wide) calls `getNotification` (`/emp_requests/v1/notifications/list`, paged), `getNotificationSingle`, `markAsRead` (`/notifications/{id}/mark-as-read`), `reactToNotification` / `fetchEmotionCount` (emoji reactions), and, for managers, `AddNotificationScreen` → `/emp_requests/v1/notifications/create` targeting departments or employees, with images. The details screen has reactions and comments. |
| `blog/` | `BlogProviderModel` (app-wide). It loads entity lists and single entities through the generic entities API: `/{slug}/entities-operations?with=tags,category_id` and `/{type}/entities-operations/{id}`. `pages/` reuses it for any content type. |
| `about_us/`, `faqs/`, `general_data/` | Static pages from `rm_page/v1/show?slug=about-us-app`, `?slug=faq`, ... FAQ has a local cache data source. |
| `contact_us/` | Company contacts and branches from the general settings, plus `sendMailToCompany` |
| `files_center/` | Company documents: `emp_requests/v1/files-center/types` and `/files` with type and status filters, search and paging (`FilesCenterViewModel`) |
| `language_settings/` | EN/AR switch. It calls `context.setLocale`, updates the cached `lang`, and tells the server through `rm_users/v1/device_sys`. |
| `user_device/` | `DeviceControllerProvider`: my logged-in devices (`rm_users/v1/devices/get`), stop a device (`/devices/stop`), and the notification permission and status (`device_sys`) |
| `ai_connect/` | "Connect ChatGPT / Claude" (`AiConnectScreen`): shows the company's MCP connector link (`/rm_mcp/v1/connect-info`) with copy and the 4 steps. "Connected apps" (`AiConnectedAppsScreen`): the assistants linked to this account (`/rm_mcp/v1/connections`), each with a confirmed disconnect (`DELETE /rm_mcp/v1/connections/{id}`). Uses a screen-level `AiConnectController`. Backend: `rm/ai` package, see `packages/rm/ai/MCP.md`. The tile shows when `PackageHelper.hasPackage('ai')`. |
| `customized_notification/` | Notification preference switches (through `DeviceControllerProvider`) |
| `request_terms/` | Rules text per request type, from the general settings |
| `team_fingerprint/` | Manager: pick an employee (`/emp_requests/v1/employees`) and view their punches (`fingerprintView`) |
| `team_today_status/` | Manager: today's attendance status of the team (`/emp_requests/v1/manager/team_today_status`) with a summary, filter and search |
| `update_profile/` | Change password screen |
| `company_structure/` | Older WebView org chart. The native one is `features/company_structure`. |
