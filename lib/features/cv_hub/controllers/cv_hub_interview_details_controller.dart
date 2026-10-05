import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:flutter/material.dart';
import '../models/cv_hub_models.dart';
import '../repos/cv_hub_repo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_strings.dart';

class CvHubInterviewDetailsController extends ChangeNotifier {
  InterviewModel? interview;
  bool isLoading = false;
  String? error;

  Future<void> fetchInterviewDetails(BuildContext context, String id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await CvHubRepo.getInterviewDetails(context: context, interviewId: id);
    if (result.success && result.data != null && result.data!['data'] != null) {
      interview = InterviewModel.fromJson(result.data!['data']);
    } else {
      error = result.message ?? "Failed to fetch interview details";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> submitEvaluation(BuildContext context, {
    required num technicalScore,
    required num softSkillsScore,
    required String recommendation,
    required String notes,
  }) async {
    if (interview == null) return false;
    
    final data = {
      "technical_score": technicalScore,
      "soft_skills_score": softSkillsScore,
      "recommendation": recommendation,
      "notes": notes,
    };

    final result = await CvHubRepo.submitEvaluation(
      context: context,
      interviewId: interview!.id.toString(),
      data: data,
    );

    if (result.success || (result.data != null && result.data!['status'] == true)) {
      AlertsService.success(context: context, message: "Evaluation submitted successfully", title: AppStrings.success);
      await fetchInterviewDetails(context, interview!.id.toString());
      return true;
    } else {
      final msg = (result.data != null && result.data!['message'] != null) ? result.data!['message'] : (result.message ?? "Failed to submit evaluation");
      AlertsService.error(context: context, message: msg, title: AppStrings.failed);
      return false;
    }
  }

  Future<bool> updateEvaluation(BuildContext context, {
    required num technicalScore,
    required num softSkillsScore,
    required String recommendation,
    required String notes,
  }) async {
    if (interview == null || interview!.myEvaluation == null) return false;

    final data = {
      "technical_score": technicalScore,
      "soft_skills_score": softSkillsScore,
      "recommendation": recommendation,
      "notes": notes,
    };

    final result = await CvHubRepo.updateEvaluation(
      context: context,
      evaluationId: interview!.myEvaluation!.id.toString(),
      data: data,
    );

    if (result.success || (result.data != null && result.data!['status'] == true)) {
      AlertsService.success(context: context, message: "Evaluation updated successfully", title: AppStrings.success);
      await fetchInterviewDetails(context, interview!.id.toString());
      return true;
    } else {
      final msg = (result.data != null && result.data!['message'] != null) ? result.data!['message'] : (result.message ?? "Failed to update evaluation");
      AlertsService.error(context: context, message: msg, title: AppStrings.failed);
      return false;
    }
  }
}
