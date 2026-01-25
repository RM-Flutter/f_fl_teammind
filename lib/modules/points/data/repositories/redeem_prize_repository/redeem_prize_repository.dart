import 'package:dartz/dartz.dart';

import 'package:app_test/modules/points/core/errors/failures.dart';
import 'package:app_test/modules/points/data/models/redeem_prize_model.dart';

abstract class RedeemPrizeRepository {
  Future<Either<Failure,RedeemPrizeModel>> redeemPrize({required String prizeName});
}