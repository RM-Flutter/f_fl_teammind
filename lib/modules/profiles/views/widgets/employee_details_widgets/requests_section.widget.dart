import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/routing/app_router.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../models/employee_profile.model.dart';
import '../profile_balance.widget.dart';

class RequestsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  const RequestsSectionWidget({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
          ProfileBalanceWidget(
            balance: employee?.balance,
            empDepartmentId: employee?.departmentId?.toString(),
            employeeId: employee?.id?.toString(),
          ),
          gapH24,
          Center(
              child: CustomElevatedButton(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  titleSize: AppSizes.s12,
                  title: AppStrings.viewTheLatestReviews.tr().toUpperCase(),
                  onPressed: () async{
                    var mine;
                    if(employee!.id.toString() == gCache['employee_profile_id'].toString()){
                      print(employee!.id.toString());
                      print(gCache['employee_profile_id'].toString());
                      mine = "me";
                    }else if(employee!.id.toString() != gCache['employee_profile_id'].toString() && (gCache['is_teamleader_in'].isNotEmpty && gCache['is_teamleader_in'].contains(employee!.departmentId) == true) ||
                        (gCache['is_manager_in'].isNotEmpty && gCache['is_manager_in'].contains(employee!.departmentId) == true)){
                      mine = "team";
                    }else{
                      mine = "company";
                    }
                    await context.pushNamed(AppRoutes.requestsById.name,
                        pathParameters: {
                          'id': "no",
                          'type': mine,
                          'lang': context.locale.languageCode
                        },
                        extra: {
                          'userId': employee!.id.toString()
                        });
                  }
                  // await context
                  //     .pushNamed(AppRoutes.payrollsList.name, extra: {
                  //   'employeeName': employee?.name,
                  //   'employeeId': employee?.id?.toString()
                  // }, pathParameters: {
                  //   'lang': context.locale.languageCode
                  // })
              )),
        ],
      ),
    );
  }
}
