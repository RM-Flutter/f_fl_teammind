import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization.service.dart';
import 'package:app_test/models/settings/general_settings.model.dart';
import 'package:provider/provider.dart';
import 'package:app_test/modules/more/views/lang_setting/logic/lang_controller.dart';

import 'package:app_test/core/constants/user_consts.dart';

class LangSettingScreens extends StatefulWidget {
  const LangSettingScreens({super.key});

  @override
  State<LangSettingScreens> createState() => _LangSettingScreensState();
}

class _LangSettingScreensState extends State<LangSettingScreens> {
  int? selectIndex;
  String? selectValue;
  @override
  Widget build(BuildContext context) {
    var jsonString;
    Map<String, dynamic> gCache = {};
    GeneralSettingsModel? generalSettingsModel;
    jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
    }
    generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
    List<String>? lang = generalSettingsModel.availableLang;
    lang = (lang == null || lang.isEmpty)
        ? ["English language",
      "اللغه العربية"]
        : lang;
    debugPrint("is--->${context.locale.languageCode}");
    if(context.locale.languageCode.contains("en")){
      selectIndex = 0;
    }if(context.locale.languageCode.contains("ar")){
      selectIndex = 1;
    }
      debugPrint("LANG Is : $lang");
    return ChangeNotifierProvider(create: (context) => LangControllerProvider(),
      child: Consumer<LangControllerProvider>(builder: (context, value, child) {
        return Scaffold(
          backgroundColor: const Color(0xffFFFFFF),
          appBar: AppBar(
            backgroundColor: const Color(0xffFFFFFF),
            leading: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back, color: Color(AppColors.dark),)),
            title: Text(
              AppStrings.languageSettings.tr().toUpperCase(),
              style:  TextStyle(
                  fontSize: AppSizes.s16,
                  fontWeight: FontWeight.w700,
                  color: Color(AppColors.dark)),
            ),
          ),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 1,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
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
                                CacheHelper.setString(key: "lang", value: (selectValue == "ar"|| selectValue == "اللغه العربية")? "ar" : "en");
                                await value.setDeviceSysLang(
                                    state: (selectValue == "ar" || selectValue == "اللغه العربية")? "ar" : "en",
                                    context: context,
                                    notiToken:await FirebaseMessaging.instance.getToken()
                                );
                                LocalizationService.setLocaleAndUpdateUrl(
                                    context: context, newLangCode: (selectValue == "ar"|| selectValue == "اللغه العربية")? "ar" : "en");

                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                decoration: BoxDecoration(
                                    color: const Color(0xffFFFFFF),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xffC9CFD2).withOpacity(0.5),
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
                                          color:(selectIndex == index)? Color(AppColors.primary) : const Color(0xffFFFFFF)
                                      ),
                                      child:  const Icon(Icons.check, color: Colors.white, size: 18,),
                                    ),
                                    const SizedBox(width: 15,),
                                    Text((lang![index].contains("English language")||lang[index].contains("en"))?"English language".toUpperCase() : "اللغه العربية", style:  const TextStyle(color: Color(0xff191C1F), fontWeight: FontWeight.w500, fontSize: 14),)
                                    ,const Spacer(),
                                    Text((lang[index].contains("en"))?"change".toUpperCase() : "تغيير", style: TextStyle(fontSize: 12 ,fontWeight: FontWeight.w500, color: Color(AppColors.primary)),)
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
                        //         color: const Color(AppColors.dark),
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
                        //             style:const TextStyle(
                        //                 fontSize: 12,
                        //                 fontWeight: FontWeight.w500,
                        //                 color: Color(0xffFFFFFF)
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
        );
      },),
    );
  }
}
