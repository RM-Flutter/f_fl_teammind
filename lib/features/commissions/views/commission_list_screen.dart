import 'package:app_test/core/widgets/app_filter_actions.widget.dart';
import 'package:app_test/core/widgets/app_empty_scroll_view.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/commissions/controllers/commission_list_controller.dart';
import 'package:app_test/features/commissions/views/widgets/commission_card_widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/widgets/searchable_dropdown_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_design.dart';

class CommissionListScreen extends StatefulWidget {
  const CommissionListScreen({super.key});

  @override
  State<CommissionListScreen> createState() => _CommissionListScreenState();
}

class _CommissionListScreenState extends State<CommissionListScreen> {
  late final CommissionListController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = CommissionListController();
    _controller.initializeScreen(context);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_controller.hasMore && !_controller.isLoadingMore) {
          _controller.loadMore(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CommissionListController>.value(
      value: _controller,
      child: Consumer<CommissionListController>(
        builder: (context, controller, _) {
          // No list -> nothing to filter: hide the filter (unless a filter is active, so it can be cleared).
          final hideFilter = !controller.isLoading &&
              (controller.commissions == null || controller.commissions!.isEmpty) &&
              controller.filterStatus == null &&
              controller.filterFromDate == null &&
              controller.filterToDate == null;
          return TemplatePage(
            pageContext: context,
            title: AppStrings.commissions.tr(),
            actions: hideFilter ? null : [
              // ── Filter button ────────────────────────────────────────
              IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: Color(AppColors.secondaryButton),
                ),
                onPressed: () async {
                  final result = await _showFilterSheet(context, controller);
                  if (result != null && context.mounted) {
                    await controller.applyFilters(
                      context: context,
                      status: result['status'],
                      fromDate: result['from_date'],
                      toDate: result['to_date'],
                    );
                  }
                },
              ),
            ],
            body: Column(
              children: [
                // ── Active filter chips ─────────────────────────────────
                if (controller.filterStatus != null ||
                    controller.filterFromDate != null ||
                    controller.filterToDate != null)
                  _ActiveFiltersBar(controller: controller),

                // ── List ─────────────────────────────────────────────────
                Expanded(child: _buildBody(context, controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CommissionListController controller) {
    if (controller.isLoading) {
      return const PayrollsAndPenaltiesRewardsLoadingScreensWidget();
    }

    if (controller.commissions == null || controller.commissions!.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () => controller.initializeScreen(context),
        child: AppEmptyScrollView(title: 'no_commissions'.tr()),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: LayoutService.contentConstraints(context),
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.initializeScreen(context),
          child: ListView.builder(
            controller: _scrollController,
            clipBehavior: Clip.none,
            padding: AppSpacing.listPadding,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.commissions!.length +
                (controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.commissions!.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSizes.s16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return TweenAnimationBuilder<double>(
                duration:
                    Duration(milliseconds: 350 + (index * 80).clamp(0, 500)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutQuart,
                builder: (ctx, value, child) => Transform.translate(
                  offset: Offset(0, 40 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                ),
                child: CommissionCardWidget(
                  commission: controller.commissions![index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Shows the filter bottom sheet and returns the selected values.
  Future<Map<String, String?>?> _showFilterSheet(
    BuildContext context,
    CommissionListController controller,
  ) {
    return showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommissionFilterSheet(
        initialStatus: controller.filterStatus,
        initialFromDate: controller.filterFromDate,
        initialToDate: controller.filterToDate,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active filters bar
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveFiltersBar extends StatelessWidget {
  final CommissionListController controller;

  const _ActiveFiltersBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: LayoutService.contentConstraints(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.s12,
            AppSizes.s8,
            AppSizes.s12,
            AppSizes.s4,
          ),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (controller.filterStatus != null)
                    _FilterChip(
                      icon: Icons.flag_outlined,
                      label:
                          '${'status'.tr()}: ${'commission_status_${controller.filterStatus!}'.tr()}',
                      onRemove: () => controller.applyFilters(
                        context: context,
                        status: null,
                        fromDate: controller.filterFromDate,
                        toDate: controller.filterToDate,
                      ),
                    ),
                  if (controller.filterFromDate != null)
                    _FilterChip(
                      icon: Icons.calendar_today_outlined,
                      label:
                          '${'date_from'.tr()}: ${controller.filterFromDate!}',
                      onRemove: () => controller.applyFilters(
                        context: context,
                        status: controller.filterStatus,
                        fromDate: null,
                        toDate: controller.filterToDate,
                      ),
                    ),
                  if (controller.filterToDate != null)
                    _FilterChip(
                      icon: Icons.event_outlined,
                      label: '${'date_to'.tr()}: ${controller.filterToDate!}',
                      onRemove: () => controller.applyFilters(
                        context: context,
                        status: controller.filterStatus,
                        fromDate: controller.filterFromDate,
                        toDate: null,
                      ),
                    ),
                  // Compact Clear All pill
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: () => controller.clearFilters(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_sweep_outlined,
                            size: 15,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: AppSizes.s4),
                          Text(
                            'clear_filters'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(AppColors.buttons);
    return Container(
      margin: const EdgeInsetsDirectional.only(end: AppSizes.s8),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: 7),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: primaryColor.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: AppSizes.s6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(AppColors.secondaryButton),
            ),
          ),
          const SizedBox(width: AppSizes.s6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Icon(
              Icons.close_rounded,
              size: 15,
              color: Color(AppColors.secondaryButton),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CommissionFilterSheet extends StatefulWidget {
  final String? initialStatus;
  final String? initialFromDate;
  final String? initialToDate;

  const _CommissionFilterSheet({
    this.initialStatus,
    this.initialFromDate,
    this.initialToDate,
  });

  @override
  State<_CommissionFilterSheet> createState() => _CommissionFilterSheetState();
}

class _CommissionFilterSheetState extends State<_CommissionFilterSheet> {
  String? _status;
  String? _fromDate;
  String? _toDate;

  static const _statusOptions = [
    'pending',
    'applied',
    'paid_separately',
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
  }

  @override
  Widget build(BuildContext context) {
    // Same fields as the shared list filter (SharedListFilterWidget): searchable dropdown +
    // plain read-only date fields, no labels above them.
    final selectedStatus = _status == null
        ? null
        : {'id': _status, 'name': 'commission_status_$_status'.tr()};
    return AppFilterSheetFrame(
      title: 'filter'.tr(),
      onApply: () => Navigator.pop(context, {
        'status': _status,
        'from_date': _fromDate,
        'to_date': _toDate,
      }),
      onClear: () => Navigator.pop(context, {
        'status': null,
        'from_date': null,
        'to_date': null,
      }),
      children: [
        SearchableDropdownSheet(
          items: _statusOptions
              .map((s) => {'id': s, 'name': 'commission_status_$s'.tr()})
              .toList(),
          selectedValue: selectedStatus,
          nameKey: 'name',
          hintText: 'status'.tr(),
          hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: Color(AppColors.border), width: 1.0),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
          fieldSuffixIcon: InkWell(
            onTap: () => setState(() => _status = null),
            child: const Icon(Icons.close, color: Colors.red, size: 20),
          ),
          onChanged: (value) =>
              setState(() => _status = value['id']?.toString()),
        ),
        _DatePickerField(
          hint: 'date_from'.tr(),
          value: _fromDate,
          onPicked: (d) => setState(() => _fromDate = d),
          onClear: () => setState(() => _fromDate = null),
        ),
        _DatePickerField(
          hint: 'date_to'.tr(),
          value: _toDate,
          onPicked: (d) => setState(() => _toDate = d),
          onClear: () => setState(() => _toDate = null),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String hint;
  final String? value;
  final ValueChanged<String> onPicked;
  final VoidCallback onClear;

  const _DatePickerField({
    required this.hint,
    required this.value,
    required this.onPicked,
    required this.onClear,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          value != null ? DateTime.tryParse(value!) ?? DateTime.now() : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      onPicked(
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: Color(AppColors.border), width: 1.0),
    );
    return TextField(
      key: ValueKey(value),
      controller: TextEditingController(text: value ?? ''),
      readOnly: true,
      onTap: () => _pick(context),
      style: AppStyles.darkContent(context).copyWith(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 12),
        suffixIcon: value != null
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: onClear,
              )
            : IconButton(
                icon: const Icon(Icons.calendar_today, size: 20),
                onPressed: () => _pick(context),
              ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
