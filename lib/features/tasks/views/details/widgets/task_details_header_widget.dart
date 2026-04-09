import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/services/layout_service.dart';
import '../../../../../core/widgets/app_bar_with_bookmark.widget.dart';


class TaskDetailsHeaderWidget extends StatelessWidget {
  var taskName;
  var taskDate;
  var assets;
  var taskCreatedAt;
  TaskDetailsHeaderWidget({super.key, this.taskDate, this.taskName, this.assets, this.taskCreatedAt});

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
    TextStyle style = AppStyles.whiteContent(context).copyWith(
      color: Colors.white.withOpacity(0.8),
      fontSize: AppSizes.s12.sp,
      fontWeight: FontWeight.w400,
    );
    return Container(
      width: 1.sw,
      height: 300.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s32.r),
            bottomRight: Radius.circular(AppSizes.s32.r)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.s32.r),
                bottomRight: Radius.circular(AppSizes.s32.r)),
            child: Image.asset(
              "assets/images/png/tasks-app-bar.png",
              fit: BoxFit.cover,
              alignment: const Alignment(0.5, 0.0),
              width: 1.sw,
              height: 300.h,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          AppStrings.tasksInfo.tr(),
                          style: AppStyles.heading(context).copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(flex: 2),
                    SvgPicture.asset(
                      "$assets",
                      height: 50.r,
                      width: 50.r,
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      taskName?.toUpperCase() ?? "",
                      style: AppStyles.heading(context).copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (taskCreatedAt != null && taskCreatedAt != "")
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(taskCreatedAt))
                                .toString(),
                            style: style,
                          ),
                        if (taskDate != null && taskDate != "")
                          Text(" : ", style: style),
                        if (taskDate != null && taskDate != "")
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(taskDate))
                                .toString(),
                            style: style,
                          ),
                        if (taskCreatedAt != null &&
                            taskCreatedAt != "" &&
                            taskDate != null &&
                            taskDate != "")
                          Text(
                            formatDateDifference(DateTime.parse(taskCreatedAt),
                                        DateTime.parse(taskDate)) !=
                                    "0 ${AppStrings.days.tr()}" &&
                                    formatDateDifference(
                                            DateTime.parse(taskCreatedAt),
                                            DateTime.parse(taskDate)) !=
                                        "0 ${AppStrings.month.tr()}"
                                ? " (${formatDateDifference(DateTime.parse(taskCreatedAt), DateTime.parse(taskDate))})"
                                : " (1 ${AppStrings.days.tr()})",
                            style: style,
                          ),
                      ],
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
