import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:rmemp/platform/platform_is.dart';
import 'package:rmemp/routing/app_router.dart';

import 'dio_adapter_reset_stub.dart' if (dart.library.io) 'dio_adapter_reset.dart' as adapter_reset;

import '../../../../models/operation_result.model.dart';
import '../../../app_config.service.dart';
import '../../../telegram_error_service.dart';
import '../../api_service_helpers.dart';
import '../../backend_services_interface.dart';

class DioApiService implements BackEndServicesInterface {
  static final DioApiService _singleton = DioApiService._internal();
  late Dio _dio;

  factory DioApiService() {
    return _singleton;
  }

  DioApiService._internal() {
    // Initialize Dio with proper timeout and connection settings
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        // Enable persistent connections
        persistentConnection: true,
        // Follow redirects
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
    
    // Add retry interceptor for connection errors (مع إعادة تعيين الاتصال لتفادي مشكلة عدم الرد حتى إعادة فتح الواي فاي)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (_shouldRetry(error)) {
            final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
            if (retryCount < 3) {
              error.requestOptions.extra['retryCount'] = retryCount + 1;
              // إغلاق الاتصالات القديمة وفتح اتصالات جديدة قبل إعادة المحاولة
              adapter_reset.resetDioAdapter(_dio);
              Future.delayed(Duration(seconds: retryCount + 1), () {
                _dio.fetch(error.requestOptions).then(
                  (response) => handler.resolve(response),
                  onError: (err) => handler.reject(err),
                );
              });
              return;
            }
          }
          handler.next(error);
        },
      ),
    );
    
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: false,
        maxWidth: 90,
      ),
    );
  }
  
  // Check if error should be retried
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.message?.contains('Failed host lookup') ?? false) ||
        (error.message?.contains('SocketException') ?? false);
  }
  
  // Get user-friendly error message
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return error.response?.statusMessage ?? 'Server error occurred';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        if (error.message?.contains('Failed host lookup') ?? false) {
          return 'Cannot connect to server. Please check your internet connection.';
        }
        return error.message ?? 'Unexpected error occurred';
      default:
        return error.message ?? 'Unexpected error occurred';
    }
  }
  static Uri _getUri(String url) {
    return Uri.parse(url);
  }
  static Future<OperationResult<T>> _handleResponse<T>(
      {required Response response,
        required bool applyTokenLogic,
        required String dataKey,
        required BuildContext context,
        bool? allData = false}) async {
    print("STATUS CODE IS --> ${response.statusCode}");
    String? respond;
    // Use a context that is still mounted (avoid "deactivated widget's ancestor" when async response arrives after screen closed)
    final safeContext = context.mounted ? context : rootNavigatorKey.currentContext;
    if (safeContext == null || !safeContext.mounted) {
      return OperationResult<T>(success: false, message: 'Request cancelled or screen closed');
    }
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(safeContext, listen: false);
    switch (response.statusCode) {
      case 200:
        final reply = response.data;
        if (reply.isEmpty) {
          return OperationResult<T>(success: false, message: 'Result is empty');
        }

        if (applyTokenLogic) {
          // if new token founded in the incomming response , then update the current token with the new one
          try {
            if (T is Map) {
              var newToken = (json as Map<String, dynamic>)['token'] as String?;
              if (newToken != null && newToken.isNotEmpty) {
                await appConfigServiceProvider.setToken(newToken);
              }
            }
          } catch (err, t) {
            debugPrint(
                '--------- Failed while updating current token from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
          }
        }
        if (json is Map == false) {
          if (reply != null && reply["status"] != null && reply["status"] == true) {
            return OperationResult<T>(
                success: true, message: reply["message"], data: reply);
          } else {
            return OperationResult<T>(
                success: false, message: reply["message"] ?? "");
          }
        }
        return ApiServiceHelpers.parseResponse<T>(
            responseJsonData: reply, dataKey: dataKey, allData: allData);

      case 400:
        respond = 'Bad Request';
        // _toast.toastMethod(LocaleKeys.respond_400.tr());
        return OperationResult<T>(success: false, message: respond);

      case 401:
        respond = 'Unauthorized';
        print("Unauthorized is ${respond}");
        // _toast.toastMethod(LocaleKeys.respond_401.tr());
        final appConfigService = Provider.of<AppConfigService>(safeContext, listen: false);
        appConfigService.logout(safeContext, viewAlert: false, skipServerLogout: true, skipNavigation: true).then((v){
          if (safeContext.mounted) {
            safeContext.goNamed(AppRoutes.splash.name,
                pathParameters: {'lang': safeContext.locale.languageCode});
          }
        }).catchError((e) {
          if (safeContext.mounted) {
            safeContext.goNamed(AppRoutes.splash.name,
                pathParameters: {'lang': safeContext.locale.languageCode});
          }
        });
        return OperationResult<T>(success: false, message: respond);


      case 429:
        respond = 'Too Many Requests';
        // _toast.toastMethod(LocaleKeys.respond_429.tr());
        return OperationResult<T>(success: false, message: respond);

      case 404:
        respond = 'Not Found';
        // _toast.toastMethod(LocaleKeys.respond_404.tr());
        return OperationResult<T>(success: false, message: respond);

      case 500:
        respond = 'Server Error';
        // _toast.toastMethod(LocaleKeys.respond_500.tr());
        return OperationResult<T>(success: false, message: respond);

      default:
        respond = 'Unknown Error';
        return OperationResult<T>(
            success: false, message: 'Result code = ${response.statusCode}');
    }
  }

/*
  static Future<OperationResult<T>> _handleResponse<T>(
      {required Response response,
      required bool applyTokenLogic,
      required String dataKey,
      required BuildContext context}) async {
    final appConfigServiceProvider =
        Provider.of<AppConfigService>(context, listen: false);
    String? respond;
    switch (response.statusCode) {
      case 200:
        String reply = response.data;
        if (reply.isEmpty) {
          return OperationResult<T>(success: false, message: 'Result is empty');
        }
        var json = jsonDecode(reply);
        if (applyTokenLogic) {
          // if new token founded in the incoming response, then update the current token with the new one
          try {
            if (T is Map) {
              var newToken =
                  (json['data'] as Map<String, dynamic>)['token'] as String?;
              if (newToken != null && newToken.isNotEmpty) {
                await appConfigServiceProvider.setToken(newToken);
              }
            }
          } catch (err, t) {
            debugPrint(
                '--------- Failed while updating current token from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
          }
        }
        return ApiServiceHelpers.parseResponse<T>(
            responseJsonData: json, dataKey: dataKey);

      case 400:
        respond = 'Bad Request';
        // _toast.toastMethod(LocaleKeys.respond_400.tr());
        return OperationResult<T>(success: false, message: respond);

      case 401:
        respond = 'Unauthorized';
        // _toast.toastMethod(LocaleKeys.respond_401.tr());
        // Applying logic that triggers while unauthorized responses
        return OperationResult<T>(success: false, message: respond);

      case 429:
        respond = 'Too Many Requests';
        // _toast.toastMethod(LocaleKeys.respond_429.tr());
        return OperationResult<T>(success: false, message: respond);

      case 404:
        respond = 'Not Found';
        // _toast.toastMethod(LocaleKeys.respond_404.tr());
        return OperationResult<T>(success: false, message: respond);

      case 500:
        respond = 'Server Error';
        // _toast.toastMethod(LocaleKeys.respond_500.tr());
        return OperationResult<T>(success: false, message: respond);

      default:
        respond = 'Unknown Error';
        return OperationResult<T>(
            success: false, message: 'Result code = ${response.statusCode}');
    }
  }
*/
  @override
  Future<OperationResult<T>> get<T>(String url,
      {required String dataKey,
        Map<String, String>? header,
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
        bool? checkOnTokenExpiration = true,
        bool? allData = false,
        required BuildContext context}) async {
    try {
      final response = await _dio.get(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
            sendTimeout: const Duration(minutes: 2),
            headers: await ApiServiceHelpers.buildHeaders(
                additionalHeaders: header, context: context)),
      );
      return await _handleResponse<T>(
          response: response,
          applyTokenLogic: checkOnTokenExpiration!,
          dataKey: dataKey,
          context: context);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      print("Caught DioException with status code: $statusCode");

      // Handle CORS errors on web
      if (kIsWeb || PlatformIs.web) {
        final errorMessage = e.message?.toLowerCase() ?? '';
        // التحقق من أخطاء CORS من خلال رسالة الخطأ أو عدم وجود response
        if (errorMessage.contains('cors') || 
            errorMessage.contains('access-control-allow-origin') ||
            errorMessage.contains('blocked by cors policy') ||
            (e.response == null && errorMessage.isNotEmpty)) {
          debugPrint('⚠️ CORS Error in get(): ${e.message}');
          debugPrint('⚠️ Request URL: ${e.requestOptions.uri}');
          return OperationResult<T>(
            success: false,
            message: 'CORS Error: The server does not allow requests from this origin. Please contact the server administrator.',
          );
        }
      }

      if (statusCode == 401) {
        print("Unauthorized (caught in DioException catch block)");
        final safeCtx = context.mounted ? context : rootNavigatorKey.currentContext;
        if (safeCtx != null && safeCtx.mounted) {
          final appConfigService =
              Provider.of<AppConfigService>(safeCtx, listen: false);
          // فقط صفّي حالة الدخول محلياً ووجّه لصفحة اللوجين
          try {
            appConfigService.clearToken(notify: true);
            appConfigService.setIsLogin(false, notify: true);
          } catch (e) {
            debugPrint('Error clearing auth state on 401 (get): $e');
          }
          if (safeCtx.mounted) {
            safeCtx.goNamed(
              AppRoutes.login.name,
              pathParameters: {'lang': safeCtx.locale.languageCode},
            );
          }
        }
        return OperationResult<T>(success: false, message: 'Unauthorized');
      }

      // Handle connection errors
      String errorMessage = _getErrorMessage(e);
      return OperationResult(
        success: false,
        message: errorMessage,
      );
    } catch (err, t) {
      debugPrint(
        '--------- Failed get() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}',
      );
      // Send to Telegram (use safe context to avoid deactivated widget lookup)
      final safeCtxForTelegram = context.mounted ? context : rootNavigatorKey.currentContext;
      final screenName = safeCtxForTelegram != null && safeCtxForTelegram.mounted
          ? TelegramErrorService.getCurrentScreenName(safeCtxForTelegram)
          : 'unknown';
      TelegramErrorService.captureException(
        err,
        stackTrace: t,
        screenName: screenName,
        extra: {
          'url': url,
          'method': 'GET',
          'dataKey': dataKey,
        },
      );
      return OperationResult(success: false, message: err.toString());
    }
  }

  @override
  Future<OperationResult<T>> post<T>(
      String url,
      dynamic data, {
        required String dataKey,
        required BuildContext context,
        Map<String, String>? header,
        bool? allData = false,
        bool? checkOnTokenExpiration = true,
      }) async {
    try {
      final response = await _dio.post(
        url,
        data: jsonEncode(data),
        options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
                additionalHeaders: header, context: context)),
      );
      return _handleResponse(
          response: response,
          applyTokenLogic: checkOnTokenExpiration!,
          dataKey: dataKey,
          context: context);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      print("Caught DioException with status code: $statusCode");

      if (statusCode == 401) {
        print("Unauthorized (caught in DioException catch block)");
        final safeCtx = context.mounted ? context : rootNavigatorKey.currentContext;
        if (safeCtx != null && safeCtx.mounted) {
          final appConfigService =
              Provider.of<AppConfigService>(safeCtx, listen: false);
          // فقط صفّي حالة الدخول محلياً ووجّه لصفحة اللوجين
          try {
            appConfigService.clearToken(notify: true);
            appConfigService.setIsLogin(false, notify: true);
          } catch (e) {
            debugPrint('Error clearing auth state on 401 (post): $e');
          }
          if (safeCtx.mounted) {
            safeCtx.goNamed(
              AppRoutes.login.name,
              pathParameters: {'lang': safeCtx.locale.languageCode},
            );
          }
        }
        return OperationResult<T>(success: false, message: 'Unauthorized');
      }

      // Handle connection errors
      String errorMessage = _getErrorMessage(e);
      return OperationResult(
        success: false,
        message: errorMessage,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed post() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      // Send to Telegram (use safe context to avoid deactivated widget lookup)
      final safeCtxForTelegram = context.mounted ? context : rootNavigatorKey.currentContext;
      final screenName = safeCtxForTelegram != null && safeCtxForTelegram.mounted
          ? TelegramErrorService.getCurrentScreenName(safeCtxForTelegram)
          : 'unknown';
      TelegramErrorService.captureException(
        err,
        stackTrace: t,
        screenName: screenName,
        extra: {
          'url': url,
          'method': 'POST',
          'dataKey': dataKey,
        },
      );
      return OperationResult(success: false, message: err.toString());
    }
  }

  @override
  Future<OperationResult<T>> postWithFormData<T>(
      String url,
      Map<String, String> data, {
        required String dataKey,
        required List<FilePickerResult> files,
        String? fileFieldName,
        Map<String, String>? header,
        bool? checkOnTokenExpiration = true,
        required BuildContext context,
        bool? allData = false,
      }) async {
    try {

      // Prepare FormData
      FormData formData = FormData.fromMap({
        ...data,
      });

      // Add files to formData
      if (files.isNotEmpty) {
        for (var file in files) {
          for (var fileItem in file.files) {
            if (fileItem.bytes != null) {
              String mimeType =
                  lookupMimeType(fileItem.name) ?? 'application/octet-stream';

              formData.files.add(MapEntry(
                fileFieldName ?? 'files[]',
                MultipartFile.fromBytes(
                  fileItem.bytes!,
                  filename: fileItem.name,
                  contentType: MediaType.parse(mimeType),
                ),
              ));
            }
          }
        }
      }

      // Send the request
      final response = await _dio.post(
        _getUri(url).toString(),
        data: formData,
        options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
                additionalHeaders: header, context: context)),
      );

      if (response.statusCode == 200) {
        var json = response.data;
        return ApiServiceHelpers.parseResponse<T>(
          responseJsonData: json,
          dataKey: dataKey,
          allData: allData,
        );
      } else {
        return OperationResult<T>(
          success: false,
          message: 'Result code = ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      print("Caught DioException with status code: $statusCode");

      if (statusCode == 401) {
        print("Unauthorized (caught in DioException catch block)");
        final safeCtx = context.mounted ? context : rootNavigatorKey.currentContext;
        if (safeCtx != null && safeCtx.mounted) {
          final appConfigService =
              Provider.of<AppConfigService>(safeCtx, listen: false);
          // فقط صفّي حالة الدخول محلياً ووجّه لصفحة اللوجين
          try {
            appConfigService.clearToken(notify: true);
            appConfigService.setIsLogin(false, notify: true);
          } catch (e) {
            debugPrint('Error clearing auth state on 401 (postFormData): $e');
          }
          if (safeCtx.mounted) {
            safeCtx.goNamed(
              AppRoutes.login.name,
              pathParameters: {'lang': safeCtx.locale.languageCode},
            );
          }
        }
        return OperationResult<T>(success: false, message: 'Unauthorized');
      }

      // Handle connection errors
      String errorMessage = _getErrorMessage(e);
      return OperationResult(
        success: false,
        message: errorMessage,
      );
    } catch (err, stackTrace) {
      debugPrint(
          'Failed postWithFormData() ❌ \n error ${err.toString()} - in Line :- ${stackTrace.toString()}');
      // Send to Telegram (use safe context to avoid deactivated widget lookup)
      final safeCtxForTelegram = context.mounted ? context : rootNavigatorKey.currentContext;
      final screenName = safeCtxForTelegram != null && safeCtxForTelegram.mounted
          ? TelegramErrorService.getCurrentScreenName(safeCtxForTelegram)
          : 'unknown';
      TelegramErrorService.captureException(
        err,
        stackTrace: stackTrace,
        screenName: screenName,
        extra: {
          'url': url,
          'method': 'POST_FORM_DATA',
          'dataKey': dataKey,
        },
      );
      return OperationResult<T>(
        success: false,
        message: err.toString(),
      );
    }
  }

  // @override
  // Future<OperationResult<T>> postWithFormData<T>(
  //   String url,
  //   Map<String, String> data, {
  //   required String dataKey,
  //   required List<FilePickerResult> files,
  //   Map<String, String>? header,
  //   String? fileFieldName,
  //   bool? checkOnTokenExpiration = true,
  //   bool? allData = false,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     var formData = FormData.fromMap(data);

  //     for (var file in files) {
  //       for (var fileItem in file.files) {
  //         String mimeType =
  //             lookupMimeType(fileItem.name) ?? 'application/octet-stream';
  //         formData.files.add(MapEntry(
  //           fileFieldName ?? 'files', // The field name for the file parameter
  //           MultipartFile.fromBytes(
  //             fileItem.bytes!,
  //             filename: fileItem.name,
  //             contentType: MediaType.parse(mimeType),
  //           ),
  //         ));
  //       }
  //     }

  //     final response = await Dio().post(
  //       url,
  //       data: formData,
  //       options: Options(
  //         headers: ApiServiceHelpers.buildHeaders(
  //             additionalHeaders: header, context: context),
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       var json = response.data;
  //       return ApiServiceHelpers.parseResponse<T>(
  //         responseJsonData: json,
  //         dataKey: dataKey,
  //         allData: allData,
  //       );
  //     } else {
  //       return OperationResult<T>(
  //         success: false,
  //         message: 'Result code = ${response.statusCode}',
  //       );
  //     }
  //   } catch (err, t) {
  //     debugPrint(
  //         'Failed postWithFormData() ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
  //     return OperationResult<T>(
  //       success: false,
  //       message: err.toString(),
  //     );
  //   }
  // }

  @override
  Future<OperationResult<T>> put<T>(String url, Map data,
      {required String dataKey,
        required BuildContext context,
        Map<String, String>? header,
        bool? allData = false,
        bool? checkOnTokenExpiration = true}) async {
    try {
      final response = await _dio.put(
        url,
        data: jsonEncode(data),
        options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
                additionalHeaders: header, context: context)),
      );
      return _handleResponse(
          response: response,
          applyTokenLogic: checkOnTokenExpiration!,
          context: context,
          allData: allData,
          dataKey: dataKey);
    }on DioError catch (e) {
      final statusCode = e.response?.statusCode;
      print("Caught DioException with status code: $statusCode");

      if (statusCode == 401) {
        print("Unauthorized (caught in DioException catch block)");
        final safeCtx = context.mounted ? context : rootNavigatorKey.currentContext;
        if (safeCtx != null && safeCtx.mounted) {
          final appConfigService =
              Provider.of<AppConfigService>(safeCtx, listen: false);
          // فقط صفّي حالة الدخول محلياً ووجّه لصفحة اللوجين
          try {
            appConfigService.clearToken(notify: true);
            appConfigService.setIsLogin(false, notify: true);
          } catch (e) {
            debugPrint('Error clearing auth state on 401 (put): $e');
          }
          if (safeCtx.mounted) {
            safeCtx.goNamed(
              AppRoutes.login.name,
              pathParameters: {'lang': safeCtx.locale.languageCode},
            );
          }
        }
        return OperationResult<T>(success: false, message: 'Unauthorized');
      }

      // Handle connection errors
      String errorMessage = _getErrorMessage(e);
      return OperationResult(
        success: false,
        message: errorMessage,
      );
    }  catch (err, t) {
      debugPrint(
          '--------- Failed put() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  @override
  Future<OperationResult<T>> delete<T>(String url, Map data,
      {required String dataKey,
        Map<String, String>? header,
        required BuildContext context,
        bool? allData = false,
        bool? checkOnTokenExpiration = true}) async {
    try {
      final response = await _dio.delete(
        url,
        data: jsonEncode(data),
        options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
                additionalHeaders: header, context: context)),
      );
      return _handleResponse(
          response: response,
          applyTokenLogic: checkOnTokenExpiration!,
          dataKey: dataKey,
          allData: allData,
          context: context);
    }on DioError catch (e) {
      final statusCode = e.response?.statusCode;
      print("Caught DioException with status code: $statusCode");

      if (statusCode == 401) {
        print("Unauthorized (caught in DioException catch block)");
        final safeCtx = context.mounted ? context : rootNavigatorKey.currentContext;
        if (safeCtx != null && safeCtx.mounted) {
          final appConfigService =
              Provider.of<AppConfigService>(safeCtx, listen: false);
          // فقط صفّي حالة الدخول محلياً ووجّه لصفحة اللوجين
          try {
            appConfigService.clearToken(notify: true);
            appConfigService.setIsLogin(false, notify: true);
          } catch (e) {
            debugPrint('Error clearing auth state on 401 (delete): $e');
          }
          if (safeCtx.mounted) {
            safeCtx.goNamed(
              AppRoutes.login.name,
              pathParameters: {'lang': safeCtx.locale.languageCode},
            );
          }
        }
        return OperationResult<T>(success: false, message: 'Unauthorized');
      }

      // Handle connection errors
      String errorMessage = _getErrorMessage(e);
      return OperationResult(
        success: false,
        message: errorMessage,
      );
    }  catch (err, t) {
      debugPrint(
          '--------- Failed delete() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  @override
  Future<OperationResult<T>> postFile<T>(
      String url,
      Uint8List fileData,
      String name, {
        required String dataKey,
        Map<String, String>? requestFields,
        Map<String, String>? header,
        required BuildContext context,
        bool isImage = true,
        bool? allData = false,
      }) async {
    try {
      String mimeType = lookupMimeType(name) ?? 'application/octet-stream';
      String fileName = name.split('/').last;

      FormData formData = FormData.fromMap({
        ...requestFields ?? {},
        'file': MultipartFile.fromBytes(
          fileData,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
                additionalHeaders: header, context: context)),
      );

      if (response.statusCode == 200) {
        var json = response.data;
        return ApiServiceHelpers.parseResponse<T>(
          responseJsonData: json,
          dataKey: dataKey,
          allData: allData,
        );
      } else {
        return OperationResult<T>(
          success: false,
          message: 'Result code = ${response.statusCode}',
        );
      }
    }on DioError catch (e) {
      final statusCode = e.response?.statusCode;
      print("Caught DioException with status code: $statusCode");

      if (statusCode == 401) {
        print("Unauthorized (caught in DioException catch block)");
        final safeCtx = context.mounted ? context : rootNavigatorKey.currentContext;
        if (safeCtx != null && safeCtx.mounted) {
          final appConfigService =
          Provider.of<AppConfigService>(safeCtx, listen: false);
          appConfigService.logout(safeCtx, viewAlert: false, skipServerLogout: true, skipNavigation: true).then((v) {
            if (safeCtx.mounted) {
              safeCtx.goNamed(AppRoutes.splash.name,
                  pathParameters: {'lang': safeCtx.locale.languageCode});
            }
          }).catchError((e) {
            if (safeCtx.mounted) {
              safeCtx.goNamed(AppRoutes.splash.name,
                  pathParameters: {'lang': safeCtx.locale.languageCode});
            }
          });
        }
        return OperationResult<T>(success: false, message: 'Unauthorized');
      }

      // Handle connection errors
      String errorMessage = _getErrorMessage(e);
      return OperationResult(
        success: false,
        message: errorMessage,
      );
    }  catch (err, t) {
      debugPrint(
          'Failed postFileWith_dio ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult<T>(
        success: false,
        message: err.toString(),
      );
    }
  }

  @override
  Future<OperationResult<T>> patch<T>(String url, Map? data,
      {required String dataKey,
        Map<String, String>? header,
        bool checkOnTokenExpiration = true,
        bool? allData = false,
        required BuildContext context}) async {
    try {
      final response = await _dio.patch(
        url,
        data: jsonEncode(data),
        options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
                additionalHeaders: header, context: context)),
      );
      return _handleResponse(
          response: response,
          applyTokenLogic: checkOnTokenExpiration,
          context: context,
          allData: allData,
          dataKey: dataKey);
    } catch (err, t) {
      debugPrint(
          '--------- Failed put() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  ////////////////////////////////////////////////////////////////
  /// Additional Methods
  ////////////////////////////////////////////////////////////////

  /// call backend and return OperationResult with Map
  static Future<OperationResult<T>> getEx<T>(String url,
      {Map<String, String>? header,
        bool? checkOnTokenExpiration = true,
        required BuildContext context}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens<T>(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }
      var result = await getString(url, context, header: header);
      if (!result.success) {
        return OperationResult(
          success: false,
          message: result.message,
        );
      }
      var map = json.decode(result.data ?? '');
      return OperationResult(success: true, data: map);
    } catch (err, t) {
      debugPrint(
          '--------- Failed get() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// call backend and return OperationResult with Map
  static Future<OperationResult<T>> postEx<T>(String url, dynamic data,
      {required String dataKey,
        Map<String, String>? header,
        bool asString = false,
        bool? allData = false,
        bool? checkOnTokenExpiration = true,
        required BuildContext context}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens<T>(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }

      if (asString) {
        data = json
            .encode(data, toEncodable: ApiServiceHelpers.customEncode)
            .replaceAll('"', '\'');
      }
      var body = json.encode(data, toEncodable: ApiServiceHelpers.customEncode);
      debugPrint('POST --------------------- $url');

      var client = Dio();
      var response = await client.post(url,
          data: utf8.encode(body),
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));

      if (response.statusCode != 200) //&& response.statusCode !=307
          {
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }
      var r = jsonDecode(response.data);
      return ApiServiceHelpers.parseResponse(
        responseJsonData: r,
        dataKey: dataKey,
        allData: allData,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed post() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// call backend and return OperationResult with Map
  static Future<OperationResult<T>> putEx<T>(String url, Map data,
      {required String dataKey,
        Map<String, String>? header,
        bool? allData = false,
        bool? checkOnTokenExpiration = true,
        required BuildContext context}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens<T>(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }

      debugPrint('POST --------------------- $url');

      var client = Dio();
      var response = await client.post(url,
          data: json.encode(data, toEncodable: ApiServiceHelpers.customEncode),
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));
      if (response.statusCode != 200) //&& response.statusCode !=307
          {
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }

      String reply = response.data;

      var r = jsonDecode(reply);
      return ApiServiceHelpers.parseResponse(
        responseJsonData: r,
        dataKey: dataKey,
        allData: allData,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed put() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// call backend and post file like images
  static Future<OperationResult<String>> postFileEx(
      String url, Uint8List fileData, String name,
      {required String dataKey,
        Map<String, String>? requestFields,
        Map<String, String>? header,
        bool isImage = true,
        bool? checkOnTokenExpiration = true,
        required BuildContext context}) async {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(context, listen: false);
    String dataString;
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens<String>(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }
      var request = http.MultipartRequest("POST", _getUri(url));
      request.headers['Authorization'] =
      'Bearer ${appConfigServiceProvider.token}';
      // request.fields['user'] = 'someone@somewhere.com';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileData,
        filename: name,
        contentType: isImage
            ? MediaType("image", path.extension(name))
            : MediaType('application', 'x-tar'),
      ));
      request.fields['name'] = name;
      request.fields['path'] = 'img';

      request.headers["Authorization"] =
      "Bearer ${appConfigServiceProvider.token}";
      // request.headers["Accept"] = vimeoUploadHeader;
      request.headers["Content-Type"] = "image/jpg";
      if (requestFields != null) {
        request.fields.addAll(requestFields);
      }
      if (header != null) {
        request.headers.addAll(header);
      }
      //request.headers["Content-Length"] = fileData.length.toString();
      var response = await request.send();
      if (response.statusCode == 200) {
        var data = (await response.stream.toBytes());
        if (kDebugMode) print(data.length);
        dataString = utf8.decode(data);
        var r = json.decode(dataString);
        return OperationResult(
          data: r['data'] is Map ? r['data']['url'] : r['data'],
          success: r['status'] is bool
              ? r['status']
              : r['status']?.toString() == "true",
          message: r['message'] is Map || r['message'] == null
              ? (r['messageAr'] ??
              r['errorString'] ??
              r['fullMessagesString'] ??
              r['errorCodeString'] ??
              'No Server Error!')
              : r['message'],
          errorCodeString: r['errorCodeString']?.toString(),
          checkAuth: r['check_auth'] is bool
              ? r['check_auth']
              : r['check_auth']?.toString() == "true",
        );
      }
      return OperationResult(
          success: false, message: 'Error HttpPosFile: ${response.statusCode}');
    } catch (err, t) {
      debugPrint(
          '--------- Failed postFile() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// call backend and return OperationResult with Map
  static Future<OperationResult<dynamic>> postEx1(
      String url, dynamic data, String dataKey, BuildContext context,
      [Map<String, String>? header,
        bool addToken = true,
        bool? allData = false,
        bool? checkOnTokenExpiration = true]) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }

      debugPrint('POST --------------------- $url');

      var client = Dio();
      var response = await client.post(url,
          data: json.encode(data, toEncodable: ApiServiceHelpers.customEncode),
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));
      if (response.statusCode != 200) {
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }

      String reply = response.data;
      var r = jsonDecode(reply);

      return ApiServiceHelpers.parseResponse(
        responseJsonData: r,
        dataKey: dataKey,
        allData: allData,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed postEx() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// call backend and return OperationResult with Map
  static Future<OperationResult<dynamic>> putEx1(
      String url, dynamic data, BuildContext context,
      {required String dataKey,
        bool? allData = false,
        Map<String, String>? header,
        bool? checkOnTokenExpiration = true}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }
      debugPrint('PUT --------------------- $url');

      var client = Dio();
      var response = await client.put(url,
          data: json.encode(data, toEncodable: ApiServiceHelpers.customEncode),
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));

      if (response.statusCode != 200) //&& response.statusCode !=307
          {
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }

      String reply = response.data;

      var r = jsonDecode(reply);
      return ApiServiceHelpers.parseResponse(
        responseJsonData: r,
        dataKey: dataKey,
        allData: allData,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed putEx() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// call backend and return OperationResult with Map
  static Future<OperationResult<dynamic>> getDynamic(
      String url, BuildContext context,
      {required String dataKey,
        bool? allData = false,
        Map<String, String>? header,
        bool? checkOnTokenExpiration = true}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }
      debugPrint('GET --------------------- $url');
      var client = Dio();
      var response = await client.get(url,
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));

      if (response.statusCode != 200) {
        if (response.statusCode == 401 &&
            BackEndServicesInterface.unauthrizedCallback != null) {
          BackEndServicesInterface.unauthrizedCallback
              ?.call(response.statusCode);
        }
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }
      String reply = response.data;
      if (reply.isEmpty) {
        return OperationResult(success: false, message: 'Result is empty');
      }
      var r = jsonDecode(reply);
      if (r['success'] != true) {
        if (r['errorCodeString'] == 'InvalidAuthentication' &&
            BackEndServicesInterface.unauthrizedCallback != null) {
          BackEndServicesInterface.unauthrizedCallback?.call(r);
        }
      }
      return ApiServiceHelpers.parseResponse(
        responseJsonData: r,
        dataKey: dataKey,
        allData: allData,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed getDynamic() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// this is for getting lat and long for map display
  static Future<OperationResult<dynamic>> getMapLatAndLong(
      String url, BuildContext context,
      {required String dataKey,
        Map<String, String>? header,
        bool? checkOnTokenExpiration = true}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }
      debugPrint('GET --------------------- $url');
      var client = Dio();
      var response = await client.get(url,
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));

      if (response.statusCode != 200) {
        if (response.statusCode == 401 &&
            BackEndServicesInterface.unauthrizedCallback != null) {
          BackEndServicesInterface.unauthrizedCallback
              ?.call(response.statusCode);
        }
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }
      final reply = response.data;
      if (reply.isEmpty) {
        return OperationResult(success: false, message: 'Result is empty');
      }
      return OperationResult(
        success: true,
        data: reply,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed getDynamic() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// call backend and return OperationResult with Map
  static Future<OperationResult<dynamic>> deleteDynamic(
      String url, BuildContext context,
      {required String dataKey,
        Map<String, String>? header,
        bool? allData = false,
        bool? checkOnTokenExpiration = true}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }
      debugPrint('DELETE --------------------- $url');
      var client = Dio();
      var response = await client.delete(url,
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));
      if (response.statusCode != 200) {
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }

      String reply = response.data;

      if (reply.isEmpty) {
        return OperationResult(success: false, message: 'Result is empty');
      }

      var r = jsonDecode(reply);

      return ApiServiceHelpers.parseResponse(
        responseJsonData: r,
        dataKey: dataKey,
        allData: allData,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed deleteDynamic() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');
      return OperationResult(success: false, message: err.toString());
    }
  }

  /// call backend and return OperationResult with Map
  static Future<OperationResult<dynamic>> dynamicDeleteEx(
      String url, BuildContext context,
      {required String dataKey,
        bool? allData = false,
        Map<String, String>? header,
        bool? checkOnTokenExpiration = true}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens(
          context: context,
          checkOnTokenExpiration: checkOnTokenExpiration!);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }
      debugPrint('DELETE --------------------- $url');
      var client = Dio();
      var response = await client.delete(url,
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));

      if (response.statusCode != 200) {
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }

      String reply = response.data;

      if (reply.isEmpty) {
        return OperationResult(success: false, message: 'Result is empty');
      }
      var r = jsonDecode(reply);
      return ApiServiceHelpers.parseResponse(
        responseJsonData: r,
        dataKey: dataKey,
        allData: allData,
      );
    } catch (err, t) {
      debugPrint(
          '--------- Failed deleteDynamicEx() from Api Service ❌ \n error ${err.toString()} - in Line :- ${t.toString()}');

      return OperationResult(success: false, message: err.toString());
    }
  }

  static Future<OperationResult<String>> getString(
      String url, BuildContext context,
      {Map<String, String>? header,
        bool? checkOnTokenExpiration = true}) async {
    try {
      // first : refresh access token using refresh token
      var validateTokensResult =
      await ApiServiceHelpers.checkExpirationOfTokens<String>(
          checkOnTokenExpiration: checkOnTokenExpiration!,
          context: context);
      if (validateTokensResult.success == false) {
        return validateTokensResult;
      }
      debugPrint('GET --------------------- $url');
      var client = Dio();
      var response = await client.get(url,
          options: Options(
            headers: await ApiServiceHelpers.buildHeaders(
              additionalHeaders: header,
              context: context,
            ),
          ));
      if (response.statusCode == 200) {
        return OperationResult(success: true, data: response.data);
      } else {
        return OperationResult(
            success: false, message: 'Result code = ${response.statusCode}');
      }
    } catch (err, t) {
      return OperationResult(
          success: false, message: err.toString() + t.toString());
    }
  }
}
