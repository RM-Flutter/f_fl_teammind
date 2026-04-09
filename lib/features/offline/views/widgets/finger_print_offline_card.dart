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
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        reverse: false,
        itemBuilder: (context, index) => InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(AppSizes.s8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.s10.r),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  offset: const Offset(0, 0),
                  blurRadius: 2.5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (fingerprint![index]['finger_day'] != null) Container(
                  width: AppSizes.s50.w,
                  padding: EdgeInsets.all(AppSizes.s4.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppSizes.s8.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        DateService.getWeekdayName(fingerprint![index]['finger_day'], context) ?? '',
                        maxLines: 1,
                        style: AppStyles.whiteContent(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.s12.sp,
                        ),
                      ),
                      AutoSizeText(
                        DateService.getDaysInMonth(fingerprint![index]['finger_day'])
                            ?.toString() ??
                            ' - ',
                        style: AppStyles.whiteContent(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.s12.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.s8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AutoSizeText(
                          _formatFingerprintDate(
                              fingerprint![index]['finger_day'].toString(),
                              context),
                          style: AppStyles.secoundaryContent(context).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: AppSizes.s14.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              _getFingerprintTypeIcon(fingerprint![index]['type']),
                              size: 16.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                _getFingerprintTypeLabel(fingerprint![index]['type']),
                                style: AppStyles.primaryContent(context).copyWith(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  const Spacer(),
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
                        : const Icon(Icons.delete, color: Colors.red),
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
        ),
        separatorBuilder: (context, index) => SizedBox(height: 15.h,),
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
      return DateFormat(
          'd-M-yyyy || hh:mm:ss',
          LocalizationService.isArabic(context: context) ? "ar" : "en"
      ).format(date);
    } catch (e) {
      return dateString; // Return original string if formatting fails
    }
  }
}

