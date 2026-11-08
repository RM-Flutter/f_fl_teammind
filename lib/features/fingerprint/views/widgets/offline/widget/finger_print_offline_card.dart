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
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

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

    final accentColor = Color(AppColors.buttons);

    return ListView.separated(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: false,
      itemBuilder: (context, index) {
        final item = fingerprint![index];
        final fingerDay = item['finger_day'];
        final type = item['type'];

        return AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppCardLeadingAvatar(
                icon: _getFingerprintTypeIcon(type),
                borderColor: accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatFingerprintDate(
                          fingerDay?.toString() ?? '', context),
                      style: AppStyles.heading(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFingerprintTypeLabel(type),
                      style: AppStyles.subtitleContent(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: (deletingIndexes != null &&
                          deletingIndexes!.contains(index))
                      ? const Center(
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
            ],
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.cardGap),
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
