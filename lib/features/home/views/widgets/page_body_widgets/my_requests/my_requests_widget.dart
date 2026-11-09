import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';
import 'package:app_test/core/widgets/fade_slide_in.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/widgets/request_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';

/// Used to get requests for current user ( my requests - my team requests - other Departments requests
class RequestsWidget extends StatelessWidget {
  final List requests;
  final GetRequestsTypes requestType;
  final VoidCallback? onActionTaken;
  const RequestsWidget({super.key, required this.requests, required this.requestType, this.onActionTaken});

  @override
  Widget build(BuildContext context) {
    /// get request type String from GetRequestsTypes
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

    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              AppSectionHeader(
                title: getRequestsTypeStr(),
                onViewAll: () async => await pushToRequestsScreenWithRequestsType(
                    context: context, reqType: requestType),
              ),
              const SizedBox(height: AppSpacing.sectionHeaderGap),
              ...requests.take(5).toList().asMap().entries.map(
                (entry) => ScrollRevealItem(
                  initialDelay: Duration(milliseconds: 120 * entry.key),
                  child: ApprovableCardWidget(
                  request: entry.value,
                  isForDepartment: requestType != GetRequestsTypes.mine,
                  onActionTaken: onActionTaken,
                  onTap: () async => await context.pushNamed(
                    AppRoutes.requestDetails.name,
                    extra: entry.value,
                    pathParameters: {
                      'type': requestType.name,
                      'id': entry.value!.id.toString(),
                      'lang': context.locale.languageCode,
                    },
                  ),
                ),
              )
                ),
            ],
          ),
        );
  }
}
