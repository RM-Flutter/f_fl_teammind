import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/proxy_actions_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';
import 'package:app_test/core/widgets/app_shortcut_card.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import '../controllers/proxy_attendance_controller.dart';
import '../controllers/proxy_requests_controller.dart';
import '../data/models/proxy_request_model.dart';
import 'proxy_request_form_screen.dart';
import 'widgets/proxy_employee_picker_sheet.dart';
import 'widgets/proxy_request_card_widget.dart';

/// "On Behalf of Employees" (route `proxyActions`): the actions this manager may take for their
/// employees (each one only when its `proxy_actions` switch is on) and "My Proxy Requests", the
/// leaves already created on someone's behalf (edit while still waiting, when allowed).
class ProxyHubScreen extends StatefulWidget {
  const ProxyHubScreen({super.key});

  @override
  State<ProxyHubScreen> createState() => _ProxyHubScreenState();
}

class _ProxyHubScreenState extends State<ProxyHubScreen> {
  final ProxyRequestsController _controller = ProxyRequestsController();

  bool get _showRequests => ProxyActionsService.canCreateLeave || ProxyActionsService.canEditLeave;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _showRequests) _controller.refresh(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _newRequest() async {
    final employee = await ProxyEmployeePickerSheet.show(context,
        ability: ProxyActionsService.leaveCreate, title: 'proxy_choose_employee'.tr());
    if (employee == null || !mounted) return;
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => ProxyRequestFormScreen(employee: employee),
    ));
    if (saved == true && mounted) _controller.refresh(context);
  }

  Future<void> _edit(ProxyRequestModel request) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => ProxyRequestFormScreen(editing: request),
    ));
    if (saved == true && mounted) _controller.refresh(context);
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (ProxyActionsService.canAttendance)
        AppShortcutCard(
          icon: Icons.fingerprint_rounded,
          title: 'proxy_attendance'.tr(),
          subtitle: 'proxy_attendance_hint'.tr(),
          onTap: () => ProxyAttendanceController.start(context),
        ),
      if (ProxyActionsService.canCreateLeave)
        AppShortcutCard(
          icon: Icons.event_available_rounded,
          title: 'proxy_new_request'.tr(),
          subtitle: 'proxy_new_request_hint'.tr(),
          onTap: _newRequest,
        ),
    ];

    return ChangeNotifierProvider<ProxyRequestsController>.value(
      value: _controller,
      child: TemplatePage(
        pageContext: context,
        title: 'proxy_title'.tr(),
        routeName: AppRoutes.proxyActions.name,
        backgroundColor: Color(AppColors.background),
        body: Consumer<ProxyRequestsController>(
          builder: (context, c, _) => NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) c.loadMore(context);
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () => c.refresh(context),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.listBottom),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (actions.isEmpty)
                    NoExistingPlaceholderScreen(
                      compact: true,
                      title: 'proxy_not_enabled'.tr(),
                      message: 'proxy_not_enabled_hint'.tr(),
                    )
                  else
                    AppResponsiveGrid(compact: 1, medium: 2, expanded: 2, rowHeight: 76, children: actions),
                  if (_showRequests) ...[
                    const SizedBox(height: AppSpacing.section),
                    AppSectionHeader(title: 'proxy_my_requests'.tr()),
                    const SizedBox(height: AppSpacing.sectionHeaderGap),
                    if (c.isLoading)
                      const AppShimmerList(count: 4, padding: EdgeInsets.zero)
                    else if (c.requests.isEmpty)
                      NoExistingPlaceholderScreen(
                        compact: true,
                        title: c.error != null ? AppStrings.somethingWentWrong.tr() : 'proxy_no_requests'.tr(),
                        message: c.error ?? 'proxy_no_requests_hint'.tr(),
                      )
                    else ...[
                      for (final r in c.requests)
                        ProxyRequestCardWidget(
                          request: r,
                          onEdit: ProxyActionsService.canEditLeave && r.isEditable ? () => _edit(r) : null,
                        ),
                      if (c.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.only(top: AppSizes.s4),
                          child: AppShimmerList(count: 1, padding: EdgeInsets.zero),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
