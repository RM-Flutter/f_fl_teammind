# payrolls

Payslips.

- `shared/repos/payroll_service.dart`: `PayrollRepo`. List and details from `rm_payroll/v1/payroll` (`EndpointsNames.payGetPosts` / `payGetPost`), filtered by employee for managers.
- `payroll_list/`: `PayrollsListViewModel.initializePayrollsListScreen` loads the list. `PayrollListItemWidget` opens the details.
- `payroll_details/`: `PayrollDetailsViewModel` loads one payroll (gross, deductions, bonuses, special bonuses, net, status). It can download the PDF from `rm_payroll/v1/payroll/{id}/pdf` and show it in `PdfViewerScreen`.
- `SecureScreen` (in `payroll_details_screen.dart`) calls the native method channel `com.rightminddev.rmemp/secure` (`enableSecureFlag`) so that salary screens cannot be captured on Android.
- `shared/models/`: `PayrollModel`, `PayrollListItemModel`.
