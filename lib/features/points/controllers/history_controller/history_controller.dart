import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/data/models/history_model.dart';
import '../../data/repositories/history_repository/get_history_repository.dart';

enum HistoryState { initial, loading, success, failure }

class HistoryController with ChangeNotifier {
  final GetHistoryRepository getHistoryRepository;
  HistoryController(this.getHistoryRepository);

  HistoryState _state = HistoryState.initial;
  HistoryState get state => _state;

  HistoryModel? _historyModel;
  HistoryModel? get historyModel => _historyModel;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> getHistory() async {
    _state = HistoryState.loading;
    notifyListeners();

    Either<Failure, HistoryModel> result = await getHistoryRepository.getHistory();

    result.fold((failure) {
      _errorMessage = failure.error;
      _state = HistoryState.failure;
      Fluttertoast.showToast(
          msg: failure.error.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      notifyListeners();
    }, (historyModel) {
      _historyModel = historyModel;
      _state = HistoryState.success;
      notifyListeners();
    });
  }
}
