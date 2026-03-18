import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:provider/provider.dart';

import '../../../../platform/platform_is.dart';
import '../../../device_info_service.dart';

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
          persistentConnection: true,
          headers: headers,
          // For web, set followRedirects and validateStatus
          followRedirects: true,
          maxRedirects: 5,
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
        onError: (DioException error, handler) {
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
    // إعادة محاولة مرة واحدة مع اتصال جديد عند timeout/قطع الاتصال (حل مشكلة عدم رد الـ API حتى إعادة فتح الواي فاي)
    _addConnectionResetRetryInterceptor();
  }

  /// عند timeout أو خطأ اتصال: إغلاق الـ adapter واستبداله بواحد جديد ثم إعادة المحاولة مرة واحدة.
  static void _addConnectionResetRetryInterceptor() {
    const _extraKey = '_connection_retry';
    dio!.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) {
          final isConnectionIssue = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              (error.message?.toLowerCase().contains('socket') ?? false) ||
              (error.message?.toLowerCase().contains('failed host lookup') ?? false);
          final alreadyRetried = error.requestOptions.extra[_extraKey] == true;
          if (!isConnectionIssue || alreadyRetried || dio == null) {
            return handler.next(error);
          }
          if (kIsWeb || PlatformIs.web) {
            return handler.next(error);
          }
          try {
            final adapter = dio!.httpClientAdapter;
            if (adapter is IOHttpClientAdapter) {
              adapter.close(force: true);
              dio!.httpClientAdapter = IOHttpClientAdapter();
            }
          } catch (_) {}
          error.requestOptions.extra[_extraKey] = true;
          dio!.fetch(error.requestOptions).then(
                (response) => handler.resolve(response),
            onError: (e) => handler.reject(e),
          );
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
    return await dio!.download(url, savePath);
  }

  /// Download file with progress (e.g. PDF from URL).
  static Future<Response> downloadDataWithProgress({
    required BuildContext context,
    required String url,
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    dio!.options.headers = {
      'Accept': 'application/json',
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id': deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
      'lang': CacheHelper.getString("lang") ?? "en",
    };
    return await dio!.download(url, savePath, onReceiveProgress: onReceiveProgress);
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

  /// GET request that returns response body as bytes (e.g. for PDF).
  static Future<Response> getDataAsBytes({
    required BuildContext context,
    required String url,
    Map<String, dynamic>? query,
    String? acceptHeader = 'application/pdf',
  }) async {
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    String cleanUrl = url.toString().endsWith('/') ? url.toString().substring(0, url.toString().length - 1) : url.toString();
    dio!.options.headers = {
      'Accept': acceptHeader ?? 'application/pdf',
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id': deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
      'lang': CacheHelper.getString("lang") ?? "en",
    };
    return await dio!.get(
      cleanUrl,
      queryParameters: query,
      options: Options(responseType: ResponseType.bytes),
    );
  }

  static Future<Response> deleteData({context,@required url, @required Map<String, dynamic>? query, token, data})async{
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

    return await dio!.delete(url, queryParameters: query, data: data??null);
  }
  static Future<Response> postData({ context ,@required url,@required Map<String, dynamic>? query, token, @required data})async{
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    final isFormData = data is FormData;
    dio!.options.headers = {
      'Accept':'application/json',
      if (!isFormData) 'Content-Type': 'application/json',
      "lang" : "${CacheHelper.getString("lang")}",
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id' : deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
    };
    // عند FormData (مثل الصور) لا نضع Content-Type ليتولى Dio إرسال multipart/form-data مع الـ boundary
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
    // PUT body must be sent as raw JSON string (same as Postman raw JSON) to avoid 500
    final String? bodyJson = data != null ? jsonEncode(data) : null;
    return await dio!.put(
      url,
      queryParameters: query,
      data: bodyJson,
      options: Options(
        contentType: Headers.jsonContentType,
        sendTimeout: dio!.options.sendTimeout,
        receiveTimeout: dio!.options.receiveTimeout,
      ),
    );
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
    // PATCH body as raw JSON string (same as PUT / Postman raw JSON)
    final String? bodyJson = data != null ? jsonEncode(data) : null;
    return await dio!.patch(
      url,
      queryParameters: query,
      data: bodyJson,
      options: Options(
        contentType: Headers.jsonContentType,
        sendTimeout: dio!.options.sendTimeout,
        receiveTimeout: dio!.options.receiveTimeout,
      ),
    );
  }
  static Future<Response> postFormData({@required url, context, formdata,@required Map<String, dynamic>? query, @required Map<String, dynamic>? data})async{
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    String? deviceUniqueId = await _getDeviceUniqueId(context, appConfigServiceProvider);
    dio!.options.headers = {
      'Accept':'application/json',
      "lang" : "${CacheHelper.getString("lang")}",
      // 'Content-Type': 'multipart/form-data', // Dio handles this automatically for FormData
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