import 'package:dartz/dartz.dart';
import 'package:app_test/modules/points/core/errors/failures.dart';
import 'package:app_test/modules/points/data/models/history_model.dart';

abstract class GetHistoryRepository {
  Future<Either<Failure,HistoryModel>> getHistory();
}