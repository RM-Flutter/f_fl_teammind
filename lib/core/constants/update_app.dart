import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';

class UpdateApp{
  static checkForForceUpdate(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final jsonString = CacheHelper.getString("USG");
    var gCache;
    if (jsonString != null) {
      gCache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
    }
    try {
      if (gCache['mandatory_updates_alert_build'] != null || gCache['mandatory_updates_end_build'] != null) {
        if(gCache['mandatory_updates_end_build'] != null && (int.parse(packageInfo.buildNumber.toString())< int.parse(gCache['mandatory_updates_end_build'].toString()))){
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  backgroundColor: Color(AppColors.background),
                  title: Center(
                    child: Text(
                      LocalizationService.isArabic(context: context) ? "يوجد تحديث متاح للتطبيق": "Available Update",
                      style:  TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(AppColors.secondaryButton)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppStrings.youMustUpdateTheAppToContinue.tr(),
                        style:  TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(AppColors.black)),
                        textAlign: TextAlign.center,

                      ),
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    CustomElevatedButton(
                      title: AppStrings.updateNow.tr(),
                      onPressed: () async {
                        final url = Uri.parse(
                            Platform.isAndroid? '${gCache['store_url']['play_store']}' :'${gCache['store_url']['app_store']}' );
                        if (await canLaunchUrl(url)) {
                          if (Platform.isAndroid) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else if (Platform.isIOS) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        } else {
                          throw 'لم يتم فتح متجر Google Play';
                        }
                      },
                      isPrimaryBackground: false,
                    )
                  ],
                ),
              );
            },
          );
        }
        if(gCache['mandatory_updates_alert_build'] != null && (int.parse(packageInfo.buildNumber.toString())< int.parse(gCache['mandatory_updates_alert_build'].toString()))){
          debugPrint("YOU MUST SHOW");
          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return WillPopScope(
                onWillPop: () async => true,
                child: AlertDialog(
                  backgroundColor: Color(AppColors.background),
                  title: Center(
                      child: Text(AppStrings.available_update.tr(),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(AppColors.secondaryButton)),
                        textAlign: TextAlign.center,)
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppStrings.youMustUpdateTheAppToContinue.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Color(AppColors.black))),
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomElevatedButton(
                          title: AppStrings.update.tr(),
                          width: 120,
                          onPressed: () async {

                            final url = Uri.parse(
                                Platform.isAndroid? '${gCache['store_url']['play_store']}' :'${gCache['store_url']['app_store']}' );
                            if (await canLaunchUrl(url)) {
                              if (Platform.isAndroid) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else if (Platform.isIOS) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            } else {
                              throw 'لم يتم فتح متجر Google Play';
                            }
                          },
                          isPrimaryBackground: false,
                        ),
                        const SizedBox(width: 10,),
                        CustomElevatedButton(
                          width: 120,
                          title: AppStrings.cancel.tr(),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          isPrimaryBackground: false,
                        ),
                      ],
                    ),

                  ],
                ),
              );
            },
          );
        }

      }
    } catch (e) {
      debugPrint("❌ Error checking update: $e");
    }
  }
}
