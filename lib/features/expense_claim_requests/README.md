# expense_claim_requests

Employees claim expenses back, with receipts attached.

- `shared/repos/expense_claim_repo.dart`: `emp_requests/v1/expense-claims` (create, update, delete) and the lists `approval-system/v1/employee_expense_claims/employee/my-approvables` (mine) and `.../manager/under-my-management-approvables` (incoming).
- `controllers/expense_claim_list_controller.dart`: personal and incoming lists, filters and incoming scope.
- `controllers/create_expense_claim_controller.dart` / `update_expense_claim_controller.dart`: category, date, amount and attachments. `submitRequest` / `submitUpdate`.
- `shared/models/expense_claim_model.dart`: claim and attached files.
- `views/`: list, create and update screens. Details and approval open `approvableDetails` with type `employee_expense_claims`, where a manager can change the approved amount.
