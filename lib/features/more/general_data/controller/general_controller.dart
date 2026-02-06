import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class GeneralController extends ChangeNotifier{
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  var dataTitle;
  var dataContent;
  var dataimage;
  getGeneralData(context)async{
    isLoading = true;
    notifyListeners();
    await DioHelper.getData(
      url: "/rm_page/v1/show",
      query: {
        "slug": "company-policy"
      },
      sendLang: true,
      context : context,
    ).then((value){
      dataTitle = value.data['page']['title'];
      dataContent = value.data['page']['content'];
      if(value.data['page']['cover_mobile'] != null &&value.data['page']['cover_mobile'].isNotEmpty){
        dataimage = value.data['page']['cover_mobile'][0]['file'];
      }
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
