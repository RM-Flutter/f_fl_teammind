import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/data/models/condition_model.dart';
import 'condition_repository.dart';
 

class GetConditionRepositoryImplementation extends ConditionRepository {
  final BuildContext context;
  GetConditionRepositoryImplementation(this.context);
  @override
  Future<Either<Failure, TermsAndConditionsModel>> getCondition() async{
    var get = Provider.of<AppConfigService>(context, listen: false);
    try {
      Response data = await DioHelper.getData(
        url: "/rm_page/v1/show?slug=points-terms-and-conditions",
        context: context,
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
