import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../models/redeem_prize_model.dart';

abstract class RedeemPrizeRepository {
  Future<Either<Failure,RedeemPrizeModel>> redeemPrize({required String prizeName});
}