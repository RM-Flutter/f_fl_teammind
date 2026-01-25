import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app_test/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';

class SuccessfulSendRequestBottomsheet extends StatelessWidget {
  const SuccessfulSendRequestBottomsheet({super.key});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          SvgPicture.asset("assets/images/svg/success_meeting.svg"),
          const SizedBox(height: 15,),
          Text(AppStrings.successful.tr().toUpperCase(), style:  TextStyle(fontSize: 24,
              fontWeight: FontWeight.w700, color: Color(AppColors.primary))),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              AppStrings.youWillBeRepliedSoonThankYouForChoosingOurApp.tr().toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xff1B1B1B),
                  fontWeight: FontWeight.w500,
                  fontSize: 14
              ),
            ),
          ),
          const Spacer(),
          CustomElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              title: AppStrings.backToMyRequests.tr().toUpperCase(),
              isPrimaryBackground: true,
              isFuture: false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
