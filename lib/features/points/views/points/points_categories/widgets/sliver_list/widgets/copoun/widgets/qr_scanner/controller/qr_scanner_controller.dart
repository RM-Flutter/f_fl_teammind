import 'dart:async';

import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QRScannerController extends ChangeNotifier{
  bool isLoading = false;
  bool isSuccess = false;
  bool isError = false;
  bool isRequestSent = false; // Prevents duplicate requests
  bool _isLoading = false;
  bool? status;
  bool gif = false;
  String? errorMessage = '';
  void startLoading() {
    _isLoading = true;
    notifyListeners();
    Timer(const Duration(seconds: 2), () {
      _isLoading = false;
      gif = true;
      stopCoinGif();
      notifyListeners();
    });
  }

  stopCoinGif() {
    return Timer(const Duration(seconds: 5), () {
      gif = false;
      notifyListeners();
    });
  }
  Future<void> addRedeemGift({String? serial, context}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      Response value = await DioHelper.postData(
        url: "/rm_pointsys/v1/redeem_gift_card",
        context: context,
        data: {
          "serial": (serial?.contains("-") ?? false) ? serial!.replaceAll('-', '') : serial,
        },
      );

      status = value.data['status'];

      if (value.data['status'] == false) {
        if (context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Fluttertoast.showToast(
                msg: value.data['message'],
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 5,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          });
        }
      } else if (value.data['status'] == true) {
        if (context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Fluttertoast.showToast(
                msg: value.data['message'],
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 5,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
          });
          isSuccess = true;
        }
      }

      errorMessage = value.data['message'];
    } catch (e) {
      isError = true;
      errorMessage = e.toString();
      print("ERROR--> $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }

    // Explicitly return void
    return;
  }

}