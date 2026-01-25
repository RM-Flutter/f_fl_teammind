import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/modules/points/core/errors/failures.dart';
import 'package:app_test/modules/points/data/models/condition_model.dart';
import '../../data/repositories/condition_repository/condition_repository.dart';

class ConditionProvider with ChangeNotifier {
  final ConditionRepository getConditionRepository;

  ConditionProvider(this.getConditionRepository);

  TermsAndConditionsModel? termsAndConditionsModel;
  bool isLoading = false;
  String? errorMessage;

  Future<void> getCondition() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    Either<Failure, TermsAndConditionsModel> result =
    await getConditionRepository.getCondition();

    result.fold(
          (failure) {
        errorMessage = failure.error;
        Fluttertoast.showToast(
            msg: failure.error.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        isLoading = false;
        notifyListeners();
      },
          (termsAndConditionsModel) {
        this.termsAndConditionsModel = termsAndConditionsModel;
        isLoading = false;
        notifyListeners();
      },
    );
  }
}
