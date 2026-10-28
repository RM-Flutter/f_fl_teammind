import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/alert_service/alerts_service.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/widgets/template_page.widget.dart';
import '../controllers/shift_change_controller.dart';
import '../models/shift_change_request_model.dart';

class AddShiftChangeRequestScreen extends StatefulWidget {
  const AddShiftChangeRequestScreen({super.key});

  @override
  State<AddShiftChangeRequestScreen> createState() =>
      _AddShiftChangeRequestScreenState();
}

class _AddShiftChangeRequestScreenState
    extends State<AddShiftChangeRequestScreen> {
  final TextEditingController _reasonController = TextEditingController();

  late DateTime _calendarFrom;
  late DateTime _calendarTo;

  ShiftAssignmentModel? _selectedMyAssignment;
  SchedulerEmployeeModel? _selectedColleague;
  ShiftAssignmentModel? _selectedColleagueAssignment; // null = one-way transfer
  bool _isTwoWaySwap = true;

  // Department Schedule Table expand/collapse state
  bool _showDepartmentTable = true;

  // Optional Shift Filter from GET /shifts
  int? _selectedShiftFilterId;

  // Optional Specific-Date Colleague Assignments Lookup (GET /assignments)
  bool _useSpecificDateLookup = false;
  DateTime? _lookupDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarFrom = DateTime(now.year, now.month, now.day);
    _calendarTo = _calendarFrom.add(const Duration(days: 14));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ShiftChangeController>(context, listen: false);
      provider.clearColleagueAssignmentsLookup();
      provider.fetchDepartmentShifts(context);
      _loadCalendar();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadCalendar() async {
    final provider = Provider.of<ShiftChangeController>(context, listen: false);
    final fromStr = DateFormat('yyyy-MM-dd').format(_calendarFrom);
    final toStr = DateFormat('yyyy-MM-dd').format(_calendarTo);
    await provider.fetchSchedulerCalendar(context, from: fromStr, to: toStr);
    if (!mounted) return;
    setState(() {
      if (provider.calendarActualFrom != null &&
          provider.calendarActualFrom!.isNotEmpty) {
        final parsedFrom = DateTime.tryParse(provider.calendarActualFrom!);
        if (parsedFrom != null) _calendarFrom = parsedFrom;
      }
      if (provider.calendarActualTo != null &&
          provider.calendarActualTo!.isNotEmpty) {
        final parsedTo = DateTime.tryParse(provider.calendarActualTo!);
        if (parsedTo != null) _calendarTo = parsedTo;
      }
    });
  }

  Future<void> _triggerSpecificDateLookup() async {
    if (_selectedColleague?.employeeId == null || _lookupDate == null) return;
    final provider = Provider.of<ShiftChangeController>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(_lookupDate!);
    await provider.fetchColleagueAssignments(
      context,
      employeeId: _selectedColleague!.employeeId!,
      date: dateStr,
      shiftId: _selectedShiftFilterId,
    );
  }

  String _formatDateLabel(String rawDate, BuildContext context) {
    try {
      final dt = DateTime.parse(rawDate.split(' ').first);
      return DateFormat('EEE, d MMM yyyy', context.locale.languageCode)
          .format(dt);
    } catch (_) {
      return rawDate.split(' ').first;
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = _calendarFrom.isBefore(today) ? today : _calendarFrom;
    final end = _calendarTo.isBefore(start) ? start : _calendarTo;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: start, end: end),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(AppColors.buttons),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(AppColors.secondaryButton),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _calendarFrom = picked.start;
        _calendarTo = picked.end;
        _selectedMyAssignment = null;
        _selectedColleague = null;
        _selectedColleagueAssignment = null;
      });
      await _loadCalendar();
    }
  }

  Future<void> _pickSpecificColleagueDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = (_lookupDate != null && !_lookupDate!.isBefore(today))
        ? _lookupDate!
        : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(AppColors.buttons),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(AppColors.secondaryButton),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lookupDate = picked;
        _selectedColleagueAssignment = null;
      });
      await _triggerSpecificDateLookup();
    }
  }

  List<DateTime> _buildCalendarDates() {
    final List<DateTime> dates = [];
    DateTime current = DateTime(
      _calendarFrom.year,
      _calendarFrom.month,
      _calendarFrom.day,
    );
    final DateTime end = DateTime(
      _calendarTo.year,
      _calendarTo.month,
      _calendarTo.day,
    );
    int safety = 0;
    while (!current.isAfter(end) && safety < 62) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
      safety++;
    }
    return dates;
  }

  List<ShiftAssignmentModel> _filterAssignmentsByShift(
    List<ShiftAssignmentModel> list,
  ) {
    if (_selectedShiftFilterId == null) return list;
    return list.where((a) => a.shiftId == _selectedShiftFilterId).toList();
  }

  Future<void> _submit(ShiftChangeController provider) async {
    final isArabic = LocalizationService.isArabic(context: context);
    if (_selectedMyAssignment == null || _selectedMyAssignment!.id == null) {
      AlertsService.error(
        context: context,
        message: isArabic
            ? 'يرجى اختيار الشيفت الخاص بك الذي تريد تبديله أو التنازل عنه'
            : 'Please select your shift assignment to swap or transfer',
        title: 'error'.tr(),
      );
      return;
    }

    if (_selectedColleague == null || _selectedColleague!.employeeId == null) {
      AlertsService.error(
        context: context,
        message: isArabic
            ? 'يرجى اختيار الزميل من نفس الإدارة'
            : 'Please select a colleague from your department',
        title: 'error'.tr(),
      );
      return;
    }

    if (_isTwoWaySwap &&
        (_selectedColleagueAssignment == null ||
            _selectedColleagueAssignment!.id == null)) {
      AlertsService.error(
        context: context,
        message: isArabic
            ? 'يرجى اختيار شيفت الزميل للتبديل معه، أو تغيير نوع الطلب إلى تنازل عن شيفت'
            : 'Please select the colleague shift to swap with, or switch to one-way transfer',
        title: 'error'.tr(),
      );
      return;
    }

    final reasonText = _reasonController.text.trim();
    if (reasonText.isEmpty) {
      AlertsService.error(
        context: context,
        message: AppStrings.pleaseEnterReason.tr(),
        title: 'error'.tr(),
      );
      return;
    }

    final success = await provider.submitShiftChangeRequest(
      context,
      receiverEmployeeId: _selectedColleague!.employeeId!,
      requesterShiftAssignmentId: _selectedMyAssignment!.id!,
      receiverShiftAssignmentId:
          _isTwoWaySwap ? _selectedColleagueAssignment?.id : null,
      reason: reasonText,
    );

    if (success && mounted) {
      AlertsService.success(
        context: context,
        message: 'request_sent_successfully'.tr(),
        title: 'success'.tr(),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);

    return TemplatePage(
      pageContext: context,
      title: AppStrings.addShiftChangeRequest.tr(),
      routeName: AppRoutes.addShiftChangeRequest.name,
      actions: [
        IconButton(
          tooltip: isArabic ? 'تغيير الفترة الزمنية' : 'Change Date Range',
          icon: Icon(
            Icons.date_range_rounded,
            color: Color(AppColors.secondaryButton),
          ),
          onPressed: _pickDateRange,
        ),
      ],
      body: Consumer<ShiftChangeController>(
        builder: (context, provider, child) {
          if (provider.isCalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final SchedulerEmployeeModel? me = provider.calendarEmployees
              .cast<SchedulerEmployeeModel?>()
              .firstWhere((e) => e?.isMe == true, orElse: () => null);

          final List<SchedulerEmployeeModel> colleagues =
              provider.calendarEmployees.where((e) => !e.isMe).toList();

          final List<ShiftAssignmentModel> myAssignments =
              _filterAssignmentsByShift(me?.assignments ?? []);

          final List<ShiftAssignmentModel> colleagueCalendarAssignments =
              _filterAssignmentsByShift(_selectedColleague?.assignments ?? []);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range chip bar
                _buildDateRangeHeader(context, isArabic),
                const SizedBox(height: 12),

                // Optional Department Shifts filter (GET /shifts)
                if (provider.departmentShifts.isNotEmpty) ...[
                  _buildDepartmentShiftsFilter(
                    context: context,
                    shifts: provider.departmentShifts,
                    isArabic: isArabic,
                  ),
                  const SizedBox(height: 12),
                ],

                // Backend error banner if status: false
                if (provider.calendarErrorMessage != null &&
                    provider.calendarErrorMessage!.isNotEmpty) ...[
                  _buildErrorBanner(provider.calendarErrorMessage!),
                  const SizedBox(height: 16),
                ],

                // Unified Department Scheduler Calendar Table (is_me first + colleagues)
                if (provider.calendarEmployees.isNotEmpty) ...[
                  _buildDepartmentScheduleCard(
                    context: context,
                    employees: provider.calendarEmployees,
                    isArabic: isArabic,
                  ),
                  const SizedBox(height: 20),
                ],

                // Step 1: Select My Shift Assignment
                _buildSectionHeader(
                  context: context,
                  stepNumber: '1',
                  title: isArabic
                      ? 'اختر الشيفت الخاص بك'
                      : 'Select Your Shift Assignment',
                  icon: Icons.event_available_rounded,
                ),
                const SizedBox(height: 10),
                if (myAssignments.isEmpty)
                  _buildEmptyNotice(
                    isArabic
                        ? 'لا توجد شيفتات متاحة لك في هذه الفترة للتبديل'
                        : 'No selectable shift assignments found for you in this date range.',
                  )
                else
                  _buildAssignmentsHorizontalList(
                    context: context,
                    assignments: myAssignments,
                    selected: _selectedMyAssignment,
                    isArabic: isArabic,
                    onSelect: (assignment) {
                      setState(() {
                        _selectedMyAssignment = assignment;
                      });
                    },
                  ),

                const SizedBox(height: 24),

                // Step 2: Select Colleague
                _buildSectionHeader(
                  context: context,
                  stepNumber: '2',
                  title: isArabic
                      ? 'اختر الزميل (من نفس الإدارة)'
                      : 'Select Colleague (Same Department)',
                  icon: Icons.people_alt_outlined,
                ),
                const SizedBox(height: 10),
                if (colleagues.isEmpty)
                  _buildEmptyNotice(
                    isArabic
                        ? 'لا يوجد زملاء متاحون في جدول الإدارة حالياً'
                        : 'No colleagues found in your department schedule.',
                  )
                else
                  _buildColleaguesSelector(
                    context: context,
                    colleagues: colleagues,
                    isArabic: isArabic,
                    provider: provider,
                  ),

                const SizedBox(height: 24),

                // Step 3: Request Type (Two-Way Swap vs One-Way Transfer) & Colleague Shift
                _buildSectionHeader(
                  context: context,
                  stepNumber: '3',
                  title: isArabic
                      ? 'نوع التبديل وشيفت الزميل'
                      : 'Swap Mode & Colleague Shift',
                  icon: Icons.swap_horiz_rounded,
                ),
                const SizedBox(height: 10),
                _buildSwapModeToggle(context, isArabic),
                if (_isTwoWaySwap) ...[
                  const SizedBox(height: 12),
                  if (_selectedColleague == null)
                    _buildEmptyNotice(
                      isArabic
                          ? 'اختر الزميل أولاً لعرض شيفتاته المتاحة للتبديل'
                          : 'Select a colleague first to view their available shifts.',
                    )
                  else ...[
                    _buildColleagueSourceToggle(context, isArabic, provider),
                    const SizedBox(height: 10),
                    if (_useSpecificDateLookup)
                      _buildSpecificDateLookupSection(
                        context: context,
                        provider: provider,
                        isArabic: isArabic,
                      )
                    else if (colleagueCalendarAssignments.isEmpty)
                      _buildEmptyNotice(
                        isArabic
                            ? 'لا توجد شيفتات متاحة لهذا الزميل في هذه الفترة'
                            : 'This colleague has no available shifts in this period.',
                      )
                    else
                      _buildAssignmentsHorizontalList(
                        context: context,
                        assignments: colleagueCalendarAssignments,
                        selected: _selectedColleagueAssignment,
                        isArabic: isArabic,
                        onSelect: (assignment) {
                          setState(() {
                            _selectedColleagueAssignment = assignment;
                          });
                        },
                      ),
                  ],
                ],

                const SizedBox(height: 24),

                // Step 4: Reason
                _buildSectionHeader(
                  context: context,
                  stepNumber: '4',
                  title: AppStrings.reason.tr(),
                  icon: Icons.notes_rounded,
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      hintText: isArabic
                          ? 'اكتب سبب طلب تبديل الشيفت...'
                          : 'Enter reason for shift change request...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                if (_selectedMyAssignment != null &&
                    _selectedColleague != null) ...[
                  const SizedBox(height: 20),
                  _buildSwapSummaryBanner(context, isArabic),
                ],

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: provider.isActionLoading
                        ? null
                        : () => _submit(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Color(AppColors.buttons).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: provider.isActionLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppStrings.sendRequest.tr(),
                            style: AppStyles.whiteContent(context).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeHeader(BuildContext context, bool isArabic) {
    final fromStr = DateFormat('d MMM yyyy', context.locale.languageCode)
        .format(_calendarFrom);
    final toStr = DateFormat('d MMM yyyy', context.locale.languageCode)
        .format(_calendarTo);

    return InkWell(
      onTap: _pickDateRange,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Color(AppColors.buttons).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(AppColors.buttons).withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 18, color: Color(AppColors.buttons)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${isArabic ? 'جدول الفترة' : 'Schedule Range'}: $fromStr - $toStr',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.buttons),
                ),
              ),
            ),
            Icon(Icons.edit_calendar_rounded,
                size: 18, color: Color(AppColors.buttons)),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentShiftsFilter({
    required BuildContext context,
    required List<ShiftDefinitionModel> shifts,
    required bool isArabic,
  }) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: Text(
              isArabic ? 'كل الورديات' : 'All Shifts',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _selectedShiftFilterId == null
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            selected: _selectedShiftFilterId == null,
            selectedColor: Color(AppColors.buttons),
            backgroundColor: Colors.white,
            onSelected: (_) {
              setState(() => _selectedShiftFilterId = null);
              if (_useSpecificDateLookup && _lookupDate != null) {
                _triggerSpecificDateLookup();
              }
            },
          ),
          const SizedBox(width: 8),
          ...shifts.map((shift) {
            final bool isSelected = _selectedShiftFilterId == shift.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8, left: 0),
              child: ChoiceChip(
                label: Text(
                  shift.name ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isSelected,
                selectedColor: Color(AppColors.buttons),
                backgroundColor: Colors.white,
                onSelected: (_) {
                  setState(() {
                    _selectedShiftFilterId = isSelected ? null : shift.id;
                  });
                  if (_useSpecificDateLookup && _lookupDate != null) {
                    _triggerSpecificDateLookup();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDepartmentScheduleCard({
    required BuildContext context,
    required List<SchedulerEmployeeModel> employees,
    required bool isArabic,
  }) {
    final dates = _buildCalendarDates();
    // Ensure `is_me: true` is always first
    final sortedEmployees = [
      ...employees.where((e) => e.isMe),
      ...employees.where((e) => !e.isMe),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () =>
                setState(() => _showDepartmentTable = !_showDepartmentTable),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.table_chart_outlined,
                      size: 19, color: Color(AppColors.buttons)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'جدول ورديات القسم (اضغط على الشيفت للاختيار)'
                          : 'Department Schedule (Tap shift to select)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.secondaryButton),
                      ),
                    ),
                  ),
                  Icon(
                    _showDepartmentTable
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          if (_showDepartmentTable && dates.isNotEmpty) ...[
            const Divider(height: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 42,
                dataRowMinHeight: 46,
                dataRowMaxHeight: 68,
                columnSpacing: 10,
                horizontalMargin: 12,
                headingRowColor: WidgetStateProperty.all(
                  Color(AppColors.cardBackground),
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      isArabic ? 'الموظف' : 'Employee',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...dates.map((dt) {
                    final dayLabel = DateFormat(
                            'EEE d/M', context.locale.languageCode)
                        .format(dt);
                    return DataColumn(
                      label: Text(
                        dayLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    );
                  }),
                ],
                rows: sortedEmployees.map((emp) {
                  final bool isMeRow = emp.isMe;
                  final bool isColleagueSelected = !isMeRow &&
                      _selectedColleague?.employeeId == emp.employeeId;

                  return DataRow(
                    color: WidgetStateProperty.all(
                      isMeRow
                          ? Color(AppColors.buttons).withOpacity(0.05)
                          : (isColleagueSelected
                              ? Colors.green.withOpacity(0.05)
                              : Colors.white),
                    ),
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: isMeRow
                              ? null
                              : () {
                                  setState(() {
                                    _selectedColleague = emp;
                                    _selectedColleagueAssignment = null;
                                  });
                                },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isMeRow)
                                Container(
                                  margin:
                                      const EdgeInsetsDirectional.only(end: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Color(AppColors.buttons),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isArabic ? 'أنت' : 'You',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 120),
                                child: Text(
                                  emp.name ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: (isMeRow || isColleagueSelected)
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isMeRow
                                        ? Color(AppColors.buttons)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ...dates.map((dt) {
                        final dateStr = DateFormat('yyyy-MM-dd').format(dt);
                        final dayAssignments = _filterAssignmentsByShift(
                          emp.assignments
                              .where((a) => a.formattedDateOnly == dateStr)
                              .toList(),
                        );

                        if (dayAssignments.isEmpty) {
                          return const DataCell(
                            Center(
                              child: Text(
                                '—',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          );
                        }

                        final assign = dayAssignments.first;
                        final bool isSelectedCell = isMeRow
                            ? (_selectedMyAssignment?.id == assign.id)
                            : (_selectedColleagueAssignment?.id == assign.id);

                        return DataCell(
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isMeRow) {
                                  _selectedMyAssignment = assign;
                                } else {
                                  _selectedColleague = emp;
                                  if (_isTwoWaySwap) {
                                    _useSpecificDateLookup = false;
                                    _selectedColleagueAssignment = assign;
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelectedCell
                                    ? Color(AppColors.buttons)
                                    : (isMeRow
                                        ? Color(AppColors.buttons)
                                            .withOpacity(0.12)
                                        : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelectedCell
                                      ? Color(AppColors.buttons)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    assign.shiftName ?? AppStrings.shifts.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelectedCell
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (assign
                                      .formattedStartTimeOnly.isNotEmpty) ...[
                                    Text(
                                      '${assign.formattedStartTimeOnly}-${assign.formattedEndTimeOnly}',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: isSelectedCell
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColleagueSourceToggle(
    BuildContext context,
    bool isArabic,
    ShiftChangeController provider,
  ) {
    return Row(
      children: [
        ChoiceChip(
          label: Text(
            isArabic ? 'من جدول الفترة' : 'From Schedule Range',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: !_useSpecificDateLookup ? Colors.white : Colors.black87,
            ),
          ),
          selected: !_useSpecificDateLookup,
          selectedColor: Color(AppColors.secondaryButton),
          backgroundColor: Colors.white,
          onSelected: (_) {
            setState(() {
              _useSpecificDateLookup = false;
              _selectedColleagueAssignment = null;
            });
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Text(
            isArabic ? 'بحث بيوم محدد' : 'Search Specific Date',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _useSpecificDateLookup ? Colors.white : Colors.black87,
            ),
          ),
          selected: _useSpecificDateLookup,
          selectedColor: Color(AppColors.secondaryButton),
          backgroundColor: Colors.white,
          onSelected: (_) {
            setState(() {
              _useSpecificDateLookup = true;
              _selectedColleagueAssignment = null;
            });
            if (_lookupDate != null) {
              _triggerSpecificDateLookup();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpecificDateLookupSection({
    required BuildContext context,
    required ShiftChangeController provider,
    required bool isArabic,
  }) {
    final dateText = _lookupDate != null
        ? DateFormat('EEE, d MMM yyyy', context.locale.languageCode)
            .format(_lookupDate!)
        : (isArabic
            ? 'اختر التاريخ لعرض ورديات الزميل'
            : 'Pick a date to load colleague shifts');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickSpecificColleagueDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded,
                    size: 18, color: Color(AppColors.buttons)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.search_rounded,
                    size: 18, color: Color(AppColors.buttons)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (provider.isColleagueAssignmentsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (provider.colleagueAssignmentsError != null &&
            provider.colleagueAssignmentsError!.isNotEmpty)
          _buildErrorBanner(provider.colleagueAssignmentsError!)
        else if (_lookupDate == null)
          _buildEmptyNotice(
            isArabic
                ? 'حدد تاريخ اليوم أو تاريخاً مستقبلياً لعرض ورديات الزميل القابلة للتبديل'
                : 'Select today or a future date to fetch colleague shift assignments.',
          )
        else if (provider.colleagueAssignments.isEmpty)
          _buildEmptyNotice(
            isArabic
                ? 'لا توجد ورديات متاحة لهذا الزميل في هذا التاريخ'
                : 'No selectable assignments found for this colleague on this date.',
          )
        else
          _buildAssignmentsHorizontalList(
            context: context,
            assignments: provider.colleagueAssignments,
            selected: _selectedColleagueAssignment,
            isArabic: isArabic,
            onSelect: (assignment) {
              setState(() {
                _selectedColleagueAssignment = assignment;
              });
            },
          ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5, color: Colors.red.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapSummaryBanner(BuildContext context, bool isArabic) {
    final myDate =
        _formatDateLabel(_selectedMyAssignment?.date ?? '', context);
    final colDate = _selectedColleagueAssignment != null
        ? _formatDateLabel(_selectedColleagueAssignment?.date ?? '', context)
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(AppColors.buttons).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(AppColors.buttons).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'ملخص طلب التبديل:' : 'Swap Summary:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: Color(AppColors.buttons),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• ${isArabic ? 'شيفتك' : 'Your Shift'}: ${_selectedMyAssignment?.shiftName ?? ''} ($myDate)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            _isTwoWaySwap
                ? '• ${isArabic ? 'مقابل شيفت الزميل' : 'With'} (${_selectedColleague?.name ?? ''}): ${_selectedColleagueAssignment != null ? '${_selectedColleagueAssignment!.shiftName ?? ''} ($colDate)' : (isArabic ? 'لم يتم الاختيار بعد' : 'Not selected yet')}'
                : '• ${isArabic ? 'تحويل إلى الزميل' : 'Transfer to'}: ${_selectedColleague?.name ?? ''}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(AppColors.buttons),
            shape: BoxShape.circle,
          ),
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: Color(AppColors.secondaryButton)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: AppStyles.titleTextContent(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: Color(AppColors.secondaryButton),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyNotice(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildAssignmentsHorizontalList({
    required BuildContext context,
    required List<ShiftAssignmentModel> assignments,
    required ShiftAssignmentModel? selected,
    required bool isArabic,
    required ValueChanged<ShiftAssignmentModel> onSelect,
  }) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: assignments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = assignments[index];
          final bool isSelected = selected?.id == item.id;
          final dateLabel = _formatDateLabel(item.date ?? '', context);
          final timeRange =
              '${item.formattedStartTimeOnly} - ${item.formattedEndTimeOnly}';

          return GestureDetector(
            onTap: () => onSelect(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 185,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(AppColors.buttons).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Color(AppColors.buttons)
                      : Colors.grey.shade200,
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.shiftName ?? AppStrings.shifts.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Color(AppColors.buttons)
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: Color(AppColors.buttons),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        timeRange,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColleaguesSelector({
    required BuildContext context,
    required List<SchedulerEmployeeModel> colleagues,
    required bool isArabic,
    required ShiftChangeController provider,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colleagues.map((emp) {
        final bool isSelected =
            _selectedColleague?.employeeId == emp.employeeId;
        return ChoiceChip(
          label: Text(
            '${emp.name ?? ''} (${emp.assignments.length})',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          selectedColor: Color(AppColors.buttons),
          backgroundColor: Colors.white,
          onSelected: (_) {
            setState(() {
              _selectedColleague = emp;
              _selectedColleagueAssignment = null;
            });
            provider.clearColleagueAssignmentsLookup();
            if (_useSpecificDateLookup && _lookupDate != null) {
              _triggerSpecificDateLookup();
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildSwapModeToggle(BuildContext context, bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isTwoWaySwap = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              decoration: BoxDecoration(
                color: _isTwoWaySwap ? Color(AppColors.buttons) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isTwoWaySwap
                      ? Color(AppColors.buttons)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 18,
                    color: _isTwoWaySwap ? Colors.white : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isArabic ? 'تبديل شيفت بشيفت' : 'Two-Way Swap',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color:
                            _isTwoWaySwap ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _isTwoWaySwap = false;
              _selectedColleagueAssignment = null;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
              decoration: BoxDecoration(
                color: !_isTwoWaySwap ? Color(AppColors.buttons) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_isTwoWaySwap
                      ? Color(AppColors.buttons)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: !_isTwoWaySwap ? Colors.white : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isArabic ? 'تنازل عن شيفت' : 'One-Way Transfer',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: !_isTwoWaySwap
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
