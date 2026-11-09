import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../../../core/widgets/active_filters_row_widget.dart';
import '../../../core/widgets/approvable_card_widget.dart';
import '../../../core/widgets/shared_list_filter_widget.dart' as app_test_filter;
import '../../../core/widgets/template_page.widget.dart';
import '../../more/notifications/views/widgets/switch_row_notification.dart';
import '../controllers/shift_change_controller.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/request_scope_helper.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';

class ShiftChangeRequestsScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const ShiftChangeRequestsScreen({super.key, this.extra});

  @override
  State<ShiftChangeRequestsScreen> createState() =>
      _ShiftChangeRequestsScreenState();
}

class _ShiftChangeRequestsScreenState extends State<ShiftChangeRequestsScreen> {
  late ShiftChangeController provider;
  Map<String, dynamic>? gCache;
  Map<String, dynamic>? us2Cache;
  final ScrollController _scrollController = ScrollController();

  bool get _isShiftsEmployee =>
      us2Cache?['worktime']?['working_hours_type']?.toString() == 'shifts';

  @override
  void initState() {
    super.initState();
    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        gCache = json.decode(jsonString);
      } catch (_) {}
    }
    final us2String = CacheHelper.getString("US2");
    if (us2String != null && us2String.isNotEmpty) {
      try {
        us2Cache = json.decode(us2String);
      } catch (_) {}
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<ShiftChangeController>(context, listen: false);
      if (widget.extra != null && widget.extra!['isIncoming'] == true) {
        provider.isForDepartment = true;
        provider.incomingFilters['empId'] = widget.extra!['empId'];
        provider.incomingFilters['empName'] = widget.extra!['empName'];
      } else if (!_isShiftsEmployee) {
        // not on shifts: no own shift requests, so open the incoming list (other departments / all company for employees)
        provider.isForDepartment = true;
      } else {
        provider.isForDepartment = false;
      }
      provider.incomingScope = RequestScopeHelper.defaultIncomingScope;
      provider.fetchRequests(context);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (provider.isForDepartment) {
          if (!provider.incomingIsLoadingMore && provider.incomingHasMore) {
            provider.fetchRequests(context, loadMore: true);
          }
        } else {
          if (!provider.personalIsLoadingMore && provider.personalHasMore) {
            provider.fetchRequests(context, loadMore: true);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    try {
      provider.resetAllFilters();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isShiftsEmployee = _isShiftsEmployee;

    return Consumer<ShiftChangeController>(
      builder: (context, provider, child) {
        return TemplatePage(
          pageContext: context,
          title: AppStrings.shiftChangeRequests.tr(),
          routeName: AppRoutes.shiftChangeRequests.name,
          actions: [
            IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: Color(AppColors.secondaryButton),
              ),
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, String?>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => app_test_filter.SharedListFilterWidget(
                    showEmployee: provider.isForDepartment,
                    showDepartment: provider.isForDepartment,
                    showDateRange: true,
                    showStatus: true,
                    statusOptions: const [
                      "waiting",
                      "waiting_seen",
                      "approved",
                      "refused",
                      "canceled"
                    ],
                    initialFilters: provider.currentFiltersMap,
                    underMyManagement: true,
                  ),
                );
                if (result != null && context.mounted) {
                  provider.applyFilters(result, context);
                }
              },
            ),
          ],
          floatingActionButton: (isShiftsEmployee && !provider.isForDepartment)
              ? FloatingActionButton(
                  heroTag: 'add_shift_change_request',
                  backgroundColor: Color(AppColors.buttons),
                  onPressed: () async {
                    final result = await context.pushNamed(
                      AppRoutes.addShiftChangeRequest.name,
                      pathParameters: {'lang': context.locale.languageCode},
                    );
                    if (result == true && mounted) {
                      provider.fetchRequests(context);
                    }
                  },
                  child:
                      const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                )
              : null,
          body: Builder(
            builder: (context) {
              if (provider.isLoading) {
                return const AppShimmerList();
              }

              final list = provider.isForDepartment
                  ? provider.teamRequests
                  : provider.myRequests;

              return Column(
                children: [
                  if (isShiftsEmployee) ...[
                    SwitchRowNotification(
                      value: provider.isForDepartment,
                      leftText: AppStrings.myRequests.tr(),
                      rightText: AppStrings.other.tr(),
                      onChanged: (val) {
                        provider.toggleDepartmentView(val, context);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
              if (provider.isForDepartment) ...[
                _ScopeSelectorRow(
                  currentScope: provider.incomingScope,
                  showAllCompany: true,
                  showTeam: RequestScopeHelper.canSeeTeam,
                  onSelected: (scope) =>
                      provider.setIncomingScope(scope, context),
                ),
              ],
              ActiveFiltersRowWidget(
                empName: provider.filterEmpName,
                depName: provider.filterDepName,
                fromDate: provider.filterFrom,
                toDate: provider.filterTo,
                onClearEmp: () => provider.clearFilterEmp(context),
                onClearDep: () => provider.clearFilterDep(context),
                onClearDate: () => provider.clearFilterDate(context),
                onClearStatus: () => provider.clearFilterStatus(context),
              ),
              Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: () => provider.fetchRequests(context),
                  child: list.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: NoExistingPlaceholderScreen(
                            height: 300,
                            title: AppStrings.noDataFounded.tr(),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          clipBehavior: Clip.none,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.page, AppSpacing.md, AppSpacing.page, 80),
                          itemCount: list.length +
                              (provider.isForDepartment
                                  ? (provider.incomingIsLoadingMore ? 1 : 0)
                                  : (provider.personalIsLoadingMore ? 1 : 0)),
                          itemBuilder: (context, index) {
                            if (index == list.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            final item = list[index];
                            return ApprovableCardWidget(
                              request: item,
                              isForDepartment: provider.isForDepartment,
                              onActionTaken: () =>
                                  provider.fetchRequests(context),
                              onTap: () async {
                                await context.pushNamed(
                                  AppRoutes.approvableDetails.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode,
                                    'type': 'shift_change_requests',
                                    'id': item.id.toString(),
                                  },
                                );
                                if (mounted) {
                                  provider.fetchRequests(context);
                                }
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
            },
          ),
        );
      },
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
