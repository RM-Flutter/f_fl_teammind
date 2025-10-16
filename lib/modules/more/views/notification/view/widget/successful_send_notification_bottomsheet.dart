import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';

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
          Text(AppStrings.successful.tr().toUpperCase(), style: const TextStyle(fontSize: 24,
              fontWeight: FontWeight.w700, color: Color(AppColors.primary))),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              AppStrings.youWillBeRepliedSoonThankYouForChoosingOurApp.tr().toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff1B1B1B),
                  fontWeight: FontWeight.w500,
                  fontSize: 14
              ),
            ),
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
