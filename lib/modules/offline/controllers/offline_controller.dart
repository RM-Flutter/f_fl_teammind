import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/app_config.service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/location.service.dart';
import 'package:app_test/core/services/settings.service.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';

class OfflineController with ChangeNotifier {
  final List<String> _usersFingerprints = [];
  bool isLoadingFingerprints = true;
  List<Map<String, dynamic>>? savedFingerprints = [];

  List<String> get usersFingerprints => _usersFingerprints;

  void initialize({required BuildContext ctx}) async {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(ctx, listen: false);

    final settings =
    appConfigServiceProvider.getSettings(type: SettingsType.userSettings);
    
    if (settings == null) {
      print("⚠️ Settings is null, skipping fingerprint initialization");
      return;
    }
    
    var jsonString;
    Map<String, dynamic> gCache = {};
    UserSettingsModel? userSettingsModel;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      try {
        gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
        UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
      } catch (e) {
        print("❌ Error decoding US1: $e");
        return;
      }
    } else {
      print("⚠️ US1 cache is empty");
      return;
    }

    try {
      userSettingsModel = UserSettingsModel.fromJson(gCache);
      final fingerprints = userSettingsModel.avFingerprint;
      print("fingerprints --> $fingerprints");
      if (fingerprints != null) {
        fingerprints.forEach((key, value) {
          if (value == 'active_all' || value == 'active_some') {
            _usersFingerprints.add(key);
            print("_usersFingerprints --> $_usersFingerprints");
          }
        });
      } else {
        print("⚠️ fingerprints is null or not a Map");
      }
    } catch (e) {
      print("❌ Error initializing fingerprints: $e");
    }

    // Load saved fingerprints from preferences
    await loadFingerprintsFromPreferences();

    // ConnectionsService.connectionStream.listen((result) {
    //   if (result.contains(ConnectivityResult.none)) {
    //     Navigator.pop(ctx);
    //   }
    // });
  }

  Future<void> loadFingerprintsFromPreferences() async {
    isLoadingFingerprints = true;
    notifyListeners();
    
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('fingerPrints')) {
        final String? jsonString = prefs.getString('fingerPrints');
        if (jsonString != null && jsonString.isNotEmpty) {
          final List<dynamic> decodedList = jsonDecode(jsonString);
          savedFingerprints = decodedList.cast<Map<String, dynamic>>();
          AppConstants.fingerPrints = savedFingerprints;
          print("Loaded fingerprints in offline screen: $savedFingerprints");
        } else {
          savedFingerprints = [];
          AppConstants.fingerPrints = [];
        }
      } else {
        savedFingerprints = [];
        AppConstants.fingerPrints = [];
        print("No fingerprints found in shared preferences");
      }
    } catch (e) {
      print("Error loading fingerprints: $e");
      savedFingerprints = [];
      AppConstants.fingerPrints = [];
    } finally {
      isLoadingFingerprints = false;
      notifyListeners();
    }
  }


  qrCode({required BuildContext ctx}) =>
      ctx.goNamed(AppRoutes.qrcodeScreen.name);

  Future<LocationData?> gps() async {
    return LocationService.getLocation();
  }
}
