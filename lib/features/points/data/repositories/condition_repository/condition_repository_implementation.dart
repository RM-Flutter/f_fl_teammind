import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_test/core/services/app_config.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/points/core/api/api_services.dart';
import 'package:app_test/features/points/core/api/end_points.dart';
import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/data/models/condition_model.dart';
import 'condition_repository.dart';

class GetConditionRepositoryImplementation extends ConditionRepository {
  final ApiServices apiServices;
  var context;
  GetConditionRepositoryImplementation(this.apiServices, this.context);
  @override
  Future<Either<Failure, TermsAndConditionsModel>> getCondition() async{
    var get = Provider.of<AppConfigService>(context, listen: false);
    try {
      Response data = await apiServices.get(
          endPoint: EndPoints.conditions,
        context: context,
        queryParameters: {
          'device_unique_id': get.deviceInformation.deviceUniqueId,
        },
      );
      debugPrint(data.data);
      return Right(TermsAndConditionsModel.fromJson(data.data));
    } catch (error) {
      if (error is DioException) {
        return Left(ServerFailure(error.response!.data['message'].toString()));
      } else {
        return Left(ServerFailure(error.toString()));
      }
    }
  }

}