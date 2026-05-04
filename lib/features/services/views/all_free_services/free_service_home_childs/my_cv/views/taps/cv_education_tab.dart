import 'package:app_test/features/services/data/models/cv_data_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/controllers/my_cv_view_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../core/constants/app_colors.dart';
import 'widgets/cv_info_item_widget.dart';

class CVEducationTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVEducationTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyCVViewModel>(context, listen: true);
    final educationList = viewModel.cvData?.education ?? cvData?.education;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Separator line
          _buildSeparator(),
          
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

  Widget _buildSeparator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: const Text(
        '----------',
        style: TextStyle(
          color: Colors.grey,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '• $title',
        style: TextStyle(
          color: Color(AppColors.titleText),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAddNewItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
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
      margin: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CVInfoItem(
            label: 'UNIVERSITY/TRAINING CENTER NAME',
            value: edu.institutionName,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'COUNTRY ID',
            value: edu.countryId?.toString(),
          ),
          CVInfoItem(
            label: 'GOVERNORATE/STATE ID',
            value: edu.stateId?.toString(),
            isRequired: true,
          ),
          CVInfoItem(
            label: 'DATE FROM',
            value: edu.dateFrom,
          ),
          CVInfoItem(
            label: 'DATE TO (OR PRESENT)',
            value: edu.dateTo,
          ),
          CVInfoItem(
            label: "BACHELOR'S/MASTER/BOARD CERTIFICATE NAME",
            value: edu.certificateName,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEducationForm() {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CVInfoItem(
            label: 'UNIVERSITY/TRAINING CENTER NAME',
            value: null,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'COUNTRY',
            value: null,
          ),
          CVInfoItem(
            label: 'GOVERNORATE/STATE',
            value: null,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'DATE FROM',
            value: null,
          ),
          CVInfoItem(
            label: 'DATE TO (OR PRESENT)',
            value: null,
          ),
          CVInfoItem(
            label: "BACHELOR'S/MASTER/BOARD CERTIFICATE NAME",
            value: null,
            isRequired: true,
          ),
        ],
      ),
    );
  }
}

