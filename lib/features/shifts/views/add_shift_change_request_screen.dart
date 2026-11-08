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
import 'package:app_test/core/constants/app_design.dart';

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
  ShiftAssignmentModel? _selectedColleagueAssignment;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarFrom = DateTime(now.year, now.month, now.day);
    _calendarTo = _calendarFrom.add(const Duration(days: 14));

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  Future<void> _submit(ShiftChangeController provider) async {
    if (_selectedMyAssignment == null || _selectedMyAssignment!.id == null) {
      AlertsService.error(
        context: context,
        message: 'please_select_your_shift_assignment_to_swap'.tr(),
        title: 'error'.tr(),
      );
      return;
    }

    if (_selectedColleague == null || _selectedColleague!.employeeId == null) {
      AlertsService.error(
        context: context,
        message: 'please_select_a_colleague_from_your_department'.tr(),
        title: 'error'.tr(),
      );
      return;
    }

    if (_selectedColleagueAssignment == null ||
        _selectedColleagueAssignment!.id == null) {
      AlertsService.error(
        context: context,
        message: 'please_select_the_colleague_shift_to_swap'.tr(),
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
      receiverShiftAssignmentId: _selectedColleagueAssignment!.id!,
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
          tooltip: 'change_date_range'.tr(),
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
              me?.assignments ?? [];

          final List<ShiftAssignmentModel> colleagueCalendarAssignments =
              _selectedColleague?.assignments ?? [];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Backend error banner if status: false
                if (provider.calendarErrorMessage != null &&
                    provider.calendarErrorMessage!.isNotEmpty) ...[
                  _buildErrorBanner(provider.calendarErrorMessage!),
                  const SizedBox(height: 16),
                ],

                // Step 1: Select My Shift Assignment
                _buildSectionHeader(
                  context: context,
                  stepNumber: '1',
                  title: 'select_your_shift_assignment'.tr(),
                  icon: Icons.event_available_rounded,
                ),
                const SizedBox(height: 10),
                if (myAssignments.isEmpty)
                  _buildEmptyNotice('no_selectable_shift_assignments_found_for_you'.tr(),
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
                  title: 'select_colleague_same_department'.tr(),
                  icon: Icons.people_alt_outlined,
                ),
                const SizedBox(height: 10),
                if (colleagues.isEmpty)
                  _buildEmptyNotice('no_colleagues_found_in_your_department_schedule'.tr(),
                  )
                else
                  _buildColleaguesSelector(
                    context: context,
                    colleagues: colleagues,
                    isArabic: isArabic,
                  ),

                const SizedBox(height: 24),

                // Step 3: Colleague Shift to Swap (Always Two-Way Swap)
                _buildSectionHeader(
                  context: context,
                  stepNumber: '3',
                  title: 'colleague_shift_to_swap'.tr(),
                  icon: Icons.swap_horiz_rounded,
                ),
                const SizedBox(height: 10),
                if (_selectedColleague == null)
                  _buildEmptyNotice('select_a_colleague_first_to_view_their'.tr(),
                  )
                else if (colleagueCalendarAssignments.isEmpty)
                  _buildEmptyNotice('this_colleague_has_no_available_shifts_in'.tr(),
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
                    borderRadius: BorderRadius.circular(AppRadius.md),
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
                      hintText: 'enter_reason_for_shift_change_request'.tr(),
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
                  height: AppButtonSize.height,
                  child: ElevatedButton(
                    onPressed: provider.isActionLoading
                        ? null
                        : () => _submit(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    child: provider.isActionLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppStrings.sendRequest.tr(),
                            style: AppStyles.whiteContent(context).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
              fontWeight: FontWeight.bold,
              fontSize: 13,
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
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildColleaguesSelector({
    required BuildContext context,
    required List<SchedulerEmployeeModel> colleagues,
    required bool isArabic,
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
          },
        );
      }).toList(),
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
                borderRadius: BorderRadius.circular(AppRadius.md),
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
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Color(AppColors.buttons).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('swap_summary'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: Color(AppColors.buttons),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• ${'your_shift'.tr()}: ${_selectedMyAssignment?.shiftName ?? ''} ($myDate)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '• ${'with'.tr()} (${_selectedColleague?.name ?? ''}): ${_selectedColleagueAssignment != null ? '${_selectedColleagueAssignment!.shiftName ?? ''} ($colDate)' : ('not_selected_yet'.tr())}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(AppRadius.md),
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
}
