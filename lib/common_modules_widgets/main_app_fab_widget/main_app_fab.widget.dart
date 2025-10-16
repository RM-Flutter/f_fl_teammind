import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../../routing/app_router.dart';
import 'main_app_fab.service.dart';

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
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (PlatformIs.mobile &&
            userSettingsFingerprints != null &&
            userSettingsFingerprints.isNotEmpty == true &&
            avFingerprints != null &&
            avFingerprints.isNotEmpty == true)
          Container(
            margin:  EdgeInsets.only(bottom: viewRequest == true? AppSizes.s75 :  35),
            child: ExpandableFab(
                distance: (avFingerprints.length < 4) ? AppSizes.s30 * 4 : AppSizes.s30 * avFingerprints.length,
                children: avFingerprints.map(
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
       if(viewRequest == true) Positioned(
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
