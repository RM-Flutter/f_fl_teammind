

import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../models/condition_model.dart';

abstract class ConditionRepository {
  Future<Either<Failure,TermsAndConditionsModel>> getCondition();
}