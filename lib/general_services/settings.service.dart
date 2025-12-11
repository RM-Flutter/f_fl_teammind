import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/settings/default_general_settings.dart';
import '../constants/settings/default_user_settings.dart';
import '../constants/settings/default_user_settings_2.dart';
import '../constants/user_consts.dart';
import '../models/endpoint.model.dart';
import '../models/operation_result.model.dart';
import '../models/settings/app_settings_model.dart';
import '../models/settings/general_settings.model.dart';
import 'app_config.service.dart';
import 'backend_services/api_service/dio_api_service/dio_api.service.dart';
import 'backend_services/get_endpoint.service.dart';

enum SettingsType {
  generalSettings,
  userSettings,
  user2Settings,
  startupSettings
}

abstract class AppSettingsService {
  /// this method for usage in entire app to get any kind of settings [generalSettings] || [userSettings] || [userSettings2]
  static AppSettingsModel? getSettings(
      {required SettingsType settingsType, required BuildContext context}) {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(context, listen: false);
    switch (settingsType) {
      case SettingsType.generalSettings:
        final generalSettings =
        appConfigServiceProvider.getSettings(type: settingsType);
        if (generalSettings == null) {
          appConfigServiceProvider.setSettings(
            type: settingsType, data: defaultGeneralSettings.toJson(),
            dataS1: defaultUserSettings.toJson(),
            dataS2: defaultUserSettings2.toJson(),
          );
          return defaultGeneralSettings;
        }
        return generalSettings;
      case SettingsType.startupSettings:
        final generalSettings =
        appConfigServiceProvider.getSettings(type: settingsType);
        if (generalSettings == null) {
          appConfigServiceProvider.setSettings(
              type: settingsType, data: defaultGeneralSettings.toJson(),
              dataS1: defaultUserSettings.toJson(),
              dataS2: defaultUserSettings2.toJson(),
          );
          return defaultGeneralSettings;
        }
        return generalSettings;

      case SettingsType.userSettings:
        final userSettings =
        appConfigServiceProvider.getSettings(type: settingsType);
        if (userSettings == null) {
          appConfigServiceProvider.setSettings(
              type: settingsType, data: defaultUserSettings.toJson());
          return defaultUserSettings;
        }
        return userSettings;

      case SettingsType.user2Settings:
        final user2Settings =
        appConfigServiceProvider.getSettings(type: settingsType);
        if (user2Settings == null) {
          appConfigServiceProvider.setSettings(
              type: settingsType, data: defaultUserSettings2.toJson());
          return defaultUserSettings2;
        }
        return user2Settings;

      default:
        return null;
    }
  }

  /// method to initialize the general settings and check if there is updates or not.
  /// setting type [general_settings] || [user_settings] || [user2_settings]
  static updateToken(context, token)async{
   await DioHelper.postData(
        url: "/rm_users/v1/devices/update_token",
        context: context,
        data: {
          "action" : "confirm",
          "token" : token
        }
    ).then((value){
      print(value.data['message']);
      if(value.data['status'] == true){
        if(value.data['update_url'] != null){
          print("THE UPDATE URL IS CHANGES");
          CacheHelper.setString(key: "update_url", value:value.data['update_url'] );
        }
      }
    }).catchError((error){
      if (error is DioError) {
        print(error.response?.data['message'] ?? 'Something went wrong');
      }
    });
  }


  static Future<Map<String, String>?> getIpCountryInfo() async {
    try {
      // final ip = ipData['ip'];
      final geoResponse = await http.get(Uri.parse('http://ip-api.com/json'));
      if (geoResponse.statusCode == 200) {
        final geoData = jsonDecode(geoResponse.body);
        return {
          'country': geoData['country'],       // اسم الدولة
          'countryCode': geoData['countryCode'], // رمز الدولة (مثلاً EG)
          'dialCode': getDialCode(geoData['countryCode']), // كود الاتصال الدولي
        };
      }
      // final ipResponse = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      // if (ipResponse.statusCode == 200) {
      //   final ipData = jsonDecode(ipResponse.body);
      // }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
  static String getDialCode(String countryCode) {
    return AppConstants.countryDialCodes[countryCode] ?? '';
  }
  static printCountryInfo() async {
    final info = await getIpCountryInfo();
    if (info != null) {
      String countryCode = info['countryCode'] ?? AppConstants.country; // رمز الدولة، مثل EG
      String dialCode = info['dialCode'] ?? AppConstants.countryCode;       // كود الاتصال الدولي، مثل +20
      
      // إذا كانت الدولة افغانستان (AF)، تغييرها إلى مصر (EG)
      if (countryCode == 'AF' || countryCode == 'af') {
        countryCode = AppConstants.country; // EG
        dialCode = AppConstants.countryCode; // +20
        print('⚠️ تم اكتشاف افغانستان من IP، تم تغييرها إلى مصر');
      }
      
      CacheHelper.setString(key: "flag", value: countryCode);
      CacheHelper.setString(key: "flagCode", value: dialCode);
      print('Country Code: $countryCode');
      print('Dial Code: $dialCode');
    } else {
      // إذا فشل الحصول على معلومات الدولة، استخدم مصر كقيمة افتراضية
      CacheHelper.setString(key: "flag", value: AppConstants.country); // EG
      CacheHelper.setString(key: "flagCode", value: AppConstants.countryCode); // +20
      print('⚠️ لم يتم الحصول على معلومات الدولة، تم استخدام مصر كقيمة افتراضية');
    }
  }

  static Future<void> initializeGeneralSettings({required SettingsType settingType,List? need, bool? allData = false, required BuildContext context}) async {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(context, listen: false);
    final flag = CacheHelper.getString("flag")?.trim();
    final flagCode = CacheHelper.getString("flagCode")?.trim();

    if (flag == null || flag.isEmpty || flagCode == null || flagCode.isEmpty) {
      await printCountryInfo();
    }
    var settingsData = appConfigServiceProvider.getSettings(type: settingType);
    var lastUpdateDate = settingsData?.lastUpdateDate ?? "";
    OperationResult<Map<String, dynamic>> result;
    var s1Cache;
    var s2Cache;
    var gCache;
    print("FAAAAAAAAAAAAAAAILD");
    String? fcm_token;

    try {
      fcm_token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print("🔥 Error while requesting permission or token: $e");
    }

    print("FAAAAAAAAAAAAAAAILD 2");

    fcm_token ??= CacheHelper.getString("fcm_token"); // fallback

    if (settingType == SettingsType.startupSettings) {
      Map<String, dynamic> body = {
        if(CacheHelper.getString("fcm_token") != fcm_token.toString()) "notification_token" : fcm_token,
        if (CacheHelper.getString("gDate")!= null )"last_update_date_general": CacheHelper.getString("gDate"),
        if (CacheHelper.getString("s1Date")!= null)"last_update_date_user": CacheHelper.getString("s1Date"),
        if (CacheHelper.getString("s2Date") != null) "last_update_date_user2": CacheHelper.getString("s2Date"),
        "needed": need ?? [
          "general_settings",
          "user_settings",
          "user2_settings",
          "check_auth"
        ],
        if(appConfigServiceProvider.token.isNotEmpty) "token": appConfigServiceProvider.token,
        "device_id": appConfigServiceProvider.deviceInformation.deviceUniqueId
      };
      result = await DioApiService().post<Map<String, dynamic>>(
          EndpointServices.getApiEndpoint(EndpointsNames.startApp).url.trim(),
          body,
          context: context,
          dataKey: 'general_settings',
          allData: allData);
    }
    else {
      String settingTypeName = settingType == SettingsType.userSettings
          ? 'user_settings'
          : 'user2_settings';
      Map<String, dynamic> body = {
        "type": settingTypeName,
        if(CacheHelper.getString("fcm_token") != fcm_token.toString()) "notification_token" : fcm_token,
        "last_update_date": lastUpdateDate
      };
      result = await DioApiService().post<Map<String, dynamic>>(
          EndpointServices.getApiEndpoint(EndpointsNames.userSettings)
              .url
              .trim(),
          body,
          context: context,
          dataKey: 'user_settings',
          allData: allData);
    }
    if (result.success && result.data != null && (result.data?.isNotEmpty ?? false)) {
      CacheHelper.setString(key: "fcm_token", value: fcm_token.toString());
      CacheHelper.setString(key: "update_url", value: result.data!['update_url'] ?? "" );
      if(result.data!['token'] != null){
        if(appConfigServiceProvider.token.isNotEmpty && appConfigServiceProvider.token != result.data!['token']){
          await updateToken(context, result.data!['token']);
          appConfigServiceProvider.setAuthenticationStatusWithToken(isLogin: true, token: result.data!['token']);
        }
      }
      if((need == null || need.contains('user_settings')) && result.data!['user_settings'] != null && result.data!['user_settings']['status']  != false && CacheHelper.getString("US1") != null && CacheHelper.getString("US1") != ""){
        CacheHelper.deleteData(key: "US1");
      }
      if((need == null || need.contains('user2_settings')) &&result.data!['user2_settings'] != null && result.data!['user2_settings'] ['status']  != false  && CacheHelper.getString("US2") != null && CacheHelper.getString("US2") != ""){
        CacheHelper.deleteData(key: "US2").then((v){
          print("DELETED FROM CACHE SUCCESS");
        });}
      if((need == null || need.contains('general_settings')) &&result.data!['general_settings'] != null && result.data!['general_settings'] ['status']  != false && CacheHelper.getString("USG") != null && CacheHelper.getString("USG") != ""){
        CacheHelper.deleteData(key: "USG");
      }
      var prefs = await SharedPreferences.getInstance();
      if((need == null || need.contains('user_settings')) && result.data!['user_settings'] != null){
        if ((need == null || need.contains('user_settings')) &&result.data!['user_settings']['data'] != null){
          CacheHelper.setString(key: "s1Date", value: result.data!['user_settings']['data']['last_update_date']);
          prefs = await SharedPreferences.getInstance();
          final jsonString = json.encode(result.data!['user_settings']['data']); // Convert JSON to String
          await prefs.setString("US1", jsonString);
        }
      }
      if ((need == null || need.contains('general_settings')) &&result.data!['general_settings']['data'] != null){
        CacheHelper.setString(key: "gDate", value: result.data!['general_settings']['data']['last_update_date']);
        GeneralSettingsModel? generalSettingsModel;
        generalSettingsModel = GeneralSettingsModel.fromJson(result.data!['general_settings']['data']);
        prefs = await SharedPreferences.getInstance();
        final jsonString = json.encode(result.data!['general_settings']['data']); // Convert JSON to String
        await prefs.setString("USG", jsonString);
      }
      if((need == null || need.contains('user2_settings')) &&result.data!['user2_settings'] != null){
        if ((need == null || need.contains('user2_settings')) &&result.data!['user2_settings']['data'] != null){
          CacheHelper.setString(key: "s2Date", value: result.data!['user2_settings']['data']['last_update_date']);
          prefs = await SharedPreferences.getInstance();
          final jsonString = json.encode(result.data!['user2_settings']['data']); // Convert JSON to String
          await prefs.setString("US2", jsonString);
        }
      }
      if((need == null || need.contains('user_settings')) &&result.data!['user_settings'] != null){
        if(CacheHelper.getString("US1") != null && result.data!['user_settings']['status'] == false){
          final prefs = await SharedPreferences.getInstance();
          final jsonString = prefs.getString("US1");
          if (jsonString != null) {
            s1Cache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
            print("S1 IS --> $s1Cache");
          }
        }
      }
      if((need == null || need.contains('user2_settings')) &&result.data!['user2_settings'] != null){
        if(CacheHelper.getString("US2") != null&& result.data!['user2_settings']['status'] == false){
          final prefs = await SharedPreferences.getInstance();
          final jsonString = prefs.getString("US2");
          if (jsonString != null) {
            s2Cache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
          }
        }
      }
      appConfigServiceProvider.setSettings(
          type: settingType,
          data:(result.data!['general_settings']!= null)?(result.data!['general_settings']['status'] == false)? gCache: result.data!['general_settings']['data'] : null,
          dataS1: (result.data!['user_settings'] != null)?(result.data!['user_settings']['status'] == false)? s1Cache: result.data!['user_settings']['data'] : null,
          dataS2: (result.data!['user2_settings'] != null)?(result.data!['user2_settings']['status'] == false)? s2Cache : result.data!['user2_settings']['data'] : null
      );
    } else {
      print("ERROR DIO IS  --> ${result.errorCodeString}");
      // if error happened , then check if i have cached version of settings or not , if i have cached version i will use it , if not , i will store the default settings version into local storage.
      if (appConfigServiceProvider.getSettings(type: settingType) == null) {
        appConfigServiceProvider.setSettings(
          type: settingType,
          data: getSettings(settingsType: settingType, context: context)?.toJson()??gCache,
          dataS1: getSettings(settingsType: settingType, context: context)?.toJson()??s1Cache,
          dataS2: getSettings(settingsType: settingType, context: context)?.toJson()??s2Cache,
        );
      }
    }
  }

  /// used to get user_settings and user_settings_2
  static Future<void> getUserSettingsAndUpdateTheStoredSettings(
      {required BuildContext context, bool? allData = false, List? need,}) async {
    await initializeGeneralSettings(
        settingType: SettingsType.startupSettings,
        allData: allData,
        need: need,
        context: context);
    // await initializeGeneralSettings(
    //     settingType: SettingsType.user2Settings,
    //     allData: allData,
    //     context: context);
  }

  /// used to get screen general message [NOTE] page route will be used as screen id.
  static String? getGeneralScreenMessageByScreenId(
      {required String screenId, required BuildContext context}) {
    List<GeneralMessageByScreen>? list = (getSettings(
        settingsType: SettingsType.generalSettings,
        context: context) as GeneralSettingsModel)
        .generalMessageByScreen;
    if (list == null || list.isEmpty) return null;
    for (var element in list) {
      if (element.screenId == screenId) {
        return LocalizationService.isArabic(context: context) ? element.screenMessage!.ar: element.screenMessage!.en;
      }
    }
    return null;
  }

  /// used to get request title
  static String? getRequestTitleFromGenenralSettings(
      {String? requestId, required BuildContext context}) {
    GeneralSettingsModel? generalSettingss;
   if (UserSettingConst.generalSettingsModel != null && UserSettingConst.generalSettingsModel!.requestTypes!.keys.contains(requestId) ?? false) {
     if(LocalizationService.isArabic(context: context)){
       return UserSettingConst.generalSettingsModel!.requestTypes?[requestId]?.title!.ar;
     }else{
       return UserSettingConst.generalSettingsModel!.requestTypes?[requestId]?.title!.en;
     }
   }
    return null;
  }
}
