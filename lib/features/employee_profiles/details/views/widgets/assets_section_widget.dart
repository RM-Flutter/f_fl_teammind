import 'package:app_test/core/services/app_toast.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app_test/core/services/url_launcher_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

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
                  widget.asset.title ?? '',
                  style: AppStyles.blackContent(context)
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                if (widget.asset.serialNumber?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.tag_rounded,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(widget.asset.serialNumber!,
                        style: AppStyles.greyContent(context)
                            .copyWith(fontSize: 12)),
                  ]),
                ],
                if (widget.asset.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(widget.asset.description!,
                      style: AppStyles.greyContent(context)
                          .copyWith(fontSize: 12, height: 1.4)),
                ],
                if (widget.asset.startAt?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(_fmt(widget.asset.startAt),
                        style: AppStyles.greyContent(context)
                            .copyWith(fontSize: 11)),
                    if (widget.asset.endsAt?.isNotEmpty == true) ...[
                      Text('  →  ',
                          style: AppStyles.greyContent(context)
                              .copyWith(fontSize: 11)),
                      Text(_fmt(widget.asset.endsAt),
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
                    if (widget.asset.assetStatus?.isNotEmpty == true)
                      _Badge(
                        prefixLabel: 'asset_status'.tr(),
                        label: widget.asset.assetStatus!.tr(),
                        isPositive: widget.asset.assetStatus == 'active',
                      ),
                    if (widget.asset.assignmentStatus?.isNotEmpty == true)
                      _Badge(
                        prefixLabel: 'assignment_status'.tr(),
                        label: widget.asset.assignmentStatus!.tr(),
                        isPositive: widget.asset.assignmentStatus == 'active',
                        isSecondary: true,
                      ),
                  ],
                ),
                if (widget.asset.signatureDocumentUrl != null &&
                    widget.asset.signatureDocumentUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'attachments'.tr(),
                          style: AppStyles.primaryContent(context).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: AppSizes.s14),
                        ),
                        const SizedBox(height: 8),
                        ...widget.asset.signatureDocumentUrl!
                            .map<Widget>((file) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                if (file.thumbnail != null &&
                                    file.thumbnail!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      file.thumbnail!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                          Icons.insert_drive_file_rounded,
                                          color: Color(AppColors.buttons),
                                          size: 40),
                                    ),
                                  )
                                else
                                  Icon(Icons.insert_drive_file_rounded,
                                      color: Color(AppColors.buttons),
                                      size: 40),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.title ?? file.type ?? 'File',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (file.file != null) ...[
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye,
                                        color:
                                            Color(AppColors.secondaryButton)),
                                    onPressed: () {
                                      UrlLauncherServiceEx.launch(
                                        context: context,
                                        url: file.file!,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.download_rounded,
                                        color: Color(AppColors.buttons)),
                                    onPressed: () {
                                      final fileName =
                                          file.file!.split('/').last;
                                      _downloadFile(file.file!, fileName);
                                    },
                                  ),
                                ]
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
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
