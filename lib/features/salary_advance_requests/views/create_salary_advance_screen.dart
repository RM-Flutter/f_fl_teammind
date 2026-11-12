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
import 'package:app_test/core/widgets/text_form_widget.dart';

import '../controllers/create_salary_advance_controller.dart';
import 'package:app_test/core/constants/app_design.dart';

class CreateSalaryAdvanceScreen extends StatefulWidget {
  const CreateSalaryAdvanceScreen({super.key});

  @override
  State<CreateSalaryAdvanceScreen> createState() => _CreateSalaryAdvanceScreenState();
}

class _CreateSalaryAdvanceScreenState extends State<CreateSalaryAdvanceScreen> {
  late final CreateSalaryAdvanceController viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CreateSalaryAdvanceController();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateSalaryAdvanceController>.value(
      value: viewModel,
      child: Consumer<CreateSalaryAdvanceController>(
        builder: (context, controller, child) {
          return TemplatePage(
            pageContext: context,
            title: 'create_salary_advance'.tr(),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page, vertical: AppSpacing.md),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: controller.totalController,
                      hintText: 'total_amount'.tr(),
                      keyboardType: TextInputType.number,
                      validator: _required,
                    ),
                    gapH14,
                    _buildTextField(
                      controller: controller.howLongToPayController,
                      hintText: 'how_long_to_pay_months'.tr(),
                      keyboardType: TextInputType.number,
                      validator: _required,
                    ),
                    gapH14,
                    _buildTextField(
                      controller: controller.fromDateController,
                      hintText: 'from_date_yyyy_mm'.tr(),
                      keyboardType: TextInputType.text,
                      suffixIcon: const Icon(Icons.calendar_today),
                      readOnly: true,
                      validator: _required,
                        onTap: () async {
                          DateTime? pickedDate;
                          await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                            ),
                            builder: (BuildContext builder) {
                              DateTime tempPickedDate = DateTime.now();
                              return Container(
                                height: 300,
                                padding: EdgeInsets.only(top: AppSizes.s10),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: AppSizes.s16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('cancel_request'.tr().split(' ')[0], style: TextStyle(color: Color(AppColors.failureRed), fontSize: 16)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              pickedDate = tempPickedDate;
                                              Navigator.pop(context);
                                            },
                                            child: Text('submit'.tr(), style: TextStyle(color: Color(AppColors.buttons), fontSize: 16, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.monthYear,
                                        initialDateTime: DateTime.now(),
                                        minimumDate: DateTime(2000),
                                        maximumDate: DateTime(2100),
                                        onDateTimeChanged: (DateTime newDate) {
                                          tempPickedDate = newDate;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          if (pickedDate != null) {
                            // Format as YYYY-MM
                            String formattedDate = "${pickedDate!.year}-${pickedDate!.month.toString().padLeft(2, '0')}";
                            controller.setFromDate(formattedDate);
                          }
                        },
                    ),
                    gapH14,
                    Text(
                      'attachments'.tr(),
                      style: AppStyles.primaryContent(context)
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    gapH14,
                    for (int idx = 0; idx < controller.attachments.length; idx++) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.image, color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: AppSizes.s12),
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
                      onTap: () => _pickAttachments(controller),
                      decoration: InputDecoration(
                        hintText: 'add_attachment'.tr(),
                        suffixIcon: const Icon(Icons.attach_file_rounded),
                      ),
                    ),
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
                                bool success = await controller.submitRequest(context);
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

  String? _required(String? value) =>
      (value == null || value.isEmpty) ? 'field_required'.tr() : null;

  Future<void> _pickAttachments(CreateSalaryAdvanceController controller) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isEmpty) return;
    final platformFiles = <PlatformFile>[];
    for (var file in images) {
      platformFiles.add(PlatformFile(
        name: file.name,
        path: file.path,
        size: await file.length(),
        bytes: await file.readAsBytes(),
      ));
    }
    controller.addAttachment(FilePickerResult(platformFiles));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
    );
  }
}
