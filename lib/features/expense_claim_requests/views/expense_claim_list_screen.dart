import 'package:app_test/core/widgets/app_empty_scroll_view.widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/features/more/notifications/views/widgets/switch_row_notification.dart';

import '../controllers/expense_claim_list_controller.dart';
import '../shared/models/expense_claim_model.dart';
import '../../../../core/widgets/shared_list_filter_widget.dart' as app_test_filter;
import '../../../../core/widgets/active_filters_row_widget.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/request_scope_helper.dart';

class ExpenseClaimListScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const ExpenseClaimListScreen({super.key, this.extra});

  @override
  State<ExpenseClaimListScreen> createState() => _ExpenseClaimListScreenState();
}

class _ExpenseClaimListScreenState extends State<ExpenseClaimListScreen> {
  late final ExpenseClaimListController viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = ExpenseClaimListController();
    _initData();
  }

  void _initData() async {
    if (widget.extra != null) {
      if (widget.extra!['isIncoming'] == true) {
        viewModel.isIncomingView = true;
        viewModel.incomingFilters['empId'] = widget.extra!['empId'];
        viewModel.incomingFilters['empName'] = widget.extra!['empName'];
      }
    }
    await viewModel.initializeScreen(context);
    if (mounted) setState(() {});

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (viewModel.isIncomingView) {
          viewModel.getIncomingRequests(context: context, loadMore: true);
        } else {
          viewModel.getPersonalRequests(context: context, loadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpenseClaimListController>.value(
      value: viewModel,
      child: Consumer<ExpenseClaimListController>(
        builder: (context, controller, child) {
          // No list -> nothing to filter: hide the filter (unless a filter is active, so it can be cleared).
          final currentList = controller.isIncomingView
              ? controller.incomingRequests
              : controller.personalRequests;
          final isLoadingList = controller.isIncomingView
              ? controller.isLoadingIncoming
              : controller.isLoadingPersonal;
          final hideFilter = !isLoadingList &&
              (currentList == null || currentList.isEmpty) &&
              !controller.currentFiltersMap.values
                  .any((v) => v != null && v.isNotEmpty);
          return TemplatePage(
            pageContext: context,
            title: 'expense_claim_requests'.tr(),
            // Create new expense claim button
            floatingActionButton: FloatingActionButton(
              heroTag: 'expense_claim_new',
              backgroundColor: Color(AppColors.buttons),
              onPressed: () async {
                final created = await context.pushNamed(
                  AppRoutes.expenseClaimCreate.name,
                  pathParameters: {'lang': context.locale.languageCode},
                );
                if (created == true) {
                  controller.initializeScreen(context);
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
            actions: hideFilter ? null : [
              // Filter button
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () async {
                  final result = await showModalBottomSheet<Map<String, String?>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => app_test_filter.SharedListFilterWidget(
                      showEmployee: controller.isIncomingView,
                      showDepartment: controller.isIncomingView,
                      showDateRange: true,
                      showStatus: true,
                      statusOptions: const ["waiting", "waiting_seen", "approved", "refused", "canceled"],
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
                // every employee can open "Other" (other departments / all company); "Team" is managers only
                ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.s16),
                    child: SwitchRowNotification(
                      value: controller.isIncomingView,
                      leftText: 'my_requests'.tr(),
                      rightText: 'other'.tr(),
                      onChanged: (value) =>
                          controller.toggleIncomingView(value, context),
                    ),
                  ),
                ],
                if (controller.isIncomingView) ...[
                  _ScopeSelectorRow(
                    currentScope: controller.incomingScope,
                    showAllCompany: true,
                    showTeam: RequestScopeHelper.canSeeTeam,
                    onSelected: (scope) =>
                        controller.setIncomingScope(scope, context),
                  ),
                ],
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
                Expanded(
                  child: controller.isIncomingView
                      ? _buildIncomingList(controller)
                      : _buildPersonalList(controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalList(ExpenseClaimListController controller) {
    if (controller.isLoadingPersonal) {
      return const PayrollsAndPenaltiesRewardsLoadingScreensWidget();
    }
    if (controller.personalRequests == null ||
        controller.personalRequests!.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () => controller.initializeScreen(context),
        child: AppEmptyScrollView(title: 'no_requests'.tr()),
      );
    }
    return _buildListView(controller, controller.personalRequests!,
        isIncoming: false);
  }

  Widget _buildIncomingList(ExpenseClaimListController controller) {
    if (controller.isLoadingIncoming) {
      return const PayrollsAndPenaltiesRewardsLoadingScreensWidget();
    }
    if (controller.incomingRequests == null ||
        controller.incomingRequests!.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () => controller.initializeScreen(context),
        child: AppEmptyScrollView(title: 'no_incoming_requests'.tr()),
      );
    }
    return _buildListView(controller, controller.incomingRequests!,
        isIncoming: true);
  }

  Widget _buildListView(
    ExpenseClaimListController controller,
    List<ExpenseClaimModel> requests, {
    required bool isIncoming,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: LayoutService.contentConstraints(context),
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.initializeScreen(context),
          child: ListView.builder(
            controller: _scrollController,
            clipBehavior: Clip.none,
            physics: const AlwaysScrollableScrollPhysics(),
            // Room so the floating add button doesn't cover the last card
            padding: AppSpacing.listPadding,
            itemCount: requests.length +
                (isIncoming
                    ? (controller.incomingIsLoadingMore ? 1 : 0)
                    : (controller.personalIsLoadingMore ? 1 : 0)),
            itemBuilder: (context, index) {
              if (index == requests.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final request = requests[index];

              return TweenAnimationBuilder<double>(
                duration:
                    Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: ApprovableCardWidget(
                  request: request,
                  isForDepartment: isIncoming,
                  onTap: () async {
                    final updated = await context.pushNamed(
                      AppRoutes.expenseClaimDetails.name,
                      pathParameters: {
                        'lang': context.locale.languageCode,
                        'id': request.id.toString(),
                      },
                      extra: request,
                    );
                    if (updated == true) {
                      controller.initializeScreen(context);
                    }
                  },
                ),
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
  final bool showAllCompany;
  final bool showTeam;
  final ValueChanged<String> onSelected;

  const _ScopeSelectorRow({
    required this.currentScope,
    required this.showAllCompany,
    this.showTeam = true,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scopes = [
      if (showTeam)
      {
        'value': 'team',
        'label':'teamRequests'.tr(),
      },
      {
        'value': 'other_departments',
        'label': 'other_departments'.tr(),
      },
      if (showAllCompany)
        {
          'value': 'all_company',
          'label': 'all_company'.tr(),
        },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.page, 0),
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
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
