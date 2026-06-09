import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import '../controllers/update_salary_advance_controller.dart';
import '../shared/models/salary_advance_request_model.dart';

class UpdateSalaryAdvanceScreen extends StatefulWidget {
  final SalaryAdvanceRequestModel existingRequest;

  const UpdateSalaryAdvanceScreen({super.key, required this.existingRequest});

  @override
  State<UpdateSalaryAdvanceScreen> createState() =>
      _UpdateSalaryAdvanceScreenState();
}

class _UpdateSalaryAdvanceScreenState
    extends State<UpdateSalaryAdvanceScreen> {
  late final UpdateSalaryAdvanceController viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = UpdateSalaryAdvanceController(
      requestId: widget.existingRequest.id!,
      existingRequest: widget.existingRequest,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateSalaryAdvanceController>.value(
      value: viewModel,
      child: Consumer<UpdateSalaryAdvanceController>(
        builder: (context, controller, child) {
          return TemplatePage(
            pageContext: context,
            title: 'edit_salary_advance'.tr(),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.s16.r),
              child: Container(
                padding: EdgeInsets.all(AppSizes.s24.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(AppColors.buttonColor).withOpacity(0.08),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 15),
                    )
                  ],
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Header ───
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(AppColors.buttonColor),
                                  Color(AppColors.buttonSecondaryColor)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(Icons.edit_note_rounded,
                                color: Colors.white, size: 22.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'edit_salary_advance'.tr(),
                                  style: AppStyles.heading(context).copyWith(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '#${widget.existingRequest.id}',
                                  style: AppStyles.content(context).copyWith(
                                      color: Colors.grey.shade500,
                                      fontSize: 13.sp),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),

                      // ─── Total Amount ───
                      _buildTextField(
                        context: context,
                        controller: controller.totalController,
                        hintText: 'total_amount'.tr(),
                        keyboardType: TextInputType.number,
                        prefixIcon: Icon(Icons.monetization_on_outlined,
                            color: Color(AppColors.buttons)),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'field_required'.tr()
                            : null,
                      ),
                      SizedBox(height: 20.h),

                      // ─── Duration ───
                      _buildTextField(
                        context: context,
                        controller: controller.howLongToPayController,
                        hintText: 'how_long_to_pay_months'.tr(),
                        keyboardType: TextInputType.number,
                        prefixIcon: Icon(Icons.calendar_view_month,
                            color: Color(AppColors.buttons)),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'field_required'.tr()
                            : null,
                      ),
                      SizedBox(height: 20.h),

                      // ─── From Date ───
                      InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (ctx, child) => Theme(
                              data: Theme.of(ctx).copyWith(
                                colorScheme: ColorScheme.light(
                                    primary: Color(AppColors.buttons)),
                              ),
                              child: child!,
                            ),
                          );
                          if (pickedDate != null) {
                            controller.setFromDate(
                                '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}');
                          }
                        },
                        child: IgnorePointer(
                          child: _buildTextField(
                            context: context,
                            controller: controller.fromDateController,
                            hintText: 'from_date_yyyy_mm'.tr(),
                            keyboardType: TextInputType.text,
                            readOnly: true,
                            prefixIcon: Icon(Icons.calendar_month,
                                color: Color(AppColors.buttons)),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'field_required'.tr()
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // ─── Existing Attachments Section ───
                      if (controller.existingAttachments.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.attachment_rounded,
                                color: Color(AppColors.buttons), size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'attachments'.tr(),
                              style: AppStyles.heading(context)
                                  .copyWith(fontSize: 15.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: controller.existingAttachments
                              .map((attachment) {
                            final isImage = attachment.fileType?.toLowerCase() == 'png' ||
                                attachment.fileType?.toLowerCase() == 'jpg' ||
                                attachment.fileType?.toLowerCase() == 'jpeg' ||
                                attachment.fileType?.toLowerCase() == 'webp' ||
                                attachment.fileType?.toLowerCase() == 'gif' ||
                                (attachment.imageList != null &&
                                    attachment.imageList!['thumbnail'] != null);

                            Widget attachmentCard;

                            if (isImage &&
                                attachment.imageList != null &&
                                attachment.imageList!['thumbnail'] != null) {
                              final String imageUrl = attachment.imageList!['thumbnail'];
                              attachmentCard = GestureDetector(
                                onTap: () {
                                  final originalUrl = attachment.imageList!['original'] ?? imageUrl;
                                  launchUrl(Uri.parse(originalUrl), mode: LaunchMode.externalApplication);
                                },
                                child: Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade100,
                                        child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey.shade100,
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Non-image file or fallback
                              attachmentCard = GestureDetector(
                                onTap: () {
                                  if (attachment.url != null) {
                                    launchUrl(Uri.parse(attachment.url!), mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    color: Color(AppColors.buttonSecondaryColor)
                                        .withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                        color: Color(AppColors.buttonSecondaryColor)
                                            .withOpacity(0.2),
                                        width: 1),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.insert_drive_file_rounded,
                                          color: Color(AppColors.buttonSecondaryColor),
                                          size: 24.sp),
                                      SizedBox(height: 4.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                                        child: Text(
                                          attachment.fileName ?? 'File',
                                          style: AppStyles.content(context).copyWith(
                                            fontSize: 10.sp,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (controller.isHr) {
                              return Stack(
                                children: [
                                  attachmentCard,
                                  Positioned(
                                    top: 2.r,
                                    right: 2.r,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final confirm = await AlertsService.customConfirm(
                                          context: context,
                                          title: 'remove_attachment'.tr(),
                                          message: 'remove_attachment_confirm'.tr(),
                                        );
                                        if (confirm == true && context.mounted) {
                                          await controller.deleteExistingAttachment(context, attachment.id!);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(3.r),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return attachmentCard;
                            }
                          }).toList(),
                        ),
                        SizedBox(height: 28.h),
                      ],

                      // ─── New Attachments Section ───
                      Row(
                        children: [
                          Icon(Icons.attach_file_rounded,
                              color: Color(AppColors.buttons), size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'add_new_attachments'.tr(),
                            style: AppStyles.heading(context)
                                .copyWith(fontSize: 15.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                            type: FileType.image,
                          );
                          if (result != null) {
                            controller.addAttachment(result);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          decoration: BoxDecoration(
                            color: Color(AppColors.buttonSecondaryColor)
                                .withOpacity(0.03),
                            border: Border.all(
                                color: Color(AppColors.buttonSecondaryColor)
                                    .withOpacity(0.3),
                                width: 1.5,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: Color(AppColors.buttonSecondaryColor)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.cloud_upload_rounded,
                                    color:
                                        Color(AppColors.buttonSecondaryColor),
                                    size: 28.sp),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'add_attachment'.tr(),
                                style: AppStyles.content(context).copyWith(
                                  color: Color(AppColors.buttonSecondaryColor),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ─── New attachment chips ───
                      if (controller.newAttachments.isNotEmpty) ...[
                        SizedBox(height: 14.h),
                        ...controller.newAttachments.asMap().entries.map((e) {
                          final idx = e.key;
                          final file = e.value.files.first;
                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Color(AppColors.buttons).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                  color:
                                      Color(AppColors.buttons).withOpacity(0.2),
                                  width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.image_rounded,
                                    color: Color(AppColors.buttons), size: 20),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(file.name,
                                      style: AppStyles.content(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                GestureDetector(
                                  onTap: () => controller.removeAttachment(idx),
                                  child: Icon(Icons.close_rounded,
                                      color: Colors.red, size: 20),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      SizedBox(height: 36.h),

                      // ─── Submit Button ───
                      controller.isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(AppColors.buttons),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(AppColors.buttonColor),
                                    Color(AppColors.buttonSecondaryColor)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(AppColors.buttonColor)
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
                                      EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14.r)),
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
                                  style: TextStyle(
                                      fontSize: 16.sp,
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

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required Widget prefixIcon,
    required String? Function(String?) validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style:
          AppStyles.content(context).copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: AppStyles.content(context)
            .copyWith(color: Colors.grey.shade600),
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
          borderSide:
              BorderSide(color: Color(AppColors.buttons), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: Color(AppColors.failureRed), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: Color(AppColors.failureRed), width: 2.0),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      ),
    );
  }
}
