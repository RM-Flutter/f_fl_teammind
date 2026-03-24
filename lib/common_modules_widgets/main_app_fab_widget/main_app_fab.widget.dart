import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import '../../constants/user_consts.dart';
import '../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../general_services/settings.service.dart';
import '../../models/settings/user_settings.model.dart';
import '../../platform/platform_is.dart';
import '../../utils/custom_expandable_fab/action_button.widget.dart';
import '../../utils/custom_expandable_fab/expandable_fab.dart';
import '../custom_floating_action_button.widget.dart';
import '../../constants/app_images.dart';
import '../../constants/app_sizes.dart';
import '../../general_services/usg_packages.service.dart';
import '../../routing/app_router.dart';
import 'main_app_fab.service.dart';

/// على الويب فقط QR والـ GPS يعملان؛ WiFi و Bluetooth لا.
bool _isWebSupportedFingerprint(String method) {
  final m = method.toLowerCase().trim();
  return m == 'fp_scan' || m == 'fp_navigate' || m == 'custom_fp_navigate';
}

class MainAppFabWidget extends StatelessWidget {
  bool? requests = false;
  bool viewRequest = true;
   MainAppFabWidget({
     this.requests,
     required this.viewRequest,
  });

  @override
  Widget build(BuildContext context) {
    var jsonString;
    var gCache;
    UserSettingsModel? userSettingsModel;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }

    userSettingsModel = UserSettingsModel.fromJson(gCache);
    final userSettingsFingerprints = userSettingsModel.avFingerprint;
    List<String>? avFingerprints;
    if (userSettingsFingerprints?.entries != null &&
        userSettingsFingerprints?.entries.isNotEmpty == true) {
      for (MapEntry entry in userSettingsFingerprints!.entries) {
        if ((entry.value as String?)?.toLowerCase().trim() == 'active_all' ||
            (entry.value as String?)?.toLowerCase().trim() == 'active_some') {
          avFingerprints ??= [];
          avFingerprints.add(entry.key);
          //avFingerprints.add("custom_fp_navigate");
          //avFingerprints.add("fp_navigate");
           avFingerprints.remove("fp_machine");
        }
      }
    }
    // على الويب نعرض فقط البصمات اللي تعمل على الويب (QR و GPS) دون المساس بالموبايل
    final List<String>? displayFingerprints = (PlatformIs.web && avFingerprints != null)
        ? avFingerprints!.where(_isWebSupportedFingerprint).toList()
        : avFingerprints;
    final bool showFingerprintFab = UsgPackagesService.isFingerprintActive &&
        userSettingsFingerprints != null &&
        userSettingsFingerprints.isNotEmpty == true &&
        displayFingerprints != null &&
        displayFingerprints.isNotEmpty;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (showFingerprintFab)
          Container(
            margin:  EdgeInsets.only(bottom: viewRequest == true? AppSizes.s75 :  35),
            child: ExpandableFab(
                distance: (displayFingerprints.length < 4) ? AppSizes.s30 * 4 : AppSizes.s30 * displayFingerprints.length,
                children: displayFingerprints.map(
                      (String fingerprintMethod) => ActionButton(
                        icon: Icon(
                          MainFabServices.getFingerprintMethodIcon(
                              fingerprintMethod: fingerprintMethod),
                          color: Colors.white,
                        ),
                        onPressed: () async => await MainFabServices
                            .getFingerprintActionMethodDependsOnFingerprintMethod(
                                context: context,
                                fingerprintMethod: fingerprintMethod),
                      ),
                    )
                    .toList()),
          ),
       if (UsgPackagesService.isRequestsActive && viewRequest == true)
          Positioned(
          child: CustomFloatingActionButton(
            iconPath: AppImages.addFloatingActionButtonIcon,
            onPressed: () async => await context
                .pushNamed(AppRoutes.addRequest.name, pathParameters: {
              'type': 'mine',
              'lang': context.locale.languageCode
            }),
            tagSuffix: 'add',
            height: AppSizes.s16,
            width: AppSizes.s16,
          ),
        ),
      ],
    );
  }
}

/* OLD ACTION BUTTONS
class HomeFloatingActionsButtons extends StatelessWidget {
  const HomeFloatingActionsButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomFloatingActionButton(
          iconPath: AppImages.fingetprintFloatingActionButtonIcon,
          onPressed: () async => await context.pushNamed(
              AppRoutes.employeesList.name,
              pathParameters: {'lang': context.locale.languageCode}),
          tagSuffix: 'fingerprint',
        ),
        gapH12,
        CustomFloatingActionButton(
          iconPath: AppImages.addFloatingActionButtonIcon,
          onPressed: () async => await context
              .pushNamed(AppRoutes.addRequest.name, pathParameters: {
            'type': 'mine',
            'lang': context.locale.languageCode
          }),
          tagSuffix: 'add',
          height: AppSizes.s16,
          width: AppSizes.s16,
        ),
      ],
    );
  }
}

*/
