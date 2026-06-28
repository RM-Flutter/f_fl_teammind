import 'package:flutter/material.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/alert_service/alerts_service.dart';
import '../shared/models/salary_advance_request_model.dart';
import '../shared/repos/salary_advance_repo.dart';

class SalaryAdvanceDetailsController extends ChangeNotifier {
  SalaryAdvanceRequestModel? requestDetails;
  bool isLoading = true;
  bool isActionLoading = false;
  UserSettingsModel? userSettings;

  bool get isManagerOrHr {
    if (userSettings == null) return false;
    
    final hasManagerRole = userSettings?.role?.map((e) => e.toLowerCase()).contains('manager') == true;
    final isTeamLeader = userSettings?.isTeamleaderIn != null && userSettings!.isTeamleaderIn!.isNotEmpty;

    return userSettings?.topManagement == true || 
           userSettings?.isHr == true || 
           (userSettings?.isManagerIn != null && userSettings!.isManagerIn!.isNotEmpty) ||
           hasManagerRole ||
           isTeamLeader;
  }

  bool get canModifyIncoming {
    if (userSettings == null) return false;

    // 1. Team Leader: NEVER allowed
    final isTeamLeader = userSettings?.isTeamleaderIn != null && userSettings!.isTeamleaderIn!.isNotEmpty;
    if (isTeamLeader) return false;

    // 2. HR / Top Management: Always allowed
    final isHr = userSettings?.isHr == true || userSettings?.topManagement == true;
    if (isHr) return true;

    // 3. Manager: Allowed only if manager_able_to_approve_salary_advances is true
    final hasManagerRole = userSettings?.role?.map((e) => e.toLowerCase()).contains('manager') == true;
    final isManager = (userSettings?.isManagerIn != null && userSettings!.isManagerIn!.isNotEmpty) || hasManagerRole;
    if (isManager) {
      return UserSettingConst.generalSettingsModel?.managerAbleToApproveSalaryAdvances == true;
    }

    return false;
  }

  bool get canReview {
    if (requestDetails == null || !canModifyIncoming) return false;
    
    final status = requestDetails!.status?.toLowerCase();
    if (status == 'cancelled' || status == 'canceled' || status == 'approved' || status == 'rejected') {
      return false;
    }
    
    // Assuming if the logged-in user is HR or Manager they can review.
    // Real implementation might need to check if they are the direct manager
    // or if HR is requested to approve.
    return true;
  }

  bool get canEdit {
    if (requestDetails == null || userSettings == null) return false;

    final status = requestDetails!.status?.toLowerCase();
    if (status == 'cancelled' || status == 'canceled' || status == 'approved' || status == 'rejected') {
      return false;
    }
    
    return canModifyIncoming;
  }

  bool get canCancel {
    if (requestDetails == null || userSettings == null) return false;

    final status = requestDetails!.status?.toLowerCase();
    if (status == 'cancelled' || status == 'canceled' || status == 'approved' || status == 'rejected') {
      return false;
    }

    final isOwner = userSettings!.empId.toString() ==
        requestDetails!.employeeId?.toString();
    
    return isOwner;
  }

  void _loadUserSettings() {
    var jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      var gCache = json.decode(jsonString) as Map<String, dynamic>;
      userSettings = UserSettingsModel.fromJson(gCache);
      UserSettingConst.userSettings = userSettings;
    }
  }

  Future<void> fetchDetails(BuildContext context, int id) async {
    isLoading = true;
    notifyListeners();
    _loadUserSettings();

    try {
      final result = await SalaryAdvanceRepo.getDetails(context: context, id: id);
      if (result.success && result.data != null) {
        var dataMap = result.data?['data'] as Map<String, dynamic>?;
        if (dataMap != null) {
          requestDetails = SalaryAdvanceRequestModel.fromJson(dataMap);
        }
      }
    } catch (e) {
      debugPrint("Error fetching request details: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reviewRequest(BuildContext context, String status) async {
    if (requestDetails == null) return false;
    
    isActionLoading = true;
    notifyListeners();

    try {
      final result = await SalaryAdvanceRepo.reviewRequest(
        context: context, 
        id: requestDetails!.id!, 
        status: status,
      );
      
      if (result.success) {
        // Refresh details
        await fetchDetails(context, requestDetails!.id!);
        return true;
      } else {
        if (context.mounted) {
          AlertsService.error(
            context: context, 
            message: result.message ?? 'error_occurred'.tr(), 
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error reviewing request: $e");
      if (context.mounted) {
        AlertsService.error(
          context: context, 
          message: 'error_occurred'.tr(), 
          title: 'error'.tr(),
        );
      }
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> cancelRequest(BuildContext context) async {
    if (requestDetails == null) return false;

    isActionLoading = true;
    notifyListeners();

    try {
      final result = await SalaryAdvanceRepo.cancelRequest(context: context, id: requestDetails!.id!);
      if (result.success) {
        return true;
      } else {
        if (context.mounted) {
          AlertsService.error(
            context: context, 
            message: result.message ?? 'error_occurred'.tr(), 
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error cancelling request: $e");
      if (context.mounted) {
        AlertsService.error(
          context: context, 
          message: 'error_occurred'.tr(), 
          title: 'error'.tr(),
        );
      }
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> removeAttachment(BuildContext context, int attachmentId) async {
    if (requestDetails == null) return false;

    isActionLoading = true;
    notifyListeners();

    try {
      final result = await SalaryAdvanceRepo.removeAttachment(
        context: context,
        requestId: requestDetails!.id!,
        attachmentId: attachmentId,
      );
      if (result.success) {
        var dataMap = result.data?['data'] as Map<String, dynamic>?;
        if (dataMap != null) {
          requestDetails = SalaryAdvanceRequestModel.fromJson(dataMap);
        } else {
          await fetchDetails(context, requestDetails!.id!);
        }
        return true;
      } else {
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: result.message ?? 'error_occurred'.tr(),
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error removing attachment: $e");
      if (context.mounted) {
        AlertsService.error(
          context: context,
          message: 'error_occurred'.tr(),
          title: 'error'.tr(),
        );
      }
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
    return false;
  }
}
