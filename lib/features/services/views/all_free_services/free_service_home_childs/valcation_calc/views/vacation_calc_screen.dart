import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_field_shell.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_design.dart';

class VacationCalcScreen extends StatefulWidget {
  const VacationCalcScreen({super.key});

  @override
  State<VacationCalcScreen> createState() => _VacationCalcScreenState();
}

class _VacationCalcScreenState extends State<VacationCalcScreen> {
  DateTime? commencementDate;
  DateTime? leaveDate;
  String? leaveType;
  final TextEditingController _daysController = TextEditingController();
  double? calculatedBalance;

  // أنواع الإجازات الثابتة مع مفاتيح الترجمة
  List<Map<String, dynamic>> get leaveTypes => [
    {'key': AppStrings.annualLeave, 'defaultDays': 21},
    {'key': AppStrings.casualLeave, 'defaultDays': 7},
    {'key': AppStrings.otherLeave, 'defaultDays': 0},
  ];

  // الحصول على اسم النوع حسب اللغة
  String _getLeaveTypeName(Map<String, dynamic> type) {
    // type['key'] نوعه dynamic، فلازم نحوله String عشان امتداد tr يشتغل عليه بشكل ثابت
    final String key = type['key'] as String;
    return key.tr();
  }

  // الحصول على عدد الأيام الافتراضي للنوع المحدد
  int _getDefaultDaysForType(String? selectedType) {
    if (selectedType == null) return 0;
    final type = leaveTypes.firstWhere(
      (t) => _getLeaveTypeName(t) == selectedType,
      orElse: () => leaveTypes.last,
    );
    return type['defaultDays'] as int;
  }

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _calculateDays() {
    if (commencementDate == null || leaveDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectBothDates.tr())),
      );
      return;
    }

    // الحصول على عدد الأيام السنوية (من الحقل أو الافتراضي)
    final annualDays = int.tryParse(_daysController.text) ?? 
                       (leaveType != null ? _getDefaultDaysForType(leaveType) : 21);
    
    // حساب عدد الأشهر الفعلية
    DateTime startDate = commencementDate!;
    final endDate = leaveDate!;
    
    // تقريب تاريخ البدء: إذا لم يكن من اليوم الأول من الشهر، نعتبره من أول يوم من الشهر التالي
    if (startDate.day != 1) {
      // الانتقال لأول يوم من الشهر التالي
      if (startDate.month == 12) {
        startDate = DateTime(startDate.year + 1, 1, 1);
      } else {
        startDate = DateTime(startDate.year, startDate.month + 1, 1);
      }
    }
    
    // حساب الفرق بالسنوات والأشهر
    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;
    
    // حساب عدد الأشهر الكاملة (من نفس اليوم في كل شهر)
    // مثال: من 1/2 إلى 1/7 = 5 أشهر كاملة
    int fullMonths = (years * 12) + months;
    
    // إذا كان يوم الانتهاء قبل يوم البدء، نطرح شهر كامل
    // مثال: من 1/2 إلى 15/7 = 5 أشهر كاملة + جزء من شهر يوليو
    if (endDate.day < startDate.day) {
      fullMonths--;
    }
    
    // حساب جزء الشهر الإضافي (الأيام المتبقية)
    double monthFraction = 0.0;
    if (endDate.day >= startDate.day) {
      // مثال: من 1/7 إلى 19/7 = 18 يوم إضافي
      final remainingDays = endDate.day - startDate.day;
      // عدد أيام الشهر الحالي (شهر الانتهاء)
      final daysInEndMonth = DateTime(endDate.year, endDate.month + 1, 0).day;
      monthFraction = remainingDays / daysInEndMonth;
    } else {
      // إذا كان يوم الانتهاء قبل يوم البدء، نحسب الأيام المتبقية من الشهر السابق
      final daysInEndMonth = DateTime(endDate.year, endDate.month + 1, 0).day;
      final remainingDays = endDate.day + (daysInEndMonth - startDate.day);
      monthFraction = remainingDays / daysInEndMonth;
    }
    
    // إجمالي الأشهر (عدد صحيح + جزء من الشهر)
    double totalMonths = fullMonths + monthFraction;
    
    // الحساب: (عدد أيام الإجازة السنوية ÷ 12) × عدد الأشهر الفعلية
    double balance = (annualDays / 12) * totalMonths;
    if (balance < 0) {
      balance = 0.0;
    }
    
    setState(() {
      calculatedBalance = balance;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isCommencement) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isCommencement) {
          commencementDate = picked;
        } else {
          leaveDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    return Scaffold(
      backgroundColor: Color(AppColors.background),
      appBar: AppBarWithBookmark(
        backgroundColor: Color(AppColors.background),
        elevation: 0,
        leading: AppBackButton(onPressed: _goBack),
        title: AppStrings.vacationCalc2.tr(),
        centerTitle: true,
        routeName: AppRoutes.vacationCalcScreen.name,
      ),
      body: AppContentWidth(
        child: SingleChildScrollView(
          padding: AppSpacing.listPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppResponsiveGrid(
                compact: 1,
                medium: 2,
                expanded: 2,
                children: [
                  _dateField(
                text: commencementDate != null
                    ? DateFormat('dd/MM/yyyy').format(commencementDate!)
                    : AppStrings.dateOfCommencement.tr(),
                filled: commencementDate != null,
                onTap: () => _selectDate(context, true),
              ),
                  _dateField(
                text: leaveDate != null
                    ? DateFormat('dd/MM/yyyy').format(leaveDate!)
                    : AppStrings.todaysDateLeave.tr(),
                filled: leaveDate != null,
                onTap: () => _selectDate(context, false),
              ),
                  AppFieldShell(
                contentPadding: 0,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: AppField.horizontalPadding),
                    focusColor: Colors.transparent,
                    isExpanded: true,
                    icon: AppFieldShell.icon(Icons.keyboard_arrow_down_rounded),
                    hint: Text(AppStrings.typeOfLeave.tr(), style: AppField.hintStyle),
                    value: leaveType,
                    items: leaveTypes.map((type) {
                      final typeName = _getLeaveTypeName(type);
                      return DropdownMenuItem(
                        value: typeName,
                        child: Text(typeName, style: AppField.valueStyle),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        leaveType = value;
                        // تحديث عدد الأيام الافتراضي عند تغيير النوع
                        final defaultDays = _getDefaultDaysForType(value);
                        _daysController.text = defaultDays > 0 ? defaultDays.toString() : '';
                      });
                    },
                  ),
                ),
              ),
                  AppFieldShell(
                child: TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  style: AppField.valueStyle,
                  decoration: InputDecoration(
                    hintText: AppStrings.numberOfDaysAnnually.tr(),
                    hintStyle: AppField.hintStyle,
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              // Calculate button: the same primary button as the filter sheets and forms.
              SizedBox(
                height: AppButtonSize.height,
                child: ElevatedButton(
                  onPressed: _calculateDays,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: AppButtonSize.padding,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  child: Text(
                    AppStrings.calculateDays.tr(),
                    style: const TextStyle(
                      fontSize: AppButtonSize.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Result
              if (calculatedBalance != null) ...[
                const SizedBox(height: AppSpacing.section),
                AppCard(
                  animateIn: true,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(Icons.beach_access_outlined, color: accent, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          AppStrings.holidayBalance.tr(),
                          style: AppStyles.heading(context)
                              .copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        calculatedBalance!.toStringAsFixed(1),
                        style: AppStyles.heading(context)
                            .copyWith(fontSize: 28, fontWeight: FontWeight.w700, color: accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: AppField.iconColor),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        AppStrings.vacationCalcNote.tr(),
                        style: AppStyles.greyContent(context).copyWith(fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// A date picker field: the hint when nothing is picked, the date when it is.
  Widget _dateField({
    required String text,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return AppFieldShell(
      onTap: onTap,
      trailingIcon: Icons.calendar_today_outlined,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: filled ? AppField.valueStyle : AppField.hintStyle,
      ),
    );
  }
}
