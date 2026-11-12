import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class ReportCompareTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final String? currentSubtitle;
  final String? compareSubtitle;

  const ReportCompareTabs({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.currentSubtitle,
    this.compareSubtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSizes.s6),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: 'current_period'.tr(),
              subtitle: currentSubtitle,
              isSelected: selectedIndex == 0,
              onTap: () {
                if (selectedIndex != 0) {
                  onTabSelected(0);
                }
              },
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: _buildTabItem(
              title: 'compare_period'.tr(),
              subtitle: compareSubtitle,
              isSelected: selectedIndex == 1,
              onTap: () {
                if (selectedIndex != 1) {
                  onTabSelected(1);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s10, horizontal: AppSizes.s8),
        decoration: BoxDecoration(
          color: isSelected ? Color(AppColors.buttons) : Color(AppColors.inputFill),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isSelected
              ? AppShadows.card
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  size: 15,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: AppSizes.s6),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              const SizedBox(height: AppSizes.s3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
