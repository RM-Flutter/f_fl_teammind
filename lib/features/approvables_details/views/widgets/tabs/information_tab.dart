import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';

class InformationTab extends StatelessWidget {
  final String? createdAt;
  final String? seenAt;
  final String? updatedAt;

  const InformationTab({
    super.key,
    this.createdAt,
    this.seenAt,
    this.updatedAt,
  });

  String _formatInfoDate(String? rawDate, BuildContext context) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final lang = LocalizationService.isArabic(context: context) ? "ar" : "en";
      return DateFormat('d-M-y | hh:mm a', lang).format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label : ",
            style: AppStyles.darkContent(context).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: AppStyles.primaryContent(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          if (createdAt != null && createdAt!.isNotEmpty)
            _buildInfoCard(
              context,
              AppStrings.createdOn.tr(),
              _formatInfoDate(createdAt, context),
            ),
          if (seenAt != null && seenAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              AppStrings.seenOn.tr(),
              _formatInfoDate(seenAt, context),
            ),
          ],
          if (updatedAt != null && updatedAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              AppStrings.statusUpdate.tr(),
              _formatInfoDate(updatedAt, context),
            ),
          ],
        ],
      ),
    );
  }
}
