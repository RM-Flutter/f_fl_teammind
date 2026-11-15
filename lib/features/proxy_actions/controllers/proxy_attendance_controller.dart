import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/proxy_actions_service.dart';
import '../data/repos/proxy_repo.dart';
import '../views/widgets/proxy_employee_picker_sheet.dart';

/// Attendance on behalf of an employee: pick the employee, confirm, punch. The server records the
/// punch at its own current time and uses the employee's branch, the same as a punch the employee
/// makes from the app (in or out is decided by the server).
abstract class ProxyAttendanceController {
  static bool _busy = false;

  static Future<void> start(BuildContext context) async {
    if (_busy) return;
    final employee = await ProxyEmployeePickerSheet.show(
      context,
      ability: ProxyActionsService.attendance,
      title: 'proxy_attendance'.tr(),
    );
    if (employee == null || !context.mounted) return;

    final confirmed = await AlertsService.confirmMessage(
      context,
      'proxy_attendance_confirm_title'.tr(namedArgs: {'name': employee.name}),
      message: 'proxy_attendance_confirm_message'.tr(),
    );
    if (!confirmed || !context.mounted) return;

    _busy = true;
    try {
      final result = await ProxyRepo.addFingerprint(context, employeeProfileId: employee.id);
      if (!context.mounted) return;
      if (result.success) {
        AlertsService.success(
          context: context,
          title: AppStrings.success.tr(),
          message: result.message ?? 'proxy_attendance_done'.tr(namedArgs: {'name': employee.name}),
        );
      } else {
        AlertsService.error(
          context: context,
          title: AppStrings.failed.tr(),
          message: result.message ?? AppStrings.somethingWentWrong.tr(),
        );
      }
    } finally {
      _busy = false;
    }
  }
}
