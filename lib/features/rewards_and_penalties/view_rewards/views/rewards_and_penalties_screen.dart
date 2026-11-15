import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/request_scope_helper.dart';
import 'package:app_test/core/widgets/active_filters_row_widget.dart';
import 'package:app_test/core/widgets/app_empty_scroll_view.widget.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';
import 'package:app_test/core/widgets/custom_floating_action_button.widget.dart';
import 'package:app_test/core/widgets/shared_list_filter_widget.dart'
    as app_test_filter;
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/features/more/notifications/views/widgets/switch_row_notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/rewards_and_penalties_controller.dart';
import '../data/models/reward_penalty_approvable_model.dart';
import '../data/repos/rewards_and_penalties.service.dart';

/// Rewards and penalties list (approval system, type `rewards_and_penalties`).
/// Tapping a card opens the shared `approvableDetails` screen; adding a reward
/// or penalty still opens the old `addRewardsAndPenalties` screen.
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
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _us1;

  @override
  void initState() {
    super.initState();
    viewModel = RewardsAndPenaltiesViewModel();
    _us1 = _readUs1();

    // Opened from someone else's profile: show their items in the incoming view.
    final myProfileId = _us1?['employee_profile_id']?.toString();
    if (widget.empId != null &&
        widget.empId!.isNotEmpty &&
        widget.empId != myProfileId &&
        RequestScopeHelper.canSeeTeam) {
      viewModel.openForEmployee(empId: widget.empId!, empName: widget.empName);
    }
    viewModel.initializeScreen(context);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        viewModel.loadMore(context);
      }
    });
  }

  Map<String, dynamic>? _readUs1() {
    try {
      final s = CacheHelper.getString('US1');
      if (s == null || s.isEmpty) return null;
      return json.decode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  bool get _canAdd =>
      _us1?['can_add_reward'] == true || _us1?['can_add_penalty'] == true;

  @override
  void dispose() {
    _scrollController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RewardsAndPenaltiesViewModel>.value(
      value: viewModel,
      child: Consumer<RewardsAndPenaltiesViewModel>(
        builder: (context, controller, _) {
          final list = controller.currentList;
          final hideFilter = !controller.isLoading &&
              (list == null || list.isEmpty) &&
              !controller.currentFiltersMap.values
                  .any((v) => v != null && v.isNotEmpty);

          return TemplatePage(
            pageContext: context,
            title: AppStrings.rewardsAndPenalties.tr(),
            floatingActionButton: _canAdd
                ? CustomFloatingActionButton(
                    iconPath: AppImages.addFloatingActionButtonIcon,
                    onPressed: () async {
                      await context.pushNamed(
                          AppRoutes.addRewardsAndPenalties.name,
                          pathParameters: {
                            'lang': context.locale.languageCode
                          });
                      if (context.mounted) controller.initializeScreen(context);
                    },
                    tagSuffix: 'add',
                    height: AppSizes.s16,
                    width: AppSizes.s16,
                  )
                : null,
            actions: hideFilter
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.filter_list_rounded),
                      onPressed: () async {
                        final result =
                            await showModalBottomSheet<Map<String, String?>>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => app_test_filter.SharedListFilterWidget(
                            showEmployee: controller.isIncomingView,
                            showDepartment: controller.isIncomingView,
                            showDateRange: true,
                            showStatus: true,
                            statusOptions: const [
                              "waiting",
                              "waiting_seen",
                              "approved",
                              "refused",
                              "canceled"
                            ],
                            initialFilters: controller.currentFiltersMap,
                            underMyManagement: true,
                          ),
                        );
                        if (result != null && context.mounted) {
                          controller.applyFilters(result, context);
                        }
                      },
                    ),
                  ],
            body: Column(
              children: [
                if (RequestScopeHelper.canSeeTeam)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                    child: SwitchRowNotification(
                      value: controller.isIncomingView,
                      leftText: AppStrings.myRewardsAndPenalties.tr(),
                      rightText: AppStrings.teamRewardsAndPenalties.tr(),
                      onChanged: (value) =>
                          controller.toggleIncomingView(value, context),
                    ),
                  ),
                if (controller.isIncomingView)
                  _ScopeSelectorRow(
                    currentScope: controller.incomingScope,
                    onSelected: (scope) =>
                        controller.setIncomingScope(scope, context),
                  ),
                ActiveFiltersRowWidget(
                  empName: controller.filterEmpName,
                  depName: controller.filterDepName,
                  fromDate: controller.filterFrom,
                  toDate: controller.filterTo,
                  status: controller.filterStatus,
                  onClearEmp: () => controller.clearFilterEmp(context),
                  onClearDep: () => controller.clearFilterDep(context),
                  onClearDate: () => controller.clearFilterDate(context),
                  onClearStatus: () => controller.clearFilterStatus(context),
                ),
                Expanded(child: _buildList(controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(RewardsAndPenaltiesViewModel controller) {
    if (controller.isLoading) {
      return const PayrollsAndPenaltiesRewardsLoadingScreensWidget();
    }
    final items = controller.currentList;
    if (items == null || items.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () => controller.initializeScreen(context),
        child: AppEmptyScrollView(
            title: AppStrings.noExistingPenaltiesAndRewards.tr()),
      );
    }
    final isLoadingMore = controller.isIncomingView
        ? controller.incomingIsLoadingMore
        : controller.personalIsLoadingMore;

    return Center(
      child: ConstrainedBox(
        constraints: LayoutService.contentConstraints(context),
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.initializeScreen(context),
          child: ListView.builder(
            controller: _scrollController,
            clipBehavior: Clip.none,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.listPadding,
            itemCount: items.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSizes.s16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final RewardPenaltyApprovableModel item = items[index];
              return ApprovableCardWidget(
                request: item,
                isForDepartment: controller.isIncomingView,
                onActionTaken: () => controller.initializeScreen(context),
                onTap: () async {
                  await context.pushNamed(
                    AppRoutes.approvableDetails.name,
                    pathParameters: {
                      'lang': context.locale.languageCode,
                      'type': RewardsAndPenaltiesRepo.approvableType,
                      'id': item.id.toString(),
                    },
                  );
                  if (context.mounted) controller.initializeScreen(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScopeSelectorRow extends StatelessWidget {
  final String currentScope;
  final ValueChanged<String> onSelected;

  const _ScopeSelectorRow({
    required this.currentScope,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scopes = [
      {'value': 'team', 'label': 'teamRequests'.tr()},
      {'value': 'other_departments', 'label': 'other_departments'.tr()},
      {'value': 'all_company', 'label': 'all_company'.tr()},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.md, AppSpacing.page, 0),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: scopes.map((s) {
              final bool isSelected = currentScope == s['value'];
              return GestureDetector(
                onTap: () => onSelected(s['value']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.s16, vertical: AppSizes.s8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(AppColors.buttons)
                        : Color(AppColors.cardBackground),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isSelected
                          ? Color(AppColors.buttons)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    s['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
