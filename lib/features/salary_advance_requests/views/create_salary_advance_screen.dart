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
import 'package:app_test/core/widgets/glassmorphism_card.widget.dart';

import '../controllers/create_salary_advance_controller.dart';

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
              padding: EdgeInsets.all(AppSizes.s16.r),
              child: GlassmorphismCard(
                padding: EdgeInsets.all(AppSizes.s24.r),
                backgroundColor: Colors.white,
                opacity: 0.9,
                boxShadow: [
                  BoxShadow(
                    color: Color(AppColors.buttonColor).withOpacity(0.08),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 15),
                  )
                ],
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: controller.totalController,
                        hintText: 'total_amount'.tr(),
                        keyboardType: TextInputType.number,
                        prefixIcon: Icon(Icons.monetization_on_outlined, color: Color(AppColors.buttons)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'field_required'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: controller.howLongToPayController,
                        hintText: 'how_long_to_pay_months'.tr(),
                        keyboardType: TextInputType.number,
                        prefixIcon: Icon(Icons.calendar_view_month, color: Color(AppColors.buttons)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'field_required'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: controller.fromDateController,
                        hintText: 'from_date_yyyy_mm'.tr(),
                        keyboardType: TextInputType.text,
                        prefixIcon: Icon(Icons.calendar_month, color: Color(AppColors.buttons)),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'field_required'.tr();
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? pickedDate;
                          await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                            ),
                            builder: (BuildContext builder) {
                              DateTime tempPickedDate = DateTime.now();
                              return Container(
                                height: 300.h,
                                padding: EdgeInsets.only(top: 10.h),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('cancel_request'.tr().split(' ')[0], style: TextStyle(color: Color(AppColors.failureRed), fontSize: 16.sp)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              pickedDate = tempPickedDate;
                                              Navigator.pop(context);
                                            },
                                            child: Text('submit'.tr(), style: TextStyle(color: Color(AppColors.buttons), fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
                    SizedBox(height: 16.h),
                    Text(
                      'attachments'.tr(),
                      style: AppStyles.heading(context).copyWith(fontSize: 16.sp),
                    ),
                    SizedBox(height: 8.h),
                      InkWell(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final List<XFile> images = await picker.pickMultiImage();
                          
                          if (images.isNotEmpty) {
                            List<PlatformFile> platformFiles = [];
                            for (var file in images) {
                              platformFiles.add(PlatformFile(
                                name: file.name,
                                path: file.path,
                                size: await file.length(),
                              ));
                            }
                            FilePickerResult result = FilePickerResult(platformFiles);
                            controller.addAttachment(result);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          decoration: BoxDecoration(
                            color: Color(AppColors.buttonSecondaryColor).withOpacity(0.03),
                            border: Border.all(color: Color(AppColors.buttonSecondaryColor).withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: Color(AppColors.buttonSecondaryColor).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.cloud_upload_rounded, color: Color(AppColors.buttonSecondaryColor), size: 32.sp),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'add_attachment'.tr(), 
                                style: AppStyles.content(context).copyWith(
                                  color: Color(AppColors.buttonSecondaryColor),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.attachments.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        ...controller.attachments.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var file = entry.value.files.first;
                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.image, color: Colors.grey.shade600),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    file.name,
                                    style: AppStyles.content(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => controller.removeAttachment(idx),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    SizedBox(height: 40.h),
                    controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(AppColors.buttonColor), Color(AppColors.buttonSecondaryColor)],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(AppColors.buttonColor).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              onPressed: () async {
                                bool success = await controller.submitRequest(context);
                                if (success && mounted) {
                                  context.pop(true);
                                }
                              },
                              child: Text(
                                'submit'.tr(),
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required Widget prefixIcon,
    required String? Function(String?) validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppStyles.content(context).copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: AppStyles.content(context).copyWith(color: Colors.grey.shade600),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Color(AppColors.buttonSecondaryColor).withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(AppColors.buttons), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(AppColors.failureRed), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(AppColors.failureRed), width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      ),
    );
  }
}
