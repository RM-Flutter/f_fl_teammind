import 'package:app_test/features/services/data/models/cv_data_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/controllers/my_cv_view_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../core/constants/app_colors.dart';
import 'widgets/cv_info_item_widget.dart';
import 'package:app_test/core/constants/app_design.dart';

class CVEducationTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVEducationTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyCVViewModel>(context, listen: true);
    final educationList = viewModel.cvData?.education ?? cvData?.education;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Education Section
          _buildSectionTitle('EDUCATION'),

          if (educationList != null && educationList.isNotEmpty)
            ...educationList.map((edu) => _buildEducationItem(edu))
          else
            _buildEmptyEducationForm(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.school_outlined, size: 18, color: Color(AppColors.secondaryButton)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Color(AppColors.secondaryButton),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '• $label',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildEducationItem(CVEducation edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CVInfoItem(
            label: 'UNIVERSITY/TRAINING CENTER NAME',
            value: edu.institutionName,
            isRequired: true,
          ),
          CVInfoItem(
            label: "BACHELOR'S/MASTER/BOARD CERTIFICATE NAME",
            value: edu.certificateName,
            isRequired: true,
          ),
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: 'COUNTRY',
                  value: edu.countryTitle ?? edu.countryId?.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CVInfoItem(
                  label: 'GOVERNORATE/STATE',
                  value: edu.stateTitle ?? edu.stateId?.toString(),
                  isRequired: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: 'DATE FROM',
                  value: edu.dateFrom,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CVInfoItem(
                  label: 'DATE TO (OR PRESENT)',
                  value: edu.dateTo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEducationForm() {
    return Container(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CVInfoItem(
            label: 'UNIVERSITY/TRAINING CENTER NAME',
            value: null,
            isRequired: true,
          ),
          const CVInfoItem(
            label: "BACHELOR'S/MASTER/BOARD CERTIFICATE NAME",
            value: null,
            isRequired: true,
          ),
          Row(
            children: [
              Expanded(
                child: const CVInfoItem(
                  label: 'COUNTRY',
                  value: null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: const CVInfoItem(
                  label: 'GOVERNORATE/STATE',
                  value: null,
                  isRequired: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: const CVInfoItem(
                  label: 'DATE FROM',
                  value: null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: const CVInfoItem(
                  label: 'DATE TO (OR PRESENT)',
                  value: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

