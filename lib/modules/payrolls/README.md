# payrolls

The employee's payslips. Gated by the `emp-payroll` package (`UsgPackagesService.isPayrollActive`). Backend: the RightMind `rm_payroll` package, read as the generic entity `emppayrolls`.

## Files
- `views/payrolls_list_screen.dart`: `PayrollsListScreen` (`/:lang/payrolls-screen`).
- `views/payroll_details_screen.dart`: `PayrollDetailsScreen` (`payrolls-screen/payroll-details`). Header (period, net), body (earnings and deductions) and a PDF download.
- `views/view_pdf_screen.dart`: `PdfViewerScreen` (Syncfusion PDF viewer).
- `models/payroll.model.dart` (`PayrollModel`, `PayrollDeductions`), `models/payroll_list_item.model.dart`.
- `services/payroll.service.dart`: `PayrollService.getPayrollsList` / `getSinglePayrollById`. These call `CrudOperationService.readEntities` / `readSingleEntityById` with `slug: 'emppayrolls'`, so the request goes to `/emppayrolls/entities-operations[/<id>]`, with filters `with`, `scope`, `page`, `departmentId`, `empId` and a date range. The old `payGetPosts`/`payGetPost` endpoints are commented out.
- `view_models/payrolls_list.viewmodel.dart`, `view_models/payroll_details.viewmodel.dart`.

## Security
- The details screen asks for **biometric or device authentication** (`local_auth`) before it shows the data.
- It turns on the native **secure flag** (`SecureScreen.enableSecureFlag()` through `MethodChannel('com.rightminddev.rmemp/secure')`) to block screenshots and screen recording, and turns it off on dispose.

## PDF
`PayrollDetailsViewModel.downloadPdf(id)` uses `<baseUrl>/rm_payroll/v1/payroll/<id>/pdf`. On web it uses `fetch` and an anchor download. On mobile it downloads the file with the bearer token and opens or saves it.
