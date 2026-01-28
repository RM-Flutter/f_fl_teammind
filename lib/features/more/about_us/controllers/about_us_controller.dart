import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/features/more/about_us/data/models/get_about_model.dart';
import '../data/remote_data/about_us_repo.dart';

class AboutUsLogicProvider extends ChangeNotifier{
  bool isLoading = false;
  String? errorMessage;
  AboutUsModel? aboutUsModel;
  getAboutUs(context){
    isLoading = true;
    notifyListeners();
    AboutUsRepo.getAboutUs(context).then((value){
      aboutUsModel = AboutUsModel.fromJson(value.data);
      isLoading = false;
      notifyListeners();
    }).catchError((error){
      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
      isLoading = false;
    });
  }
}