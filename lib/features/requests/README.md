# requests

Employee requests (vacation, permission, mission, work from home, ... the types are defined by the company in settings). This is the "Requests" tab.

| Path | Role |
|---|---|
| `main_request_layout/` | `RequestsScreen` with tabs **Mine / My team / Other departments / All company** (`GetRequestsTypes`). `RequestsViewModel.initializeRequestsScreen` loads them through the approval system: mine via `RequestsServices.getMyApprovables(type: 'employee_requests')` (`approval-system/v1/employee_requests/employee/my-approvables`); team, other and all via `getManagerApprovables(scope: team / other_departments / all_company)` (`.../manager/under-my-management-approvables`). `FilterController` and the search/filter widgets filter by request type, department, employee, status and date. |
| `add/` | `AddRequestScreen` + `AddNewRequestController` (below) |
| `details/` | `RequestDetailsScreen` + `RequestDetailsViewModel`. It loads one request (`/emp_requests/v1/my_request`) and shows tabs for info, reason, manager response, comments and tracking (the `features/tracking` widgets). Actions: ask to ignore, ask to remember, complain, download attachments, and the employee's history and balance statistics. |
| `calender/` | `RequestsCalendarScreen`: Syncfusion calendar of requests |
| `view_by_ids/` | Requests of one type for one employee, plus a summary report (`/emp_reports/v1/summary_report`) |
| `shared/ui/widgets/` | Buttons used across the request screens |

## How adding a request works (`AddNewRequestController`)

1. **Request types** come from the cached general settings (`UserSettingConst.generalSettingsModel.requestTypes`). Each type carries its rules: date or date-time range, half day, attachments, "instead of holiday", balance. The type list is filtered by the employee's available balance.
2. **Duration** is computed on the device:
   - `_calcDuration` and `_getHoursDifference` handle hour-based requests
   - `_getDateDifferenceWithoutWeekendsAndOfficailHolidays` uses the weekends and holidays in `USG`
3. Optional attachments (`pickFile`, camera or gallery) are uploaded as form data.
4. `createNewRequest` posts to `emp_requests/v1/create_new_request`. On success it shows `SuccessfullAddRequestSheet`.
5. The same controller also creates complaints (`createNewComplaint` → `/emp_requests/v1/complain`). It loads departments from `/rm_general/v1/json/departments` and employees from `/emp_requests/v1/employees`.

The rule text per request type comes from `AppSettingsService.getRequestRulesMessageFromGenenralSettings`. Managers act on requests in `approvables_details`.
