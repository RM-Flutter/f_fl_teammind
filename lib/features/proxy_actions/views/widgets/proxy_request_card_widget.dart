import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import '../../data/models/proxy_request_model.dart';

/// One leave created on an employee's behalf: employee, type, dates and duration, status.
/// [onEdit] is set when the manager may still edit it (shows the edit badge, opens on tap).
class ProxyRequestCardWidget extends StatelessWidget {
  final ProxyRequestModel request;
  final VoidCallback? onEdit;

  const ProxyRequestCardWidget({super.key, required this.request, this.onEdit});

  String _date(BuildContext context, String raw) {
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd/MM/yyyy', context.locale.languageCode).format(d);
  }

  @override
  Widget build(BuildContext context) {
    final from = _date(context, request.dateFrom);
    final to = _date(context, request.dateTo);
    final dates = from == to || to.isEmpty ? from : '$from : $to';
    final third = request.duration.isEmpty ? dates : '$dates (${request.duration})';
    return AppCard.listItem(
      context: context,
      margin: const EdgeInsets.only(bottom: AppSizes.s10),
      title: request.employeeName.isEmpty ? request.typeName : request.employeeName,
      subtitle: request.employeeName.isEmpty ? null : request.typeName,
      thirdLine: third,
      avatarUrl: request.employeeAvatar,
      topBadges: onEdit == null
          ? null
          : [
              AppStatusBadge(
                label: 'proxy_editable'.tr(),
                color: Color(AppColors.buttons),
                icon: Icons.edit_rounded,
              ),
            ],
      trailing: AppStatusBadge.fromStatus(status: request.status),
      onTap: onEdit,
    );
  }
}
