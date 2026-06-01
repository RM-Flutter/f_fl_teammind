import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_sizes.dart';

class FingerprintCardOffline extends StatelessWidget {
  List? fingerprint = [];
   FingerprintCardOffline({super.key, this.fingerprint});

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
                  color: Color(AppColors.buttons).withOpacity(0.2),
                  offset: const Offset(0, 0),
                  blurRadius: 2.5.r,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (fingerprint![index]['finger_day'] != null)Container(
                    width: AppSizes.s50.w,
                    padding: EdgeInsets.all(AppSizes.s4.w),
                    decoration: BoxDecoration(
                      color: Color(AppColors.buttons),
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
                            height: 1.5.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSizes.s8.w),
                  child: AutoSizeText(
                    _formatFingerprintDate(fingerprint![index]['finger_day'].toString(), context),
                    style: AppStyles.primaryContent(context).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: AppSizes.s14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        separatorBuilder: (context, index) => SizedBox(height: 15.h,),
        itemCount: fingerprint!.length);
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
      ];
      
      for (String format in formats) {
        try {
          date = DateFormat(format).parse(dateString);
          break;
        } catch (_) {}
      }
      
      if (date == null) return dateString;
      
      return DateFormat('yyyy-MM-dd hh:mm a', LocalizationService.isArabic(context: context) ? 'ar' : 'en').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
