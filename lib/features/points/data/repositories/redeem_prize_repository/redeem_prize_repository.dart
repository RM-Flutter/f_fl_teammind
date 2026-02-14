import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/data/models/redeem_prize_model.dart';
import 'package:dartz/dartz.dart';


abstract class RedeemPrizeRepository {
  Future<Either<Failure,RedeemPrizeModel>> redeemPrize({required String prizeName});
}