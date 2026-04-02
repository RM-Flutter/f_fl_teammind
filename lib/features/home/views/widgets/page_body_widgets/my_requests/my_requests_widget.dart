import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/widgets/request_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Used to get requests for current user ( my requests - my team requests - other Departments requests
class RequestsWidget extends StatelessWidget {
  final List requests;
  final GetRequestsTypes requestType;
  const RequestsWidget({super.key, required this.requests, required this.requestType});

  @override
  Widget build(BuildContext context) {
    /// get request type String from GetRequestsTypes
    print("requests is --> ${requests.length}");
    print("requests is --> ${requests[0].reason}");
    String getRequestsTypeStr() {
      switch (requestType) {
        case GetRequestsTypes.mine:
          return AppStrings.mineRequests.tr();
        case GetRequestsTypes.myTeam:
          return AppStrings.teamRequests.tr();
        case GetRequestsTypes.otherDepartment:
          return AppStrings.otherDepartmentRequests.tr();
        case GetRequestsTypes.allCompany:
          return AppStrings.allCompanyRequests.tr();
      }
    }

    /// navigate to requests screens with passing the kind of the wanted requests
    Future<void> pushToRequestsScreenWithRequestsType(
        {required GetRequestsTypes reqType,
        required BuildContext context}) async {
      await context.pushNamed(AppRoutes.requests2.name,
          extra: requests,
          pathParameters: {
        'type': reqType.name,
        'lang': context.locale.languageCode
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getRequestsTypeStr(),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3489EF),
                      ),),
                  TextButton(
                    onPressed: () async =>
                        await pushToRequestsScreenWithRequestsType(
                            context: context, reqType: requestType),
                    child: const Text("VIEW ALL",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ],
              ),
              gapH16,
              ...requests.map(
                (req) => RequestCard(
                  request: req,
                  reqType: requestType,
                ),
              )
            ],
          ),
        );
  }
}
