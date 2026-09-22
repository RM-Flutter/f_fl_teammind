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
import 'package:app_test/features/more/notifications/views/widgets/switch_row_notification.dart';


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

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    viewModel = RewardsAndPenaltiesViewModel();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    String? targetEmpId = widget.empId;
    if (targetEmpId == null) {
      final jsonString = CacheHelper.getString("US1");
      if (jsonString != null && jsonString.isNotEmpty) {
        final cache = json.decode(jsonString) as Map<String, dynamic>;
        targetEmpId = cache['employee_profile_id']?.toString();
      }
    }
    
    viewModel.initializeRewardsAndPenaltiesListScreen(
        context: context, empId: targetEmpId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (viewModel.isForTeam) {
        if (viewModel.hasMoreTeam && !viewModel.isLoadingMoreTeam) {
          viewModel.loadMoreTeam(context, widget.empId);
        }
      } else {
        if (viewModel.hasMorePersonal && !viewModel.isLoadingMorePersonal) {
          viewModel.loadMorePersonal(context, widget.empId);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          floatingActionButton: (gCache?['can_add_reward'] == true || gCache?['can_add_penalty'] == true)?CustomFloatingActionButton(
            iconPath: AppImages.addFloatingActionButtonIcon,
            onPressed: () async {
              await context.pushNamed(
                  AppRoutes.addRewardsAndPenalties.name,
                  pathParameters: {'lang': context.locale.languageCode});
              
              String? targetEmpId = widget.empId;
              if (targetEmpId == null && gCache != null) {
                targetEmpId = gCache['employee_profile_id']?.toString();
              }
              await viewModel.initializeRewardsAndPenaltiesListScreen(
                  context: context, empId: targetEmpId);
            },
            tagSuffix: 'add',
            height: AppSizes.s16,
            width: AppSizes.s16,
          ) : null,
          bottomAppbarWidget: widget.empId != null &&
                  widget.empId?.isNotEmpty == true &&
                  widget.empName != null &&
                  widget.empName?.isNotEmpty == true &&
                  UserSettingConst.userSettings?.userId.toString() != widget.empId
              ? null
              : null,
          pageContext: context,
          title: AppStrings.rewardsAndPenalties.tr(),

          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 1100 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.s12),
                child: RefreshIndicator.adaptive(
                  onRefresh: () async {
                    String? targetEmpId = widget.empId;
                    if (targetEmpId == null) {
                      final jsonString = CacheHelper.getString("US1");
                      if (jsonString != null && jsonString.isNotEmpty) {
                        final cache = json.decode(jsonString) as Map<String, dynamic>;
                        targetEmpId = cache['employee_profile_id']?.toString();
                      }
                    }
                    await viewModel.initializeRewardsAndPenaltiesListScreen(
                        context: context, empId: targetEmpId);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    child: Consumer<RewardsAndPenaltiesViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.isLoading) {
                            return const PayrollsAndPenaltiesRewardsLoadingScreensWidget();
                          }
                          
                          final bool isManager = gCache != null && 
                              (gCache['is_teamleader_in']?.isNotEmpty == true || 
                               gCache['is_manager_in']?.isNotEmpty == true);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isManager) ...[
                                const SizedBox(height: 10),
                                SwitchRowNotification(
                                  value: viewModel.isForTeam,
                                  leftText: AppStrings.myRewardsAndPenalties.tr(),
                                  rightText: AppStrings.teamRewardsAndPenalties.tr(),
                                  onChanged: (val) {
                                    viewModel.toggleTeamView(val, context);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                              
                              if (!viewModel.isForTeam) ...[
                                if (viewModel.rewardsAndPenalties == null || viewModel.rewardsAndPenalties!.isEmpty)
                                  NoExistingPlaceholderScreen(
                                    height: 0.6.sh,
                                    title: AppStrings.noExistingPenaltiesAndRewards.tr(),
                                  )
                                else
                                  ...viewModel.rewardsAndPenalties!.map(
                                    (rewardAndPenalty) =>
                                        RewardAndPenaltyCardWidget(
                                          rewardAndPenalty: rewardAndPenalty,
                                        )
                                  ),
                                if (viewModel.isLoadingMorePersonal)
                                  const Center(child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  )),
                              ] else ...[
                                if (viewModel.rewardsAndPenaltiesTeam == null || viewModel.rewardsAndPenaltiesTeam!.isEmpty)
                                  NoExistingPlaceholderScreen(
                                    height: 0.6.sh,
                                    title: AppStrings.noExistingPenaltiesAndRewards.tr(),
                                  )
                                else
                                  ...viewModel.rewardsAndPenaltiesTeam!.map(
                                    (rewardAndPenalty) =>
                                        RewardAndPenaltyCardWidget(
                                          rewardAndPenalty: rewardAndPenalty,
                                          isTeam: true,
                                        )
                                  ),
                                if (viewModel.isLoadingMoreTeam)
                                  const Center(child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  )),
                              ],
                              const SizedBox(height: 50),
                            ],
                          );
                        }),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
