import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/modules/more/views/aboutus/logic/get_about_model.dart';

class AboutUsLogicProvider extends ChangeNotifier{
  bool isLoading = false;
  String? errorMessage;
  AboutUsModel? aboutUsModel;
  getAboutUs(context){
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
        url: "/rm_page/v1/show?with=metas&slug=about-us-app",
        sendLang: true,
        context : context,
    ).then((value){
      aboutUsModel = AboutUsModel.fromJson(value.data);
      isLoading = false;
      notifyListeners();
    }).catchError((error){
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
      isLoading = false;
    });
  }
}