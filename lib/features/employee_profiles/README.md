# employee_profiles

The employee directory and the full employee profile that managers see.

## List (`list/`)

- `EmployeesListViewModel`: loads `/emp_requests/v1/employees` (optionally `?department_id=`). It supports search (`updateSearchQuery`) and a department filter modal. Departments come from the cached settings (`DepartmentModel`).
- `EmployeesListScreen`: tapping an employee opens `employeeDetails`.

## Details (`details/`)

- `EmployeeDetailsViewModel`: loads `/emp_requests/v1/employees/{id}`. It lazily loads each tab's data with `fetchDataForIndex`: overtime, salary advance, expense claims, shift change requests, daily reports and team evaluations (`rm_evaluation/v1/evaluation/emp_evaluations`).
- `EmployeeDetailsScreen`: header plus tabbed sections (`views/widgets/`):
  - general: job, department, manager, weekend, this week's shifts, today's attendance
  - contacts and social links
  - accounts and payroll
  - assets
  - requests and leave balances (tap a balance to see the requests by type: `RequestsByBalanceAndEmployeeIdViewModel`)
  - rewards and penalties, evaluations, daily reports, expense claims, salary advances, overtime, shift change requests (each links to its own feature)

## Shared (`shared/`)

- `models/employee_profile_model.dart`: the large `EmployeeProfileModel` (working hours, payroll, bonuses and deductions, assets, custom data, titles, weekend and recurring rules, week shifts, today's attendance).
- `repos/employee_repo.dart`.

The personal profile, reports and approval screens also open `employeeDetails`.
