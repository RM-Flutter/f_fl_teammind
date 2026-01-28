import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_test/features/more/faqs/data/remote_data/faqs_repo.dart';
import 'package:app_test/features/more/faqs/data/models/get_faq_model.dart';

class FaqModelProvider extends ChangeNotifier{
  bool isLoading = false;
  String? errorMessage;
  FaqModel? faqModel;
  getFaq(context){
    isLoading = true;
    notifyListeners();
    FaqsRepo.getFaq(context).then((value){
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
