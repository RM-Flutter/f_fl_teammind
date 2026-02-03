import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../general_services/date.service.dart';
import '../../../../models/fingerprint.model.dart';
import '../../../../utils/modal_sheet_helper.dart';
import 'fingerprint_details_modal_sheet.widget.dart';

class FingerprintCard extends StatelessWidget {
  final FingerPrintModel fingerprint;
  const FingerprintCard({super.key, required this.fingerprint});

  @override
  Widget build(BuildContext context) {
    String? formatFingerDatetime(List<FingerDateTime>? fingerDatetime) {
      // Check if the list is empty
      if (fingerDatetime?.isEmpty == true || fingerDatetime == null) {
        return null;
      }

      // Extract the first and last time strings
      String? firstTime = fingerDatetime.first.time;
      String? lastTime = fingerDatetime.last.time;
      if (firstTime == null && lastTime == null) {
        return null;
      }
      // Parse the time strings to DateTime objects
      print("FIRST IS --> ${firstTime}");
      DateTime firstDateTime = DateFormat('hh:mm:ss', "en").parse(firstTime!);
      DateTime lastDateTime = DateFormat('hh:mm:ss', "en").parse(lastTime!);

      // Format the DateTime objects to the desired format (e.g., "hh:mm a")
      String formattedFirstTime = DateFormat('hh:mm a', LocalizationService.isArabic(context: context) ? "ar" :"en").format(firstDateTime);
      String formattedLastTime = DateFormat('hh:mm a', LocalizationService.isArabic(context: context) ? "ar" :"en").format(lastDateTime);

      // Get the length of the list
      int length = fingerDatetime.length;

      // Construct the final string
      String result = '$formattedFirstTime : $formattedLastTime ($length)';

      return result;
    }

    return InkWell(
      onTap: () => ModalSheetHelper.showModalSheet(
          context: context,viewProfile: false,
          height: AppSizes.s400,
          title: AppStrings.fingerprintInfo.tr(),
          modalContent: FingerprintDetailsModalSheet(fingerprint: fingerprint)),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.s8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.s10),
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
            if (fingerprint.fingerDay != null)
              Container(
                width: AppSizes.s50,
                padding: const EdgeInsets.all(AppSizes.s4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppSizes.s8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      DateService.getWeekdayName(fingerprint.fingerDay, context) ?? '',
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.s12,
                        color: Colors.white,
                      ),
                    ),
                    AutoSizeText(
                      DateService.getDaysInMonth(fingerprint.fingerDay)
                              ?.toString() ??
                          ' - ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.s12,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    DateFormat('d-M-yyyy', LocalizationService.isArabic(context: context) ? "ar" :"en").format(DateTime.parse(fingerprint.fingerDay.toString())).toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: AppSizes.s14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  if (formatFingerDatetime(fingerprint.fingerDateTime) != null)
                    AutoSizeText(
                      formatFingerDatetime(fingerprint.fingerDateTime) ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppSizes.s12,
                        letterSpacing: 0.5,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  // if (formatFingerDatetime(fingerprint.fingerDateTime) != null)
                  //   AutoSizeText(
                  //     formatFingerDatetime(fingerprint.fingerDateTime) ?? '',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.w400,
                  //       fontSize: AppSizes.s12,
                  //       letterSpacing: 0.5,
                  //       color: Colors.grey.withOpacity(0.5),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
