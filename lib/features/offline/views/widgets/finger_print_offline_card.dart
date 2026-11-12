import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/date_service.dart';

import '../../../../core/constants/app_strings.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

class FingerprintCardOffiline extends StatelessWidget {
  final List? fingerprint;
  final void Function(int index)? onDelete;
  final Set<int>? deletingIndexes;

  const FingerprintCardOffiline({
    super.key,
    this.fingerprint,
    this.onDelete,
    this.deletingIndexes,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        reverse: false,
        itemBuilder: (context, index) {
          final String? uploadError =
              fingerprint![index]['upload_error']?.toString();
          final bool hasError = uploadError != null && uploadError.isNotEmpty;
          final accentColor = hasError
              ? const Color(0xFFC62828)
              : Color(AppColors.buttons);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppCard(
                border: hasError
                    ? Border.all(color: Colors.red, width: 1.5)
                    : AppBorders.card,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppCardLeadingAvatar(
                      icon: _getFingerprintTypeIcon(fingerprint![index]['type']),
                      borderColor: accentColor,
                    ),
                    const SizedBox(width: AppSizes.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatFingerprintDate(
                                fingerprint![index]['finger_day'].toString(),
                                context),
                            style: AppStyles.heading(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSizes.s2),
                          Text(
                            _getFingerprintTypeLabel(
                                fingerprint![index]['type']),
                            style: AppStyles.subtitleContent(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: AppSizes.s8),
                      IconButton(
                        icon: deletingIndexes != null &&
                                deletingIndexes!.contains(index)
                            ? SizedBox(
                                width: 18.w,
                                height: 18.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_outline_rounded,
                                color: Colors.red),
                        onPressed: (deletingIndexes != null &&
                                deletingIndexes!.contains(index))
                            ? null
                            : () {
                                onDelete!(index);
                              },
                      ),
                    ],
                  ],
                ),
              ),
              if (hasError)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                      top: 6.h, start: 4.w, end: 4.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          uploadError,
                          style: AppStyles.primaryContent(context).copyWith(
                            color: Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(
              height: AppSpacing.cardGap,
            ),
        itemCount: fingerprint!.length);
  }

  IconData _getFingerprintTypeIcon(dynamic type) {
    final t = type?.toString().toLowerCase() ?? '';
    switch (t) {
      case 'fp_scan':
        return Icons.qr_code;
      case 'fp_wifi':
        return Icons.wifi;
      case 'fp_navigate':
      case 'custom_fp_navigate':
        return Icons.gps_fixed;
      case 'fp_bluetooth':
        return Icons.bluetooth;
      default:
        return Icons.fingerprint;
    }
  }

  String _getFingerprintTypeLabel(dynamic type) {
    final t = type?.toString().toLowerCase() ?? '';
    switch (t) {
      case 'fp_scan':
        return AppStrings.qrCode.tr();
      case 'fp_wifi':
        return AppStrings.wifi.tr();
      case 'fp_navigate':
      case 'custom_fp_navigate':
        return AppStrings.gps.tr();
      case 'fp_bluetooth':
        return AppStrings.bluetooth.tr();
      default:
        return t.isNotEmpty ? t : '—';
    }
  }

  String _formatFingerprintDate(String dateString, BuildContext context) {
    try {
      if (dateString.isEmpty) return '';

      DateTime? date;

      // Try different date formats
      List<String> formats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd',
        'dd-MM-yyyy HH:mm:ss',
        'dd-MM-yyyy',
        'dd/MM/yyyy HH:mm:ss',
        'dd/MM/yyyy',
      ];

      for (String format in formats) {
        try {
          date = DateFormat(format).parse(dateString);
          break;
        } catch (e) {
          continue;
        }
      }

      if (date == null) {
        // If all formats fail, try DateTime.parse as last resort
        try {
          date = DateTime.parse(dateString);
        } catch (e) {
          return dateString; // Return original string if parsing fails
        }
      }

      // Format the date for display
      return DateFormat('d-M-yyyy || hh:mm:ss',
              LocalizationService.isArabic(context: context) ? "ar" : "en")
          .format(date);
    } catch (e) {
      return dateString; // Return original string if formatting fails
    }
  }
}
