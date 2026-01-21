import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_test/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/modules/more/views/faq/logic/get_faq_model.dart';

class FaqModelProvider extends ChangeNotifier{
  bool isLoading = false;
  String? errorMessage;
  FaqModel? faqModel;
  getFaq(context){
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
        url: "/rm_page/v1/show?slug=faq",
        context: context,
    ).then((value){
      isLoading = false;
      faqModel = FaqModel.fromJson(value.data);
      notifyListeners();
    }).catchError((error){
      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }
}