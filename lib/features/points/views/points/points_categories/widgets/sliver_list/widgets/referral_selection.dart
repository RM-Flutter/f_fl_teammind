import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../prize/widgets/raya/widgets/bottom_sheet_external_success.dart';

class ReferralSection extends StatelessWidget {
  ReferralSection({super.key,});

  @override
  Widget build(BuildContext context) {
    final jsonString = CacheHelper.getString("US1");
    var us1Cache;
    if (jsonString != null && jsonString != "") {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
    }
    return  Padding(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(AppStrings.referralDescripe.tr(), style: const TextStyle(height: 24/12, fontSize: 12, fontWeight: FontWeight.w400, color: Color(AppColors.gray1),),textAlign: TextAlign.center,)
          ,const SizedBox(height: 25,),
          Text(AppStrings.referralCodeInviteFriend.tr().toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(AppColors.oc1),),textAlign: TextAlign.center,)
          ,const SizedBox(height: 10,),
          Container(
            height: 50,
            alignment: Alignment.center,
            padding:  const EdgeInsets.symmetric(horizontal: 15),
            decoration: ShapeDecoration(
              color: AppThemeService.colorPalette.tertiaryColorBackground.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.s10),
                side: const BorderSide(
                  color: Color(0xffE3E5E5),
                  width: 1.0,
                ),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Row(
              children: [
                Text(us1Cache['referral_code'].toString(), style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color(AppColors.gray1)),),
                const Spacer(),
                GestureDetector(
                  onTap: (){
                    PointsSuccessSheet.copyToClipboard(context, text: us1Cache['referral_code'].toString());
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent
                    ),
                    child: Text(AppStrings.copy.tr(), style: const TextStyle(color: Color(AppColors.oc1), fontSize: 12, fontWeight: FontWeight.w600),),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
