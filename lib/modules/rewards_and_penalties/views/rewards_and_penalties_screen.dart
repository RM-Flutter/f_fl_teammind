import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import '../../../common_modules_widgets/custom_floating_action_button.widget.dart';
import '../../../common_modules_widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../general_services/layout.service.dart';
import '../../../routing/app_router.dart';
import '../../../utils/general_screen_message_widget.dart';
import '../../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../view_models/rewards_and_penalties.viewmodel.dart';
import 'widgets/reward_and_penalty_card.widget.dart';

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
          pageContext: context,
          title: AppStrings.rewardsAndPenalties.tr().toUpperCase(),
          onRefresh: () async =>
              await viewModel.initializeRewardsAndPenaltiesListScreen(
                  context: context, empId: widget.empId),
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.s12),
            child: SingleChildScrollView(
              child: Consumer<RewardsAndPenaltiesViewModel>(
                  builder: (context, viewModel, child) => viewModel.isLoading
                      ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                      : (viewModel.rewardsAndPenalties?.isEmpty == true ||
                              viewModel.rewardsAndPenalties == null)&&(viewModel.rewardsAndPenaltiesTeam?.isEmpty == true ||
                              viewModel.rewardsAndPenaltiesTeam == null)
                          ? NoExistingPlaceholderScreen(
                              height: LayoutService.getHeight(context) * 0.6,
                              title: AppStrings.noExistingPenaltiesAndRewards.tr())
                          : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(viewModel.rewardsAndPenalties != null && viewModel.rewardsAndPenalties?.isEmpty == false)
                          Text(AppStrings.myRewardsAndPenalties.tr(),style: const TextStyle(
                                color: Color(AppColors.dark),fontWeight: FontWeight.w600,fontSize: 16
                              ),),
                        const SizedBox(height: 15,),
                        // if(viewModel.rewardsAndPenalties != null && viewModel.rewardsAndPenalties?.isEmpty == false)     const SizedBox(height: 15,),
                        //       GeneralScreenMessageWidget(
                        //           screenId: '/penalties-and-rewards'),
                              ...viewModel.rewardsAndPenalties!.map(
                                  (rewardAndPenalty) =>
                                      RewardAndPenaltyCardWidget(
                                        rewardAndPenalty: rewardAndPenalty,
                                      )),
                        if(viewModel.rewardsAndPenalties != null && viewModel.rewardsAndPenalties?.isEmpty == false)     const SizedBox(height: 25,),
                        if(viewModel.rewardsAndPenaltiesTeam != null && viewModel.rewardsAndPenaltiesTeam?.isEmpty == false && (gCache['is_teamleader_in'].isNotEmpty ||gCache['is_manager_in'].isNotEmpty))
                          Text(AppStrings.teamRewardsAndPenalties.tr(),style: const TextStyle(
                            color: Color(AppColors.dark),fontWeight: FontWeight.w600,fontSize: 16
                        ),),
                        if(viewModel.rewardsAndPenaltiesTeam != null && viewModel.rewardsAndPenaltiesTeam?.isEmpty == false && (gCache['is_teamleader_in'].isNotEmpty ||gCache['is_manager_in'].isNotEmpty))   const SizedBox(height: 15,),
                        // if(viewModel.rewardsAndPenaltiesTeam != null && viewModel.rewardsAndPenaltiesTeam?.isEmpty == false && gCache['is_teamleader_in'].isNotEmpty)  const SizedBox(height: 15,),
                        // if(viewModel.rewardsAndPenaltiesTeam != null && viewModel.rewardsAndPenaltiesTeam?.isEmpty == false && gCache['is_teamleader_in'].isNotEmpty)  GeneralScreenMessageWidget(
                        //     screenId: '/penalties-and-rewards'),
                        if(viewModel.rewardsAndPenaltiesTeam != null && viewModel.rewardsAndPenaltiesTeam?.isEmpty == false && (gCache['is_teamleader_in'].isNotEmpty ||gCache['is_manager_in'].isNotEmpty))   ...viewModel.rewardsAndPenaltiesTeam!.map(
                                (rewardAndPenalty) => RewardAndPenaltyCardWidget(
                                  rewardAndPenalty: rewardAndPenalty,
                                )),
                            ])),
            ),
          )),
    );
  }
}
