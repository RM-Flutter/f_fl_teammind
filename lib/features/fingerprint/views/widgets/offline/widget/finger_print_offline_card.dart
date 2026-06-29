import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';

class FingerprintCardOffline extends StatelessWidget {
  final List? fingerprint;
  final void Function(int index)? onDelete;
  final Set<int>? deletingIndexes;

  const FingerprintCardOffline({
    super.key,
    this.fingerprint,
    this.onDelete,
    this.deletingIndexes,
  });

  @override
  Widget build(BuildContext context) {
    if (fingerprint == null || fingerprint!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: false,
      itemBuilder: (context, index) {
        final item = fingerprint![index];
        final fingerDay = item['finger_day'];
        final type = item['type'];

        return Container(
          padding: EdgeInsets.all(AppSizes.s8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.s10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(AppColors.buttons).withOpacity(0.2),
                offset: const Offset(0, 0),
                blurRadius: 2.5,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Day badge
              if (fingerDay != null)
                Container(
                  width: AppSizes.s50,
                  padding: EdgeInsets.symmetric(
                      vertical: AppSizes.s6, horizontal: AppSizes.s4),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons),
                    borderRadius: BorderRadius.circular(AppSizes.s8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        DateService.getWeekdayName(fingerDay, context) ?? '',
                        maxLines: 1,
                        style: AppStyles.whiteContent(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.s12,
                        ),
                      ),
                      AutoSizeText(
                        DateService.getDaysInMonth(fingerDay)?.toString() ?? '-',
                        style: AppStyles.whiteContent(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.s14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

              // Date + type info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.s8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Formatted date & time
                      AutoSizeText(
                        _formatFingerprintDate(
                            fingerDay?.toString() ?? '', context),
                        style: AppStyles.primaryContent(context).copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: AppSizes.s14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      // Fingerprint type row
                      Row(
                        children: [
                          Icon(
                            _getFingerprintTypeIcon(type),
                            size: 14,
                            color: Color(AppColors.buttons),
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _getFingerprintTypeLabel(type),
                              style: AppStyles.primaryContent(context).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(AppColors.buttons),
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

              // Delete button
              if (onDelete != null)
                SizedBox(
                  width: 36,
                  height: 36,
                  child: (deletingIndexes != null &&
                          deletingIndexes!.contains(index))
                      ? Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          ),
                        )
                      : IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 22),
                          onPressed: () => onDelete!(index),
                        ),
                ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemCount: fingerprint!.length,
    );
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
        'yyyy-MM-dd HH:mm',
        'yyyy-MM-dd',
        'dd-MM-yyyy HH:mm:ss',
        'dd-MM-yyyy',
      ];

      for (String format in formats) {
        try {
          date = DateFormat(format).parse(dateString);
          break;
        } catch (_) {}
      }

      if (date == null) {
        try {
          date = DateTime.parse(dateString);
        } catch (_) {
          return dateString;
        }
      }

      return DateFormat(
        'd-M-yyyy || hh:mm a',
        LocalizationService.isArabic(context: context) ? 'ar' : 'en',
      ).format(date);
    } catch (e) {
      return dateString;
    }
  }
}
