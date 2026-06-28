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

class SalaryAdvanceListScreen extends StatefulWidget {
  const SalaryAdvanceListScreen({super.key});

  @override
  State<SalaryAdvanceListScreen> createState() => _SalaryAdvanceListScreenState();
}

class _SalaryAdvanceListScreenState extends State<SalaryAdvanceListScreen> {
  late final SalaryAdvanceListController viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = SalaryAdvanceListController();
    _initData();
  }

  void _initData() async {
    await viewModel.initializeScreen(context);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
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
                      controller.toggleIncomingView(val);
                    },
                  ),
                  SizedBox(height: 10),
                ],
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
      return NoExistingPlaceholderScreen(
        height: 0.6.sh,
        title: 'no_requests'.tr(),
      );
    }

    return _buildListView(controller, controller.personalRequests!, isIncoming: false);
  }

  Widget _buildIncomingList(SalaryAdvanceListController controller) {
    if (controller.isLoadingIncoming) {
      return const PayrollsAndPenaltiesRewardsLoadingScreensWidget();
    }
    
    if (controller.incomingRequests == null || controller.incomingRequests!.isEmpty) {
      return NoExistingPlaceholderScreen(
        height: 0.6.sh,
        title: 'no_incoming_requests'.tr(),
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
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];

                // Only HR, Top Management, and authorized managers can edit requests
                final canEdit = controller.canModifyIncoming;

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
