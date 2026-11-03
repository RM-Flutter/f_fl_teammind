import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';

enum TrackingFilterOption {
  all,
  hasTracking,
  noTracking;

  String getLabel({bool isArabic = true}) {
    switch (this) {
      case TrackingFilterOption.all:
        return 'all'.tr();
      case TrackingFilterOption.hasTracking:
        return 'with_tracking'.tr();
      case TrackingFilterOption.noTracking:
        return 'missing_required'.tr();
    }
  }
}

class TrackingFilterChips extends StatelessWidget {
  final TrackingFilterOption selected;
  final ValueChanged<TrackingFilterOption> onSelected;

  const TrackingFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: TrackingFilterOption.values.map((option) {
          final isSelected = selected == option;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(option.getLabel(isArabic: isAr)),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: Color(AppColors.buttons).withOpacity(0.15),
              backgroundColor: Color(AppColors.cardBackground),
              side: BorderSide(
                color: isSelected ? Color(AppColors.buttons) : Color(AppColors.border),
                width: isSelected ? 1.5 : 1.0,
              ),
              labelStyle: AppStyles.content(context).copyWith(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Color(AppColors.buttons) : const Color(0xff606060),
              ),
              onSelected: (_) => onSelected(option),
            ),
          );
        }).toList(),
      ),
    );
  }
}
