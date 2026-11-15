import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:intl/intl.dart';

abstract class RewardsAndPenaltiesRepo {
  static String? formatDate(context,String? dateString) {
    if (dateString == null) return null;

    try {
      // Parse the string into a DateTime object
      DateTime parsedDate = DateTime.parse(dateString);

      // Format the DateTime object into the desired format
      String formattedDate = DateFormat('d MMMM yyyy', LocalizationService.isArabic(context: context)? "ar" : "en").format(parsedDate);

      return formattedDate;
    } catch (e) {
      // Handle any parsing errors
      return null;
    }
  }

  static String getRewardAndPenaltyImage({String? type}) {
    if (type?.toLowerCase().trim().contains('reward') ?? false) {
      return AppImages.reward;
    }
    return AppImages.penalty;
  }

  /// Approval-system type key: lists, details and manager actions go through
  /// `/approval-system/v1/rewards_and_penalties/...`.
  static const String approvableType = 'rewards_and_penalties';
}
