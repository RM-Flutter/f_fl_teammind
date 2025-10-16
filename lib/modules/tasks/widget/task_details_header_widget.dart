import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/layout.service.dart';

class TaskDetailsHeaderWidget extends StatelessWidget {
  var taskName;
  var taskDate;
  var assets;
  var taskCreatedAt;
  TaskDetailsHeaderWidget({this.taskDate, this.taskName, this.assets, this.taskCreatedAt});

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
    TextStyle style = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: AppSizes.s10,
      fontWeight: FontWeight.w400,
    );
    return Container(
      height: AppSizes.s300,
      clipBehavior: Clip.antiAlias,
      width: LayoutService.getWidth(context),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/png/home_back.png"),
            fit: BoxFit.fill,
            opacity: 0.4),
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s28),
            bottomRight: Radius.circular(AppSizes.s28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              AppStrings.tasksInfo.tr() ?? '',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(AppSizes.s10),
              child: InkWell(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2)),
                  child: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.white,
                    size: AppSizes.s18,
                  ),
                ),
              ),
            ),
          ),
          gapH20,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset("$assets", height: 38, width: 43,),
                const SizedBox(height: 10,),
                Text(
                  taskName ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.s17,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(taskCreatedAt != null && taskCreatedAt != "")Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(taskCreatedAt)).toString(),style: style),
                    if(taskDate != null && taskDate != "")Text(" | ",style: style),
                    if(taskDate != null && taskDate != "")Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(taskDate)).toString(),style: style),
                    if(taskCreatedAt != null && taskCreatedAt != "" && taskDate != null && taskDate != "")
                      Text(formatDateDifference(DateTime.parse(taskCreatedAt), DateTime.parse(taskDate)) != "0 ${AppStrings.days.tr()}" &&
                          formatDateDifference(DateTime.parse(taskCreatedAt), DateTime.parse(taskDate)) != "0 ${AppStrings.month.tr()}"?
                      " (${formatDateDifference(DateTime.parse(taskCreatedAt), DateTime.parse(taskDate))})" : " (1 ${AppStrings.days.tr()})",style: style),

                  ],
                )
                 ],
            ),
          )
        ],
      ),
    );
  }
}
