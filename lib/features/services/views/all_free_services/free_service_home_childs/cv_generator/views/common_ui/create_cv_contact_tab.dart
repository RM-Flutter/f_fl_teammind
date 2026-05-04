import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/cv_generator/controllers/create_cv_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../../core/constants/app_colors.dart';
import '../../../../../../../../core/constants/app_strings.dart';

class CreateCVContactTab extends StatelessWidget {
  final CreateCVViewModel viewModel;

  const CreateCVContactTab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: viewModel.phoneController,
            label: AppStrings.phone.tr(),
            isRequired: true,
            hint: AppStrings.enterYourPhoneNumber.tr(),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: viewModel.emailController,
            label: AppStrings.email.tr(),
            isRequired: true,
            hint: AppStrings.enterYourEmail.tr(),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: viewModel.linkedinController,
            label: AppStrings.linkedin.tr(),
            hint: AppStrings.enterYourLinkedInProfileURL.tr(),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: viewModel.behanceController,
            label: AppStrings.behance.tr(),
            hint: AppStrings.enterYourBehanceProfileURL.tr(),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: viewModel.whatsappController,
            label: AppStrings.whatsapp.tr(),
            hint: AppStrings.enterYourWhatsAppNumber.tr(),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.titleText),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

