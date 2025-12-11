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

class FingerprintCardOffiline extends StatelessWidget {
  List? fingerprint = [];
   FingerprintCardOffiline({super.key, this.fingerprint});

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
                if (fingerprint![index]['finger_day'] != null)Container(
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
                          DateService.getWeekdayName(fingerprint![index]['finger_day'], context) ?? '',
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizes.s12,
                            color: Colors.white,
                          ),
                        ),
                        AutoSizeText(
                          DateService.getDaysInMonth(fingerprint![index]['finger_day'])
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
                  child: AutoSizeText(
                    _formatFingerprintDate(fingerprint![index]['finger_day'].toString(), context),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: AppSizes.s14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 15,),
        itemCount: fingerprint!.length);
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
