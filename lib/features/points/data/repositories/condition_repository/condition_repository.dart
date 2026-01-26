

import 'package:dartz/dartz.dart';
import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/data/models/condition_model.dart';

abstract class ConditionRepository {
  Future<Either<Failure,TermsAndConditionsModel>> getCondition();
}