import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';


class SuccessfulSendRequestBottomsheet extends StatelessWidget {

 @override
 Widget build(BuildContext context) {
  return Container(
   height: MediaQuery.of(context).size.height * 0.5,
   width: double.infinity,
   decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
   ),
   child: Column(
    children: [
     SizedBox(height: 30),
     SvgPicture.asset("assets/images/svg/success_meeting.svg"),
     SizedBox(height: 15,),
     Text(AppStrings.successful.tr().toUpperCase(), style: AppStyles.primaryContent(context).copyWith(fontSize: 24.sp,
       fontWeight: FontWeight.w700)),
     Padding(
      padding: EdgeInsets.all(15.0),
      child: Text(
       AppStrings.youWillBeRepliedSoonThankYouForChoosingOurApp.tr().toUpperCase(),
       textAlign: TextAlign.center,
       style: AppStyles.almostBlack1BContent(context).copyWith(
         fontWeight: FontWeight.w500,
         fontSize: 14.sp)),
     ),
     Spacer(),
     CustomElevatedButton(
       onPressed: () async {
        Navigator.pop(context);
        Navigator.pop(context);
       },
       title: AppStrings.backToMyRequests.tr().toUpperCase(),
       isPrimaryBackground: true,
       isFuture: false),
     SizedBox(height: 20),
    ],
   ),
  );
 }
}


