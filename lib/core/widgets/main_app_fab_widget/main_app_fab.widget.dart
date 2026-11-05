import 'dart:convert';

import 'package:app_test/core/helpers/package_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/user_consts.dart';
import '../../models/settings/user_settings.model.dart';
import '../../platform/platform_is.dart';
import '../../platform/web_fingerprint_capabilities.dart';
import '../../services/backend_services/api_service/dio_api_service/shared.dart';
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

    userSettingsModel = gCache != null ? UserSettingsModel.fromJson(gCache) : null;
    // Visibility is driven only by allowed_fingerprint_types (type => true/false, resolved by the backend).
    final allowedTypes = userSettingsModel?.allowedFingerprintTypes;

    bool isTypeAllowed(String key) {
      if (allowedTypes == null || allowedTypes.isEmpty) return false;
      final raw = allowedTypes[key] ??
          (key == 'custom_fp_navigate' ? allowedTypes['fp_navigate'] : null);
      if (raw is bool) return raw;
      final s = raw?.toString().toLowerCase().trim();
      return s == 'true' || s == '1';
    }

    // Standard bottom-to-top priority order ( excluding fp_machine )
    const orderedKeys = <String>[
      'fp_scan',
      'fp_navigate',
      'custom_fp_navigate',
      'fp_wifi',
      'fp_bluetooth',
    ];

    List<String> avFingerprints = [];
    for (final key in orderedKeys) {
      if (isTypeAllowed(key)) {
        if (key == 'custom_fp_navigate' && avFingerprints.contains('fp_navigate')) {
          continue;
        }
        avFingerprints.add(key);
      }
    }

    // Include any additional keys from map if not already checked
    if (allowedTypes != null) {
      for (final entry in allowedTypes.entries) {
        final k = entry.key;
        if (k == 'fp_machine' || avFingerprints.contains(k)) continue;
        if (k == 'custom_fp_navigate' && avFingerprints.contains('fp_navigate')) continue;
        if (isTypeAllowed(k)) {
          avFingerprints.add(k);
        }
      }
    }

    if (kIsWeb || PlatformIs.web) {
      // Browser rules (GPS everywhere, QR on smartphones with a camera only; when a face image is needed,
      // only smartphones with a camera get any method and they take a photo) — see WebFingerprintCapabilities.
      final bool phone = WebFingerprintCapabilities.isPhone(context);
      return FutureBuilder<bool>(
        future: WebFingerprintCapabilities.hasCamera(),
        builder: (context, snapshot) => _buildFabs(
          context,
          WebFingerprintCapabilities.filterMethods(
            avFingerprints,
            phone: phone,
            camera: snapshot.data == true,
          ),
        ),
      );
    }
    return _buildFabs(context, avFingerprints);
  }

  Widget _buildFabs(BuildContext context, List<String> avFingerprints) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (PackageHelper.hasPackage('fingerprint-sys') &&
            avFingerprints.isNotEmpty)
          Container(
            margin: EdgeInsets.only(
                bottom: (viewRequest == true &&
                        PackageHelper.hasPackage('emp-requests'))
                    ? AppSizes.s75
                    : 35),
            child: ExpandableFab(
                distance: (avFingerprints.length < 4)
                    ? AppSizes.s30 * 4
                    : AppSizes.s30 * avFingerprints.length,
                children: avFingerprints
                    .map(
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
       if(viewRequest == true && PackageHelper.hasPackage('emp-requests')) Positioned(
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
