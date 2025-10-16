import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';

import '../../constants/app_strings.dart';
import '../../general_services/alert_service/alerts.service.dart';
import '../../general_services/app_config.service.dart';
import '../../modules/personal_profile/viewmodels/personal_profile.viewmodel.dart';
import '../../routing/app_router.dart';

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

  getDeviceSysSet({context, required bool state}) async {
    isLoading2 = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_users/v1/device_sys",
        context: context,
        data: {
          "action": "set",
          "key": "notification_token",
          "value": await FirebaseMessaging.instance.getToken(),
        },
      );
      isLoading2 = false;
      notificationStatus = state;
      print("state---$state");
      CacheHelper.setBool("status", state);
      print("STATUS IS ---> ${CacheHelper.getBool("status")}");
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
      if (error is DioError) {
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
