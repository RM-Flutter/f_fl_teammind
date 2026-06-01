import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../controllers/overtime_requests_controller.dart';

class AddOvertimeRequestScreen extends StatefulWidget {
  const AddOvertimeRequestScreen({super.key});

  @override
  State<AddOvertimeRequestScreen> createState() => _AddOvertimeRequestScreenState();
}

class _AddOvertimeRequestScreenState extends State<AddOvertimeRequestScreen> {
  final _durationController = TextEditingController();
  DateTime? selectedDate;

  void _submit() async {
    if (selectedDate == null || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.dataIsRequired.tr())));
      return;
    }

    final provider = Provider.of<OvertimeRequestsProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final success = await provider.addRequest(context, dateStr, _durationController.text);
    
    if (success) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      pageContext: context,
      title: AppStrings.addOvertimeRequest.tr(),
      routeName: AppRoutes.addOvertimeRequestScreen.name,
      body: Consumer<OvertimeRequestsProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardSection(
                  title: AppStrings.date.tr(),
                  icon: Icons.calendar_today_outlined,
                  child: _buildDatePicker(),
                ),
                SizedBox(height: 24.h),
                _buildCardSection(
                  title: AppStrings.durationMinutes.tr(),
                  icon: Icons.timer_outlined,
                  child: _buildDurationField(),
                ),
                if (_durationController.text.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _buildDurationPreview(),
                ],
                SizedBox(height: 48.h),
                _buildSubmitButton(provider),
                SizedBox(height: 20.h),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildCardSection({required String title, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Row(
            children: [
              Icon(icon, size: 18.r, color: Color(AppColors.buttons)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: AppStyles.titleTextContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: Color(AppColors.secondaryButton).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
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
              child: child!,
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
                  ? DateFormat('EEEE, d MMMM yyyy').format(selectedDate!) 
                  : AppStrings.selectDate.tr(),
              style: AppStyles.darkContent(context).copyWith(
                fontSize: 15.sp,
                fontWeight: selectedDate != null ? FontWeight.bold : FontWeight.normal,
                color: selectedDate != null ? Colors.black : Colors.grey.shade400,
              ),
            ),
          ),
          Icon(Icons.calendar_month, size: 18.r, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildDurationField() {
    return TextField(
      controller: _durationController,
      keyboardType: TextInputType.number,
      onChanged: (val) => setState(() {}),
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: AppStrings.enterMinutes.tr(),
        hintStyle: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.normal),
        suffixText: AppStrings.minutes.tr(),
        suffixStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
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
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Color(AppColors.buttons).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16.r, color: Color(AppColors.buttons)),
          SizedBox(width: 8.w),
          Text(
            text,
            style: AppStyles.primaryContent(context).copyWith(
              fontSize: 14.sp,
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
      height: 55.h,
      child: ElevatedButton(
        onPressed: provider.isActionLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppColors.buttons),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Color(AppColors.buttons).withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        ),
        child: provider.isActionLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                AppStrings.sendRequest.tr(),
                style: AppStyles.whiteContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
      ),
    );
  }
}
