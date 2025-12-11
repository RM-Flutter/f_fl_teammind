import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import '../../../../../common_modules_widgets/request_card.widget.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../models/request.model.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../services/requests.services.dart';

/// Used to get requests for current user ( my requests - my team requests - other Departments requests
class RequestsWidget extends StatelessWidget {
  final List requests;
  final GetRequestsTypes requestType;
  const RequestsWidget(
      {super.key, required this.requests, required this.requestType});

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

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 1100 : double.infinity
        ),
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.s24, vertical: AppSizes.s12),
          decoration: ShapeDecoration(
            color: Theme.of(context).cardTheme.color,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            shadows: [
              BoxShadow(
                color: Color(0xffC9CFD2).withOpacity(0.5),
                blurRadius: AppSizes.s5,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getRequestsTypeStr(),
                      style: TextStyle(
                        fontSize: AppSizes.s19,
                        fontWeight: FontWeight.w700,
                        color: const Color(AppColors.blue),
                        // تحسين الخطوط في الويب
                        letterSpacing: kIsWeb ? 0.3 : null,
                      ),),
                  TextButton(
                    onPressed: () async =>
                        await pushToRequestsScreenWithRequestsType(
                            context: context, reqType: requestType),
                    child: AutoSizeText(AppStrings.viewAll.tr(),
                        style: Theme.of(context).textTheme.bodySmall),
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
        ),
      ),
    );
  }
}
