import 'package:app_test/core/services/app_toast.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/expandable_text_widget.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/data/models/reward_and_penalty_model.dart' show MediaFile;
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_test/core/services/url_launcher_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

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
              clipBehavior: Clip.none,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: employee!.assets!.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
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
              clipBehavior: Clip.none,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: employee!.empCustomData!.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
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

class _AssetCard extends StatefulWidget {
  final Assets asset;

  const _AssetCard({required this.asset});

  @override
  State<_AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<_AssetCard> {
  double _downloadProgress = 0.0;

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      if (kIsWeb) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('downloading'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 10),
                  Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            );
          },
        ),
      );

      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/$fileName";

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) Navigator.of(context).pop();
      await OpenFilex.open(filePath);

      AppToast.showToast(
        msg: '✅ ${'downloaded'.tr()}: $fileName',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      AppToast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final accent = Color(AppColors.buttons);
    final files = asset.signatureDocumentUrl ?? const <MediaFile>[];
    final hasPeriod = asset.startAt?.isNotEmpty == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
        border: AppBorders.card,
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon, title and serial number
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppCardLeadingAvatar(
                icon: Icons.devices_other_rounded,
                borderColor: accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.blackContent(context)
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    if (asset.serialNumber?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tag_rounded,
                                size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(asset.serialNumber!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.greyContent(context)
                                      .copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (asset.description?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            ExpandableTextWidget(
              text: asset.description!,
              maxLines: 2,
              style: AppStyles.greyContent(context)
                  .copyWith(fontSize: 12.5, height: 1.5),
            ),
          ],
          if (hasPeriod) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // the day the employee received the asset
                        Text(
                          'asset_received_on'.tr(),
                          style: AppStyles.greyContent(context).copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          asset.endsAt?.isNotEmpty == true
                              ? '${_fmt(asset.startAt)}  →  ${_fmt(asset.endsAt)}'
                              : _fmt(asset.startAt),
                          style: AppStyles.blackContent(context).copyWith(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (asset.assetStatus?.isNotEmpty == true ||
              asset.assignmentStatus?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (asset.assetStatus?.isNotEmpty == true)
                  _Badge(
                    prefixLabel: 'asset_status'.tr(),
                    label: asset.assetStatus!.tr(),
                    isPositive: asset.assetStatus == 'active' ||
                        asset.assetStatus!.toLowerCase() == 'good',
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
          if (files.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_file_rounded, size: 16, color: accent),
                const SizedBox(width: 6),
                Text(
                  '${'attachments'.tr()} (${files.length})',
                  style: AppStyles.primaryContent(context).copyWith(
                      fontWeight: FontWeight.w700, fontSize: AppSizes.s13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...files.map<Widget>((file) => _AttachmentTile(
                  file: file,
                  onView: file.file == null
                      ? null
                      : () => UrlLauncherServiceEx.launch(
                            context: context,
                            url: file.file!,
                            mode: LaunchMode.externalApplication,
                          ),
                  onDownload: file.file == null
                      ? null
                      : () => _downloadFile(
                          file.file!, file.file!.split('/').last),
                )),
          ],
        ],
      ),
    );
  }

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat('dd MMM yyyy', context.locale.languageCode).format(DateTime.parse(raw));
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: badgeColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          if (prefixLabel != null) ...[
            Text(
              '${prefixLabel!}: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: badgeColor.withOpacity(0.75),
              ),
            ),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: badgeColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final MediaFile file;
  final VoidCallback? onView;
  final VoidCallback? onDownload;

  const _AttachmentTile({required this.file, this.onView, this.onDownload});

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: (file.thumbnail != null && file.thumbnail!.isNotEmpty)
                ? Image.network(
                    file.thumbnail!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fileIcon(accent),
                  )
                : _fileIcon(accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.title ?? file.type ?? 'File',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          if (onView != null)
            _RoundAction(icon: Icons.visibility_rounded, color: accent, onTap: onView!),
          if (onDownload != null) ...[
            const SizedBox(width: 6),
            _RoundAction(icon: Icons.download_rounded, color: accent, onTap: onDownload!),
          ],
        ],
      ),
    );
  }

  Widget _fileIcon(Color accent) => Container(
        width: 40,
        height: 40,
        color: accent.withOpacity(0.10),
        child: Icon(Icons.insert_drive_file_rounded, color: accent, size: 22),
      );
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: color.withOpacity(0.10), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
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
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: AppBorders.card,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: Color(AppColors.buttons), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: ExpandableTextWidget(
              text: item,
              maxLines: 3,
              style: AppStyles.blackContent(context)
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
