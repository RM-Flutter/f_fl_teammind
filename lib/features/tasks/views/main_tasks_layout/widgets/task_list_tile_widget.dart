import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  TaskListTileWidget({
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
          margin: const EdgeInsets.only(bottom: AppSizes.s12),
          decoration: BoxDecoration(
            boxShadow: (complete == "completed" || complete == "closed")
                ? null : null,
                // : [
                //     BoxShadow(
                //       color: Color(AppColors.lightGrey).withValues(alpha: 0.5),
                //       blurRadius: AppSizes.s5,
                //       spreadRadius: 1,
                //     )
                //   ],
            border: Border.all(
              color: (complete == "completed" || complete == "closed")
                  ? Color(AppColors.primary)
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
                      SvgPicture.asset(assetName),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(AppColors.dark),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                if (createdAt.isNotEmpty)
                                  Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(DateTime.parse(createdAt))
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                      color: Color(AppColors.grey4F),
                                    ),
                                  ),
                                if (date.isNotEmpty)
                                  const Text(
                                    " | ",
                                    style: TextStyle(
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
                                    style: const TextStyle(
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
                                    style: TextStyle(
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
                    color: Color(AppColors.primary),
                    borderRadius: BorderRadius.only(
                      topRight: LocalizationService.isArabic(context: context)
                          ? const Radius.circular(0)
                          : const Radius.circular(AppSizes.s12),
                      bottomRight: LocalizationService.isArabic(context: context)
                          ? const Radius.circular(0)
                          : const Radius.circular(AppSizes.s12),
                      topLeft: LocalizationService.isArabic(context: context)
                          ? const Radius.circular(AppSizes.s12)
                          : const Radius.circular(0),
                      bottomLeft: LocalizationService.isArabic(context: context)
                          ? const Radius.circular(AppSizes.s12)
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