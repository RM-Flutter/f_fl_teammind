import 'package:app_test/modules/points/data/repositories/prize_repository/prize_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_test/core/services/app_config.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:app_test/modules/points/core/api/api_services.dart';
import 'package:app_test/modules/points/core/api/end_points.dart';
import 'package:app_test/modules/points/core/errors/failures.dart';
import 'package:app_test/modules/points/data/models/Prize_model.dart';
import 'package:app_test/modules/points/data/models/copoun_model.dart';

class GetPrizeRepositoryImplementation extends GetPrizeRepository {
  final ApiServices apiServices;
  var context;
  GetPrizeRepositoryImplementation(this.apiServices, this.context);
  @override
  Future<Either<Failure, PrizeModel>> getPrize() async{
    var get = Provider.of<AppConfigService>(context, listen: false);
    try {
      Response data = await apiServices.get(
          endPoint: EndPoints.getPrize,
          context: context,
          queryParameters: {
            'device_unique_id': get.deviceInformation.deviceUniqueId
          }
      );
      print(data.data);
      return Right(PrizeModel.fromJson(data.data));
    } catch (error) {
      if (error is DioException) {
        return Left(ServerFailure(error.response!.data['message'].toString()));
      } else {
        return Left(ServerFailure(error.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, CopounModel>> sendCopoun({required String copounCode}) async{
    var get = Provider.of<AppConfigService>(context, listen: false);
    print("SERIAL IS ---> $copounCode");
    try {
      Response data = await apiServices.post(
          endPoint: EndPoints.coupoun,
          context: context,
          data: {
            'serial' : copounCode.replaceAll('-', ''),
          }
      );
      print(data.data);
      return Right(CopounModel.fromJson(data.data));
    } catch (error) {
      if (error is DioException) {
        return Left(ServerFailure(error.response!.data['message'].toString()));
      } else {
        return Left(ServerFailure(error.toString()));
      }
    }
  }
}