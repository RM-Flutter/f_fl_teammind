import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/user_consts.dart';
import '../models/settings/general_settings.model.dart';
import '../services/backend_services/api_service/dio_api_service/shared.dart';
import '../services/localization_service.dart';

class LanguageDropdownButton extends StatelessWidget {
  const LanguageDropdownButton({super.key});

  @override
  Widget build(BuildContext context) {
    var jsonString;
    GeneralSettingsModel generalSettingsModel;
    var gCache;
    jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "null") {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          gCache = decoded;
          UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
        }
      } catch (e) {
        debugPrint("Error parsing USG in LanguageDropdownButton: $e");
      }
    }
    if (gCache != null) {
      generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
    } else {
      generalSettingsModel = GeneralSettingsModel(lastUpdateDate: '');
    }
    List<String>? supportedLocales = generalSettingsModel
        .availableLang;
    supportedLocales = (supportedLocales == null || supportedLocales.isEmpty)
        ? ['en', 'ar']
        : supportedLocales;
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSizes.s12,
      right: AppSizes.s10,
      child: PopupMenuButton<String>(
        initialValue: context.locale.languageCode,
        onSelected: (val) => LocalizationService.setLocaleAndUpdateUrl(
            context: context, newLangCode: val),
        itemBuilder: (BuildContext context) {
          return supportedLocales!.map((String locale) {
            return PopupMenuItem<String>(
              value: locale,
              child: Text(
                locale == "ar" ? "عربي" : "English",
                style: TextStyle(
                    color: context.locale.languageCode == locale
                        ? Color(AppColors.secondaryButton)
                        : Color(AppColors.buttons),
                    fontSize: AppSizes.s14,
                    fontWeight: context.locale.languageCode == locale
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            );
          }).toList();
        },
        icon: Stack(
          children: [
            const Icon(
              Icons.circle,
              size: AppSizes.s36,
              color: Colors.white,
            ),
            Positioned.fill(
              child: Icon(
                Icons.language,
                color: Color(AppColors.secondaryButton),
                size: AppSizes.s36,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.s12),
        ),
      ),
      // child: SizedBox(
      //   width: LayoutService.getWidth(context),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: [
      //       SwitchRow(
      //         rightText: 'EN',
      //         leftText: 'AR',
      //         isLoginPageStyle: true,
      //         value: LocalizationService.isArabic(context: context),
      //         onChanged: (newValue) =>
      // LocalizationService.setLocaleAndUpdateUrl(
      //     context: context, newLangCode: newValue ? 'ar' : 'en'),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
