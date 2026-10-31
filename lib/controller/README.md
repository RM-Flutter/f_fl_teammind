# controller

Shared `ChangeNotifier` controllers that several modules use. They call the API with **`DioHelper`** and relative paths, not with `DioApiService`.

| Controller | Used by | Endpoints | What it does |
|---|---|---|---|
| `request_controller/request_controller.dart`: `RequestController` (global provider) | complaints, request comments | `emp_requests/v1/complain?type=myTeam\|mine`, `emp_requests/v1/complain/<id>?type=`, `rm_postcontrol/v1/add_request`, `/<slug>/entities-operations/<id>/comments` | Paginated complaint lists (`getRequest`, `getRequestMine`), complaint details (`getOneRequest`), creating a complaint or request with images (`addRequest`), adding comments with attachments and voice (`addComment`), plus image pickers. |
| `task_controller/task_view_model.dart`: `TaskViewModel` | `modules/tasks`, home "my tasks" | `emp_requests/v1/task` (GET list by date, POST create), `task/<id>` (GET/PUT), `task/<id>/status`, `emp_requests/v1/employees` | Task CRUD, subtask status updates, the assignee list, the date picker and image attachments. |
| `filter_controller/filter_controller.dart`: `FilterController` | request search and filter | `emp_requests/v1/employees`, `/departments/entities-operations` | Loads request types (from `US2` balance), employees and departments for the filter UI. |
| `device_sys/device_controller.dart`: `DeviceControllerProvider` (global) | More, then User devices | `rm_users/v1/devices/get`, `devices/stop`, `rm_users/v1/device_sys` | Lists the user's logged-in devices, stops (logs out) a device, and gets or sets per-device notification status. |
| `evaluation_controller/evaluation_controller.dart`: `EvaluationViewModel` | `modules/evaluation` | `rm_evaluation/v1/evaluation/required_evaluations`, `emp_evaluations` | Loads the evaluations the user must fill in or has received. Each item has a `submitUrl` that opens in a webview. |
