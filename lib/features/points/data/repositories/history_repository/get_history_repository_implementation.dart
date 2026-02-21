import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/features/points/core/end_points/end_points.dart';
import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/core/points_api/api_services.dart';
import 'package:app_test/features/points/data/models/history_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'get_history_repository.dart';

class GetHistoryRepositoryImplementation extends GetHistoryRepository {
  final ApiServices apiServices;
  var context;
  GetHistoryRepositoryImplementation(this.apiServices, this.context);
  @override
  Future<Either<Failure, HistoryModel>> getHistory() async{
    var get = Provider.of<AppConfigService>(context, listen: false);
    try {
      Response data = await apiServices.get(
          endPoint: PointFeatureEndPoints.getHistory,
        context: context,
        queryParameters: {
            'device_unique_id': get.deviceInformation.deviceUniqueId
        }
      );
      debugPrint(data.data.toString());
      return Right(HistoryModel.fromJson(data.data));
    } catch (error, stacktrace) {
      debugPrint("🔥 Error in getHistory: \$error");
      debugPrint("🔥 Stacktrace: \$stacktrace");
      if (error is DioException) {
        final response = error.response;
        if (response != null && response.data != null && response.data is Map && response.data['message'] != null) {
          return Left(ServerFailure(response.data['message'].toString()));
        }
        return Left(ServerFailure(error.message ?? 'Network error occurred'));
      } else {
        return Left(ServerFailure(error.toString()));
      }
    }
  }

}