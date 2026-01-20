import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../models/Prize_model.dart';
import '../../models/copoun_model.dart';

abstract class GetPrizeRepository {
  Future<Either<Failure,PrizeModel>> getPrize();
  Future<Either<Failure,CopounModel>> sendCopoun({required String copounCode});
}