import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/user_consts.dart';
import '../../../general_services/app_config.service.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/location.service.dart';
import '../../../general_services/settings.service.dart';
import '../../../models/settings/user_settings.model.dart';
import '../../../routing/app_router.dart';

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
    var jsonString;
    var gCache;
    UserSettingsModel? userSettingsModel;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }

    userSettingsModel = UserSettingsModel.fromJson(gCache);
    final fingerprints = userSettingsModel.avFingerprint;
  print("fingerprints --> ${fingerprints}");
    if (fingerprints != null && fingerprints is Map) {
      fingerprints.forEach((key, value) {
        if (value == 'active_all' || value == 'active_some') {
          _usersFingerprints.add(key);
          print("_usersFingerprints --> $_usersFingerprints");
        }
      });
    } else {
      print("⚠️ fingerprints is null or not a Map");
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
          print("Loaded fingerprints in offline screen: ${savedFingerprints}");
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
