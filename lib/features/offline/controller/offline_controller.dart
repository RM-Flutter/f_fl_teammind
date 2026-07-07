import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class OfflineController with ChangeNotifier {
  final List<String> _usersFingerprints = [];
  bool isLoadingFingerprints = true;
  List<Map<String, dynamic>>? savedFingerprints = [];
  final Set<int> _deletingOfflineIndexes = {};

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
    var gCache;
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

    if (gCache == null) {
      debugPrint("⚠️ gCache is null");
      return;
    }

    try {
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
          savedFingerprints = decodedList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
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

  /// حذف بصمة أوفلاين واحدة من الكاش (SharedPreferences + الذاكرة)
  Future<void> deleteOfflineFingerprintAt(int index) async {
    if (savedFingerprints == null ||
        index < 0 ||
        index >= savedFingerprints!.length) {
      return;
    }

    _deletingOfflineIndexes.add(index);
    notifyListeners();

    // إعطاء الفرصة لرسم اللودينج قبل تنفيذ الحذف
    await Future.delayed(const Duration(milliseconds: 100));

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    savedFingerprints!.removeAt(index);
    AppConstants.fingerPrints = savedFingerprints;

    if (savedFingerprints!.isEmpty) {
      await prefs.remove('fingerPrints');
    } else {
      await prefs.setString(
        'fingerPrints',
        jsonEncode(savedFingerprints),
      );
    }

    _deletingOfflineIndexes.remove(index);
    notifyListeners();
  }

  Set<int> get deletingOfflineIndexes => _deletingOfflineIndexes;


  qrCode({required BuildContext ctx}) =>
      ctx.goNamed(AppRoutes.qrcodeScreen.name);

  Future<LocationData?> gps() async {
    return LocationService.getLocation();
  }
}
