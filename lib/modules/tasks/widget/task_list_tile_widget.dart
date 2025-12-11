import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/routing/app_router.dart';

import '../../../constants/app_sizes.dart';
import '../../../general_services/localization.service.dart';

class TaskListTileWidget extends StatelessWidget {
  final String title;
  final String date;
  final String createdAt;
  final String id;
  final String assetName;
  final String complete;
  var onTap;
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

    return GestureDetector(
      onTap: onTap ?? (){},
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.s12),
        padding: EdgeInsets.only(left: LocalizationService.isArabic(context: context) ?0 :15,
            right: LocalizationService.isArabic(context: context) ?15 :0),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xffC9CFD2).withOpacity(0.5),
                blurRadius: AppSizes.s5,
                spreadRadius: 1,
              )
            ],
            border: Border.all(color: complete == "completed" || complete == "closed"? const Color(AppColors.primary) : Colors.transparent),
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.s8),
            ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(assetName),
                const SizedBox(width: 12,),
                SizedBox(
                  width: !kIsWeb ? MediaQuery.sizeOf(context).width * 0.6 : MediaQuery.sizeOf(context).width * 0.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(AppColors.dark))),
                      const SizedBox(height: 5,),
                      Row(
                        children: [
                          if(createdAt != null && createdAt != "")Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(createdAt)).toString(),style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 8, color: Color(0xff4F4F4F))),
                          if(date != null && date != "")const Text(" | ",style: TextStyle(fontWeight: FontWeight.w400, fontSize: 8, color: Color(0xff4F4F4F))),
                          if(date != null && date != "")Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(date)).toString(),style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 8, color: Color(0xff4F4F4F))),
                          if(createdAt != null && createdAt != "" && date != null && date != "")
                             Text(formatDateDifference(DateTime.parse(createdAt), DateTime.parse(date)) != "0 ${AppStrings.days.tr()}" &&
                                 formatDateDifference(DateTime.parse(createdAt), DateTime.parse(date)) != "0 ${AppStrings.month.tr()}"?
                             " (${formatDateDifference(DateTime.parse(createdAt), DateTime.parse(date))})" : " (1 ${AppStrings.days.tr()})",style: TextStyle(fontWeight: FontWeight.w400, fontSize: 8, color: Color(0xff4F4F4F))),

                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            ),
            Spacer(),
           if(complete == "completed" || complete == "closed") Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 5 ,vertical: 30),
              decoration: BoxDecoration(
                  color: const Color(AppColors.primary),
                  borderRadius: BorderRadius.only(
                    topRight: LocalizationService.isArabic(context: context) ?const Radius.circular(0) : const Radius.circular(4) ,
                    bottomRight: LocalizationService.isArabic(context: context) ?const Radius.circular(0) : const Radius.circular(4) ,
                    topLeft: LocalizationService.isArabic(context: context) ?const Radius.circular(5) : const Radius.circular(0) ,
                    bottomLeft: LocalizationService.isArabic(context: context) ?const Radius.circular(5) : const Radius.circular(0) ,
                  )
              ),
              child: complete == "closed"? Icon(Icons.close, color: Colors.white):Icon(Icons.check, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}