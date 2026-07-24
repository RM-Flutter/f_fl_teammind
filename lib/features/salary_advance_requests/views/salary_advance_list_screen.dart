import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/features/more/notifications/views/widgets/switch_row_notification.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';

import '../../salary_advance_requests/controllers/salary_advance_list_controller.dart';
import '../../salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'widgets/salary_advance_list_item_widget.dart';
import '../../../../core/widgets/shared_list_filter_widget.dart' as app_test_filter;
import '../../../../core/widgets/active_filters_row_widget.dart';

class SalaryAdvanceListScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const SalaryAdvanceListScreen({super.key, this.extra});

  @override
  State<SalaryAdvanceListScreen> createState() => _SalaryAdvanceListScreenState();
}

class _SalaryAdvanceListScreenState extends State<SalaryAdvanceListScreen> {
  late final SalaryAdvanceListController viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = SalaryAdvanceListController();
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
    if (mounted) {
      setState(() {});
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (viewModel.isIncomingView) {
          if (!viewModel.incomingIsLoadingMore && viewModel.incomingHasMore) {
            viewModel.getIncomingRequests(context: context, loadMore: true);
          }
        } else {
          if (!viewModel.personalIsLoadingMore && viewModel.personalHasMore) {
            viewModel.getPersonalRequests(context: context, loadMore: true);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    try {
      viewModel.resetAllFilters();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SalaryAdvanceListController>.value(
      value: viewModel,
      child: Consumer<SalaryAdvanceListController>(
        builder: (context, controller, child) {
          return TemplatePage(
            pageContext: context,
            title: 'salary_advance_requests'.tr(),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list_rounded, color: Color(AppColors.secondaryButton)),
                onPressed: () async {
                  final result = await showModalBottomSheet<Map<String, String?>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => app_test_filter.SharedListFilterWidget(
                      showEmployee: controller.isIncomingView,
                      showDepartment: controller.isIncomingView,
                      showDateRange: false,
                      showStatus: true,
                      statusOptions: const ['approved', 'cancelled', 'pending'],
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
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.pushNamed(
                  AppRoutes.salaryAdvanceCreate.name,
                  pathParameters: {'lang': context.locale.languageCode},
                ).then((value) {
                  if (value == true) {
                    controller.initializeScreen(context);
                  }
                });
              },
              backgroundColor: Color(AppColors.buttons),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: Column(
              children: [
                if (controller.isManagerOrHr) ...[
                  SizedBox(height: 10),
                  SwitchRowNotification(
                    value: controller.isIncomingView,
                    leftText: 'my_requests'.tr(),
                    rightText: 'incoming_requests'.tr(),
                    onChanged: (val) {
                      controller.toggleIncomingView(val, context);
                    },
                  ),
                  SizedBox(height: 10),
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

  Widget _buildPersonalList(SalaryAdvanceListController controller) {
    if (controller.isLoadingPersonal) {
      return const PayrollsAndPenaltiesRewardsLoadingScreensWidget();
    }
    
    if (controller.personalRequests == null || controller.personalRequests!.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () => controller.initializeScreen(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: NoExistingPlaceholderScreen(
            height: 0.6.sh,
            title: 'no_requests'.tr(),
          ),
        ),
      );
    }

    return _buildListView(controller, controller.personalRequests!, isIncoming: false);
  }

  Widget _buildIncomingList(SalaryAdvanceListController controller) {
    if (controller.isLoadingIncoming) {
      return const PayrollsAndPenaltiesRewardsLoadingScreensWidget();
    }
    
    if (controller.incomingRequests == null || controller.incomingRequests!.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () => controller.initializeScreen(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: NoExistingPlaceholderScreen(
            height: 0.6.sh,
            title: 'no_incoming_requests'.tr(),
          ),
        ),
      );
    }

    return _buildListView(controller, controller.incomingRequests!, isIncoming: true);
  }

  Widget _buildListView(
      SalaryAdvanceListController controller,
      List<SalaryAdvanceRequestModel> requests,
      {required bool isIncoming}) {

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 1100 : double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.s12),
          child: RefreshIndicator.adaptive(
            onRefresh: () => controller.initializeScreen(context),
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: requests.length + (isIncoming ? (controller.incomingIsLoadingMore ? 1 : 0) : (controller.personalIsLoadingMore ? 1 : 0)),
              itemBuilder: (context, index) {
                if (index == requests.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final request = requests[index];

                // Only HR and Top Management can edit incoming requests (never personal requests)
                final canEdit = isIncoming && controller.canEdit;

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: SalaryAdvanceListItemWidget(
                    request: request,
                    isIncoming: isIncoming,
                    canEdit: canEdit,
                    onRefresh: () => controller.initializeScreen(context),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
