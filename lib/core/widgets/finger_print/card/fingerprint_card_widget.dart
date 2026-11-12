import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/fingerprint/data/models/fingerprint_model.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import 'bottom_sheet/finger_print_details_modal_sheet_widget.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

class FingerprintCard extends StatelessWidget {
  final FingerPrintModel fingerprint;
  const FingerprintCard({super.key, required this.fingerprint});

  @override
  Widget build(BuildContext context) {
    String? formatFingerDatetime(List<FingerDateTime>? fingerDatetime) {
      if (fingerDatetime?.isEmpty == true || fingerDatetime == null) {
        return null;
      }

      String? firstTime = fingerDatetime.first.time;
      String? lastTime = fingerDatetime.last.time;
      if (firstTime == null && lastTime == null) {
        return null;
      }
      debugPrint("FIRST IS --> ${firstTime}");
      DateTime firstDateTime = DateFormat('hh:mm:ss', "en").parse(firstTime!);
      DateTime lastDateTime = DateFormat('hh:mm:ss', "en").parse(lastTime!);

      String formattedFirstTime = DateFormat('hh:mm a', LocalizationService.isArabic(context: context) ? "ar" :"en").format(firstDateTime);
      String formattedLastTime = DateFormat('hh:mm a', LocalizationService.isArabic(context: context) ? "ar" :"en").format(lastDateTime);

      int length = fingerDatetime.length;
      String result = '$formattedFirstTime : $formattedLastTime ($length)';
      return result;
    }

    final timeSubtitle = formatFingerDatetime(fingerprint.fingerDateTime);
    final accentColor = Color(AppColors.buttons);

    return AppCard(animateIn: true, 
      onTap: () => ModalSheetHelper.showModalSheet(
          context: context,
          viewProfile: false,
          height: AppSizes.s400,
          title: AppStrings.fingerprintInfo.tr(),
          modalContent: FingerprintDetailsModalSheet(fingerprint: fingerprint)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (fingerprint.fingerDay != null)
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.12),
                border: Border.all(color: accentColor, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    DateService.getWeekdayName(fingerprint.fingerDay, context) ?? '',
                    maxLines: 1,
                    minFontSize: 8,
                    style: AppStyles.heading(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: accentColor,
                      height: 1.1,
                    ),
                  ),
                  AutoSizeText(
                    DateService.getDaysInMonth(fingerprint.fingerDay)?.toString() ?? '-',
                    maxLines: 1,
                    minFontSize: 9,
                    style: AppStyles.heading(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.2,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d-M-yyyy', LocalizationService.isArabic(context: context) ? "ar" : "en")
                      .format(DateTime.parse(fingerprint.fingerDay.toString())),
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (timeSubtitle != null) ...[
                  const SizedBox(height: AppSizes.s3),
                  Text(
                    timeSubtitle,
                    style: AppStyles.subtitleContent(context).copyWith(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
