import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/alert_service/alerts_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../controllers/overtime_requests_controller.dart';
import '../../../../core/widgets/searchable_dropdown_sheet.dart';
import 'package:app_test/features/requests/main_request_layout/controller/filter_controller.dart';

class AddOvertimeRequestScreen extends StatefulWidget {
  final bool isForEmployee;
  const AddOvertimeRequestScreen({super.key, this.isForEmployee = false});

  @override
  State<AddOvertimeRequestScreen> createState() => _AddOvertimeRequestScreenState();
}

class _AddOvertimeRequestScreenState extends State<AddOvertimeRequestScreen> {
  final _durationController = TextEditingController();
  DateTime? selectedDate;
  Map<String, dynamic>? selectedEmployee;
  String? selectEmpId;

  void _submit() async {
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
        context.pop();
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
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isForEmployee) ...[
                  _buildCardSection(
                    title: AppStrings.employeeName.tr(),
                    icon: Icons.person_outline,
                    child: SearchableDropdownSheet(
                      items: filterController.employees,
                      selectedValue: selectedEmployee,
                      nameKey: 'name',
                      hintText: AppStrings.employeeName.tr(),
                      hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 14),
                      height: 24,
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() {
                          selectedEmployee = value;
                          selectEmpId = value['id']?.toString();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                ],
                _buildCardSection(
                  title: AppStrings.date.tr(),
                  icon: Icons.calendar_today_outlined,
                  child: _buildDatePicker(),
                ),
                SizedBox(height: 24),
                _buildCardSection(
                  title: AppStrings.durationMinutes.tr(),
                  icon: Icons.timer_outlined,
                  child: _buildDurationField(),
                ),
                if (_durationController.text.isNotEmpty) ...[
                  SizedBox(height: 16),
                  _buildDurationPreview(),
                ],
                SizedBox(height: 48),
                _buildSubmitButton(provider),
                SizedBox(height: 20),
              ],
            ),
          );
        }
      ),
    ));
  }

  Widget _buildCardSection({required String title, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Color(AppColors.buttons)),
              SizedBox(width: 8),
              Text(
                title,
                style: AppStyles.titleTextContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(AppColors.secondaryButton).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
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
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.92,
                  ),
                  child: child!,
                ),
              ),
            );
          },
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
          });
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedDate != null
                  ? DateFormat('EEEE, d MMMM yyyy', context.locale.languageCode).format(selectedDate!)
                  : AppStrings.selectDate.tr(),
              style: AppStyles.darkContent(context).copyWith(
                fontSize: 15,
                fontWeight: selectedDate != null ? FontWeight.bold : FontWeight.normal,
                color: selectedDate != null ? Colors.black : Colors.grey.shade400,
              ),
            ),
          ),
          Icon(Icons.calendar_month, size: 18, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildDurationField() {
    return TextField(
      controller: _durationController,
      keyboardType: TextInputType.number,
      onChanged: (val) => setState(() {}),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: AppStrings.enterMinutes.tr(),
        hintStyle: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.normal),
        suffixText: AppStrings.minutes.tr(),
        suffixStyle: TextStyle(color: Colors.grey, fontSize: 13),
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );
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
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Color(AppColors.buttons).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: Color(AppColors.buttons)),
          SizedBox(width: 8),
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
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: provider.isActionLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppColors.buttons),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Color(AppColors.buttons).withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    );
  }
}
