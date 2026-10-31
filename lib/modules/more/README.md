# more

The "More" tab (`/:lang/more`): a menu of every secondary feature, plus several small sub-features that live in this folder.

## `views/more_screen.dart`: `MoreScreen`
A menu of links, filtered by package gating and user permissions, to:
- personal profile, employees list, team fingerprint, tasks, complaints, rewards and penalties, payrolls, evaluations
- requests, request terms, user devices, language, update password, about us, FAQ, contact us
- generic pages (`defaultPage` / `defaultListPage`)

It also handles logout (through `AppConfigService`).

## Sub-features
| Folder | Route | What and how |
|---|---|---|
| `views/notification/` | `/:lang/notifications` (bottom-nav "page"), `notification-screen/add-notification`, `notification-details-screen/:id` | `NotificationProviderModel` (global). **List**: `getNotification` GETs `/rmnotifications/entities-operations` when the user's `US1.role` contains `personal`, otherwise `/emp_requests/v1/notifications/list`. **Details**: `/rmnotifications/entities-operations/<id>`. **Send** (manager): `AddNotificationScreen` picks employees and departments, adds images and voice, and POSTs `/emp_requests/v1/notifications/create`. |
| `widgets/customize_notification_screen.dart` | | Per-category notification toggles. |
| `views/blog/` | `/:lang/blog_details/:title/:type/:id` | `BlogProviderModel` (global). `getBlog(slug)` calls `/<slug>/entities-operations?with=tags,category_id`, and `getOneBlog` fetches one item. It is also the data source of `modules/pages`. |
| `views/user_devices/` | `/:lang/userDevices-screen` | Logged-in devices through `DeviceControllerProvider` (`rm_users/v1/devices/get`, `devices/stop`). |
| `views/lang_setting/` | `/:lang/lang-setting-screen` | AR/EN switch. `LangControllerProvider` also sends the language to `rm_users/v1/device_sys`. |
| `views/update_password/` | `more/update-password` | `rm_users/v1/update_password`. |
| `views/team_fingerprint/` | `more/teamFingerprint` | Employees under the manager (`emp_requests/v1/employees`). Tapping one opens `fingerprintView/:id/:name`. |
| `views/aboutus/` | `more/about-us-screen` | `rm_page/v1/show?with=metas&slug=about-us-app`. |
| `views/faq/` | `more/faq-screen` | `rm_page/v1/show?slug=faq`. |
| `views/request_terms/` | `more/request-terms-screen` | The policy and terms for each request type, from settings. |
| `views/contactus/` | `more/contact-us` | Contact info from general settings (`GeneralSettings` model) and contact actions. |
| `views/general_data/` | `more/general-data-screen` | A generic data screen. `GeneralController` loads an `rm_page/v1/show` page. |
| `views/company_structure/` | `more/webview` | `WebViewStack`, a webview page (company structure or any URL). |

`view_models/more.viewmodel.dart` is empty.
