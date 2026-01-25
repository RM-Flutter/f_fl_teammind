import 'package:dartz/dartz.dart';
import 'package:app_test/modules/points/core/errors/failures.dart';
import 'package:app_test/modules/points/data/models/Prize_model.dart';
import 'package:app_test/modules/points/data/models/copoun_model.dart';

abstract class GetPrizeRepository {
  Future<Either<Failure,PrizeModel>> getPrize();
  Future<Either<Failure,CopounModel>> sendCopoun({required String copounCode});
}