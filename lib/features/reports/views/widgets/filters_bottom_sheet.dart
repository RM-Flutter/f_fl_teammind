import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/reports/data/models/report_catalog_model.dart';
import 'package:app_test/features/reports/data/models/report_filter_options_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
  }

  InputDecoration _dropdownDecoration(String label, BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.center,
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
          if (widget.filtersConfig.showDepartments && widget.filterOptions.departments.isNotEmpty)
            DropdownButtonFormField<int>(
              decoration: _dropdownDecoration('department'.tr(), context),
              value: _filters['department_id'] as int?,
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
                  _filters.remove('employee_id');
                });
              },
            ),
          if (widget.filtersConfig.showDepartments && widget.filterOptions.departments.isNotEmpty)
            const SizedBox(height: 16),
            
          if (widget.filtersConfig.showEmployees && widget.filterOptions.employees.isNotEmpty)
            DropdownButtonFormField<int>(
              decoration: _dropdownDecoration('employee'.tr(), context),
              value: _filters['employee_id'] as int?,
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('all'.tr(), style: AppStyles.content(context)),
                ),
                ...widget.filterOptions.employees.where((emp) {
                  final selectedDept = _filters['department_id'];
                  if (selectedDept == null) return true;
                  return emp.departmentId == selectedDept;
                }).map((emp) {
                  return DropdownMenuItem<int>(
                    value: emp.id,
                    child: Text(emp.name, style: AppStyles.content(context)),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _filters['employee_id'] = val;
                });
              },
            ),
          if (widget.filtersConfig.showEmployees && widget.filterOptions.employees.isNotEmpty)
            const SizedBox(height: 16),
            
          if (widget.filtersConfig.showRequestTypes && widget.filterOptions.requestTypes.isNotEmpty)
            DropdownButtonFormField<int>(
              decoration: _dropdownDecoration('request_type'.tr(), context),
              value: _filters['request_type_id'] as int?,
              items: [
                if (!widget.filtersConfig.requestTypesRequired)
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text('all'.tr(), style: AppStyles.content(context)),
                  ),
                ...widget.filterOptions.requestTypes.map((req) {
                  return DropdownMenuItem<int>(
                    value: req.id,
                    child: Text(req.title, style: AppStyles.content(context)),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _filters['request_type_id'] = val;
                });
              },
            ),
          if (widget.filtersConfig.showRequestTypes && widget.filterOptions.requestTypes.isNotEmpty)
            const SizedBox(height: 16),
            
          if (widget.filtersConfig.showTimePeriod && widget.filterOptions.timeFrames.isNotEmpty)
            DropdownButtonFormField<String>(
              decoration: _dropdownDecoration('time_period'.tr(), context),
              value: _filters['time_frame'] as String?,
              items: [
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
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.buttons),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              widget.onApplyFilters(_filters);
              Navigator.pop(context);
            },
            child: Text(
              'apply_filters'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
