# requests

HR requests: leaves, permissions, missions, … Employees create them, managers approve or refuse them. Gated by the `emp-requests` package. Backend: the RightMind `emp_requests` package (`emp_requests/v1/*`), plus `emp_reports` for summaries.

## Screens and routes
| Screen | Route | Purpose |
|---|---|---|
| `views/requests_screen.dart`: `RequestsScreen` | `/:lang/requests/:type` (bottom-nav tab) | Tabs for mine, my team, other departments and all company, each with search and filter (`widgets/search_filter_widget.dart`, `active_filters_widget.dart`). |
| `views/requests_calendar_screen.dart` | `requests/requests-calendar` | Requests on a Syncfusion calendar (`RequestDataSource`), built from the already-loaded request lists. |
| `views/add_request_screen.dart`: `AddRequestScreen` | `requests/add-new-request` | New request form. |
| `views/requests_by_id_screen.dart` | `requests/requests-by-id/:id` | Requests of one request type, with the `emp_reports/v1/summary_report` summary. |
| `views/request_details_screen.dart` | `requests/request-details/:id` | Details, attachments (with download), comments, and manager actions. |

## View models
- `requests.viewmodel.dart`: `RequestsViewModel`. Paginated lists per `GetRequestsTypes` through `RequestsServices`.
- `add_new_request.viewmodel.dart`: `AddNewRequestViewModel`, the most complex one:
  - `_getRequestTypes` builds the request types available to the user from **`US2.balance`** (user2 settings). No balance means no request types.
  - The date and time pickers (`selectDate`, `_selectDateRange`, `_selectDateTimeRange`, `selectInsteadOfHolidays`, `checkHalfDate`) depend on the type's unit (days or hours).
  - Duration is calculated on the client: `_calcDuration`, `_getHoursDifference`, and `_getDateDifferenceWithoutWeekendsAndOfficailHolidays` (skips weekends and official holidays from settings).
  - `createNewRequest` POSTs `emp_requests/v1/create_new_request` (form data when there are attachments). `getDepartment` loads `/departments/entities-operations`.
  - `createNewComplaint` (POST `emp_requests/v1/complain`) is also here. It is used by the complaints module.
- `request_details.viewmodel.dart`: `RequestDetailsViewModel`. Loads `emp_requests/v1/my_request` and runs actions.
- `management_response.viewmodel.dart`: the manager approves or refuses with a reason (`emp_requests/v1/action`), and can use ask-remember or ask-ignore.
- `statistics.viewmodel.dart` (requests of one type, used by the balances and statistics modal), `requests_with_type_id_viewmodel.dart` (summary report), `requests_calendar.viewmodel.dart`, `get_all_request.dart`.

## Modals and widgets
`widgets/modals/`: statistics and balances (`StatisticsModal`), summary reports, management response. `request_details_header_widget.dart` handles attachment downloads, with web (`dart_html_stub.dart`) and IO (`directory_stub.dart`) variants.

## Request statuses
`waiting`, `waiting_cancel`, `waiting_seen`, `seen`, `approved`, `canceled`, `refused` (see `services/requests.services.dart`).
