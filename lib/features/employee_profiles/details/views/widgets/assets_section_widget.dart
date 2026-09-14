import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AssetsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;

  const AssetsSectionWidget({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final hasAssets = employee?.assets != null && employee!.assets!.isNotEmpty;
    final hasCustomData =
        employee?.empCustomData != null && employee!.empCustomData!.isNotEmpty;

    if (!hasAssets && !hasCustomData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(AppStrings.noDataFounded.tr()),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          if (hasAssets) ...[
            _SectionLabel(AppStrings.assets.tr()),
            gapH12,
            ListView.separated(
              shrinkWrap: true,
              reverse: false,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: employee!.assets!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _AssetCard(asset: employee!.assets![index]),
            ),
            const SizedBox(height: 24),
          ],
          if (hasCustomData) ...[
            _SectionLabel(AppStrings.customData.tr()),
            gapH12,
            ListView.separated(
              shrinkWrap: true,
              reverse: false,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: employee!.empCustomData!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _CustomDataCard(
                item: employee!.empCustomData![index].item ?? '',
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text.toUpperCase(),
          style: AppStyles.subtitleContent(context).copyWith(
              fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
      );
}

class _AssetCard extends StatelessWidget {
  final Assets asset;

  const _AssetCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color(AppColors.buttons).withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.devices_other_rounded,
                color: Color(AppColors.buttons), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.title ?? '',
                  style: AppStyles.blackContent(context)
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                if (asset.serialNumber?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.tag_rounded,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(asset.serialNumber!,
                        style: AppStyles.greyContent(context)
                            .copyWith(fontSize: 12)),
                  ]),
                ],
                if (asset.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(asset.description!,
                      style: AppStyles.greyContent(context)
                          .copyWith(fontSize: 12, height: 1.4)),
                ],
                if (asset.startAt?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(_fmt(asset.startAt),
                        style: AppStyles.greyContent(context)
                            .copyWith(fontSize: 11)),
                    if (asset.endsAt?.isNotEmpty == true) ...[
                      Text('  →  ',
                          style: AppStyles.greyContent(context)
                              .copyWith(fontSize: 11)),
                      Text(_fmt(asset.endsAt),
                          style: AppStyles.greyContent(context)
                              .copyWith(fontSize: 11)),
                    ],
                  ]),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (asset.assetStatus?.isNotEmpty == true)
                      _Badge(
                        prefixLabel: 'asset_status'.tr(),
                        label: asset.assetStatus!.tr(),
                        isPositive: asset.assetStatus == 'active',
                      ),
                    if (asset.assignmentStatus?.isNotEmpty == true)
                      _Badge(
                        prefixLabel: 'assignment_status'.tr(),
                        label: asset.assignmentStatus!.tr(),
                        isPositive: asset.assignmentStatus == 'active',
                        isSecondary: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }
}

class _Badge extends StatelessWidget {
  final String? prefixLabel;
  final String label;
  final bool isPositive;
  final bool isSecondary;

  const _Badge({
    required this.label,
    required this.isPositive,
    this.prefixLabel,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color successColor = Color(0xFF2D6A4F);
    const Color errorColor = Color(0xFFC72C41);
    final Color bg = isPositive
        ? successColor.withOpacity(0.10)
        : errorColor.withOpacity(0.10);
    final Color fg = isPositive ? successColor : errorColor;
    final Color badgeColor = isSecondary ? Color(AppColors.buttons) : fg;
    final Color badgeBg =
        isSecondary ? Color(AppColors.buttons).withOpacity(0.08) : bg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixLabel != null) ...[
            Text(
              '${prefixLabel!}: ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: badgeColor.withOpacity(0.7),
                letterSpacing: 0.2,
              ),
            ),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: badgeColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDataCard extends StatelessWidget {
  final String item;

  const _CustomDataCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: Color(AppColors.buttons), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item,
                style: AppStyles.blackContent(context)
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
