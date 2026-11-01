# lib/core/models

Plain Dart models shared by several features. Each has `fromJson`/`toJson`.

| File | Purpose |
|---|---|
| `operation_result.model.dart` | `OperationResult<T>` (`success`, `message`, `data`, ...). Every `DioApiService` call returns this. |
| `endpoint_model.dart` | `EndpointsNames` enum and `EndPoint` (name + url). URLs are resolved in `services/backend_services/get_endpoint_service.dart`. |
| `settings/general_settings.model.dart` | Typed model of the general settings (`USG`): features, request types, holidays, appearance, contacts, `has_employee_profile`, ... |
| `settings/user_settings.model.dart`, `user_settings_2.model.dart` | Typed `US1` / `US2` settings |
| `settings/fingerprint_security_checks.model.dart` | Levels for each fingerprint security check (see `constants/README.md`) |
| `settings/license.model.dart`, `app_settings_model.dart` | Licence info and the base settings type |
| `notifications_model.dart`, `requests_model.dart`, `employee_action_model.dart` | Shared list models for notifications, requests and manager actions |
| `book_mark_model.dart` | Local bookmarks (see `services/bookmark_service.dart`) |
| `device_information.model.dart` | Device id, OS, model and app version, sent with `start_app` and the device endpoints |
| `color_palette.model.dart`, `color_value.model.dart` | Branding palette parsed from server settings |

Many screens skip these typed models and read the raw cached JSON (`json.decode(CacheHelper.getString("US1"))`). When you add a new settings field, add it to the model too.
