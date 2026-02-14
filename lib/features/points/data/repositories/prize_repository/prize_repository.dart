import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../../models/copoun_model.dart';
import '../../models/prize_model.dart';

abstract class GetPrizeRepository {
  Future<Either<Failure,PrizeModel>> getPrize();
  Future<Either<Failure,CopounModel>> sendCopoun({required String copounCode});
}