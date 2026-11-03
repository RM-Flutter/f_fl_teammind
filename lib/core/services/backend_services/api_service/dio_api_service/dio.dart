import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:provider/provider.dart';

import '../../../../platform/platform_is.dart';
import '../../../device_info_service.dart';
import '../../../talker_service.dart';

class DioHelper{
  static Dio? dio;
  static initail(BuildContext context){
    // Prepare headers with CORS support for web
    Map<String, dynamic> headers = {
      'Accept':'application/json',
      "lang" : "${CacheHelper.getString("lang")}",
      'Content-Type':"application/json",
      'X-App-Type': (kIsWeb || PlatformIs.web) ? 'web' : 'mobile',
    };

    // Note: CORS headers are response headers, so they should NOT be added to client requests.

    // if (kIsWeb || PlatformIs.web) {
    //   headers.addAll({
    //     'Access-Control-Allow-Origin': '*',
    //     'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
    //     'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, lang, device-unique-id',
    //   });
    // }

    dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          receiveDataWhenStatusError: true,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: (kIsWeb || PlatformIs.web) ? null : const Duration(seconds: 30),
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
    dio!.interceptors.add(TalkerLoggerService.dioLogger);
    dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-App-Type'] = (kIsWeb || PlatformIs.web) ? 'web' : 'mobile';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("response.statusCode == ${response.statusCode}");
          // Check for suspended/licence-denied error codes in any response
          final data = response.data;
          if (data is Map) {
            final errorCode = data['error']?.toString();
            if (errorCode == 'INSTANCE_SUSPENDED' || errorCode == 'LICENCE_ACCESS_DENIED') {
              final ctx = rootNavigatorKey.currentContext;
              if (ctx != null && ctx.mounted) {
                final routeName = errorCode == 'INSTANCE_SUSPENDED'
                    ? AppRoutes.instanceSuspended.name
                    : AppRoutes.licenceDenied.name;
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  try {
                    ctx.goNamed(
                      routeName,
                      pathParameters: {'lang': ctx.locale.languageCode},
                      extra: data['message']?.toString(),
                    );
                  } catch (e) {
                    debugPrint('Error navigating to suspended screen from interceptor: $e');
                  }
                });
              }
            }
          }
          if (response.statusCode == 401) {
            _handleUnauthorized(response.requestOptions);
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            _handleUnauthorized(error.requestOptions);
          }
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

          return handler.next(error);
        },
      ),
    );
    // إعادة محاولة مرة واحدة مع اتصال جديد عند timeout/قطع الاتصال (حل مشكلة عدم رد الـ API حتى إعادة فتح الواي فاي)
    _addConnectionResetRetryInterceptor();
  }

  /// True while a 401 logout + redirect is running, so parallel 401 responses redirect only once
  static bool _handlingUnauthorized = false;

  /// Any authenticated request answered with 401 (expired / revoked token): log out locally and go to the login page.
  /// Requests sent without a token (login itself, wrong password) and the logout call are left to their caller.
  static void _handleUnauthorized(RequestOptions options) {
    // Logged-out requests still send "Bearer null" / "Bearer ", so look at the token itself
    final token = (options.headers['Authorization']?.toString() ?? '').replaceFirst('Bearer', '').trim();
    if (token.isEmpty || token == 'null' || options.path.contains('log_out') || _handlingUnauthorized) return;

    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    _handlingUnauthorized = true;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        await Provider.of<AppConfigService>(ctx, listen: false)
            .logout(ctx, viewAlert: false, skipServerLogout: true, skipNavigation: true);
      } catch (e) {
        debugPrint('Error clearing auth state on 401: $e');
      }
      try {
        if (ctx.mounted) {
          ctx.goNamed(AppRoutes.login.name, pathParameters: {'lang': ctx.locale.languageCode});
        }
      } catch (e) {
        debugPrint('Error navigating to login on 401: $e');
      }
      _handlingUnauthorized = false;
    });
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
          if (error.requestOptions.data is FormData) {
            try {
              error.requestOptions.data = (error.requestOptions.data as FormData).clone();
            } catch (_) {}
          }
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
    
    final Map<String, dynamic> headers = {
      'Accept': 'application/json',
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id': deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
      'lang': CacheHelper.getString("lang") ?? "en",
    };
    
    return await dio!.download(
      url, 
      savePath, 
      onReceiveProgress: onReceiveProgress,
      options: Options(headers: headers),
    );
  }

  static Future<String?> _getDeviceUniqueId(BuildContext? context, AppConfigService appConfigServiceProvider) async {
    try {
      final deviceInfo = appConfigServiceProvider.deviceInformation;
      var deviceUniqueId = deviceInfo.deviceUniqueId;

      // If deviceUniqueId is valid, sanitize and return it
      if (deviceUniqueId.isNotEmpty && deviceUniqueId != 'Unknown Device') {
        return DeviceInformationService.sanitizeDeviceId(deviceUniqueId);
      }

      // If not valid and we have context, try to initialize device info
      if (context != null) {
        await DeviceInformationService.initializeAndSetDeviceInfo(context: context);
        final updatedDeviceInfo = appConfigServiceProvider.deviceInformation;
        deviceUniqueId = updatedDeviceInfo.deviceUniqueId;
        if (deviceUniqueId.isNotEmpty && deviceUniqueId != 'Unknown Device') {
          return DeviceInformationService.sanitizeDeviceId(deviceUniqueId);
        }
      }

      String fallbackId = CacheHelper.getString("deviceIdentifier") ?? '';
      if (fallbackId.isEmpty) {
        fallbackId = 'fallback-${DateTime.now().millisecondsSinceEpoch}';
        CacheHelper.setString(key: "deviceIdentifier", value: fallbackId);
      }
      return DeviceInformationService.sanitizeDeviceId(fallbackId);
    } catch (e) {
      debugPrint('Error getting device unique ID: $e');
      String fallbackId = CacheHelper.getString("deviceIdentifier") ?? '';
      if (fallbackId.isEmpty) {
        fallbackId = 'fallback-${DateTime.now().millisecondsSinceEpoch}';
        CacheHelper.setString(key: "deviceIdentifier", value: fallbackId);
      }
      return DeviceInformationService.sanitizeDeviceId(fallbackId);
    }
  }  static Future<Response> getData({@required url, @required Map<String, dynamic>? query,context,lang,  token,bool sendLang = false, Map<String, dynamic>? data})async{
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
    
    final Map<String, dynamic> headers = {
      'Accept': acceptHeader ?? 'application/pdf',
      if (deviceUniqueId != null && deviceUniqueId.isNotEmpty)
        'device-unique-id': deviceUniqueId,
      'Authorization': 'Bearer ${appConfigServiceProvider.token}',
      'lang': CacheHelper.getString("lang") ?? "en",
    };

    return await dio!.get(
      cleanUrl,
      queryParameters: query,
      options: Options(
        responseType: ResponseType.bytes,
        headers: headers,
      ),
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