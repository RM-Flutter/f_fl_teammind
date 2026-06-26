import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/services/localization_service.dart';

class TaskListTileWidget extends StatelessWidget {
  final String title;
  final String date;
  final String createdAt;
  final String id;
  final String assetName;
  final String complete;
  final VoidCallback? onTap;
  const TaskListTileWidget({
    super.key,
    required this.date,
    required this.onTap,
    required this.createdAt,
    required this.complete,
    required this.id,
    required this.title,
    required this.assetName,
  });

  @override
  Widget build(BuildContext context) {
    String formatDateDifference(DateTime start, DateTime end) {
      if (end.isBefore(start)) {
        final temp = start;
        start = end;
        end = temp;
      }
      int totalDays = end.difference(start).inDays;
      int months = totalDays ~/ 30;
      int days = totalDays % 30;
      if (months > 0) {
        return "$months ${AppStrings.month.tr()}";
      } else {
        return "$days ${AppStrings.days.tr()}";
      }
    }

    return IntrinsicHeight(
      child: GestureDetector(
        onTap: onTap ?? (){},
        child: Container(
          margin: EdgeInsets.only(bottom: AppSizes.s12),
          decoration: BoxDecoration(
            boxShadow: (complete == "completed" || complete == "closed")
                ? null : null,
            border: Border.all(
              color: (complete == "completed" || complete == "closed")
                  ? Color(AppColors.buttons)
                  : Colors.grey.shade300,
              width: 1.0,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.s12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: LocalizationService.isArabic(context: context) ? 0 : 15,
                    right: LocalizationService.isArabic(context: context) ? 15 : 0,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        assetName, 
                        width: 24, 
                        height: 24,
                        colorFilter: ColorFilter.mode(Color(AppColors.buttons), BlendMode.srcIn),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: AppStyles.heading(context).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                if (createdAt.isNotEmpty)
                                  Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(DateTime.parse(createdAt))
                                        .toString(),
                                    style: AppStyles.greyContent(context).copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                      color: Color(AppColors.grey4F),
                                    ),
                                  ),
                                if (date.isNotEmpty)
                                  Text(
                                    " | ",
                                    style: AppStyles.greyContent(context).copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                      color: Color(AppColors.grey4F),
                                    ),
                                  ),
                                if (date.isNotEmpty)
                                  Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(DateTime.parse(date))
                                        .toString(),
                                    style: AppStyles.greyContent(context).copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                      color: Color(AppColors.grey4F),
                                    ),
                                  ),
                                if (createdAt.isNotEmpty && date.isNotEmpty)
                                  Text(
                                    formatDateDifference(DateTime.parse(createdAt),
                                                DateTime.parse(date)) !=
                                            "0 ${AppStrings.days.tr()}" &&
                                            formatDateDifference(
                                                    DateTime.parse(createdAt),
                                                    DateTime.parse(date)) !=
                                                "0 ${AppStrings.month.tr()}"
                                        ? " (${formatDateDifference(DateTime.parse(createdAt), DateTime.parse(date))})"
                                        : " (1 ${AppStrings.days.tr()})",
                                    style: AppStyles.greyContent(context).copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                      color: Color(AppColors.grey4F),
                                    ),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (complete == "completed" || complete == "closed")
                Container(
                  width: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons),
                    borderRadius: BorderRadius.only(
                      topRight: LocalizationService.isArabic(context: context)
                          ? const Radius.circular(0)
                          : Radius.circular(AppSizes.s12),
                      bottomRight: LocalizationService.isArabic(context: context)
                          ? const Radius.circular(0)
                          : Radius.circular(AppSizes.s12),
                      topLeft: LocalizationService.isArabic(context: context)
                          ? Radius.circular(AppSizes.s12)
                          : const Radius.circular(0),
                      bottomLeft: LocalizationService.isArabic(context: context)
                          ? Radius.circular(AppSizes.s12)
                          : const Radius.circular(0),
                    ),
                  ),
                  child: Icon(
                    complete == "closed" ? Icons.close : Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}