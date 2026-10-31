# profiles

The company employee directory and employee profile details, for colleagues and managers. The user's own editable profile is in `personal_profile`.

## Files
- `views/employees_list_screen.dart`: `EmployeesListScreen` (`/:lang/employees-list`). Search and department filter.
- `views/employee_details_screen.dart`: `EmployeeDetailsScreen` (`employees-list/employee-details/:id`). A header and tabbed sections.
- `views/widgets/employee_details_widgets/`: `GeneralSectionWidget`, `ContactsSectionWidget`, `AccountsSectionWidget`, `RequestsSectionWidget`, `requests_by_balance_empid_modal.widget.dart`.
- `views/widgets/`: header, balance cards (`ProfileBalanceWidget`), assets, evaluations, social icons, tiles.
- `models/employee_profile.model.dart`: `EmployeeProfileModel` (large, about 700 lines), `EmpSocialMedia`.
- `services/employee.service.dart`: `EmployeeService.getEmployees` (`emp_requests/v1/employees`, optional department filter) and `getEmployeeData` (`emp_requests/v1/employees/<id>`).
- `viewmodels/employees_list.viewmodel.dart`, `viewmodels/employee_details.viewmodel.dart`, `viewmodels/requests_by_balance_empid.viewmodel.dart`.

## How it works
- The list view model loads employees through `EmployeeService` and departments through `CrudOperationService` (`slug: 'departments'`).
- The details view model loads:
  - the profile (`getEmployeeData`)
  - salary advances (`/emp-salary-advances/entities-operations`)
  - evaluations (`/rm_evaluation/v1/evaluation/emp_evaluations`, with `emp_id` when it is another employee)
- Tapping a balance opens the requests of that type for that employee. This goes through `RequestsServices.getRequestsByTypeDependsOnUserPrivileges` (`RequestsByBalanceAndEmployeeIdViewModel`).
- A manager can open that employee's punches with `/:lang/employee-fingerprint/:employeeId`.
