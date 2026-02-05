import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/location_service.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/features/offline/data/local_data/offline_local_data_source.dart';

class OfflineController with ChangeNotifier {
  final List<String> _usersFingerprints = [];
  bool isLoadingFingerprints = true;
  List<Map<String, dynamic>>? savedFingerprints = [];

  List<String> get usersFingerprints => _usersFingerprints;


  void initialize({required BuildContext ctx}) async {
    final appConfigServiceProvider = Provider.of<AppConfigService>(ctx, listen: false);
    final settings = appConfigServiceProvider.getSettings(type: SettingsType.userSettings);
    
    if (settings == null) {
      debugPrint("⚠️ Settings is null, skipping fingerprint initialization");
      return;
    }
    
    // Use local data source to get user settings
    final gCache = OfflineLocalDataSource.getUserSettingsFromCache();
    if (gCache == null) {
      debugPrint("⚠️ US1 cache is empty");
      return;
    }
    
    UserSettingsModel? userSettingsModel;
    try {
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    } catch (e) {
      debugPrint("❌ Error decoding US1: $e");
      return;
    }

    try {
      userSettingsModel = UserSettingsModel.fromJson(gCache);
      final fingerprints = userSettingsModel.avFingerprint;
      debugPrint("fingerprints --> $fingerprints");
      if (fingerprints != null) {
        fingerprints.forEach((key, value) {
          if (value == 'active_all' || value == 'active_some') {
            _usersFingerprints.add(key);
            debugPrint("_usersFingerprints --> $_usersFingerprints");
          }
        });
      } else {
        debugPrint("⚠️ fingerprints is null or not a Map");
      }
    } catch (e) {
      debugPrint("❌ Error initializing fingerprints: $e");
    }

    // Load saved fingerprints from preferences
    await loadFingerprintsFromPreferences();
  }

  Future<void> loadFingerprintsFromPreferences() async {
    isLoadingFingerprints = true;
    notifyListeners();
    
    // Use local data source to load fingerprints
    savedFingerprints = await OfflineLocalDataSource.loadFingerprintsFromPreferences();
    AppConstants.fingerPrints = savedFingerprints;
    
    if (savedFingerprints != null && savedFingerprints!.isNotEmpty) {
      debugPrint("Loaded fingerprints in offline screen: $savedFingerprints");
    } else {
      debugPrint("No fingerprints found in shared preferences");
    }
    
    isLoadingFingerprints = false;
    notifyListeners();
  }

}
