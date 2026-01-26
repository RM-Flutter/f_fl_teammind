import 'dart:convert';

import 'package:app_test/modules/points/widgets/add_friend_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/all_bottom_sheet.dart';
import 'package:app_test/core/widgets/slider_home_menu.dart';
import 'package:app_test/modules/home/controllers/home_controller.dart';


class ReferralSection extends StatefulWidget {
  const ReferralSection({super.key});

  @override
  State<ReferralSection> createState() => _ReferralSectionState();
}

class _ReferralSectionState extends State<ReferralSection> {
  TextEditingController linkController = TextEditingController();
  TextEditingController friendNameController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  void copyToClipboard(BuildContext context, {text}) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
        msg: AppStrings.textCopiedToClipboard.tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => HomeController(),
    child: Consumer<HomeController>(
      builder: (context, value, child) {
        final json2String = CacheHelper.getString("US2");
        Map<String, dynamic> us2Cache = {};
        if (json2String != null && json2String != "") {
          us2Cache = json.decode(json2String) as Map<String, dynamic>;
        }
        final json1String = CacheHelper.getString("US1");
        Map<String, dynamic> us1Cache = {};
        if (json1String != null && json1String != "") {
          us1Cache = json.decode(json1String) as Map<String, dynamic>;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            if(!kIsWeb)  Container(
                width: kIsWeb ? 800:double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.aboutPointsProgram.tr().toUpperCase(),
                  style:  TextStyle(
                    fontSize: 14,
                    color: Color(AppColors.primary),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if(!kIsWeb) const SizedBox(height: 15,),
              if(!kIsWeb) Text(
                AppStrings.pointsCondationAbout.tr(),
                style:  const TextStyle(
                  fontSize: 12,
                  color: Color(AppColors.black),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if(!kIsWeb) const SizedBox(height: 30,),
              Container(
                alignment: Alignment.topLeft,
                height: 200,
                child: ListView(
                  reverse: false,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: (){
                        defaultActionBottomSheet(context: context,
                            viewHeaderIcon : false,
                            widgetTextFormField: false,
                            viewRefLinkButton: true,
                            refLink: us2Cache['referral_form'].toString(),
                            title: AppStrings.referralLink.tr().toUpperCase(),
                            subTitle: AppStrings.referralLinkDescripe.tr(),
                            buttonText: AppStrings.copy.tr().toUpperCase(),
                            onTapButton:(){
                              copyToClipboard(context, text: us2Cache['referral_form']);
                            }
                        );
                      },
                      child: SliderHomeMenu2(
                        title: AppStrings.referralLink.tr().toUpperCase(),
                        description: AppStrings.inviteYourFriend.tr().toUpperCase(),
                        src: "assets/images/svg/ref_link.svg",
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        defaultActionBottomSheet(context: context,
                            viewHeaderIcon : false,
                            widgetTextFormField: false,
                            viewRefLinkButton: true,
                            refLink: us1Cache['referral_code'].toString(),
                            title: AppStrings.referralCode.tr().toUpperCase(),
                            subTitle: AppStrings.referralCodeDescripe.tr(),
                            buttonText: AppStrings.copy.tr().toUpperCase(),
                            onTapButton:(){
                              copyToClipboard(context, text: us1Cache['referral_code']);
                            }
                        );
                      },
                      child: SliderHomeMenu2(
                        title: AppStrings.referralCode.tr().toUpperCase(),
                        description: AppStrings.inviteYourFriend.tr().toUpperCase(),
                        src: "assets/images/svg/ref_link.svg",
                      ),
                    ),
                   if(!kIsWeb) GestureDetector(
                      onTap: (){
                        context.pushNamed(AppRoutes.pointsContactScreenView.name,
                            pathParameters: {'lang': context.locale.languageCode,});
                      },
                      child: SliderHomeMenu2(
                        title: AppStrings.recommend.tr().toUpperCase(),
                        description: AppStrings.fromContactList.tr().toUpperCase(),
                        src: "assets/images/svg/rec.svg",
                      ),
                    ),
                    const SizedBox(width: 0,),
                    GestureDetector(
                      onTap: ()async{
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          builder: (BuildContext context) {
                            return const AddFriendBottomSheet();
                          },
                        );
                      },
                      child: SliderHomeMenu2(
                        title: AppStrings.registerFriend.tr().toUpperCase(),
                        description: AppStrings.invitation.tr().toUpperCase(),
                        src: "assets/images/svg/reg_fri.svg",
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    ),
    );
  }
}
