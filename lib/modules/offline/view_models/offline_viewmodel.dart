import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/user_consts.dart';
import '../../../general_services/app_config.service.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/location.service.dart';
import '../../../general_services/settings.service.dart';
import '../../../models/settings/user_settings.model.dart';
import '../../../core/routing/app_router.dart';

class OfflineViewModel with ChangeNotifier {
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
      debugPrint("⚠️ Settings is null, skipping fingerprint initialization");
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
        debugPrint("❌ Error decoding US1: $e");
        return;
      }
    } else {
      debugPrint("⚠️ US1 cache is empty");
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
          debugPrint("Loaded fingerprints in offline screen: $savedFingerprints");
        } else {
          savedFingerprints = [];
          AppConstants.fingerPrints = [];
        }
      } else {
        savedFingerprints = [];
        AppConstants.fingerPrints = [];
        debugPrint("No fingerprints found in shared preferences");
      }
    } catch (e) {
      debugPrint("Error loading fingerprints: $e");
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
