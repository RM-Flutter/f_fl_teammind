import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  final Widget? icon;
  final double? marginBottom;
  List? weekends;
  bool? isList = false;

  ProfileTile({
    super.key,
    this.icon,
    this.isList,
    this.weekends,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(AppColors.buttons);
    final String? subtitleText = (isList == true && weekends != null)
        ? weekends!.where((e) => e != null).map((e) => e.toString()).join(' · ')
        : trailingTitle;

    return Padding(
      padding: EdgeInsets.only(
        bottom: marginBottom?.h ?? AppSpacing.cardGap,
        left: AppSizes.s8,
        right: AppSizes.s8,
      ),
      child: AppCard(
        padding: AppSpacing.cardPadding,
        child: isTitleOnly == true
            ? Center(
                child: Text(
                  title.toString(),
                  style: AppStyles.heading(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppCardLeadingAvatar(
                    icon: Icons.info_outline_rounded,
                    borderColor: accentColor,
                  ),
                  const SizedBox(width: AppSizes.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.heading(context).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitleText != null &&
                            subtitleText.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSizes.s3),
                          Text(
                            subtitleText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.subtitleContent(context).copyWith(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (subtitleText != null &&
                      subtitleText.trim().isNotEmpty &&
                      subtitleText.length <= 24) ...[
                    const SizedBox(width: AppSizes.s8),
                    AppStatusBadge(
                      label: subtitleText,
                      color: accentColor,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class ProfileTileEva extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  final bool? isDone;
  var url;
  var eva;
  var createAt;
  var totalPoints;
  var gainedPoints;
  final double? marginBottom;

  ProfileTileEva({
    super.key,
    this.totalPoints,
    this.eva,
    this.gainedPoints,
    this.icon,
    this.isDone,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  bool _resolveIsDone() {
    if (isDone != null) return isDone!;
    if (icon is Icon) {
      final ic = icon as Icon;
      if (ic.icon == Icons.check_circle_outline ||
          ic.icon == Icons.check_circle_outline_rounded ||
          ic.color == Colors.green) {
        return true;
      }
      return false;
    }
    return false;
  }

  String _formatDate(BuildContext context, dynamic rawDate) {
    if (rawDate == null || rawDate.toString().trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(rawDate.toString());
      return DateFormat(
        'dd MMM yyyy',
        LocalizationService.isArabic(context: context) ? 'ar' : 'en',
      ).format(dt);
    } catch (_) {
      return rawDate.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool done = _resolveIsDone();
    final Color statusColor = done
        ? Color(AppColors.successGreen)
        : Color(AppColors.warningYellow);
    final IconData statusIcon = done
        ? Icons.check_circle_outline_rounded
        : Icons.schedule_rounded;
    final String statusLabel =
        done ? 'completed'.tr() : AppStrings.pendingStatus.tr();

    final subtitleParts = <String>[];
    final formattedDate = _formatDate(context, createAt);
    if (formattedDate.isNotEmpty) {
      subtitleParts.add(formattedDate);
    }
    if (gainedPoints != null && totalPoints != null) {
      subtitleParts.add('$gainedPoints / $totalPoints');
    } else if (eva is List && (eva as List).isNotEmpty) {
      final firstWithPoints = (eva as List).cast<dynamic>().firstWhere(
            (item) => item is Map && item['gained_points'] != null,
            orElse: () => null,
          );
      if (firstWithPoints != null) {
        subtitleParts.add(
          '${firstWithPoints['gained_points'] ?? 0} / ${firstWithPoints['total_points'] ?? 0}',
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom?.h ?? AppSpacing.cardGap),
      child: AppCard(
        padding: AppSpacing.cardPadding,
        onTap: () => showEvaluationBottomSheet(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppCardLeadingAvatar(
              nameForInitials: title,
              icon: Icons.assignment_turned_in_outlined,
              borderColor: statusColor,
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s3),
                    Text(
                      subtitleParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.subtitleContent(context).copyWith(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSizes.s8),
            AppStatusBadge(
              label: statusLabel,
              color: statusColor,
              icon: statusIcon,
            ),
          ],
        ),
      ),
    );
  }

  void showEvaluationBottomSheet(BuildContext context) {
    final List resultsList = (eva is List) ? (eva as List) : const [];
    final String headerDate = _formatDate(context, createAt);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.s20,
              horizontal: AppSpacing.page,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.65,
            ),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSizes.s16),
                Text(
                  AppStrings.evaluationsInfo.tr(),
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(AppColors.secondaryButton),
                  ),
                ),
                if (headerDate.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s8),
                  AppStatusBadge(
                    label: headerDate,
                    color: Color(AppColors.buttons),
                    icon: Icons.calendar_today_rounded,
                  ),
                ],
                const SizedBox(height: AppSizes.s16),
                Flexible(
                  child: resultsList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.s24),
                            child: Text(
                              AppStrings.noExistingEvaluation.tr(),
                              style: AppStyles.subtitleContent(context),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          clipBehavior: Clip.none,
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          itemCount: resultsList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.cardGap),
                          itemBuilder: (context, index) {
                            final item = resultsList[index];
                            if (item is! Map || item['gained_points'] == null) {
                              return const SizedBox.shrink();
                            }
                            final String evaluatorName =
                                item['employee_name']?.toString() ?? '-';
                            final String evalDate =
                                item['created_at']?.toString() ?? '';
                            final String scoreText =
                                '${item['gained_points'] ?? 0} / ${item['total_points'] ?? 0}';
                            final Color badgeColor = Color(AppColors.buttons);

                            return AppCard(
                              padding: AppSpacing.cardPadding,
                              child: Row(
                                children: [
                                  AppCardLeadingAvatar(
                                    nameForInitials: evaluatorName,
                                    borderColor: badgeColor,
                                  ),
                                  const SizedBox(width: AppSizes.s12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          evaluatorName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppStyles.heading(context)
                                              .copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (evalDate.isNotEmpty) ...[
                                          const SizedBox(height: AppSizes.s3),
                                          Text(
                                            evalDate,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppStyles.subtitleContent(
                                                    context)
                                                .copyWith(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.s8),
                                  AppStatusBadge(
                                    label: scoreText,
                                    color: badgeColor,
                                    icon: Icons.stars_rounded,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileTileNotTap extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  var url;
  var eva;
  var createAt;
  var totalPoints;
  var gainedPoints;
  final double? marginBottom;

  ProfileTileNotTap({
    super.key,
    this.totalPoints,
    this.eva,
    this.gainedPoints,
    this.icon,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(AppColors.buttons);
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom?.h ?? AppSpacing.cardGap),
      child: AppCard(
        padding: AppSpacing.cardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppCardLeadingAvatar(
              nameForInitials: title,
              icon: Icons.info_outline_rounded,
              borderColor: accentColor,
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (trailingTitle != null &&
                      trailingTitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s3),
                    Text(
                      trailingTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.subtitleContent(context).copyWith(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTileEvaReq extends StatelessWidget {
  final String title;
  final String? empName;
  final String? department;
  final String? name;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  final bool? isDone;
  var url;
  var createAt;
  final double? marginBottom;

  ProfileTileEvaReq({
    super.key,
    this.empName,
    this.department,
    this.name,
    this.icon,
    this.isDone,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.isTitleOnly = true,
    required this.title,
  });

  bool _resolveIsDone() {
    if (isDone != null) return isDone!;
    if (icon is Icon) {
      final ic = icon as Icon;
      if (ic.icon == Icons.check_circle_outline ||
          ic.icon == Icons.check_circle_outline_rounded ||
          ic.color == Colors.green) {
        return true;
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool done = _resolveIsDone();
    final Color statusColor = done
        ? Color(AppColors.successGreen)
        : Color(AppColors.warningYellow);
    final IconData statusIcon = done
        ? Icons.check_circle_outline_rounded
        : Icons.schedule_rounded;
    final String statusLabel =
        done ? 'completed'.tr() : AppStrings.pendingStatus.tr();

    final subtitleParts = <String>[
      if (empName != null && empName!.trim().isNotEmpty) empName!.trim(),
      if (department != null && department!.trim().isNotEmpty)
        department!.trim(),
    ];

    final String dateStr =
        (createAt != null && createAt.toString().trim().isNotEmpty)
            ? createAt.toString().trim()
            : '';

    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom?.h ?? 0),
      child: AppCard(
        padding: AppSpacing.cardPadding,
        onTap: () async {
          if (url != null && url.toString().trim().isNotEmpty) {
            await launchUrl(Uri.parse(url.toString()));
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppCardLeadingAvatar(
              nameForInitials:
                  (empName != null && empName!.trim().isNotEmpty)
                      ? empName
                      : title,
              borderColor: statusColor,
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s3),
                    Text(
                      subtitleParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.subtitleContent(context).copyWith(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (dateStr.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s2),
                    Text(
                      dateStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.subtitleContent(context).copyWith(
                        fontSize: 10.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSizes.s8),
            AppStatusBadge(
              label: statusLabel,
              color: statusColor,
              icon: statusIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTilePay extends StatelessWidget {
  final String title;
  final String? empName;
  final String? name;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  var url;
  var createAt;
  final double? marginBottom;

  ProfileTilePay({
    super.key,
    this.empName,
    this.name,
    this.icon,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(AppColors.buttons);
    final subtitleParts = <String>[
      if (empName != null && empName!.trim().isNotEmpty) empName!.trim(),
      if (createAt != null && createAt.toString().trim().isNotEmpty)
        createAt.toString().trim(),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom?.h ?? AppSpacing.cardGap),
      child: AppCard(
        padding: AppSpacing.cardPadding,
        onTap: () async {
          if (url != null && url.toString().trim().isNotEmpty) {
            await launchUrl(Uri.parse(url.toString()));
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppCardLeadingAvatar(
              nameForInitials:
                  (empName != null && empName!.trim().isNotEmpty)
                      ? empName
                      : title,
              borderColor: accentColor,
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.s3),
                    Text(
                      subtitleParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.subtitleContent(context).copyWith(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
