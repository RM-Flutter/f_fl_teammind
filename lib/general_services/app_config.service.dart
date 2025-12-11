import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';
import '../models/device_information.model.dart';
import '../models/settings/app_settings_model.dart';
import '../models/settings/general_settings.model.dart';
import '../models/settings/user_settings.model.dart';
import '../models/settings/user_settings_2.model.dart';
import 'alert_service/alerts.service.dart';
import 'backend_services/api_service/dio_api_service/dio.dart';
import 'backend_services/api_service/dio_api_service/shared.dart';
import 'settings.service.dart';
import '../routing/app_router.dart';

class   AppConfigService extends ChangeNotifier {
  AppConfigService() {
    //intialize application services
    _initializeConnectionListener();

    init();
  }
  bool isConnected = true;
  bool isInitialized = false;

  StreamSubscription<InternetConnectionStatus>? _listener;
  void _initializeConnectionListener() {
    // في الويب، لا نستخدم InternetConnectionChecker لأنه يسبب refresh مستمر
    // نعتمد على ConnectionService بدلاً منه
    if (kIsWeb) {
      isConnected = true; // افتراض أن الويب متصل دائماً
      return;
    }
    _listener = InternetConnectionChecker.instance.onStatusChange.listen((status) {
      final connected = status == InternetConnectionStatus.connected;
      if (connected != isConnected) {
        isConnected = connected;
        // لا نستخدم notifyListeners هنا لأننا لا نريد refresh في GoRouter
        // ConnectionService يتولى ذلك
      }
    });
  }
  /// api url
  String? apiURL;

  /// api url to for checking on (refresh token && access token) expiration date.
  String? refreshTokenApiUrl;

  /// [OPTIONAL GLOBAL FLAG ] enable or disable checking for (refresh token && access token) before any request to backend server.
  bool? checkOnTokenExpiration;

  /// stream server url
  String? wsURL;

  /// is right to left
  bool isRTL = false;

  /// any keys here will not be cleared when user signout
  /// examples :- remember user credentials feature.
  List<String> dontClearKeys = [];

  SharedPreferences? _prefs;

  ///locale getter often used to get the current language and send it in the header of the request
  String get language => getValueString('language');
  ///locale setter
  set language(v) {
    if (_prefs == null) {
      init().then((_) => setValueString('language', v));
    } else {
      setValueString('language', v);
    }
    notifyListeners();
  }

  ///access token getter
  String get token => getValueString('token');
  /// setter method to set the access token status with optional parameter [notify] set it true if you wanna to notify all application and route system.
  Future<void> setToken(v, {bool? notify = false}) async {
    if (_prefs == null) {
      await init();
    }
    // Always use await to ensure token is saved before proceeding
    await setValueString('token', v);
    debugPrint('Token saved: ${v != null && v.toString().isNotEmpty ? v.toString().substring(0, v.toString().length > 20 ? 20 : v.toString().length) + "..." : "empty"}');
    if (notify == true) {
      notifyListeners();
    }
  }

  /// setter method to set the current user status with optional parameter [notify] set it true if you wanna to notify all application and route system.
  Future<void> setIsLogin(bool v, {bool? notify = false}) async {
    if (_prefs == null) {
      await init().then((_) => setValueBool('is_login', v));
    } else {
      setValueBool('is_login', v);
    }
    if (notify == true) {
      notifyListeners();
    }
  }

  /// getter to get the current user login status
  bool get isLogin => getValueBool('is_login');

  /// Used When Login to set and notify listeners for token and authentication status
  Future<void> setAuthenticationStatusWithToken(
      {required bool isLogin, required String? token}) async {
    await setIsLogin(isLogin);
    await setToken(token, notify: true);
    debugPrint(
        '----- Authentication status set to $isLogin with token :- ${token?.substring(0, token.length > 20 ? 20 : token.length)}...');
    
    // Clear Dio headers to force refresh with new token
    try {
      if (DioHelper.dio != null) {
        // Remove old authorization header
        DioHelper.dio!.options.headers.remove('Authorization');
        debugPrint('Dio headers cleared, will be refreshed on next request');
      }
    } catch (e) {
      debugPrint('Error clearing Dio headers after login: $e');
    }
    
    notifyListeners();
  }

  /// refresh token getter
  String get refreshToken => getValueString('refreshToken');

  /// refresh token setter
  set refreshToken(v) {
    if (_prefs == null) {
      init().then((_) => setValueString('refreshToken', v));
    } else {
      setValueString('refreshToken', v);
    }
  }

  /// access token expire date getter
  int get accessTokenExpDate => getValueInt('accessTokenExpDate');

  /// access token expire date setter
  set accessTokenExpDate(v) {
    if (_prefs == null) {
      init().then((_) => setValueInt('accessTokenExpDate', v));
    } else {
      setValueInt('accessTokenExpDate', v);
    }
  }

  ///refresh token expire date getter
  int get refreshTokenExpDate => getValueInt('refreshTokenExpDate');

  ///refresh token expire date setter
  set refreshTokenExpDate(v) {
    if (_prefs == null) {
      init().then((_) => setValueInt('refreshTokenExpDate', v));
    } else {
      setValueInt('refreshTokenExpDate', v);
    }
  }

  // App General Settings [generalSettings - user_settings - user2_settings]

  /// getter used to get stored settings depends on the Settings SettingsType { generalSettings, userSettings, user2Settings }.
  AppSettingsModel? getSettings({required SettingsType type}) {
    switch (type) {
      case SettingsType.generalSettings:
        return GeneralSettingsModel.fromJson(_generalSettigns);
      case SettingsType.userSettings:
        return UserSettingsModel.fromJson(_userSettings);
      case SettingsType.user2Settings:
        return UserSettings2Model.fromJson(_user2Settings);
      default:
        return null;
    }
  }

  /// setter used to set settings to local storage depends on SettingsType { generalSettings, userSettings, user2Settings }.
  void setSettings(
      {required SettingsType type, required Map<String, dynamic>? data, Map<String, dynamic>? dataS1, Map<String, dynamic>? dataS2}) {
    switch (type) {
      case SettingsType.generalSettings || SettingsType.startupSettings:
        if (data != null && dataS1 != null && dataS2 != null) {
          print("Done S");
          _generalSettigns = data;
          _userSettings = dataS1;
          _user2Settings = dataS2;
          return;
        }
      case SettingsType.userSettings|| SettingsType.startupSettings:
        if (dataS1 != null) {
          print("Done S1");
          _userSettings = dataS1;
        }
        return;
      case SettingsType.user2Settings|| SettingsType.startupSettings:
        if (dataS2 != null) {
          print("Done S2");
          _user2Settings = dataS2;
        }
        return;
    }
  }

  /// [generalSettings] getter used to get stored general settings.
  Map<String, dynamic> get _generalSettigns => getValueMap('general_settings');

  /// [generalSettings] setter used to set general settings to local storage.
  set _generalSettigns(Map<String, dynamic> v) {
    if (_prefs == null) {
      init().then((_) => setValueMap('general_settings', v));
    } else {
      setValueMap('general_settings', v);
    }
  }

  /// [userSettings] getter used to get stored user settings.
  Map<String, dynamic> get _userSettings => getValueMap('user_settings');

  /// [userSettings] setter used to set user settings in local storage.
  set _userSettings(Map<String, dynamic> v) {
    if (_prefs == null) {
      init().then((_) => setValueMap('user_settings', v));
    } else {
      setValueMap('user_settings', v);
    }
  }

  /// [user2Settings] getter used to get stored user settings.
  Map<String, dynamic> get _user2Settings => getValueMap('user2_settings');

  /// [user2Settings] setter used to set user settings in local storage.
  set _user2Settings(Map<String, dynamic> v) {
    if (_prefs == null) {
      init().then((_) => setValueMap('user2_settings', v));
    } else {
      setValueMap('user2_settings', v);
    }
  }

  /// [ProtectionDate] getter used with screen protection and local authentication services.
  String get protectionDate => getValueString('protection_date');

  /// [ProtectionDate] setter used with screen protection and local authentication services.
  set protectionDate(String v) {
    if (_prefs == null) {
      init().then((_) => setValueString('protection_date', v));
    } else {
      setValueString('protection_date', v);
    }
  }

  /// [recordPath] getter used to get the path of the record.
  String get recordPath => getValueString('record_path');

  /// [recordPath] setter used to set the path of the record.
  set recordPath(String v) {
    if (_prefs == null) {
      init().then((_) => setValueString('record_path', v));
    } else {
      setValueString('record_path', v);
    }
  }

  // packages information section

  /// [AppName] getter
  String get appName => getValueString('appName');

  /// [AppName] setter
  set appName(String v) {
    if (_prefs == null) {
      init().then((_) => setValueString('appName', v));
    } else {
      setValueString('appName', v);
    }
  }

  /// [packageName] getter
  String get packageName => getValueString('packageName');

  /// [packageName] setter
  set packageName(String v) {
    if (_prefs == null) {
      init().then((_) => setValueString('packageName', v));
    } else {
      setValueString('packageName', v);
    }
  }

  /// [appVersion] getter
  String get appVersion => getValueString('appVersion');

  /// [appVersion] setter
  set appVersion(String v) {
    if (_prefs == null) {
      init().then((_) => setValueString('appVersion', v));
    } else {
      setValueString('appVersion', v);
    }
  }

  /// [buildNumber] getter
  String get buildNumber => getValueString('buildNumber');

  /// [buildNumber] setter
  set buildNumber(String v) {
    if (_prefs == null) {
      init().then((_) => setValueString('buildNumber', v));
    } else {
      setValueString('buildNumber', v);
    }
  }

  /// [DeviceInformationMap] getter
  DeviceInfo get deviceInformation =>
      DeviceInfo.fromMap(getValueMap('DeviceInformationMap'));

  /// [DeviceInfo] setter
  set deviceInformation(DeviceInfo v) {
    if (_prefs == null) {
      init().then((_) => setValueMap('DeviceInformationMap', v.toMap()));
    } else {
      setValueMap('DeviceInformationMap', v.toMap());
    }
  }

  /// initlize the config service
  /// you must call before calling any other function
  Future<void> init() async {
    try {
      if (_prefs != null) return;
      _prefs = await SharedPreferences.getInstance();
      isInitialized = true;
      notifyListeners();
      debugPrint('--------- Config Service is Initialized Successfully ✔️');
      return;
    } catch (err, t) {
      debugPrint(
          '--------- Failed to initialize Config Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
    }
    return;
  }

  /// remove all local config values
  Future<bool> resetConfig() async {
    if (_prefs == null) return false;

    // Fetch all keys from shared preferences
    var keys = _prefs!.getKeys();
    var result = true;

    for (var key in keys) {
      // Skip the "dateWatchScreen" key
      if (key != "dateWatchScreen") {
        var r = await _prefs!.remove(key);
        if (!r) result = false;
      }
    }

    return result;
  }

  /// save data localy
  Future<bool> setValueMap(dynamic key, Map v) async {
    if (_prefs == null) return false;
    await _prefs?.setString(key.toString(), json.encode(v));
    return true;
  }

  /// save data localy
  Future<bool> setValueString(dynamic key, String? v) async {
    if (_prefs == null) {
      await init();
      if (_prefs == null) return false;
    }
    if (v == null) {
      await _prefs?.remove(key.toString());
    } else {
      await _prefs?.setString(key.toString(), v);
      // Force a reload to ensure the value is persisted (especially important on web)
      await _prefs?.reload();
    }
    return true;
  }

  /// save data localy
  Future<bool> setValueBool(dynamic key, bool v) async {
    if (_prefs == null) return false;
    await _prefs?.setBool(key.toString(), v);
    return true;
  }

  /// save data localy
  Future<bool> setValueInt(dynamic key, int v) async {
    if (_prefs == null) return false;
    await _prefs?.setInt(key.toString(), v);
    return true;
  }

  /// get data localy
  String getValueString(dynamic key) {
    if (_prefs == null) return '';
    return _prefs?.getString(key.toString()) ?? '';
  }

  /// check if data exist
  bool checkValueExist(dynamic key) {
    if (_prefs == null) return false;
    return _prefs?.get(key.toString()) != null;
  }

  /// get data localy
  Map<String, dynamic> getValueMap(dynamic key) {
    return json.decode(_prefs?.getString(key.toString()) ?? '{}') ?? {};
  }

  /// get data localy
  int getValueInt(dynamic key) {
    return _prefs?.getInt(key.toString()) ?? 0;
  }

  /// get data localy
  bool getValueBool(dynamic key) {
    return _prefs?.getBool(key.toString()) ?? false;
  }
  Future<void> clearToken({bool? notify = true}) async {
    if (_prefs == null) await init();
    // Remove token from SharedPreferences
    await _prefs?.remove('token');
    // Also clear from memory to ensure it's not cached
    // Force a reload by ensuring _prefs is initialized
    if (notify == true) {
      notifyListeners();
    }
    debugPrint('Token cleared from storage');
  }
  Future<void> logout(context, {bool viewAlert = false, bool skipServerLogout = false, bool skipNavigation = false}) async {
    if(viewAlert == true){
      bool isLogout = await AlertsService.confirmMessage(context, AppStrings.logout.tr(),
          message: AppStrings.areYouSureYouWantToLogout.tr());
      if (isLogout == false) return;
    }
    
    // Clear local data first - use await to ensure completion
    await clearToken(notify: true);
    await setIsLogin(false, notify: true);
    
    // Clear refresh token and expiration dates
    if (_prefs != null) {
      await _prefs?.remove('refreshToken');
      await _prefs?.remove('accessTokenExpDate');
      await _prefs?.remove('refreshTokenExpDate');
    }
    
    // Clear cache data
    await CacheHelper.deleteData(key: "US1");
    await CacheHelper.deleteData(key: "US2");
    //  CacheHelper.deleteData(key: "USG");
    await CacheHelper.deleteData(key: "gDate");
    await CacheHelper.deleteData(key: "s1Date");
    await CacheHelper.deleteData(key: "s2Date");
    await CacheHelper.deleteData(key: "fcmToken");
    
    // Clear device information if needed (optional)
    // await _prefs?.remove('DeviceInformationMap');
    
    debugPrint('User has been logged out, and token is cleared.');
    
    // Clear Dio headers to ensure token is not cached
    try {
      if (DioHelper.dio != null) {
        DioHelper.dio!.options.headers.remove('Authorization');
        DioHelper.dio!.options.headers.remove('device-unique-id');
      }
    } catch (e) {
      debugPrint('Error clearing Dio headers: $e');
    }
    
    // Try to notify server, but don't fail if it doesn't work (e.g., 401)
    if (!skipServerLogout) {
      try {
        await DioHelper.postData(
          url: "/rm_users/v1/log_out", 
          context: context,
          query: null,
          data: {},
        );
      } catch (e) {
        // Ignore errors when logging out (especially 401)
        debugPrint('Logout API call failed (this is OK): $e');
      }
    }
    
    // Notify listeners after all cleanup is done
    notifyListeners();
    
    // Navigate to login screen after logout (unless skipNavigation is true)
    if (!skipNavigation && context.mounted) {
      try {
        context.goNamed(
          AppRoutes.login.name,
          pathParameters: {'lang': context.locale.languageCode},
        );
      } catch (e) {
        debugPrint('Error navigating to login after logout: $e');
      }
    }
  }
}
