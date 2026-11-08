import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/widgets/glassmorphism_card.widget.dart';

import '../controllers/update_expense_claim_controller.dart';
import '../shared/models/expense_claim_model.dart';
import 'package:app_test/core/constants/app_design.dart';

class UpdateExpenseClaimScreen extends StatefulWidget {
  final ExpenseClaimModel existingRequest;

  const UpdateExpenseClaimScreen({
    super.key,
    required this.existingRequest,
  });

  @override
  State<UpdateExpenseClaimScreen> createState() =>
      _UpdateExpenseClaimScreenState();
}

class _UpdateExpenseClaimScreenState extends State<UpdateExpenseClaimScreen> {
  late final UpdateExpenseClaimController viewModel;

  static const List<Map<String, String>> _categories = [
    {'value': 'supplies', 'label': 'Office Supplies'},
    {'value': 'travel', 'label': 'Travel'},
    {'value': 'food', 'label': 'Food'},
    {'value': 'maintenance', 'label': 'Maintenance'},
  ];

  @override
  void initState() {
    super.initState();
    viewModel = UpdateExpenseClaimController(
      requestId: widget.existingRequest.id!,
      existingRequest: widget.existingRequest,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return ChangeNotifierProvider<UpdateExpenseClaimController>.value(
      value: viewModel,
      child: Consumer<UpdateExpenseClaimController>(
        builder: (context, controller, child) {
          return TemplatePage(
            pageContext: context,
            title: 'edit_expense_claim'.tr(),
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
                            child: const Icon(Icons.edit_note_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'edit_expense_claim'.tr(),
                                  style: AppStyles.heading(context).copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '#${widget.existingRequest.id}',
                                  style: AppStyles.content(context).copyWith(
                                      color: Colors.grey.shade500,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ─── Reason (OPTIONAL on update) ───
                      _buildTextField(
                        context: context,
                        controller: controller.reasonController,
                        hintText: 'reason'.tr(),
                        keyboardType: TextInputType.text,
                        prefixIcon: Icon(Icons.notes_rounded,
                            color: Color(AppColors.buttons)),
                      ),
                      const SizedBox(height: 20),

                      // ─── Money Value (OPTIONAL on update) ───
                      _buildTextField(
                        context: context,
                        controller: controller.moneyValueController,
                        hintText: 'total_amount'.tr(),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: Icon(Icons.monetization_on_outlined,
                            color: Color(AppColors.buttons)),
                        validator: (v) {
                          if (v != null &&
                              v.trim().isNotEmpty &&
                              double.tryParse(v.trim()) == null) {
                            return 'invalid_value'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // ─── Date From (OPTIONAL on update) ───
                      _buildTextField(
                        context: context,
                        controller: controller.dateFromController,
                        hintText: 'expense_date'.tr(),
                        keyboardType: TextInputType.text,
                        prefixIcon: Icon(Icons.calendar_month_rounded,
                            color: Color(AppColors.buttons)),
                        readOnly: true,
                        onTap: () => _pickDate(context, controller),
                      ),
                      const SizedBox(height: 20),

                      // ─── Category (OPTIONAL on update) ───
                      _buildCategoryDropdown(
                          context, controller, isArabic),
                      const SizedBox(height: 20),

                      // ─── Notes (OPTIONAL on update) ───
                      _buildTextField(
                        context: context,
                        controller: controller.notesController,
                        hintText: 'notes'.tr(),
                        keyboardType: TextInputType.multiline,
                        prefixIcon: Icon(Icons.description_outlined,
                            color: Color(AppColors.buttons)),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // ─── Add New Files (OPTIONAL) ───
                      _buildFilePicker(context, controller),

                      const SizedBox(height: 40),

                      // ─── Save Button ───
                      controller.isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(AppColors.buttons),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: AppButtonSize.height,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(AppColors.buttons),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.button),
                                ),
                                onPressed: () async {
                                  final success =
                                      await controller.submitUpdate(context);
                                  if (success && mounted) {
                                    Navigator.of(context).pop(true);
                                  }
                                },
                                child: Text(
                                  'save_changes'.tr(),
                                  style: const TextStyle(
                                      fontSize: 15,
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
      BuildContext context, UpdateExpenseClaimController controller) async {
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
      UpdateExpenseClaimController controller, bool isArabic) {
    final Map<String, String> categoryLabelsAr = {
      'supplies': 'مستلزمات',
      'travel': 'سفر',
      'food': 'طعام',
      'maintenance': 'صيانة',
    };

    String? currentValue = controller.categoryController.text.isEmpty
        ? null
        : controller.categoryController.text;
    // Verify it's a valid option
    if (currentValue != null &&
        !_categories.any((c) => c['value'] == currentValue)) {
      currentValue = null;
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'category'.tr(),
        labelStyle:
            AppStyles.content(context).copyWith(color: Colors.grey.shade600),
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
          borderSide: BorderSide(color: Color(AppColors.buttons), width: 1.5),
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
      BuildContext context, UpdateExpenseClaimController controller) {
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
                  color:
                      Color(AppColors.buttonSecondaryColor).withOpacity(0.3),
                  width: 1.5,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttonSecondaryColor)
                        .withOpacity(0.1),
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
        if (controller.newAttachments.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...controller.newAttachments.asMap().entries.map((entry) {
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
                    onPressed: () => controller.removeNewAttachment(idx),
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
    required BuildContext context,
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
        labelStyle:
            AppStyles.content(context).copyWith(color: Colors.grey.shade600),
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
          borderSide:
              BorderSide(color: Color(AppColors.buttons), width: 1.5),
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
