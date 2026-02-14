

import 'package:app_test/features/points/core/errors/failures.dart';
import 'package:app_test/features/points/data/models/condition_model.dart';
import 'package:dartz/dartz.dart';

abstract class ConditionRepository {
  Future<Either<Failure,TermsAndConditionsModel>> getCondition();
}