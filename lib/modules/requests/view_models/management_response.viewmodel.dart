import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_strings.dart';
import '../../../general_services/alert_service/alerts.service.dart';
import '../../../routing/app_router.dart';
import '../../../services/requests.services.dart';

class ManagementResponseViewModal extends ChangeNotifier {
  final TextEditingController reasonController = TextEditingController();

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  List availableActions = [
     AppStrings.approved.tr(),
     AppStrings.refused.tr(),
  ];
  String? selectedRequestStatus;

  Future<void> sendManagerAction(
      {required BuildContext context, required String requestId}) async {
    try {
      if (selectedRequestStatus == null) {
        Fluttertoast.showToast(
            msg: AppStrings.pleaseSelectAction.tr(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }
      // if (reasonController.text.isEmpty) {
      //   AlertsService.warning(
      //     context: context,
      //     message: AppStrings.pleaseEnterReason.tr(),
      //     title: AppStrings.warning.tr(),
      //   );
      //   return;
      // }
      final response = await RequestsServices.managerAction(
          requestId: requestId,
          action: selectedRequestStatus.toString(),
          replay: reasonController.text,
          context: context);
      if (response.success) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: response.message!,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        context.goNamed(AppRoutes.requests2.name, pathParameters: {
          'type': 'myTeam',
          'lang': context.locale.languageCode
        });
      } else {
        Fluttertoast.showToast(
            msg: response.message!,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }
    } catch (ex, t) {
      debugPrint('Error While Sending Manager Action $ex -> $t');
      AlertsService.error(
          context: context,
          message: 'Error While Sending Manager Action, Please Try Later',
          title: AppStrings.failed.tr());
      return;
    }
  }
}
