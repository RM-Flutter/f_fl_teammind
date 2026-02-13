import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';

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
    final balance = (annualDays / 12) * totalMonths;
    
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithBookmark(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(AppColors.dark),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
          onPressed: _goBack,
        ),
        title: AppStrings.vacationCalc2.tr(),
        titleStyle: TextStyle(
          color: Color(AppColors.dark),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        routeName: AppRoutes.vacationCalcScreen.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date of commencement of work
            _buildDropdownField(
              label: commencementDate != null
                  ? DateFormat('dd/MM/yyyy').format(commencementDate!)
                  : AppStrings.dateOfCommencement.tr(),
              onTap: () => _selectDate(context, true),
            ),
            
            const SizedBox(height: 16),
            
            // Today's date/Time of taking leave
            _buildDropdownField(
              label: leaveDate != null
                  ? DateFormat('dd/MM/yyyy').format(leaveDate!)
                  : AppStrings.todaysDateLeave.tr(),
              onTap: () => _selectDate(context, false),
            ),
            
            const SizedBox(height: 16),
            
            // Type of leave
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(AppStrings.typeOfLeave.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                  value: leaveType,
                  items: leaveTypes.map((type) {
                    final typeName = _getLeaveTypeName(type);
                    return DropdownMenuItem(
                      value: typeName,
                      child: Text(typeName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),),
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
            
            const SizedBox(height: 16),
            
            // Number of days agreed upon annually
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: AppStrings.numberOfDaysAnnually.tr(),
                  hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Calculate Button
            Center(
              child: ElevatedButton(
                onPressed: _calculateDays,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(AppColors.dark),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  AppStrings.calculateDays.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Result
            if (calculatedBalance != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.holidayBalance.tr(),
                      style: TextStyle(
                        color: Color(AppColors.dark),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    calculatedBalance!.toStringAsFixed(1),
                    style: TextStyle(
                      color: Color(AppColors.dark),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                AppStrings.vacationCalcNote.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
