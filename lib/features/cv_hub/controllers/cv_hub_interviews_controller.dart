import 'package:flutter/material.dart';
import '../models/cv_hub_models.dart';
import '../repos/cv_hub_repo.dart';

class CvHubInterviewsController extends ChangeNotifier {
  List<InterviewModel> interviews = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchInterviews(BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await CvHubRepo.getMyInterviews(context: context);
    if (result.success && result.data != null && result.data!['data'] != null) {
      final List data = result.data!['data'];
      interviews = data.map((e) => InterviewModel.fromJson(e)).toList();
    } else {
      error = result.message ?? "Failed to fetch interviews";
    }

    isLoading = false;
    notifyListeners();
  }
}
