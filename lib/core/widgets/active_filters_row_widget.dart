import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';

class ActiveFiltersRowWidget extends StatelessWidget {
  final String? empName;
  final String? depName;
  final String? fromDate;
  final String? toDate;
  final String? status;
  final Function() onClearEmp;
  final Function() onClearDep;
  final Function() onClearDate;
  final Function() onClearStatus;

  const ActiveFiltersRowWidget({
    Key? key,
    this.empName,
    this.depName,
    this.fromDate,
    this.toDate,
    this.status,
    required this.onClearEmp,
    required this.onClearDep,
    required this.onClearDate,
    required this.onClearStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasFilters = empName != null || depName != null || (fromDate != null && toDate != null) || status != null;
    
    if (!hasFilters) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (depName != null) _buildChip(context, '${'department'.tr()}: $depName', onClearDep),
            if (empName != null) _buildChip(context, '${'employeeName'.tr()}: $empName', onClearEmp),
            if (status != null) _buildChip(context, '${'status'.tr()}: ${status!.tr()}', onClearStatus),
            if (fromDate != null && toDate != null) _buildChip(context, '${'date'.tr()}: $fromDate - $toDate', onClearDate),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Function() onClear) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(AppColors.secondaryButton).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppStyles.darkContent(context).copyWith(
              fontSize: 12,
              color: Color(AppColors.secondaryButton),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onClear,
            child: Icon(
              Icons.close,
              size: 16,
              color: Color(AppColors.secondaryButton),
            ),
          ),
        ],
      ),
    );
  }
}
