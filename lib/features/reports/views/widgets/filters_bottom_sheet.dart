import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/multi_searchable_dropdown_sheet.dart';
import 'package:app_test/features/reports/data/models/report_catalog_model.dart';
import 'package:app_test/features/reports/data/models/report_filter_options_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/searchable_dropdown_sheet.dart';

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
  String? _errorMessage;

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

  bool get _hasEmployeeStatus => widget.filtersConfig.showEmployeeStatus;
  
  bool get _hasCompare => widget.filtersConfig.showCompare;

  List<EmployeeOption> get _filteredEmployees {
    final selectedDepts = _filters['department_ids'] as List<int>? ?? [];
    final selectedStatus = _filters['employee_status'] as String?;
    return widget.filterOptions.employees.where((e) {
      if (selectedDepts.isNotEmpty && !selectedDepts.contains(e.departmentId)) return false;
      if (selectedStatus != null && selectedStatus.isNotEmpty && e.status != selectedStatus) return false;
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
    
    _filters['department_ids'] ??= <int>[];
    _filters['employee_ids'] ??= <int>[];

    
    _filters['period_type'] ??= widget.filtersConfig.defaultPeriodType.isNotEmpty 
        ? widget.filtersConfig.defaultPeriodType 
        : 'time_frame';
        
    if (_filters['time_frame'] == null && _filters['period_type'] == 'time_frame') {
      _filters['time_frame'] = widget.filtersConfig.defaultTimeFrame.isNotEmpty 
          ? widget.filtersConfig.defaultTimeFrame 
          : (widget.filterOptions.timeFrames.isNotEmpty ? widget.filterOptions.timeFrames.first.key : null);
    }
    
    _filters['compare'] ??= false;
    _filters['compare_period_type'] ??= 'time_frame';

    if (_filters['compare_time_frame'] == null && _filters['compare_period_type'] == 'time_frame') {
      _filters['compare_time_frame'] = widget.filterOptions.timeFrames.isNotEmpty 
          ? widget.filterOptions.timeFrames.first.key 
          : null;
    }
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
  
  Future<void> _selectDateRange(String fromKey, String toKey) async {
    final DateTime now = DateTime.now();
    final DateTime initialFrom = _filters[fromKey] != null 
        ? DateTime.parse(_filters[fromKey]) 
        : now;
    final DateTime initialTo = _filters[toKey] != null 
        ? DateTime.parse(_filters[toKey]) 
        : now;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: initialFrom, end: initialTo),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(AppColors.buttons),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filters[fromKey] = DateFormat('yyyy-MM-dd').format(picked.start);
        _filters[toKey] = DateFormat('yyyy-MM-dd').format(picked.end);
      });
    }
  }

  Widget _buildDateRangePicker(String title, String fromKey, String toKey) {
    final fromDate = _filters[fromKey] as String?;
    final toDate = _filters[toKey] as String?;
    final text = (fromDate != null && toDate != null) 
        ? '$fromDate - $toDate' 
        : 'select_date_range'.tr();

    return InkWell(
      onTap: () => _selectDateRange(fromKey, toKey),
      child: InputDecorator(
        decoration: _dropdownDecoration(title),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: AppStyles.content(context)),
            Icon(Icons.calendar_today, color: Color(AppColors.buttons), size: 20),
          ],
        ),
      ),
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

            if (_hasDepartments) ...[
              MultiSearchableDropdownSheet(
                hintText: 'department'.tr(),
                items: widget.filterOptions.departments
                    .map((e) => {'id': e.id, 'title': e.title})
                    .toList(),
                selectedValues: widget.filterOptions.departments
                    .where((e) => (_filters['department_ids'] as List<int>? ?? []).contains(e.id))
                    .map((e) => {'id': e.id, 'title': e.title})
                    .toList(),
                nameKey: 'title',
                borderSide: BorderSide(color: Color(AppColors.inputBorder)),
                borderRadius: BorderRadius.circular(12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onChanged: (vals) {
                  setState(() {
                    _filters['department_ids'] = vals.map((v) => v['id'] as int).toList();
                    _filters['employee_ids'] = <int>[];
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            if (_hasEmployees) ...[
              MultiSearchableDropdownSheet(
                hintText: 'employee'.tr(),
                items: _filteredEmployees
                    .map((e) => {'id': e.id, 'name': e.name})
                    .toList(),
                selectedValues: _filteredEmployees
                    .where((e) => (_filters['employee_ids'] as List<int>? ?? []).contains(e.id))
                    .map((e) => {'id': e.id, 'name': e.name})
                    .toList(),
                nameKey: 'name',
                borderSide: BorderSide(color: Color(AppColors.inputBorder)),
                borderRadius: BorderRadius.circular(12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onChanged: (vals) {
                  setState(() {
                    _filters['employee_ids'] = vals.map((v) => v['id'] as int).toList();
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            if (_hasEmployeeStatus) ...[
              DropdownButtonFormField<String>(
                decoration: _dropdownDecoration('employee_status'.tr()),
                value: _filters['employee_status'] as String?,
                isExpanded: true,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('all'.tr(), style: AppStyles.content(context)),
                  ),
                  DropdownMenuItem<String>(
                    value: 'active',
                    child: Text('active'.tr(), style: AppStyles.content(context)),
                  ),
                  DropdownMenuItem<String>(
                    value: 'inactive',
                    child: Text('inactive'.tr(), style: AppStyles.content(context)),
                  ),
                  DropdownMenuItem<String>(
                    value: 'on_leave',
                    child: Text('on_leave'.tr(), style: AppStyles.content(context)),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _filters['employee_status'] = val;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            if (_hasRequestTypes) ...[
              SearchableDropdownSheet(
                hintText: 'request_type'.tr(),
                items: widget.filterOptions.requestTypes
                    .map((e) => {'id': e.id, 'title': e.title})
                    .toList(),
                selectedValue: (() {
                  final list = widget.filterOptions.requestTypes
                      .where((e) => e.id == _filters['request_type_id'])
                      .map((e) => {'id': e.id, 'title': e.title})
                      .toList();
                  return list.isEmpty ? null : list.first;
                })(),
                nameKey: 'title',
                borderSide: BorderSide(color: Color(AppColors.inputBorder)),
                borderRadius: BorderRadius.circular(12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onChanged: (val) {
                  setState(() {
                    _filters['request_type_id'] = val['id'] as int;
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // We completely hide the time period section if it's locked to keep the UI clean,
            // because the user can't change it anyway. The default values will still be sent.
            if (widget.filtersConfig.showTimePeriod && !widget.filtersConfig.lockTimePeriod) ...[
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  title: Text('time_period'.tr(), style: AppStyles.content(context)),
                  value: _filters['use_time_period'] ?? true,
                  activeColor: Color(AppColors.buttons),
                  onChanged: (val) {
                    setState(() {
                      _filters['use_time_period'] = val;
                    });
                  },
                ),
              ),
              if (_filters['use_time_period'] ?? true) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _dropdownDecoration('period_type'.tr()),
                  value: _filters['period_type'] as String?,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'time_frame',
                      child: Text('time_frame'.tr(), style: AppStyles.content(context)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'from_to',
                      child: Text('from_to'.tr(), style: AppStyles.content(context)),
                    ),
                  ],
                  onChanged: widget.filtersConfig.lockTimePeriod
                      ? null
                      : (val) {
                          setState(() {
                            _filters['period_type'] = val;
                          });
                        },
                ),
                const SizedBox(height: 16),

                if (_filters['period_type'] == 'time_frame' && _hasTimeFrames) ...[
                  DropdownButtonFormField<String>(
                    decoration: _dropdownDecoration('time_period'.tr()),
                    value: _filters['time_frame'] as String?,
                    isExpanded: true,
                    items: [
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

                if (_filters['period_type'] == 'from_to') ...[
                  _buildDateRangePicker('date_range'.tr(), 'date_from', 'date_to'),
                  const SizedBox(height: 16),
                ],
              ],
            ],

            if (_hasCompare) ...[
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  title: Text('compare_with'.tr(), style: AppStyles.content(context)),
                  value: _filters['compare'] ?? false,
                  activeColor: Color(AppColors.buttons),
                  onChanged: (val) {
                    setState(() {
                      _filters['compare'] = val;
                    });
                  },
                ),
              ),
              if (_filters['compare'] == true) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _dropdownDecoration('compare_period_type'.tr()),
                  value: _filters['compare_period_type'] as String?,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'time_frame',
                      child: Text('time_frame'.tr(), style: AppStyles.content(context)),
                    ),
                    DropdownMenuItem<String>(
                      value: 'from_to',
                      child: Text('from_to'.tr(), style: AppStyles.content(context)),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _filters['compare_period_type'] = val;
                    });
                  },
                ),
                const SizedBox(height: 16),

                if (_filters['compare_period_type'] == 'time_frame' && _hasTimeFrames) ...[
                  DropdownButtonFormField<String>(
                    decoration: _dropdownDecoration('compare_time_period'.tr()),
                    value: _filters['compare_time_frame'] as String?,
                    isExpanded: true,
                    items: [
                      ...widget.filterOptions.timeFrames.map((tf) {
                        return DropdownMenuItem<String>(
                          value: tf.key,
                          child: Text(tf.label, style: AppStyles.content(context)),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _filters['compare_time_frame'] = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                if (_filters['compare_period_type'] == 'from_to') ...[
                  _buildDateRangePicker('compare_date_range'.tr(), 'compare_date_from', 'compare_date_to'),
                  const SizedBox(height: 16),
                ],
              ],
            ],

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.buttons),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (widget.filtersConfig.requestTypesRequired) {
                  final reqTypeId = _filters['request_type_id'];
                  if (reqTypeId == null) {
                    setState(() {
                      _errorMessage = 'please_select_request_type'.tr();
                    });
                    return;
                  }
                }
                
                setState(() {
                  _errorMessage = null;
                });

                final clean = Map<String, dynamic>.fromEntries(
                  _filters.entries.where((e) {
                    if (e.value == null) return false;
                    return true;
                  }),
                );
                
                // Add empty lists explicitly for keys that require them
                if (!clean.containsKey('department_ids')) clean['department_ids'] = [];
                if (!clean.containsKey('employee_ids')) clean['employee_ids'] = [];
                if (!clean.containsKey('request_type_id')) clean['request_type_id'] = null;


                if (clean['use_time_period'] == false) {
                  clean.remove('period_type');
                  clean.remove('time_frame');
                  clean.remove('date_from');
                  clean.remove('date_to');
                }
                clean.remove('use_time_period');

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
}
