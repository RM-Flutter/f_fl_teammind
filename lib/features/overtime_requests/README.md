# overtime_requests

Overtime requests for employees, and requests that managers create for their team.

- `controllers/overtime_requests_controller.dart`: `OvertimeRequestsProvider` (app-wide provider). `fetchRequests` (personal, or incoming with `setIncomingScope` / `toggleDepartmentView`), the filters (date, department, employee, status), `addRequest`, `addManagerRequest` and `updateRequestStatus`.
- `services/overtime_requests_service.dart`: `rm_fingerprint/v1/overtime_requests` (employee), `rm_fingerprint/v1/manager/overtime_requests` (manager), and the approval-system list `approval-system/v1/overtime/employee/my-approvables`.
- `models/overtime_request_model.dart`: request, manager reply, employee profile.
- `views/`: list (`overtime_requests_screen`), calendar view, add screen and details screen. The newer flow opens `approvableDetails` with type `overtime` for approvals.
