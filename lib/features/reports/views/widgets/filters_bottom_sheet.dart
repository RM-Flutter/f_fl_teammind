import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/reports/data/models/report_catalog_model.dart';
import 'package:app_test/features/reports/data/models/report_filter_options_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Filter bottom sheet for reports.
///
/// Display logic is driven **entirely by the API response** (`filterOptions`):
/// - A dropdown is shown only if the corresponding list from the API is non-empty
///   AND the `filtersConfig` flag allows it.
/// - No extra API calls are made here — all data comes from the already-fetched
///   `filterOptions` (filter-options endpoint).
class FiltersBottomSheet extends StatefulWidget {
  final FiltersConfigModel filtersConfig;
  final ReportFilterOptionsModel filterOptions;
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FiltersBottomSheet({
    Key? key,
    required this.filtersConfig,
    required this.filterOptions,
    required this.initialFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late Map<String, dynamic> _filters;

  // Convenience getters — drive visibility from API data, not local config
  bool get _hasDepartments =>
      widget.filtersConfig.showDepartments &&
      widget.filterOptions.departments.isNotEmpty;

  bool get _hasEmployees =>
      widget.filtersConfig.showEmployees &&
      widget.filterOptions.employees.isNotEmpty;

  bool get _hasRequestTypes =>
      widget.filtersConfig.showRequestTypes &&
      widget.filterOptions.requestTypes.isNotEmpty;

  bool get _hasTimeFrames =>
      widget.filtersConfig.showTimePeriod &&
      widget.filterOptions.timeFrames.isNotEmpty;

  /// Employees filtered by the currently selected department (client-side)
  List<EmployeeOption> get _filteredEmployees {
    final selectedDept = _filters['department_id'] as int?;
    if (selectedDept == null) return widget.filterOptions.employees;
    return widget.filterOptions.employees
        .where((e) => e.departmentId == selectedDept)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppStyles.hintContent(context),
      filled: true,
      fillColor: Color(AppColors.inputFill),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(AppColors.inputBorder)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(AppColors.inputBorder)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(AppColors.inputFocusedBorder)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'filter_reports'.tr(),
              style: AppStyles.heading(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── Departments ──────────────────────────────────────────────
            if (_hasDepartments) ...[
              DropdownButtonFormField<int>(
                decoration: _dropdownDecoration('department'.tr()),
                value: _filters['department_id'] as int?,
                isExpanded: true,
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text('all'.tr(), style: AppStyles.content(context)),
                  ),
                  ...widget.filterOptions.departments.map((dept) {
                    return DropdownMenuItem<int>(
                      value: dept.id,
                      child: Text(dept.title, style: AppStyles.content(context)),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() {
                    _filters['department_id'] = val;
                    // Reset employee when department changes
                    _filters.remove('employee_id');
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Employees (filtered client-side by selected department) ──
            if (_hasEmployees) ...[
              DropdownButtonFormField<int>(
                decoration: _dropdownDecoration('employee'.tr()),
                value: _validateEmployeeValue(_filters['employee_id'] as int?),
                isExpanded: true,
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text('all'.tr(), style: AppStyles.content(context)),
                  ),
                  ..._filteredEmployees.map((emp) {
                    return DropdownMenuItem<int>(
                      value: emp.id,
                      child: Text(
                        emp.name,
                        style: AppStyles.content(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() {
                    _filters['employee_id'] = val;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Request Types ────────────────────────────────────────────
            if (_hasRequestTypes) ...[
              DropdownButtonFormField<int>(
                decoration: _dropdownDecoration('request_type'.tr()),
                value: _filters['request_type_id'] as int?,
                isExpanded: true,
                items: [
                  if (!widget.filtersConfig.requestTypesRequired)
                    DropdownMenuItem<int>(
                      value: null,
                      child: Text('all'.tr(), style: AppStyles.content(context)),
                    ),
                  ...widget.filterOptions.requestTypes.map((rt) {
                    return DropdownMenuItem<int>(
                      value: rt.id,
                      child: Text(rt.title, style: AppStyles.content(context)),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() {
                    _filters['request_type_id'] = val;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Time Frame ───────────────────────────────────────────────
            if (_hasTimeFrames) ...[
              DropdownButtonFormField<String>(
                decoration: _dropdownDecoration('time_period'.tr()),
                value: _filters['time_frame'] as String?,
                isExpanded: true,
                items: [
                  if (!widget.filtersConfig.lockTimePeriod)
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('all'.tr(), style: AppStyles.content(context)),
                    ),
                  ...widget.filterOptions.timeFrames.map((tf) {
                    return DropdownMenuItem<String>(
                      value: tf.key,
                      child: Text(tf.label, style: AppStyles.content(context)),
                    );
                  }),
                ],
                onChanged: widget.filtersConfig.lockTimePeriod
                    ? null
                    : (val) {
                        setState(() {
                          _filters['time_frame'] = val;
                        });
                      },
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            // ── Apply button ─────────────────────────────────────────────
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.buttons),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Pass only non-null filters to avoid sending empty keys
                final clean = Map<String, dynamic>.fromEntries(
                  _filters.entries.where((e) => e.value != null),
                );
                widget.onApplyFilters(clean);
                Navigator.pop(context);
              },
              child: Text(
                'apply_filters'.tr(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Make sure the stored employee_id is still valid after department filter changes.
  int? _validateEmployeeValue(int? empId) {
    if (empId == null) return null;
    final exists = _filteredEmployees.any((e) => e.id == empId);
    return exists ? empId : null;
  }
}
