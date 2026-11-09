import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/fcm_token.service.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';

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
        ? ["English Language",
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
          backgroundColor: Color(AppColors.background),
          appBar: AppBarWithBookmark(
            backgroundColor: Colors.white,
            leading: const AppBackButton(),
            title: AppStrings.languageSettings.tr(),
            titleStyle: AppStyles.heading(context).copyWith(
                fontSize: AppSizes.s16,
                fontWeight: FontWeight.w700),
            routeName: AppRoutes.langSettingScreen.name,
          ),
          body: AppContentWidth(
            child: ListView(
              padding: AppSpacing.pagePadding.copyWith(top: AppSpacing.section * 2),
              children: [
                // Big symbol, then a hint, then the two choices side by side.
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(AppColors.buttons).withValues(alpha: 0.10),
                    ),
                    child: Icon(Icons.translate_rounded,
                        size: 34, color: Color(AppColors.buttons)),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'choose_language'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyles.heading(context)
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'choose_language_hint'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyles.greyContent(context).copyWith(fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.section * 2),
                Row(
                  children: [
                    for (var index = 0; index < lang!.length; index++) ...[
                      if (index > 0) const SizedBox(width: AppSpacing.cardGap),
                      Expanded(
                        child: _LanguageTile(
                          isArabic: !(lang![index].contains("English language") ||
                              lang![index].contains("en")),
                          selected: selectIndex == index,
                          onTap: () async {
                            final isArabic = !(lang![index].contains("English language") ||
                                lang![index].contains("en"));
                            setState(() {
                              selectIndex = index;
                              selectValue = lang![index].toString();
                            });
                            final code = isArabic ? "ar" : "en";
                            CacheHelper.setString(key: "lang", value: code);
                            LocalizationService.setLocaleAndUpdateUrl(
                                context: context, newLangCode: code);
                            await value.setDeviceSysLang(
                              state: code,
                              context: context,
                              notiToken: FcmTokenService.getCachedToken(),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },),
    );
  }
}

/// One language as a tall tile: its own symbol, its own name, and a check when it is the one in use.
class _LanguageTile extends StatelessWidget {
  final bool isArabic;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageTile({required this.isArabic, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    return AppCard(
      onTap: onTap,
      color: selected ? accent.withValues(alpha: 0.06) : null,
      border: Border.all(
          color: selected ? accent : Colors.grey.withValues(alpha: 0.18),
          width: selected ? 1.5 : 1),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.section * 1.5, horizontal: AppSpacing.md),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppCardLeadingAvatar(
                size: 64,
                fallbackText: isArabic ? 'ع' : 'EN',
                nameForInitials: isArabic ? 'ع' : 'EN',
                borderColor: selected ? accent : Colors.grey.shade400,
              ),
              if (selected)
                PositionedDirectional(
                  end: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.check_circle_rounded, size: 22, color: accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isArabic ? 'العربية' : 'English',
            style: AppStyles.darkContent(context)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
