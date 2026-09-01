import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../data/models/approvable_details_model.dart';
import 'required_approvals_table_widget.dart';

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
                    // Tab 1: REASON
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Text(
                          details.reason != null && details.reason!.trim().isNotEmpty
                              ? details.reason!.trim()
                              : AppStrings.thereIsNoRequests.tr(),
                          textAlign: TextAlign.center,
                          style: AppStyles.darkContent(context).copyWith(fontSize: 14),
                        ),
                      ),
                    ),

                    // Tab 2: MANAGER RESPONSE (Required Approvals Cycle)
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        child: (details.requiredApprovals != null &&
                                details.requiredApprovals!.isNotEmpty)
                            ? RequiredApprovalsTableWidget(
                                requiredApprovals: details.requiredApprovals!,
                              )
                            : Center(
                                child: Text(
                                  AppStrings.thereIsStillNoResponseFromTheManager.tr(),
                                  style: AppStyles.darkContent(context).copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Tab 3: INFORMATION
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 25),
                          if (details.createdAt != null && details.createdAt!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${AppStrings.createdOn.tr()} : ",
                                    style: AppStyles.darkContent(context).copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatInfoDate(details.createdAt, context),
                                    style: AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (details.seenAt != null && details.seenAt!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${AppStrings.seenOn.tr()} : ",
                                    style: AppStyles.darkContent(context).copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatInfoDate(details.seenAt, context),
                                    style: AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (details.updatedAt != null && details.updatedAt!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${AppStrings.statusUpdate.tr()} : ",
                                    style: AppStyles.darkContent(context).copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatInfoDate(details.updatedAt, context),
                                    style: AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
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

  String _formatInfoDate(String? rawDate, BuildContext context) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final lang = LocalizationService.isArabic(context: context) ? "ar" : "en";
      return DateFormat('d-M-y | hh:mm a', lang).format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }
}
