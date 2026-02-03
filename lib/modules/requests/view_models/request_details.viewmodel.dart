import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/request.model.dart';
import '../../../constants/app_sizes.dart';
import '../../../general_services/alert_service/alerts.service.dart';
import '../../../general_services/settings.service.dart';
import '../../../models/operation_result.model.dart';
import '../../../models/settings/user_settings.model.dart';
import '../../../models/settings/user_settings_2.model.dart';
import '../../../routing/app_router.dart';
import '../../../services/requests.services.dart';
import '../../../utils/modal_sheet_helper.dart';
import '../views/widgets/modals/statistics.modal.dart';

class RequestDetailsViewModel extends ChangeNotifier {
  bool? isLoading = false;
  String? errorMessage;
  final ScrollController scrollController = ScrollController();
  UserSettingsModel? userSettings;
  List<RequestModel>? requests;
  RequestModel? requestModel;
  void initializeRequestDetails({required BuildContext context}) {
    var jsonString;
    UserSettingsModel? userSettingsModel;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    userSettingsModel = UserSettingsModel.fromJson(gCache);
    userSettings = userSettingsModel;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> showAndGetEmployeeStatistics(
      BuildContext context, String empId, {type}) async {
    // First get the employee balance
    List<MapEntry<String, Balance>>? empVocationBalance =
        await getEmployeeVocationBalance(context: context, empId: empId,);
    if (empVocationBalance == null || empVocationBalance.isEmpty) {
      AlertsService.info(
          context: context,
          message: AppStrings.employeeHasNoVocationBalance.tr(),
          title: AppStrings.information.tr());
      return;
    }
    // finally if the employee balance getten successfully , then show statistics modal and pass balance to it
    await ModalSheetHelper.showModalSheet(
      id: empId,
        context: context,
        modalContent: StatisticsModal(
            employeeId: empId, empVocationBalance: empVocationBalance, type: type, requests: requests,),
        title: AppStrings.statistics.tr(),
        viewProfile: true,
        height: 500);
  }

  Future<List<MapEntry<String, Balance>>?> getEmployeeVocationBalance(
      {required BuildContext context, required String empId}) async {
    try {
      final result = await RequestsServices.getEmployeeBalance(
          context: context, empId: empId);
      if (result.success) {
        final balanceData = result.data?['balance'];
        var requestsData = result.data?['requests'] as List<dynamic>?;
        requests = requestsData
            ?.map((item) => RequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (balanceData is Map<String, dynamic>) {
          return balanceData.entries.map((entry) {
            return MapEntry(entry.key, Balance.fromJson(entry.value));
          }).toList();
        } else {
          AlertsService.error(
              context: context,
              message: 'Unexpected data format for balance',
              title: AppStrings.failed.tr());
          return null;
        }
      } else {
        AlertsService.error(
            context: context,
            message: result.message ?? 'Failed to get vocation balance',
            title: AppStrings.failed.tr());
        return null;
      }
    } catch (ex, t) {
      debugPrint(
          'Error while getting Vocation Balance of employee $empId , error :- ${ex.toString()} in $t');
      AlertsService.error(
          context: context,
          message: 'Error while getting Vocation Balance of employee',
          title: AppStrings.failed.tr());
      return null;
    }
  }

  Future<void> askToIgnore(
      {required BuildContext context, String? requestId}) async {
    if (requestId == null) return;
    try {
      OperationResult<Map<String, dynamic>> result =
          await RequestsServices.askIgnore(
              requestId: requestId, context: context);
      if (result.success) {
        await AlertsService.success(
            title: AppStrings.success.tr(),
            context: context,
            message: result.message ?? 'Asking to Ignore Sending Successfully');
        context.goNamed(AppRoutes.requests2.name, pathParameters: {
          'type': 'mine',
          'lang': context.locale.languageCode
        });
        return;
      } else {
        AlertsService.error(
            title: AppStrings.failed.tr(),
            context: context,
            message:
                result.message ?? 'Failed Sending Ignore Request , try later!');
        return;
      }
    } catch (ex) {
      AlertsService.error(
          context: context, message: ex.toString(), title: 'Failed !');
      return;
    }
  }

  Future<void> askToRemember(
      {required BuildContext context, String? requestId}) async {
    if (requestId == null) return;
    try {
      OperationResult<Map<String, dynamic>> result =
          await RequestsServices.askRemember(
              requestId: requestId, context: context);
      if (result.success) {
        await AlertsService.success(
            title: AppStrings.success.tr(),
            context: context,
            message: result.message ?? AppStrings.askingToRememberSendingSuccessfully.tr());
        // context.goNamed(AppRoutes.requests.name, pathParameters: {
        //   'type': 'mine',
        //   'lang': context.locale.languageCode
        // });
        return;
      } else {
        AlertsService.error(
            title: AppStrings.failed.tr(),
            context: context,
            message:
                result.message ?? 'Failed Sending Ask to Remeber , try later!');
        return;
      }
    } catch (ex) {
      AlertsService.error(
          context: context, message: ex.toString(), title: 'Failed !');
      return;
    }
  }

  Future<void> askToComplain(
      {required BuildContext context, required String? requestId, }) async {
    await AlertsService.info(
        context: context,
        message: 'This Feature Under Development',
        title: AppStrings.information.tr());
  }
  Future<void> getOneRequest(BuildContext context, id) async {
    isLoading = true;
    notifyListeners();
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    
    try {
      // Remove trailing slash for better web compatibility
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/my_request",
        context: context,
        query: {
          'id': id.toString(),
          // if((gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty) && (gCache['id'].toString() != userId))'seen' : 1
        },
      );
      
      print("Response data: ${response.data}");
      isLoading = false;
      if (response.data != null && response.data['request'] != null) {
        requestModel = RequestModel.fromJson(response.data['request']);
      }
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      print("ERROR IS ---> ${e.toString()}");
      if (context.mounted) {
        AlertsService.error(
          context: context,
          message: errorMessage ?? 'Failed to load request details',
          title: AppStrings.failed.tr(),
        );
      }
      notifyListeners();
    }
  }
  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }
  Future<void> downloadFile(String fileUrl, String fileName) async {
    final dio = Dio();

    try {
      // Get app directory
      Directory dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/$fileName";

      // Start downloading
      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print("${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      print("Download completed: $filePath");
    } catch (e) {
      print("Download failed: $e");
    }
  }
  Future<void> fetchAndDownloadFile({link}) async {
    final dio = Dio();

    try {
      final response = await dio.get(link);
      String fileUrl = response.data["file_url"];
      String fileName = "example.pdf"; // You can parse it from the URL or API too

      await requestPermissions(); // For Android
      await downloadFile(fileUrl, fileName);
    } catch (e) {
      print("Error fetching or downloading: $e");
    }
  }
}
