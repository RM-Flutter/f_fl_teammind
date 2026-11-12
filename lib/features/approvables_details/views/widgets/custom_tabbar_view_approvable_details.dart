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
import 'package:app_test/features/tracking/views/widgets/tracking_section_employee.dart';
import 'package:app_test/features/tracking/views/widgets/tracking_section_manager.dart';
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

  /// Spec: tracking is linked to requests. Until the API sends the request type's
  /// `tracking_requirement`, the tab shows on every employee request (dummy data).
  bool get _showTracking => type == null || type == 'employee_requests';

  /// Start shows only when today is inside the request's dates.
  bool get _isDateMatched {
    final from = DateTime.tryParse(details.dateFrom ?? '');
    final to = DateTime.tryParse(details.dateTo ?? '') ?? from;
    if (from == null) return true;
    final today = DateUtils.dateOnly(DateTime.now());
    return !today.isBefore(DateUtils.dateOnly(from)) &&
        !today.isAfter(DateUtils.dateOnly(to!));
  }

  bool get _isCancelled {
    final s = (details.status ?? '').toLowerCase();
    return s == 'canceled' || s == 'cancelled';
  }

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
                // Spread the tabs over the whole bar (like Interview Details) when every label fits
                // in an equal share; otherwise (a phone with 4 tabs) scroll them from the start
                // instead of cutting "Manager Response".
                final titles = [
                  AppStrings.reason.tr(),
                  AppStrings.managerResponse.tr(),
                  AppStrings.information.tr(),
                  if (_showTracking) 'tracking'.tr(),
                ];
                final style =
                    DefaultTextStyle.of(context).style.merge(mainTextStyle);
                final scaler = MediaQuery.textScalerOf(context);
                final widest = titles
                    .map((t) => (TextPainter(
                          text: TextSpan(text: t, style: style),
                          textDirection: Directionality.of(context),
                          textScaler: scaler,
                          maxLines: 1,
                        )..layout())
                            .width)
                    .reduce((a, b) => a > b ? a : b);
                final fits = widest + AppSizes.s16 * 2 <=
                    constraints.maxWidth / titles.length;
                return TabBar(
                  dividerColor: Colors.transparent,
                  indicatorPadding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                  isScrollable: !fits,
                  tabAlignment: fits ? TabAlignment.fill : TabAlignment.start,
                  labelPadding: fits
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(horizontal: AppSizes.s16),
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
                        child: Text(
                          AppStrings.reason.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.managerResponse.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.information.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    if (_showTracking)
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'tracking'.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
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
                      SingleChildScrollView(
                        child: isApplicant
                            ? TrackingSectionEmployee(
                                request: details,
                                padding: EdgeInsets.zero,
                                isDateMatched: _isDateMatched,
                                isRequestCancelled: _isCancelled,
                              )
                            : TrackingSectionManager(
                                request: details, padding: EdgeInsets.zero),
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
