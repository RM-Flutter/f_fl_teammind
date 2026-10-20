import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';

class AddManualPointModal extends StatefulWidget {
  final Function(String label) onSubmit;

  const AddManualPointModal({super.key, required this.onSubmit});

  static Future<void> show(BuildContext context, {required Function(String label) onSubmit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddManualPointModal(onSubmit: onSubmit),
    );
  }

  @override
  State<AddManualPointModal> createState() => _AddManualPointModalState();
}

class _AddManualPointModalState extends State<AddManualPointModal> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _quickSuggestionsAr = [
    'وصلت عند العميل 📍',
    'انتهاء الاجتماع 🤝',
    'بدء المعاينة الميدانية 🔍',
    'تسليم العقد والمستندات 📄',
    'توقف للاستراحة ☕',
  ];

  final List<String> _quickSuggestionsEn = [
    'Arrived at Client 📍',
    'Meeting Ended 🤝',
    'Field Inspection Started 🔍',
    'Contract & Documents Handover 📄',
    'Short Break ☕',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(bool isAr) {
    final text = _controller.text.trim();
    final defaultLabel = isAr ? 'نقطة مسجلة يدويًا' : 'Manual Point';
    widget.onSubmit(text.isEmpty ? defaultLabel : text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);
    final suggestions = isAr ? _quickSuggestionsAr : _quickSuggestionsEn;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 16,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(AppColors.divider),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(AppColors.buttons).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_location_alt_rounded, color: Color(AppColors.buttons), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'تسجيل نقطة رئيسية يدويًا' : 'Record Milestone Manually',
                      style: AppStyles.heading(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.titleText),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr
                          ? 'تُسجل فورًا وتُرسل لإشعار الإدارة بمحطة وصولك'
                          : 'Recorded instantly and notifies management of your arrival',
                      style: AppStyles.subtitleContent(context).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick suggestions
          Text(
            isAr ? 'مقترحات سريعة:' : 'Quick Suggestions:',
            style: AppStyles.content(context).copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xff606060),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ActionChip(
                    backgroundColor: Color(AppColors.cardBackground),
                    side: BorderSide(color: Color(AppColors.border)),
                    label: Text(
                      suggestion,
                      style: AppStyles.content(context).copyWith(fontSize: 11),
                    ),
                    onPressed: () {
                      _controller.text = suggestion;
                      setState(() {});
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Text input
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: isAr
                  ? 'اكتب وصف النقطة أو المحطة (اختياري)...'
                  : 'Enter stop description or note (optional)...',
              hintStyle: AppStyles.hintContent(context).copyWith(fontSize: 12),
              filled: true,
              fillColor: Color(AppColors.cardBackground),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(AppColors.border)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(AppColors.border)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(AppColors.buttons)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    side: BorderSide(color: Color(AppColors.border)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    isAr ? 'إلغاء' : 'Cancel',
                    style: AppStyles.content(context).copyWith(color: const Color(0xff606060)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.buttons),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                  ),
                  onPressed: () => _submit(isAr),
                  icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                  label: Text(
                    isAr ? 'تسجيل النقطة الآن 📍' : 'Record Milestone 📍',
                    style: AppStyles.whiteContent(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
