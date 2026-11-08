import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/commissions/controllers/commission_list_controller.dart';
import 'package:app_test/features/commissions/views/widgets/commission_card_widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
          return TemplatePage(
            pageContext: context,
            title: AppStrings.commissions.tr(),
            actions: [
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: NoExistingPlaceholderScreen(
            height: 0.6.sh,
            title: 'no_commissions'.tr(),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: double.infinity),
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.initializeScreen(context),
          child: ListView.builder(
            controller: _scrollController,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.commissions!.length +
                (controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.commissions!.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return TweenAnimationBuilder<double>(
                duration: Duration(
                    milliseconds: 350 + (index * 80).clamp(0, 500)),
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
        constraints: const BoxConstraints(maxWidth: double.infinity),
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
                        horizontal: 12,
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
                          const SizedBox(width: 4),
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
      margin: const EdgeInsetsDirectional.only(end: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(AppColors.secondaryButton),
            ),
          ),
          const SizedBox(width: 6),
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

  InputDecoration _fieldDecoration({Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Color(AppColors.inputFill),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: Color(AppColors.inputBorder)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: Color(AppColors.inputBorder)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: Color(AppColors.inputFocusedBorder)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'filter'.tr(),
              style: AppStyles.heading(context).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ── Status Dropdown ────────────────────────────────────────────
            Text(
              'status'.tr(),
              style: AppStyles.primaryContent(context).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _status,
              isExpanded: true,
              decoration: _fieldDecoration(),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('all'.tr(), style: AppStyles.content(context)),
                ),
                ..._statusOptions.map(
                  (s) => DropdownMenuItem<String?>(
                    value: s,
                    child: Text(
                      'commission_status_$s'.tr(),
                      style: AppStyles.content(context),
                    ),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _status = val),
            ),
            const SizedBox(height: 16),

            // ── From Date ──────────────────────────────────────────────────
            _DatePickerField(
              label: 'date_from'.tr(),
              value: _fromDate,
              decoration: _fieldDecoration(
                suffixIcon: _fromDate != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                        onPressed: () => setState(() => _fromDate = null),
                      )
                    : Icon(Icons.calendar_today_outlined,
                        size: 18, color: Color(AppColors.buttons)),
              ),
              onPicked: (d) => setState(() => _fromDate = d),
            ),
            const SizedBox(height: 16),

            // ── To Date ────────────────────────────────────────────────────
            _DatePickerField(
              label: 'date_to'.tr(),
              value: _toDate,
              decoration: _fieldDecoration(
                suffixIcon: _toDate != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                        onPressed: () => setState(() => _toDate = null),
                      )
                    : Icon(Icons.calendar_today_outlined,
                        size: 18, color: Color(AppColors.buttons)),
              ),
              onPicked: (d) => setState(() => _toDate = d),
            ),
            const SizedBox(height: 24),

            // ── Apply & Clear buttons ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppButtonSize.height,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.buttons),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, {
                        'status': _status,
                        'from_date': _fromDate,
                        'to_date': _toDate,
                      }),
                      child: Text(
                        'apply'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: AppButtonSize.height,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(AppColors.secondaryButton),
                      side: BorderSide(color: Color(AppColors.secondaryButton)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () => Navigator.pop(context, {
                      'status': null,
                      'from_date': null,
                      'to_date': null,
                    }),
                    child: Text(
                      AppStrings.clear.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final InputDecoration decoration;
  final ValueChanged<String> onPicked;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.decoration,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.primaryContent(context).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value != null
                  ? DateTime.tryParse(value!) ?? DateTime.now()
                  : DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              onPicked(
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
              );
            }
          },
          child: InputDecorator(
            decoration: decoration,
            child: Text(
              value ?? 'select_date'.tr(),
              style: value != null
                  ? AppStyles.content(context)
                  : AppStyles.hintContent(context),
            ),
          ),
        ),
      ],
    );
  }
}
