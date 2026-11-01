# salary_advance_requests

Employees ask for an advance on their salary. Managers review it.

| Path | Role |
|---|---|
| `shared/repos/salary_advance_repo.dart` | `rm_payroll/v1/salary-advance-requests`: create, `personal`, `incoming`, details, review, update and delete (`EndpointsNames.salaryAdvance*`). It also lists approvables through `approval-system/v1/salary_advance/employee/my-approvables`. |
| `controllers/salary_advance_list_controller.dart` | Personal and incoming tabs, filters (date, department, employee, status), incoming scope |
| `controllers/create_salary_advance_controller.dart` / `update_salary_advance_controller.dart` | Form state: amount, from-date and attachments. `submitRequest` / `submitUpdate`. |
| `controllers/salary_advance_details_controller.dart` | `fetchDetails`, `reviewRequest` (manager approve or refuse), `cancelRequest`, `removeAttachment` |
| `views/` | List, create, update and details screens, plus the list item widget |
