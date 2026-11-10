import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';

import '../controllers/create_expense_claim_controller.dart';
import 'package:app_test/core/constants/app_design.dart';

class CreateExpenseClaimScreen extends StatefulWidget {
  const CreateExpenseClaimScreen({super.key});

  @override
  State<CreateExpenseClaimScreen> createState() =>
      _CreateExpenseClaimScreenState();
}

class _CreateExpenseClaimScreenState extends State<CreateExpenseClaimScreen> {
  late final CreateExpenseClaimController viewModel;

  // Available categories from API docs
  static const List<Map<String, String>> _categories = [
    {'value': 'supplies', 'label': 'Office Supplies'},
    {'value': 'travel', 'label': 'Travel'},
    {'value': 'food', 'label': 'Food'},
    {'value': 'maintenance', 'label': 'Maintenance'},
  ];

  @override
  void initState() {
    super.initState();
    viewModel = CreateExpenseClaimController();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return ChangeNotifierProvider<CreateExpenseClaimController>.value(
      value: viewModel,
      child: Consumer<CreateExpenseClaimController>(
        builder: (context, controller, child) {
          return TemplatePage(
            pageContext: context,
            title: 'create_expense_claim'.tr(),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page, vertical: AppSpacing.md),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reason (required)
                    _buildTextField(
                      controller: controller.reasonController,
                      hintText: 'reason'.tr(),
                      keyboardType: TextInputType.text,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'field_required'.tr()
                          : null,
                    ),
                    gapH14,
                    // Money value (required)
                    _buildTextField(
                      controller: controller.moneyValueController,
                      hintText: 'total_amount'.tr(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'field_required'.tr();
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'invalid_value'.tr();
                        }
                        return null;
                      },
                    ),
                    gapH14,
                    // Date (optional, default: today)
                    _buildTextField(
                      controller: controller.dateFromController,
                      hintText: 'expense_date'.tr(),
                      keyboardType: TextInputType.text,
                      suffixIcon: const Icon(Icons.calendar_today),
                      readOnly: true,
                      onTap: () => _pickDate(context, controller),
                    ),
                    gapH14,
                    // Category (optional)
                    _buildCategoryDropdown(context, controller, isArabic),
                    gapH14,
                    // Notes (optional)
                    _buildTextField(
                      controller: controller.notesController,
                      hintText: 'notes'.tr(),
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      minLines: 2,
                    ),
                    gapH14,
                    // Files (optional: jpg, jpeg, png, webp, pdf)
                    _buildFilePicker(context, controller),
                    gapH24,
                    Center(
                      child: controller.isLoading
                          ? const CircularProgressIndicator()
                          : CustomElevatedButton(
                              backgroundColor: Color(AppColors.secondaryButton),
                              titleSize: AppSizes.s14,
                              radius: AppSizes.s24,
                              title: 'submit'.tr(),
                              onPressed: () async {
                                bool success =
                                    await controller.submitRequest(context);
                                if (success && mounted) {
                                  context.pop(true);
                                }
                              },
                            ),
                    ),
                    gapH24,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(
      BuildContext context, CreateExpenseClaimController controller) async {
    final now = DateTime.now();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 300,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: now,
            maximumDate: now,
            onDateTimeChanged: (date) {
              controller.setDateFrom(
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
            },
          ),
        ),
      );
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 2),
        lastDate: now,
      );
      if (picked != null) {
        controller.setDateFrom(
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
      }
    }
  }

  Widget _buildCategoryDropdown(BuildContext context,
      CreateExpenseClaimController controller, bool isArabic) {
    final Map<String, String> categoryLabelsAr = {
      'supplies': 'مستلزمات',
      'travel': 'سفر',
      'food': 'طعام',
      'maintenance': 'صيانة',
    };

    return DropdownButtonFormField<String>(
      value: controller.categoryController.text.isEmpty
          ? null
          : controller.categoryController.text,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: InputDecoration(hintText: 'category'.tr()),
      items: _categories.map((cat) {
        final label = isArabic
            ? (categoryLabelsAr[cat['value']] ?? cat['label']!)
            : cat['label']!;
        return DropdownMenuItem<String>(
          value: cat['value'],
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) controller.setCategory(value);
      },
    );
  }

  Widget _buildFilePicker(
      BuildContext context, CreateExpenseClaimController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'attachments'.tr(),
          style: AppStyles.primaryContent(context)
              .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        gapH14,
        for (int idx = 0; idx < controller.attachments.length; idx++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file_rounded,
                    color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.attachments[idx].files.first.name,
                    style: AppStyles.content(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.red, size: 18),
                  onPressed: () => controller.removeAttachment(idx),
                ),
              ],
            ),
          ),
          gapH8,
        ],
        TextFormField(
          readOnly: true,
          onTap: () async {
            final picker = ImagePicker();
            final List<XFile> images = await picker.pickMultiImage();
            if (images.isNotEmpty) {
              List<PlatformFile> platformFiles = [];
              for (var image in images) {
                final file = await image.readAsBytes();
                platformFiles.add(PlatformFile(
                  path: image.path,
                  name: image.name,
                  size: file.length,
                  bytes: file,
                ));
              }
              controller.addAttachment(FilePickerResult(platformFiles));
            }
          },
          decoration: InputDecoration(
            hintText: 'add_attachment'.tr(),
            suffixIcon: const Icon(Icons.attach_file_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLines,
    int? minLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      maxLines: maxLines ?? 1,
      minLines: minLines,
      decoration: InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
    );
  }
}
