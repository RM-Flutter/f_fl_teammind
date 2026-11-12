import 'package:app_test/core/services/app_toast.dart';
import 'dart:convert';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:html'
    if (dart.library.io) 'package:app_test/core/services/dart_html_stub.dart'
    as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/services/url_launcher_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controllers/rewards_and_penalties_controller.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_details_sheet.widget.dart';

class RewardsAndPenaltiesDetailsModal extends StatefulWidget {
  final dynamic rewardAndPenalty;
  final VoidCallback? onCancel;

  const RewardsAndPenaltiesDetailsModal(
      {super.key, required this.rewardAndPenalty, this.onCancel});

  @override
  State<RewardsAndPenaltiesDetailsModal> createState() =>
      _RewardsAndPenaltiesDetailsModalState();
}

class _RewardsAndPenaltiesDetailsModalState
    extends State<RewardsAndPenaltiesDetailsModal> {
  double _downloadProgress = 0.0;

  Future<void> _downloadFile(String url, String fileName) async {
    if (kIsWeb) {
      try {
        final fetchResult = html.window.fetch(url);
        fetchResult.then((response) {
          return (response as dynamic).blob();
        }).then((blob) {
          final blobUrl = html.Url.createObjectUrlFromBlob(blob as dynamic);
          final html.AnchorElement downloadAnchor =
              html.AnchorElement(href: blobUrl);
          downloadAnchor.download = fileName;
          downloadAnchor.style.display = 'none';
          html.document.body?.append(downloadAnchor);
          downloadAnchor.click();
          downloadAnchor.remove();
          html.Url.revokeObjectUrl(blobUrl);
        }).catchError((e) {
          AppToast.showToast(msg: "Download failed: $e");
        });
      } catch (e) {
        AppToast.showToast(msg: "Error: $e");
      }
      return;
    }

    try {
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
                  const SizedBox(height: AppSizes.s10),
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
    final rewardAndPenalty = widget.rewardAndPenalty;
    String? formatDateString(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('EEEE, dd MMM yyyy',
                LocalizationService.isArabic(context: context) ? "ar" : "en")
            .format(dateTime);
      } catch (e) {
        return dateString;
      }
    }

    String? formatDateString2(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        DateTime dateTime = DateTime.parse(dateString);
        return DateFormat('MMM yyyy',
                LocalizationService.isArabic(context: context) ? "ar" : "en")
            .format(dateTime);
      } catch (e) {
        return dateString;
      }
    }

    var jsonString = CacheHelper.getString("US1");
    Map<String, dynamic>? gCache;
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        gCache = json.decode(jsonString) as Map<String, dynamic>;
      } catch (_) {}
    }

    bool canShowComplaintButton = false;
    if (gCache != null &&
        rewardAndPenalty.employeeId != null &&
        gCache['employee_profile_id'] != null) {
      final bool isOwner = rewardAndPenalty.employeeId.toString() ==
          gCache['employee_profile_id'].toString();

      String typeKeyStr = '';
      if (rewardAndPenalty.type is String)
        typeKeyStr = rewardAndPenalty.type.toLowerCase();
      else {
        try {
          typeKeyStr = rewardAndPenalty.type?.key?.toLowerCase() ?? '';
        } catch (_) {}
      }

      final bool isPenalty =
          !typeKeyStr.contains('reward') && !typeKeyStr.contains('bonus');

      bool isWithinTwoMonths = false;
      try {
        String? dateToCheck =
            rewardAndPenalty.createdAt ?? rewardAndPenalty.dueDate;
        if (dateToCheck != null && dateToCheck.isNotEmpty) {
          DateTime penaltyDate = DateTime.parse(dateToCheck);
          DateTime now = DateTime.now();
          isWithinTwoMonths = now.difference(penaltyDate).inDays < 60;
        }
      } catch (_) {}

      canShowComplaintButton = isOwner && isPenalty && isWithinTwoMonths;
    }

    String translateType(String type) {
      if (type.toLowerCase() == 'penalty') return AppStrings.penalty.tr();
      if (type.toLowerCase() == 'reward') return AppStrings.reward.tr();
      return type;
    }

    String translateCategory(String category) {
      if (category.toLowerCase() == 'amount') return AppStrings.amount.tr();
      if (category.toLowerCase() == 'hours') return AppStrings.hours.tr();
      if (category.toLowerCase() == 'days') return AppStrings.days.tr();
      return category;
    }

    String getDynamicValue(dynamic field) {
      if (field == null) return "";
      if (field is String) return field;
      try {
        return field.value ?? field.key ?? "";
      } catch (_) {
        return field.toString();
      }
    }

    String getDynamicKey(dynamic field) {
      if (field == null) return "";
      if (field is String) return field;
      try {
        return field.key ?? field.value ?? "";
      } catch (_) {
        return field.toString();
      }
    }

    final typeValue = translateType(getDynamicValue(rewardAndPenalty.type));
    final categoryValue =
        translateCategory(getDynamicValue(rewardAndPenalty.category));
    final amount = rewardAndPenalty.amount?.toString() ?? "0";
    final actionKey = getDynamicKey(rewardAndPenalty.action);
    final payrollDate = rewardAndPenalty.payroll?.dateFrom;
    final isRewardType = getDynamicKey(rewardAndPenalty.type).toLowerCase().contains('reward') ||
        getDynamicKey(rewardAndPenalty.type).toLowerCase().contains('bonus');
    final accent = isRewardType ? Color(AppColors.successGreen) : Color(AppColors.failureRed);
    final statusLabel = actionKey == 'applied'
        ? AppStrings.applied.tr()
        : actionKey == 'waiting'
            ? 'waiting'.tr()
            : null;
    final statusColor = actionKey == 'applied' ? Color(AppColors.successGreen) : Color(AppColors.warningYellow);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rewardAndPenalty.profile?.name != null)
          AppDetailsHeader(
            icon: isRewardType ? Icons.emoji_events_outlined : Icons.warning_amber_rounded,
            color: accent,
            title: rewardAndPenalty.profile!.name!,
            subtitle: rewardAndPenalty.manager?.name == null
                ? null
                : '${AppStrings.from.tr()} ${rewardAndPenalty.manager!.name!}',
            badgeLabel: statusLabel,
            badgeColor: statusColor,
            onTap: rewardAndPenalty.profile?.id == null
                ? null
                : () => context.pushNamed(AppRoutes.employeeDetails.name, pathParameters: {
                      'id': rewardAndPenalty.profile!.id.toString(),
                      'lang': context.locale.languageCode,
                    }),
          ),
        const SizedBox(height: AppSpacing.section),
        AppDetailsHighlight(
          value: '$amount $categoryValue',
          caption: [
            if (typeValue.isNotEmpty) typeValue,
            if (rewardAndPenalty.dueDate != null) formatDateString2(rewardAndPenalty.dueDate) ?? '',
          ].where((e) => e.isNotEmpty).join(' · '),
          color: accent,
        ),
        const SizedBox(height: AppSpacing.section),
        AppInfoCard(rows: [
          if (rewardAndPenalty.createdAt != null)
            AppInfoRow(label: AppStrings.createdAt.tr(), value: formatDateString(rewardAndPenalty.createdAt) ?? ''),
          AppInfoRow(
              label: AppStrings.applied.tr(),
              value: actionKey == "applied"
                  ? "${AppStrings.yes.tr()} (${payrollDate ?? AppStrings.thereIsNoSalary.tr()})"
                  : AppStrings.no.tr()),
          if (rewardAndPenalty.reason != null && rewardAndPenalty.reason!.isNotEmpty)
            AppInfoRow(label: AppStrings.reason.tr(), value: rewardAndPenalty.reason!),
        ]),
        if (rewardAndPenalty.files != null &&
            rewardAndPenalty.files!.isNotEmpty) ...[
          gapH16,
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'attachments'.tr(),
                  style: AppStyles.primaryContent(context).copyWith(
                      fontWeight: FontWeight.w600, fontSize: AppSizes.s14),
                ),
                gapH8,
                ...rewardAndPenalty.files!.map<Widget>((file) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.s8),
                    padding: const EdgeInsets.all(AppSizes.s8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        if (file.thumbnail != null &&
                            file.thumbnail!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
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
                              color: Color(AppColors.buttons), size: 40),
                        gapW8,
                        Expanded(
                          child: Text(
                            file.title ?? file.type ?? 'File',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (file.file != null) ...[
                          IconButton(
                            icon: Icon(Icons.remove_red_eye,
                                color: Color(AppColors.secondaryButton)),
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
                              final fileName = file.file!.split('/').last;
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
        if ((actionKey == "waiting" && (rewardAndPenalty.canCancel ?? true)) || canShowComplaintButton) ...[
          const SizedBox(height: AppSpacing.section),
          AppSheetActions(
            primaryLabel: canShowComplaintButton ? AppStrings.complaint.tr() : null,
            onPrimary: () {
              final subject = 'complaint_regarding_penalty'.tr();
              final details = LocalizationService.isArabic(context: context)
                  ? 'أتقدم بتظلم/شكوى بخصوص الجزاء الموقع عليّ:\n\n- القيمة: $amount $categoryValue\n- تاريخ توقيع الجزاء: ${formatDateString(rewardAndPenalty.createdAt) ?? ''}\n- السبب: ${rewardAndPenalty.reason ?? ''}\n\nنص الشكوى:\n'
                  : 'I am submitting a complaint regarding the penalty applied to me:\n\n- Amount: $amount $categoryValue\n- Date: ${formatDateString(rewardAndPenalty.createdAt) ?? ''}\n- Reason: ${rewardAndPenalty.reason ?? ''}\n\nComplaint Details:\n';
              context.pushNamed(
                AppRoutes.newComplainScreen.name,
                pathParameters: {'lang': context.locale.languageCode},
                extra: {'initialSubject': subject, 'initialDetails': details},
              );
            },
            dangerLabel: (actionKey == "waiting" && (rewardAndPenalty.canCancel ?? true)) ? 'cancel'.tr() : null,
            onDanger: () {
              context.pop();
              widget.onCancel?.call();
            },
          ),
        ],
        gapH24,
      ],
    );
  }
}

class RewardAndPenaltyRowTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool? isNewLine;

  const RewardAndPenaltyRowTile(
      {super.key,
      required this.title,
      required this.subtitle,
      this.isNewLine = false});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = AppStyles.primaryContent(context)
        .copyWith(fontWeight: FontWeight.w600, fontSize: AppSizes.s14);
    Widget titleWidget = AutoSizeText(title, style: textStyle);

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isNewLine == true
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    AutoSizeText(subtitle,
                        style: textStyle.copyWith(
                            color: Color(AppColors.black),
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    Expanded(
                      child: AutoSizeText(subtitle,
                          style: textStyle.copyWith(
                              color: Color(AppColors.black),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
          gapH16,
        ],
      ),
    );
  }
}
