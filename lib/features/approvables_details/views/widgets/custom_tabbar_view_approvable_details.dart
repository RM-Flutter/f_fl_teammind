import 'package:app_test/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../data/models/approvable_details_model.dart';
import 'tabs/reason_tab.dart';
import 'tabs/manager_response_tab.dart';
import 'tabs/information_tab.dart';
import 'package:app_test/features/tracking/views/widgets/request_tracking_tab.dart';
import 'package:app_test/core/constants/app_design.dart';

class CustomTabbarViewApprovableDetails extends StatelessWidget {
  final ApprovableDetailsModel details;

  /// Approvable type (`employee_requests`, `overtime` ...). Tracking belongs to requests only.
  final String? type;

  /// The signed-in employee owns this request: the tracking tab shows the employee view
  /// (start / stop, key points); otherwise the manager / HR view.
  final bool isApplicant;

  const CustomTabbarViewApprovableDetails({
    super.key,
    required this.details,
    this.type,
    this.isApplicant = false,
  });

  /// Tracking belongs to employee requests whose type has tracking (`tracking.requirement` is
  /// `optional` or `required`; the details API sends the block).
  bool get _showTracking =>
      (type == null || type == 'employee_requests') &&
      details.id != null &&
      details.tracking != null &&
      !details.tracking!.isInactive;

  @override
  Widget build(BuildContext context) {
    final mainTextStyle = AppStyles.heading(context).copyWith(
      fontSize: 10.5,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.page,
          right: AppSpacing.page,
          top: AppSpacing.md,
          bottom: 0),
      child: DefaultTabController(
        length: _showTracking ? 4 : 3,
        child: Column(
          children: [
            Container(
              width: double
                  .infinity, // full-width bar, even when the tabs are fewer
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryButton),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              height: 52,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.s8, vertical: AppSizes.s6),
              child: LayoutBuilder(builder: (context, constraints) {
                // Tabs always split the bar equally; long labels shrink to fit.
                return TabBar(
                  dividerColor: Colors.transparent,
                  indicatorPadding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                  isScrollable: false,
                  tabAlignment: TabAlignment.fill,
                  labelPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: Color(AppColors.buttons),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
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
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.reason.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.managerResponse.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.information.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    if (_showTracking)
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'tracking'.tr(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 0),
                child: TabBarView(
                  children: [
                    ReasonTab(
                      reason: details.reason,
                      details: details,
                    ),
                    ManagerResponseTab(
                        requiredApprovals: details.requiredApprovals),
                    InformationTab(
                      createdAt: details.createdAt,
                      seenAt: details.seenAt,
                      seenBy: details.seenBy,
                      updatedAt: details.updatedAt,
                      employeeActions: details.employeeActions,
                    ),
                    if (_showTracking)
                      RequestTrackingTab(
                          requestId: details.id!, isOwner: isApplicant),
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
