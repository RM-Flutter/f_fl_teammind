import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_elevated_button.widget.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/alert_service/alerts_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../controllers/overtime_requests_controller.dart';
import '../../../../core/widgets/searchable_dropdown_sheet.dart';
import 'package:app_test/features/requests/main_request_layout/controller/filter_controller.dart';
import 'package:app_test/core/constants/app_design.dart';

class AddOvertimeRequestScreen extends StatefulWidget {
  final bool isForEmployee;
  const AddOvertimeRequestScreen({super.key, this.isForEmployee = false});

  @override
  State<AddOvertimeRequestScreen> createState() => _AddOvertimeRequestScreenState();
}

class _AddOvertimeRequestScreenState extends State<AddOvertimeRequestScreen> {
  final _durationController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? selectedDate;
  Map<String, dynamic>? selectedEmployee;
  String? selectEmpId;

  Future<void> _submit() async {
    if (selectedDate == null) {
      AlertsService.error(
        context: context,
        message: AppStrings.selectDate.tr(),
        title: 'error'.tr(),
      );
      return;
    }
    if (_durationController.text.isEmpty) {
      AlertsService.error(
        context: context,
        message: AppStrings.durationIsRequired.tr(),
        title: 'error'.tr(),
      );
      return;
    }

    final provider = Provider.of<OvertimeRequestsProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
    // Normalize Arabic/Eastern Arabic numerals to Western Arabic numerals
    final normalizedDuration = _normalizeNumerals(_durationController.text.trim());
    // Validate that the normalized value is a valid positive integer
    final parsedDuration = int.tryParse(normalizedDuration);
    if (parsedDuration == null || parsedDuration <= 0) {
      AlertsService.error(
        context: context,
        message: AppStrings.durationIsRequired.tr(),
        title: 'error'.tr(),
      );
      return;
    }

    bool success = false;
    if (widget.isForEmployee) {
      if (selectEmpId == null) {
        AlertsService.error(
          context: context,
          message: AppStrings.employeeName.tr(),
          title: 'error'.tr(),
        );
        return;
      }
      success = await provider.addManagerRequest(context, dateStr, normalizedDuration, selectEmpId!);
    } else {
      success = await provider.addRequest(context, dateStr, normalizedDuration);
    }

    if (success) {
      if (context.mounted) {
        AlertsService.success(
          context: context,
          message: 'request_sent_successfully'.tr(),
          title: 'success'.tr(),
        );
        context.pop(true);
      }
    }
  }

  /// Converts Arabic-Indic (٠١٢...) and Eastern Arabic numerals to Western Arabic (012...)
  String _normalizeNumerals(String input) {
    return input.replaceAllMapped(RegExp(r'[\u0660-\u0669\u06f0-\u06f9]'), (match) {
      final ch = match.group(0)!.codeUnitAt(0);
      if (ch >= 0x0660 && ch <= 0x0669) {
        return (ch - 0x0660).toString();
      } else {
        return (ch - 0x06F0).toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      pageContext: context,
      title: AppStrings.addOvertimeRequest.tr(),
      routeName: AppRoutes.addOvertimeRequestScreen.name,
      body: ChangeNotifierProvider(
        create: (context) {
          final controller = FilterController();
          if (widget.isForEmployee) controller.getEmployees(context: context, underMyManagement: true);
          return controller;
        },
        child: Consumer2<OvertimeRequestsProvider, FilterController>(
          builder: (context, provider, filterController, child) {
            return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isForEmployee) ...[
                  SearchableDropdownSheet(
                    items: filterController.employees,
                    selectedValue: selectedEmployee,
                    nameKey: 'name',
                    hintText: AppStrings.employeeName.tr(),
                    onChanged: (value) {
                      setState(() {
                        selectedEmployee = value;
                        selectEmpId = value['id']?.toString();
                      });
                    },
                  ),
                  gapH14,
                ],
                TextFormField(
                  readOnly: true,
                  controller: _dateController,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    hintText: AppStrings.selectDate.tr(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                gapH14,
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: AppStrings.durationMinutes.tr(),
                    suffixText: AppStrings.minutes.tr(),
                  ),
                ),
                if (_durationController.text.isNotEmpty) ...[
                  gapH14,
                  _buildDurationPreview(),
                ],
                gapH24,
                Center(child: _buildSubmitButton(provider)),
                gapH24,
              ],
            ),
          );
        }
      ),
    ));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text =
            DateFormat('EEEE, d MMMM yyyy', context.locale.languageCode).format(picked);
      });
    }
  }

  Widget _buildDurationPreview() {
    int totalMinutes = int.tryParse(_durationController.text) ?? 0;
    if (totalMinutes <= 0) return const SizedBox.shrink();

    int hoursCount = totalMinutes ~/ 60;
    int minutesCount = totalMinutes % 60;

    String text = "";
    if (hoursCount > 0) {
      text += "$hoursCount ${AppStrings.hours.tr()}";
    }
    if (minutesCount > 0) {
      if (text.isNotEmpty) text += " ";
      text += "$minutesCount ${AppStrings.minutes.tr()}";
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.s4),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s10),
      decoration: BoxDecoration(
        color: Color(AppColors.buttons).withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: Color(AppColors.buttons)),
          SizedBox(width: AppSizes.s8),
          Text(
            text,
            style: AppStyles.primaryContent(context).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.buttons),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(OvertimeRequestsProvider provider) {
    if (provider.isActionLoading) return const CircularProgressIndicator();
    return CustomElevatedButton(
      backgroundColor: Color(AppColors.secondaryButton),
      titleSize: AppSizes.s14,
      radius: AppSizes.s24,
      title: AppStrings.sendRequest.tr(),
      onPressed: _submit,
    );
  }
}
