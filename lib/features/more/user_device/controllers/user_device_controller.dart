import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/features/more/user_device/data/remote_data/user_device_repo.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';

class DeviceControllerProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isLoading2 = false;
  bool isSuccess = false;
  bool isDeleteSuccess = false;
  bool notificationStatus = CacheHelper.getBool("status") ?? false;
  String? errorMessage;
  String? errorMessage2;
  var status;
  List devices = [];
  changeStatus(newStatus){
    status = newStatus;
    notifyListeners();
  }
  void setNotificationStatus(bool status) {
    notificationStatus = status;
    notifyListeners();
  }
  getDevices({context}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/rm_users/v1/devices/get",
        context: context,
      );
      isLoading = false;
      devices = response.data['devices'];
      notifyListeners();
    } catch (error) {
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }
  }
  deleteDevices({context, deviceId}) async {
    isDeleteLoading = true;
    notifyListeners();
    try {
      await DioHelper.postData(
        url: "/rm_users/v1/devices/stop",
        data:(deviceId != null)? {
          if(deviceId != null) "device_id" : deviceId
        } : null,
        context: context,
      ).then((v){
        if(v.data['status'] == true){
          AlertsService.success(
            title: AppStrings.success.tr(),
            context: context,
            message: v.data['message'] ?? AppStrings.success.tr(),);
          isDeleteSuccess = true;
        }else{
          AlertsService.error(
            title: AppStrings.failed.tr(),
            context: context,
            message: v.data['message'] ?? AppStrings.failed.tr(),);
        }
        isDeleteLoading = false;
        notifyListeners();
      });
    } catch (error) {
      isDeleteLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }
  }

  getDeviceSysGet({context}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_users/v1/device_sys",
        context: context,
        data: {
          "action": "get",
          "key": "notification_token_status",
        },
      );
      isLoading = false;
      notificationStatus = response.data['device']['notification_token_status'] == 1 ? true : false;
      print("notificationStatus --> $notificationStatus");
      notifyListeners();
    } catch (error) {
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }
  }
  Future<bool> requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('Firebase requestPermission error: $e');
      return false;
    }
  }

  static bool _isFcmServiceUnavailable(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('service_not_available') ||
        msg.contains('firebase_messaging') ||
        msg.contains('ioexception');
  }

  getDeviceSysSet({context, required bool state}) async {
    bool allowed = false;
    try {
      allowed = await requestNotificationPermission();
    } catch (e) {
      debugPrint('requestNotificationPermission: $e');
    }
    if (!allowed) {
      Fluttertoast.showToast(
        msg: "الإشعارات غير مفعلة – برجاء السماح أولاً.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    isLoading2 = true;
    notifyListeners();

    try {
      // FCM token: cache only (generated at app start by FcmTokenService; do not call getToken here)
      final String? token = CacheHelper.getString("fcm_token");
      if (token == null || token.isEmpty) {
        Fluttertoast.showToast(
          msg: "جاري تجهيز الإشعارات. أعد فتح التطبيق أو انتظر قليلاً.",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        isLoading2 = false;
        notifyListeners();
        return;
      }

      final response = await DioHelper.postData(
        url: "/rm_users/v1/device_sys",
        context: context,
        data: {
          "action": "set",
          "key": "notification_token",
          "value": token,
        },
      );

      isLoading2 = false;
      notificationStatus = state;
      CacheHelper.setBool("status", state);

      if (response.data['status'] == true) {
        Fluttertoast.showToast(
          msg: response.data['message'],
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        getDeviceSysSet2(context: context, state: state);
      } else {
        Fluttertoast.showToast(
          msg: response.data['message'],
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

      notifyListeners();
    } catch (error) {
      isLoading2 = false;
      notifyListeners();

      if (error is DioError) {
        errorMessage2 = error.response?.data['message'] ?? 'Something went wrong';
      } else if (_isFcmServiceUnavailable(error)) {
        errorMessage2 = "خدمة الإشعارات غير متاحة حالياً. تأكد من الاتصال بالإنترنت وخدمات Google.";
      } else {
        errorMessage2 = error.toString();
      }

      Fluttertoast.showToast(
        msg: errorMessage2 ?? AppStrings.failed.tr(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  getDeviceSysSet2({context, required bool state}) async {
    isLoading2 = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_users/v1/device_sys",
        context: context,
        data: {
          "action": "set",
          "key": "notification_token_status",
          "value": state,
        },
      );
      if(response.data['status'] == true){
        isSuccess = true;
      }else{
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      isLoading2 = false;
      notificationStatus = state;
      print("state---$state");
      CacheHelper.setBool("status", state);
      notifyListeners();
    } catch (error) {
      isLoading2 = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage2 = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage2 = error.toString();
      }
    }
  }
}