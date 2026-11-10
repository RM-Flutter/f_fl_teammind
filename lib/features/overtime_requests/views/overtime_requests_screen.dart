import 'package:app_test/core/widgets/app_empty_scroll_view.widget.dart';
import 'package:app_test/core/widgets/app_shortcut_card.widget.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../../more/notifications/views/widgets/switch_row_notification.dart';
import '../controllers/overtime_requests_controller.dart';
import '../../../../core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../../../../core/widgets/shared_list_filter_widget.dart'
    as app_test_filter;
import '../../../../core/widgets/active_filters_row_widget.dart';
import 'overtime_calendar_screen.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/request_scope_helper.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';

class OvertimeRequestsScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const OvertimeRequestsScreen({super.key, this.extra});

  @override
  State<OvertimeRequestsScreen> createState() => _OvertimeRequestsScreenState();
}

class _OvertimeRequestsScreenState extends State<OvertimeRequestsScreen> {
  late OvertimeRequestsProvider provider;
  Map<String, dynamic>? gCache;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      gCache = json.decode(jsonString);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<OvertimeRequestsProvider>(context, listen: false);
      if (widget.extra != null) {
        if (widget.extra!['isIncoming'] == true) {
          provider.isForDepartment = true;
          provider.incomingFilters['empId'] = widget.extra!['empId'];
          provider.incomingFilters['empName'] = widget.extra!['empName'];
        } else {
          provider.isForDepartment = false;
        }
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
    try {
      provider.resetAllFilters();
    } catch (_) {}
    super.dispose();
  }

  String formatStatus(String? status) {
    if (status == null) return '';
    switch (status) {
      case 'hrApproved':
        return AppStrings.hrApprovedStatus.tr();
      case 'managerApproved':
        return AppStrings.managerApprovedStatus.tr();
      case 'pending':
        return AppStrings.pendingStatus.tr();
      case 'waiting':
        return AppStrings.pendingStatus.tr();
      case 'rejected':
        return AppStrings.rejectedStatus.tr();
      case 'refused':
        return AppStrings.rejectedStatus.tr();
      default:
        return status
            .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
            .trim()
            .replaceFirstMapped(
                RegExp(r'^[a-z]'), (match) => match.group(0)!);
    }
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.toLowerCase().contains('approved')) return Colors.green;
    if (status.toLowerCase().contains('rejected') ||
        status.toLowerCase().contains('refused')) return Colors.red;
    return Color(AppColors.warningYellow);
  }

  String formatDuration(int? totalMinutes) {
    if (totalMinutes == null) return "0 ${AppStrings.minutes.tr()}";
    int hoursCount = totalMinutes ~/ 60;
    int minutesCount = totalMinutes % 60;

    if (hoursCount == 0) return "$minutesCount ${AppStrings.minutes.tr()}";
    if (minutesCount == 0) return "$hoursCount ${AppStrings.hours.tr()}";
    return "$hoursCount ${AppStrings.hours.tr()} $minutesCount ${AppStrings.minutes.tr()}";
  }

  String _getCalendarButtonTitle(
      BuildContext context, OvertimeRequestsProvider provider) {
    if (!provider.isForDepartment) {
      return 'my_requests_calendar'.tr();
    }
    switch (provider.incomingScope) {
      case 'other_departments':
        return 'other_departments_calendar'.tr();
      case 'all_company':
        return 'all_company_calendar'.tr();
      case 'team':
      default:
        return 'team_requests_calendar'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      pageContext: context,
      title: AppStrings.overtimeRequests.tr(),
      routeName: AppRoutes.overtimeRequestsScreen.name,
      actions: [
        Consumer<OvertimeRequestsProvider>(
          builder: (context, provider, _) {
            final list = provider.isForDepartment
                ? provider.teamRequests
                : provider.myRequests;
            // No list -> nothing to filter (unless a filter is active, so it can be cleared).
            if (!provider.isLoading &&
                list.isEmpty &&
                !provider.currentFiltersMap.values
                    .any((v) => v != null && v.isNotEmpty)) {
              return const SizedBox.shrink();
            }
            return IconButton(
          icon: Icon(Icons.filter_list_rounded,
              color: Color(AppColors.secondaryButton)),
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
                statusOptions: const ["waiting", "waiting_seen", "approved", "refused", "canceled"],
                initialFilters: provider.currentFiltersMap,
                underMyManagement: true,
              ),
            );
            if (result != null && context.mounted) {
              provider.applyFilters(result, context);
            }
          },
        );
          },
        ),
      ],
      floatingActionButton: Consumer<OvertimeRequestsProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            heroTag: provider.isForDepartment
                ? 'add_manager_overtime'
                : 'add_overtime',
            backgroundColor: Color(AppColors.buttons),
            onPressed: () async {
              final result = await context.pushNamed(
                AppRoutes.addOvertimeRequestScreen.name,
                pathParameters: {'lang': context.locale.languageCode},
                extra: {'isForEmployee': provider.isForDepartment},
              );
              if (result == true && mounted) {
                provider.fetchRequests(context);
              }
            },
            child: Icon(
                provider.isForDepartment ? Icons.person_add_alt_1 : Icons.add,
                color: Colors.white),
          );
        },
      ),
      body: Consumer<OvertimeRequestsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppShimmerList();
          }

          final list = provider.isForDepartment
              ? provider.teamRequests
              : provider.myRequests;

          return Column(
            children: [
              // every employee can open "Other" (other departments / all company); "Team" is managers only
              ...[
                SwitchRowNotification(
                  value: provider.isForDepartment,
                  leftText: AppStrings.myRequests.tr(),
                  rightText: AppStrings.other.tr(),
                  onChanged: (val) {
                    provider.toggleDepartmentView(val, context);
                  },
                ),
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
                onClearStatus: () {},
              ),
              // No requests -> nothing to show on a calendar, so no calendar entry.
              if (list.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, AppSpacing.md, AppSpacing.page, 0),
                child: AppShortcutCard(
                  title: _getCalendarButtonTitle(context, provider),
                  subtitle: AppStrings.calendarShortcutHint.tr(),
                  icon: Icons.calendar_month_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OvertimeCalendarScreen(
                          requests: list,
                          title: _getCalendarButtonTitle(context, provider),
                          isForDepartment: provider.isForDepartment,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: () => provider.fetchRequests(context),
                  child: list.isEmpty
                      ? AppEmptyScrollView(title: AppStrings.noDataFounded.tr())
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
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.overtimeRequestDetailsScreen.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode
                                  },
                                  extra: item,
                                );
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
