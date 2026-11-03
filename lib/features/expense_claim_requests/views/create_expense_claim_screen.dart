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
import 'package:app_test/core/widgets/glassmorphism_card.widget.dart';

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
              padding: EdgeInsets.all(AppSizes.s16),
              child: GlassmorphismCard(
                padding: EdgeInsets.all(AppSizes.s24),
                backgroundColor: Colors.white,
                opacity: 0.9,
                boxShadow: [
                  BoxShadow(
                    color: Color(AppColors.buttonColor).withOpacity(0.08),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 15),
                  ),
                ],
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Header ───
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(AppColors.buttons),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.receipt_long_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'create_expense_claim'.tr(),
                              style: AppStyles.heading(context)
                                  .copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ─── Reason (REQUIRED) ───
                      _buildTextField(
                        controller: controller.reasonController,
                        hintText: 'reason'.tr(),
                        keyboardType: TextInputType.text,
                        prefixIcon: Icon(Icons.notes_rounded,
                            color: Color(AppColors.buttons)),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'field_required'.tr()
                                : null,
                      ),
                      const SizedBox(height: 20),

                      // ─── Money Value (REQUIRED) ───
                      _buildTextField(
                        controller: controller.moneyValueController,
                        hintText: 'total_amount'.tr(),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icon(Icons.monetization_on_outlined,
                            color: Color(AppColors.buttons)),
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
                      const SizedBox(height: 20),

                      // ─── Date From (OPTIONAL, default: today) ───
                      _buildTextField(
                        controller: controller.dateFromController,
                        hintText: 'expense_date'.tr(),
                        keyboardType: TextInputType.text,
                        prefixIcon: Icon(Icons.calendar_month_rounded,
                            color: Color(AppColors.buttons)),
                        readOnly: true,
                        onTap: () => _pickDate(context, controller),
                      ),
                      const SizedBox(height: 20),

                      // ─── Category (OPTIONAL) ───
                      _buildCategoryDropdown(
                          context, controller, isArabic),
                      const SizedBox(height: 20),

                      // ─── Notes (OPTIONAL) ───
                      _buildTextField(
                        controller: controller.notesController,
                        hintText: 'notes'.tr(),
                        keyboardType: TextInputType.multiline,
                        prefixIcon: Icon(Icons.description_outlined,
                            color: Color(AppColors.buttons)),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // ─── Files (OPTIONAL: jpg, jpeg, png, webp, pdf) ───
                      _buildFilePicker(context, controller),

                      const SizedBox(height: 40),

                      // ─── Submit Button ───
                      controller.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(AppColors.buttons),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(AppColors.buttons)
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.md)),
                                ),
                                onPressed: () async {
                                  bool success =
                                      await controller.submitRequest(context);
                                  if (success && mounted) {
                                    context.pop(true);
                                  }
                                },
                                child: Text(
                                  'submit'.tr(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                    ],
                  ),
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
      decoration: InputDecoration(
        labelText: 'category'.tr(),
        labelStyle: AppStyles.content(context)
            .copyWith(color: Colors.grey.shade600),
        prefixIcon:
            Icon(Icons.category_outlined, color: Color(AppColors.buttons)),
        filled: true,
        fillColor: Color(AppColors.buttonSecondaryColor).withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              BorderSide(color: Color(AppColors.buttons), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
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
        GestureDetector(
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
              FilePickerResult result = FilePickerResult(platformFiles);
              controller.addAttachment(result);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Color(AppColors.buttonSecondaryColor).withOpacity(0.03),
              border: Border.all(
                  color: Color(AppColors.buttonSecondaryColor).withOpacity(0.3),
                  width: 1.5,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttonSecondaryColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cloud_upload_rounded,
                      color: Color(AppColors.buttonSecondaryColor), size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'add_attachment'.tr(),
                  style: AppStyles.content(context).copyWith(
                    color: Color(AppColors.buttonSecondaryColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'jpg, jpeg, png, webp, pdf',
                  style: AppStyles.content(context).copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (controller.attachments.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...controller.attachments.asMap().entries.map((entry) {
            int idx = entry.key;
            var file = entry.value.files.first;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file_rounded,
                      color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      file.name,
                      style: AppStyles.content(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.red),
                    onPressed: () => controller.removeAttachment(idx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required Widget prefixIcon,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      maxLines: maxLines ?? 1,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppStyles.content(context).copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: AppStyles.content(context)
            .copyWith(color: Colors.grey.shade600),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Color(AppColors.buttonSecondaryColor).withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Color(AppColors.buttons), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              BorderSide(color: Color(AppColors.failureRed), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              BorderSide(color: Color(AppColors.failureRed), width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
