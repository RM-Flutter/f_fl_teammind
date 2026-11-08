import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/core/widgets/glassmorphism_card.widget.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import '../controllers/update_salary_advance_controller.dart';
import '../shared/models/salary_advance_request_model.dart';
import 'package:app_test/core/constants/app_design.dart';

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
                  )
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
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(AppColors.buttons),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(Icons.edit_note_rounded,
                                color: Colors.white, size: 22),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'edit_salary_advance'.tr(),
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
                      SizedBox(height: 28),

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
                      SizedBox(height: 20),

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
                      SizedBox(height: 20),

                      

                      // ─── Submit Button ───
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

  Widget _buildTextField({
    required BuildContext context,
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
            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
