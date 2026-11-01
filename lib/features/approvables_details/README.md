# approvables_details

One details-and-action screen for **every type** of item that goes through the backend approval system (`emp-approval-system`). It is the only feature that uses `flutter_bloc`.

Route: `approvableDetails` with path params `:type/:id`. `type` is one of `employee_requests`, `overtime`, `salary_advance`, `employee_expense_claims`, `shift_change_requests`. `extra['autoOpenAction']` can open the action sheet straight away.

| Path | Role |
|---|---|
| `cubit/approvable_details_cubit.dart` | `ApprovableDetailsCubit` with states Loading, Loaded, Error, ActionSubmitting, ActionSuccess and ActionError. Methods: `fetchDetails`, `fetchCurrentLevelApprovers`, `submitTakeAction`, `submitTakeActionAsSomeoneElse`, `askIgnore`, `askRemember`. |
| `data/services/approvables_details_service.dart` | API calls, all under `/approval-system/v1/{type}/`: `employee/approvables/{id}` (details), `.../ask-ignore`, `.../remember`, `manager/approvables/{id}/current-level-approvers`, `manager/take-action`, `manager/take-action-as-someone-else`, and `employee_requests/manager/approvables/{id}/overlapping-vacations` |
| `data/models/approvable_details_model.dart` | Details, required approvals per level, current-level approvers, overlapping vacations, seen-by |
| `views/approvable_details_screen.dart` | Header, tabs (information, reason, manager response) and the bottom action bar |
| `views/widgets/approvals_table/`, `required_approvals_table_widget.dart` | Approval chain: levels and who approved, refused or is pending |
| `views/widgets/manager_take_action_modal.dart` + `manager_take_action/` | Approve or refuse, with a reply, attachment, and optionally another approver (act on someone's behalf) |
| `views/widgets/overlapping_vacations_sheet.dart` | Who else is off on the same dates |
| `views/widgets/overtime_update_dialog.dart`, `expense_claim_update_amount_dialog.dart` | Type-specific edits before approval (overtime hours, claim amount) |

## Flow

The screen creates the cubit and calls `fetchDetails(type, id)`. What the bottom bar shows depends on the returned permissions:

- **employee**: ask ignore, remember, complain
- **manager at the current level**: take action

A manager action posts and then re-fetches the details.
