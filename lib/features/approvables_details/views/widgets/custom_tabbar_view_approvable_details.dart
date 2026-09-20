import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../data/models/approvable_details_model.dart';
import 'tabs/reason_tab.dart';
import 'tabs/manager_response_tab.dart';
import 'tabs/information_tab.dart';

class CustomTabbarViewApprovableDetails extends StatelessWidget {
  final ApprovableDetailsModel details;

  const CustomTabbarViewApprovableDetails({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final mainTextStyle = AppStyles.heading(context).copyWith(
      fontSize: 10.5,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryButton),
                borderRadius: BorderRadius.circular(30),
              ),
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
                labelPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  color: Color(AppColors.buttons),
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: Colors.white,
                labelStyle: mainTextStyle,
                unselectedLabelStyle: mainTextStyle,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.reason.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.managerResponse.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.information.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TabBarView(
                  children: [
                    ReasonTab(reason: details.reason),
                    ManagerResponseTab(requiredApprovals: details.requiredApprovals),
                    InformationTab(
                      createdAt: details.createdAt,
                      seenAt: details.seenAt,
                      seenBy: details.seenBy,
                      updatedAt: details.updatedAt,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
