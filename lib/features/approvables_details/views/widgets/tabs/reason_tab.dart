import 'package:flutter/material.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';

class ReasonTab extends StatelessWidget {
  final String? reason;

  const ReasonTab({super.key, this.reason});

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);
    final defaultNoReasonText =
        isArabic ? "لا يوجد سبب مذكور" : "There is no reason";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Text(
          reason != null && reason!.trim().isNotEmpty
              ? reason!.trim()
              : defaultNoReasonText,
          textAlign: TextAlign.center,
          style: AppStyles.darkContent(context).copyWith(fontSize: 14),
        ),
      ),
    );
  }
}
