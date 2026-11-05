import 'package:app_test/core/services/app_error_reporter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import '../models/approvable_details_model.dart';

class ApprovablesDetailsService {
  /// Fetch details of a specific request/approvable
  /// URL: /api/approval-system/v1/:type/employee/approvables/:id
  static Future<OperationResult<ApprovableDetailsModel>> getApprovableDetails({
    required BuildContext context,
    required String type,
    required String id,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: "/approval-system/v1/$type/employee/approvables/$id",
        context: context,
      );

      if (response.data != null && response.data['status'] == true) {
        final approvableJson = response.data['approvable'];
        if (approvableJson != null) {
          final model = ApprovableDetailsModel.fromJson(
            approvableJson as Map<String, dynamic>,
          );
          return OperationResult(
            success: true,
            data: model,
            message: response.data['message']?.toString(),
          );
        }
      }
      return OperationResult(
        success: false,
        message: response.data?['message']?.toString() ?? 'Failed to load details',
      );
    } catch (e) {
      debugPrint("Error in getApprovableDetails: $e");
      return OperationResult(success: false, message: AppErrorReporter.safeMessage(e));
    }
  }

  /// Employee Ask Remember
  /// POST: /api/approval-system/v1/:type/employee/approvables/:id/remember
  static Future<OperationResult<bool>> askRemember({
    required BuildContext context,
    required String type,
    required String id,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: "/approval-system/v1/$type/employee/approvables/$id/remember",
        context: context,
        data: {},
      );

      if (response.data != null && response.data['status'] == true) {
        return OperationResult(
          success: true,
          data: true,
          message: response.data['message']?.toString() ?? 'Remember notification sent',
        );
      }
      return OperationResult(
        success: false,
        message: response.data?['message']?.toString() ?? 'Failed to send remember',
      );
    } catch (e) {
      return OperationResult(success: false, message: AppErrorReporter.safeMessage(e));
    }
  }

  /// Employee Ask Ignore
  /// POST: /api/approval-system/v1/:type/employee/approvables/:id/ask-ignore
  static Future<OperationResult<bool>> askIgnore({
    required BuildContext context,
    required String type,
    required String id,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: "/approval-system/v1/$type/employee/approvables/$id/ask-ignore",
        context: context,
        data: {},
      );

      if (response.data != null && response.data['status'] == true) {
        return OperationResult(
          success: true,
          data: true,
          message: response.data['message']?.toString() ?? 'Ask ignore sent',
        );
      }
      return OperationResult(
        success: false,
        message: response.data?['message']?.toString() ?? 'Failed to send ask ignore',
      );
    } catch (e) {
      return OperationResult(success: false, message: AppErrorReporter.safeMessage(e));
    }
  }

  /// Manager Approve Cancel
  /// POST: /api/approval-system/v1/:type/manager/approvables/:id/approve-cancel
  static Future<OperationResult<bool>> approveCancel({
    required BuildContext context,
    required String type,
    required String id,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: "/approval-system/v1/$type/manager/approvables/$id/approve-cancel",
        context: context,
        data: {},
      );

      if (response.data != null && response.data['status'] == true) {
        return OperationResult(
          success: true,
          data: true,
          message: response.data['message']?.toString() ?? 'Cancel approved successfully',
        );
      }
      return OperationResult(
        success: false,
        message: response.data?['message']?.toString() ?? 'Failed to approve cancel',
      );
    } catch (e) {
      debugPrint("Error in approveCancel: $e");
      return OperationResult(success: false, message: e.toString());
    }
  }

  /// Get active level approvers (when can_take_action_as_someone_else == true)
  /// GET: /api/approval-system/v1/:type/manager/approvables/:id/current-level-approvers
  static Future<OperationResult<List<CurrentLevelApproverModel>>> getCurrentLevelApprovers({
    required BuildContext context,
    required String type,
    required String id,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: "/approval-system/v1/$type/manager/approvables/$id/current-level-approvers",
        context: context,
      );

      if (response.data != null && response.data['status'] == true) {
        final List<dynamic>? list = response.data['approvers'];
        final approvers = list
                ?.map((e) => CurrentLevelApproverModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        return OperationResult(
          success: true,
          data: approvers,
          message: response.data['message']?.toString(),
        );
      }
      return OperationResult(
        success: false,
        message: response.data?['message']?.toString() ?? 'Failed to fetch approvers',
      );
    } catch (e) {
      debugPrint("Error in getCurrentLevelApprovers: $e");
      return OperationResult(success: false, message: AppErrorReporter.safeMessage(e));
    }
  }

  /// Direct Manager Take Action
  /// POST: /api/approval-system/v1/:type/manager/take-action
  static Future<OperationResult<bool>> takeAction({
    required BuildContext context,
    required String type,
    required String approvableId,
    required String action, // approve | refuse
    String? reply,
    PlatformFile? file,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'approvable_id': approvableId,
        'action': action,
      };
      if (reply != null && reply.trim().isNotEmpty) {
        formMap['reply'] = reply.trim();
      }
      if (file != null) {
        if (file.bytes != null) {
          formMap['file'] = MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          );
        } else if (file.path != null) {
          formMap['file'] = await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          );
        }
      }

      final formData = FormData.fromMap(formMap);

      final response = await DioHelper.postData(
        url: "/approval-system/v1/$type/manager/take-action",
        context: context,
        data: formData,
      );

      if (response.data != null && response.data['status'] == true) {
        return OperationResult(
          success: true,
          data: true,
          message: response.data['message']?.toString() ?? 'Action taken successfully',
        );
      }
      return OperationResult(
        success: false,
        message: response.data?['message']?.toString() ?? 'Failed to take action',
      );
    } catch (e) {
      debugPrint("Error in takeAction: $e");
      return OperationResult(success: false, message: AppErrorReporter.safeMessage(e));
    }
  }

  /// Manager Take Action as Someone Else
  /// POST: /api/approval-system/v1/:type/manager/take-action-as-someone-else
  static Future<OperationResult<bool>> takeActionAsSomeoneElse({
    required BuildContext context,
    required String type,
    required String approvableId,
    required String action, // approve | refuse
    required String employeeId,
    String? reply,
    PlatformFile? file,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'approvable_id': approvableId,
        'action': action,
        'employee_id': employeeId,
      };
      if (reply != null && reply.trim().isNotEmpty) {
        formMap['reply'] = reply.trim();
      }
      if (file != null) {
        if (file.bytes != null) {
          formMap['file'] = MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          );
        } else if (file.path != null) {
          formMap['file'] = await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          );
        }
      }

      final formData = FormData.fromMap(formMap);

      final response = await DioHelper.postData(
        url: "/approval-system/v1/$type/manager/take-action-as-someone-else",
        context: context,
        data: formData,
      );

      if (response.data != null && response.data['status'] == true) {
        return OperationResult(
          success: true,
          data: true,
          message: response.data['message']?.toString() ?? 'Action taken successfully',
        );
      }
      return OperationResult(
        success: false,
        message: response.data?['message']?.toString() ?? 'Failed to take action',
      );
    } catch (e) {
      debugPrint("Error in takeActionAsSomeoneElse: $e");
      return OperationResult(success: false, message: AppErrorReporter.safeMessage(e));
    }
  }

  /// Get overlapping vacations for a specific approvable request
  /// GET: /api/approval-system/v1/employee_requests/manager/approvables/:id/overlapping-vacations
  static Future<OperationResult<List<OverlappingVacationModel>>> getOverlappingVacations({
    required BuildContext context,
    required String id,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: '/approval-system/v1/employee_requests/manager/approvables/$id/overlapping-vacations',
        context: context,
      );

      if (response.data != null && response.data['status'] == true) {
        final List<dynamic> list = response.data['overlapping_vacations'] ?? [];
        final items = list
            .map((e) => OverlappingVacationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return OperationResult(success: true, data: items, message: response.data['message']?.toString());
      }
      return OperationResult(
        success: false,
        message: response.data?['message']?.toString() ?? 'Failed to load overlapping vacations',
      );
    } catch (e) {
      debugPrint('Error in getOverlappingVacations: $e');
      return OperationResult(success: false, message: AppErrorReporter.safeMessage(e));
    }
  }
}
