import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/services/app_error_reporter.dart';
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
        errorMessage = error.response?.data['message'] ?? 'something_went_wrong'.tr();
      } else {
        errorMessage = AppErrorReporter.safeMessage(error);
      }
    });
  }
}
