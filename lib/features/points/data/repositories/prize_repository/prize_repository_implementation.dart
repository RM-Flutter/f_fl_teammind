import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/features/points/data/repositories/prize_repository/prize_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/data/models/Prize_model.dart';
import 'package:app_test/features/points/data/models/copoun_model.dart';

class GetPrizeRepositoryImplementation extends GetPrizeRepository {
  final BuildContext context;

  GetPrizeRepositoryImplementation(this.context);

  @override
  Future<Either<Failure, PrizeModel>> getPrize() async {
    var get = Provider.of<AppConfigService>(context, listen: false);
    try {
      Response data = await DioHelper.getData(
        url: "/prizes/entities-operations",
        context: context,
      );
      debugPrint(data.data);
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
  Future<Either<Failure, CopounModel>> sendCopoun(
      {required String copounCode}) async {
    var get = Provider.of<AppConfigService>(context, listen: false);
    debugPrint("SERIAL IS ---> $copounCode");
    try {
      Response data = await DioHelper.postData(
        url: "/rm_pointsys/v1/redeem_gift_card",
        context: context,
        data: {
          'serial': copounCode.replaceAll('-', ''),
        },
      );
      debugPrint(data.data);
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
