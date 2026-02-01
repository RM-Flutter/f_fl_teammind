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
  List devices = [];

  getDevices({context}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await UserDeviceRepo.getDevices(context: context);
      isLoading = false;
      devices = response.data['devices'];
      notifyListeners();
    } catch (error) {
      isLoading = false;
      notifyListeners();
      if (error is DioException) {
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
      await UserDeviceRepo.stopDevice(context: context, deviceId: deviceId).then((v){
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
      if (error is DioException) {
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
      final response = await UserDeviceRepo.deviceSysGet(context: context);
      isLoading = false;
      notificationStatus = response.data['device']['notification_token_status'] == 1 ? true : false;
      debugPrint("notificationStatus --> $notificationStatus");
      notifyListeners();
    } catch (error) {
      isLoading = false;
      notifyListeners();
      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }
  }
  getDeviceSysSet({context, required bool state}) async {
    isLoading2 = true;
    notifyListeners();
    try {
      final response = await UserDeviceRepo.deviceSysSetToken(
        context: context,
        token: await FirebaseMessaging.instance.getToken(),
      );
      isLoading2 = false;
      notificationStatus = state;
      debugPrint("state---$state");
      CacheHelper.setBool("status", state);
      debugPrint("STATUS IS ---> ${CacheHelper.getBool("status")}");
      if(response.data['status'] == true){
        getDeviceSysSet2(context: context,state: state);
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
      notifyListeners();
    } catch (error) {
      isLoading2 = false;
      notifyListeners();
      if (error is DioException) {
        errorMessage2 = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage2 = error.toString();
      }
    }
    Fluttertoast.showToast(
        msg: errorMessage2!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  getDeviceSysSet2({context, required bool state}) async {
    isLoading2 = true;
    notifyListeners();
    try {
      final response = await UserDeviceRepo.deviceSysSetTokenStatus(
        context: context,
        state: state,
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
      debugPrint("state---$state");
      CacheHelper.setBool("status", state);
      notifyListeners();
    } catch (error) {
      isLoading2 = false;
      notifyListeners();
      if (error is DioException) {
        errorMessage2 = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage2 = error.toString();
      }
    }
  }
}
