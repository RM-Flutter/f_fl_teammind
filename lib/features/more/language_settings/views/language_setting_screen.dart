import 'dart:convert';

import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/fcm_token.service.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/more/language_settings/controllers/language_controller.dart';

import 'package:app_test/core/constants/user_consts.dart';


class LangSettingScreens extends StatefulWidget {
  @override
  State<LangSettingScreens> createState() => _LangSettingScreensState();
}

class _LangSettingScreensState extends State<LangSettingScreens> {
  int? selectIndex;
  String? selectValue;
  @override
  Widget build(BuildContext context) {
    List<String>? lang = (AppSettingsService.getSettings(
        context: context,
        settingsType: SettingsType.generalSettings) as GeneralSettingsModel)
        .availableLang;
    lang = (lang == null || lang.isEmpty)
        ? ["English language",
      "اللغه العربية"]
        : lang;
    print("is--->${context.locale.languageCode}");
    if(context.locale.languageCode != null){
      if(context.locale.languageCode.contains("en")){
        selectIndex = 0;
      }if(context.locale.languageCode.contains("ar")){
        selectIndex = 1;
      }
    }
    print("LANG Is : $lang");
    return ChangeNotifierProvider(create: (context) => LangControllerProvider(),
      child: Consumer<LangControllerProvider>(builder: (context, value, child) {
        return Scaffold(
          backgroundColor: Color(AppColors.white),
          appBar: AppBarWithBookmark(
            backgroundColor: Color(AppColors.white),
            leading: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back, color: Color(AppColors.dark),)),
            title: AppStrings.languageSettings.tr().toUpperCase(),
            titleStyle: TextStyle(
                fontSize: AppSizes.s16,
                fontWeight: FontWeight.w700,
                color: Color(AppColors.dark)),
            routeName: AppRoutes.langSettingScreen.name,
          ),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 1,
                  width: MediaQuery.of(context).size.width < 600
                      ? double.infinity
                      : 1100,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: ()async{
                                  setState(() {
                                    selectIndex = index;
                                    selectValue = lang![index].toString();
                                  });
                                  print("selectValue --> ${selectValue}");
                                  print("selectValue is ----> $selectValue");
                                  CacheHelper.setString(key: "lang", value: (selectValue == "ar"|| selectValue == "اللغه العربية")? "ar" : "en");
                                  LocalizationService.setLocaleAndUpdateUrl(
                                      context: context, newLangCode: (selectValue == "ar"|| selectValue == "اللغه العربية")? "ar" : "en");
                                  await value.setDeviceSysLang(
                                    state: (selectValue == "ar" || selectValue == "اللغه العربية")? "ar" : "en",
                                    context: context,
                                    notiToken: FcmTokenService.getCachedToken(),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                  decoration: BoxDecoration(
                                      color: Color(AppColors.white),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(AppColors.lightGrey).withOpacity(0.5),
                                          blurRadius: AppSizes.s5,
                                          spreadRadius: 1,
                                        )
                                      ]
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Color(AppColors.primary)),
                                            color:(selectIndex == index)? Color(AppColors.primary) : Color(AppColors.white)
                                        ),
                                        child: const Icon(Icons.check, color: Colors.white, size: 18,),
                                      ),
                                      const SizedBox(width: 15,),
                                      Text((lang![index].contains("English language")||lang![index].contains("en"))?"English language".toUpperCase() : "اللغه العربية", style: TextStyle(color: Color(AppColors.almostBlack), fontWeight: FontWeight.w500, fontSize: 14),)
                                      ,const Spacer(),
                                      Text((lang![index].contains("en"))?"change".toUpperCase() : "تغيير", style: TextStyle(fontSize: 12 ,fontWeight: FontWeight.w500, color: Color(AppColors.primary)),)
                                    ],
                                  ),
                                ),
                              ),
                              separatorBuilder: (context, index) => const SizedBox(height: 19,),
                              padding: EdgeInsets.zero,
                              itemCount: lang!.length
                          ),
                          const SizedBox(height: 40,),
                          // SizedBox(
                          //   width: MediaQuery.sizeOf(context).width * 0.6,
                          //   child: GestureDetector(
                          //     onTap: (){
                          //       //  Navigator.pop(context);
                          //     },
                          //     child: Container(
                          //       height: 50,
                          //       alignment: Alignment.center,
                          //       decoration: BoxDecoration(
                          //         color: Color(AppColors.dark),
                          //         borderRadius: BorderRadius.circular(50),
                          //       ),
                          //       padding: const EdgeInsets.symmetric(horizontal: 40),
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           SvgPicture.asset("assets/images/svg/add-lang.svg"),
                          //           const SizedBox(width: 12,),
                          //           Text(
                          //             AppStrings.addLanguage.tr().toUpperCase(),
                          //             style:TextStyle(
                          //                 fontSize: 12,
                          //                 fontWeight: FontWeight.w500,
                          //                 color: Color(AppColors.white)
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                  )
              ),
            ),
          ),
        );
      },),
    );
  }
}
