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
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
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
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page, vertical: AppSpacing.md),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: controller.totalController,
                      label: 'total_amount'.tr(),
                    ),
                    gapH14,
                    _buildTextField(
                      controller: controller.howLongToPayController,
                      label: 'how_long_to_pay_months'.tr(),
                    ),
                    gapH24,
                    Center(
                      child: controller.isLoading
                          ? const CircularProgressIndicator()
                          : CustomElevatedButton(
                              backgroundColor: Color(AppColors.secondaryButton),
                              titleSize: AppSizes.s14,
                              radius: AppSizes.s24,
                              title: 'save_changes'.tr(),
                              onPressed: () async {
                                final success =
                                    await controller.submitUpdate(context);
                                if (success && mounted) {
                                  Navigator.of(context).pop(true);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (v) =>
          (v == null || v.isEmpty) ? 'field_required'.tr() : null,
      decoration: InputDecoration(
        labelText: label,
        // The theme has no label style (only hint), so the default label was almost invisible.
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        floatingLabelStyle: TextStyle(
            color: Color(AppColors.secondaryButton),
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
