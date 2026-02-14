import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/features/points/core/end_points/end_points.dart';
import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/core/points_api/api_services.dart';
import 'package:app_test/features/points/data/models/redeem_prize_model.dart';
import 'package:app_test/features/points/data/repositories/redeem_prize_repository/redeem_prize_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class RedeemPrizeRepositoryImplementation extends RedeemPrizeRepository {
  final ApiServices apiServices;
  var context;
  RedeemPrizeRepositoryImplementation(this.apiServices, this.context);

  @override
  Future<Either<Failure, RedeemPrizeModel>> redeemPrize({required String prizeName}) async{
    var get = Provider.of<AppConfigService>(context, listen: false);
    try {
      Response data = await apiServices.post(
          endPoint: PointFeatureEndPoints.postPrize,
          context: context,
          data: {
            'prize' : prizeName,
          }
      );
      print(data.data);
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