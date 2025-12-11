import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/general_services/app_config.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/device_info.service.dart';
import 'package:rmemp/platform/platform_is.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:provider/provider.dart';

class DioHelper{
  static Dio? dio;
  static initail(BuildContext context){
    // Prepare headers with CORS support for web
    Map<String, dynamic> headers = {
      'Accept':'application/json',
      "lang" : "${CacheHelper.getString("lang")}",
      'Content-Type':"application/json",
    };
    
    // Add CORS headers for web platform
    if (kIsWeb || PlatformIs.web) {
      headers.addAll({
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, lang, device-unique-id',
      });
    }
    
    dio = Dio(
        BaseOptions(
            baseUrl: AppConstants.baseUrl,
            receiveDataWhenStatusError: true,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: headers,
            // For web, set followRedirects and validateStatus
            followRedirects: true,
            validateStatus: (status) {
              return status != null && status < 500;
            },
        )
    );
    dio!.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));
    dio!.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          print("response.statusCode == ${response.statusCode}");
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          print("error.response?.statusCode ==z ${error.response?.statusCode}");
          
          // Handle CORS errors on web
          if (kIsWeb || PlatformIs.web) {
            final errorMessage = error.message?.toLowerCase() ?? '';
            // التحقق من أخطاء CORS من خلال رسالة الخطأ أو عدم وجود response
            if (errorMessage.contains('cors') || 
                errorMessage.contains('access-control-allow-origin') ||
                errorMessage.contains('blocked by cors policy') ||
                (error.response == null && errorMessage.isNotEmpty)) {
              debugPrint('⚠️ CORS Error detected: ${error.message}');
              debugPrint('⚠️ Request URL: ${error.requestOptions.uri}');
              debugPrint('⚠️ This error usually means the server does not allow requests from this origin.');
              // Continue with the error to let the app handle it gracefully
            }
          }
          
          // Note: 401 handling is done in dio_api.service.dart where context is available
          // Don't handle 401 here as context is not accessible in this interceptor
          return handler.next(error);
        },
      ),
    );
  }
  static Future<Response> downloadData({context,@required url,savePath})async{
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    dio!.options.headers = {
      'Accept':'application/json',
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id' : deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
      "lang" : "${CacheHelper.getString("lang")}",
    };
    print("Headers: ${dio!.options.headers}");
    return await dio!.download(url, savePath );
  }
  
  static Future<String?> _getDeviceUniqueId(BuildContext? context, AppConfigService appConfigServiceProvider) async {
    try {
      final deviceInfo = appConfigServiceProvider.deviceInformation;
      var deviceUniqueId = deviceInfo.deviceUniqueId;
      
      // If deviceUniqueId is valid, return it
      if (deviceUniqueId.isNotEmpty && deviceUniqueId != 'Unknown Device') {
        return deviceUniqueId;
      }
      
      // If not valid and we have context, try to initialize device info
      if (context != null) {
        await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
        final updatedDeviceInfo = appConfigServiceProvider.deviceInformation;
        deviceUniqueId = updatedDeviceInfo.deviceUniqueId;
        if (deviceUniqueId.isNotEmpty && deviceUniqueId != 'Unknown Device') {
          return deviceUniqueId;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting device unique ID: $e');
      return null;
    }
  }
  static Future<Response> getData({@required url, @required Map<String, dynamic>? query,context,lang,  token,bool sendLang = false, Map<String, dynamic>? data})async{
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    
    // Remove trailing slash from URL for better web compatibility
    String cleanUrl = url.toString().endsWith('/') ? url.toString().substring(0, url.toString().length - 1) : url.toString();
    
    dio!.options.headers = {
      'Accept':'application/json',
      if(sendLang == true)"Accept-Language" : CacheHelper.getString("lang") ?? "en",
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id' : deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
       "lang" : "${CacheHelper.getString("lang")}",
    };
    print("Headers: ${dio!.options.headers}");
    print("Request URL: $cleanUrl");
    print("Query Parameters: $query");
    return await dio!.get(cleanUrl, queryParameters: query );
  }
  static Future<Response> deleteData({@required url, @required Map<String, dynamic>? query, token, data})async{
    dio!.options.headers = {
      'Accept':'application/json',
      'Authorization': 'Bearer $token',
    };

    return await dio!.delete(url, queryParameters: query, data: data??null);
  }
  static Future<Response> postData({ context ,@required url,@required Map<String, dynamic>? query, token, @required data})async{
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    dio!.options.headers = {
      'Accept':'application/json',
      'Content-Type': 'application/json',
      "lang" : "${CacheHelper.getString("lang")}",
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id' : deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',

    };
    return await dio!.post(url, queryParameters: query, data: data??null);
  }
  static Future<Response> putData({ context ,@required url,@required Map<String, dynamic>? query, token, @required Map<String, dynamic>? data})async{
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    dio!.options.headers = {
      'Accept':'application/json',
      'Content-Type': 'application/json',
      "lang" : "${CacheHelper.getString("lang")}",
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id' : deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
    };
    return await dio!.put(url, queryParameters: query, data: data??null);
  }
  static Future<Response> patchData({ context ,@required url,@required Map<String, dynamic>? query, token, @required Map<String, dynamic>? data})async{
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    dio!.options.headers = {
      'Accept':'application/json',
      'Content-Type': 'application/json',
      "lang" : "${CacheHelper.getString("lang")}",
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id' : deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
    };
    return await dio!.patch(url, queryParameters: query, data: data??null);
  }
  static Future<Response> postFormData({@required url, context, formdata,@required Map<String, dynamic>? query, @required Map<String, dynamic>? data})async{
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    dio!.options.headers = {
      'Accept':'application/json',
      "lang" : "${CacheHelper.getString("lang")}",
      'Content-Type': 'multipart/form-data',
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id' : deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
    };
    return await dio!.post(url, queryParameters: query, data: formdata);
  }

  static Future<Response> postDataSocket({@required url,@required Map<String, dynamic>? query, token, @required Map<String, dynamic>? data})async{
    dio!.options.headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${token}',
    };

    return await dio!.post(url, queryParameters: query, data: data??null);
  }

  static Future<Response> updateData({@required url,@required Map<String, dynamic>? query, token, @required Map<String, dynamic>? data})async{
    dio!.options.headers = {
      'Accept':'application/json',
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    };

    return await dio!.put(url, queryParameters: query, data: data??null);
  }
  static Future<dynamic> uploadImage({File? file, url, token}) async {
    dio!.options.headers = {
      'Accept':'application/json',
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    };
    var fileName = file!.path.split('/').last;
    FormData formData = FormData.fromMap({
      "profile_pic": await MultipartFile.fromFile(file.path, filename:fileName),
    });
    var response = await dio!.post(url, data: formData);
    return response.data;
  }
}