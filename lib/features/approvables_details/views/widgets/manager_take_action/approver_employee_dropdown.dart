import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../../data/models/approvable_details_model.dart';
import 'package:app_test/core/constants/app_design.dart';

class ApproverEmployeeDropdown extends StatelessWidget {
  final String? selectedEmployeeId;
  final List<CurrentLevelApproverModel> activeApprovers;
  final bool isLoadingApprovers;
  final bool isArabic;
  final ValueChanged<String?> onChanged;

  const ApproverEmployeeDropdown({
    super.key,
    required this.selectedEmployeeId,
    required this.activeApprovers,
    required this.isLoadingApprovers,
    required this.isArabic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('select_approver_employee'.tr(),
          style: AppStyles.darkContent(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.secondaryButton),
          ),
        ),
        const SizedBox(height: 8),
        if (isLoadingApprovers)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator.adaptive(),
            ),
          )
        else if (activeApprovers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Text('no_approvers_available_for_this_level'.tr(),
              style: const TextStyle(fontSize: 12, color: Colors.amber),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedEmployeeId,
                isExpanded: true,
                dropdownColor: Colors.white,
                icon: Icon(Icons.arrow_drop_down,
                    color: Color(AppColors.buttons), size: 24),
                hint: Text('selectEmployee'.tr(),
                  style: AppStyles.darkContent(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.secondaryButton),
                  ),
                ),
                items: activeApprovers.map((emp) {
                  final label =
                      '${emp.name ?? ''} ${emp.jobTitle != null ? '(${emp.jobTitle})' : ''}';
                  return DropdownMenuItem<String>(
                    value: emp.id?.toString(),
                    child: Text(
                      label,
                      style: AppStyles.darkContent(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.secondaryButton),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
