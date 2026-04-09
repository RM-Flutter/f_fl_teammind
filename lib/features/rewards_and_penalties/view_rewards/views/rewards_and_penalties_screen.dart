import 'dart:convert';

import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/custom_floating_action_button.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/views/widgets/reward_and_penalty_card.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/rewards_and_penalties_controller.dart';

class RewardsAndPenaltiesScreen extends StatefulWidget {
  final String? empId;
  final String? empName;
  const RewardsAndPenaltiesScreen({super.key, this.empId, this.empName});

  @override
  State<RewardsAndPenaltiesScreen> createState() =>
      _RewardsAndPenaltiesScreenState();
}

class _RewardsAndPenaltiesScreenState extends State<RewardsAndPenaltiesScreen> {
  late final RewardsAndPenaltiesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = RewardsAndPenaltiesViewModel();
    viewModel.initializeRewardsAndPenaltiesListScreen(
        context: context, empId: widget.empId);
  }

  @override
  Widget build(BuildContext context) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return ChangeNotifierProvider<RewardsAndPenaltiesViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          floatingActionButton: (gCache['can_add_reward'] == true || gCache['can_add_penalty'] == true)?CustomFloatingActionButton(
            iconPath: AppImages.addFloatingActionButtonIcon,
            onPressed: () async => await context.pushNamed(
                AppRoutes.addRewardsAndPenalties.name,
                pathParameters: {'lang': context.locale.languageCode}),
            tagSuffix: 'add',
            height: AppSizes.s16,
            width: AppSizes.s16,
          ) : null,
          bottomAppbarWidget: widget.empId != null &&
                  widget.empId?.isNotEmpty == true &&
                  widget.empName != null &&
                  widget.empName?.isNotEmpty == true &&
                  UserSettingConst.userSettings?.userId.toString() != widget.empId
              ? PreferredSize(
                  preferredSize: Size.fromHeight(AppSizes.s40.h),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.s12.w, vertical: AppSizes.s6.h),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        widget.empName!,
                        style: AppStyles.heading(context).copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizes.s20.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : null,
          pageContext: context,
          title: AppStrings.rewardsAndPenalties.tr(),
          onRefresh: () async =>
              await viewModel.initializeRewardsAndPenaltiesListScreen(
                  context: context, empId: widget.empId),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 1100.w : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.s12.r),
                child: SingleChildScrollView(
                  child: Consumer<RewardsAndPenaltiesViewModel>(
                      builder: (context, viewModel, child) => viewModel.isLoading
                          ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                          : (viewModel.rewardsAndPenalties?.isEmpty == true ||
                                  viewModel.rewardsAndPenalties == null) &&
                                  (viewModel.rewardsAndPenaltiesTeam?.isEmpty == true ||
                                      viewModel.rewardsAndPenaltiesTeam == null)
                              ? NoExistingPlaceholderScreen(
                                  height: 0.6.sh,
                                  title: AppStrings.noExistingPenaltiesAndRewards.tr())
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      if (viewModel.rewardsAndPenalties != null &&
                                          viewModel.rewardsAndPenalties?.isEmpty == false)
                                        Text(
                                          AppStrings.myRewardsAndPenalties.tr(),
                                          style: AppStyles.heading(context).copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp),
                                        ),
                                      SizedBox(height: 15.h),
                                      ...viewModel.rewardsAndPenalties!.map(
                                          (rewardAndPenalty) =>
                                              RewardAndPenaltyCardWidget(
                                                rewardAndPenalty: rewardAndPenalty,
                                              )),
                                      if (viewModel.rewardsAndPenalties != null &&
                                          viewModel.rewardsAndPenalties?.isEmpty == false)
                                        SizedBox(height: 25.h),
                                      if (viewModel.rewardsAndPenaltiesTeam != null &&
                                          viewModel.rewardsAndPenaltiesTeam?.isEmpty == false &&
                                          (gCache['is_teamleader_in'].isNotEmpty ||
                                              gCache['is_manager_in'].isNotEmpty))
                                        Text(
                                          AppStrings.teamRewardsAndPenalties.tr(),
                                          style: AppStyles.heading(context).copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp),
                                        ),
                                      if (viewModel.rewardsAndPenaltiesTeam != null &&
                                          viewModel.rewardsAndPenaltiesTeam?.isEmpty == false &&
                                          (gCache['is_teamleader_in'].isNotEmpty ||
                                              gCache['is_manager_in'].isNotEmpty))
                                        SizedBox(height: 15.h),
                                      if (viewModel.rewardsAndPenaltiesTeam != null &&
                                          viewModel.rewardsAndPenaltiesTeam?.isEmpty == false &&
                                          (gCache['is_teamleader_in'].isNotEmpty ||
                                              gCache['is_manager_in'].isNotEmpty))
                                        ...viewModel.rewardsAndPenaltiesTeam!.map(
                                            (rewardAndPenalty) =>
                                                RewardAndPenaltyCardWidget(
                                                  rewardAndPenalty: rewardAndPenalty,
                                                )),
                                    ])),
                ),
              ),
            ),
          )),
    );
  }
}
