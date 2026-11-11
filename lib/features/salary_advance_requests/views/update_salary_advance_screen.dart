import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_sheet_submit_button.widget.dart';
import '../controllers/update_salary_advance_controller.dart';
import '../shared/models/salary_advance_request_model.dart';

/// "Edit Salary Advance" bottom sheet (same design as the overtime / expense claim edit sheets).
/// Pops `true` after a successful save.
class UpdateSalaryAdvanceScreen extends StatefulWidget {
  final SalaryAdvanceRequestModel existingRequest;

  const UpdateSalaryAdvanceScreen({super.key, required this.existingRequest});

  static Future<bool?> show(BuildContext context, SalaryAdvanceRequestModel request) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdateSalaryAdvanceScreen(existingRequest: request),
    );
  }

  @override
  State<UpdateSalaryAdvanceScreen> createState() => _UpdateSalaryAdvanceScreenState();
}

class _UpdateSalaryAdvanceScreenState extends State<UpdateSalaryAdvanceScreen> {
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
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'edit_salary_advance'.tr(),
                          style: AppStyles.darkContent(context).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.secondaryButton),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: controller.isLoading ? null : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(controller: controller.totalController, label: 'total_amount'.tr()),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(
                      controller: controller.howLongToPayController,
                      label: 'how_long_to_pay_months'.tr(),
                    ),
                    const SizedBox(height: 24),
                    AppSheetSubmitButton(
                      title: 'save_changes'.tr(),
                      onPressed: () async {
                        final success = await controller.submitUpdate(context);
                        if (success && context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (v) => (v == null || v.isEmpty) ? 'field_required'.tr() : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        floatingLabelStyle: TextStyle(
            color: Color(AppColors.secondaryButton), fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
