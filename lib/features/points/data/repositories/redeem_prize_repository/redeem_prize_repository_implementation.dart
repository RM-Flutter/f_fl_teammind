import 'package:app_test/features/points/data/repositories/redeem_prize_repository/redeem_prize_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
 
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/data/models/redeem_prize_model.dart';

class RedeemPrizeRepositoryImplementation extends RedeemPrizeRepository {
  final BuildContext context;
  RedeemPrizeRepositoryImplementation(this.context);

  @override
  Future<Either<Failure, RedeemPrizeModel>> redeemPrize({required String prizeName}) async{
    var get = Provider.of<AppConfigService>(context, listen: false);
    try {
      Response data = await DioHelper.postData(
        url: "/redeem-requests/entities-operations/store",
        context: context,
        data: {
          'prize' : prizeName,
        },
      );
      debugPrint(data.data);
      return Right(RedeemPrizeModel.fromJson(data.data));
    } catch (error) {
      if (error is DioException) {
        return Left(ServerFailure(error.response!.data['message'].toString()));
      } else {
        return Left(ServerFailure(error.toString()));
      }
    }
  }

}
