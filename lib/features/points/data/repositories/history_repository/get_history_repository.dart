import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../../models/history_model.dart';

abstract class GetHistoryRepository {
  Future<Either<Failure,HistoryModel>> getHistory();
}