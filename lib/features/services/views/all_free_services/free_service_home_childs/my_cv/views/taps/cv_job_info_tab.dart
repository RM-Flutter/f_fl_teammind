import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/views/taps/widgets/cv_info_item_widget.dart' show CVInfoItem;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/services/data/models/cv_data_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/controllers/my_cv_view_model.dart';
import 'package:app_test/core/constants/app_design.dart';

class CVJobInfoTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVJobInfoTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyCVViewModel>(context, listen: true);
    final jobInfo = viewModel.cvData?.jobInfo ?? cvData?.jobInfo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: 'CURRENT JOB TITLE',
                  value: jobInfo?.currentJobTitle,
                  isRequired: true,
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CVInfoItem(
                  label: 'JOB',
                  value: jobInfo?.jobTitle ?? jobInfo?.jobId?.toString(),
                  isRequired: true,
                  hint: '(SELECT)',
                  icon: Icons.work_outline,
                ),
              ),
            ],
          ),
          CVInfoItem(
            label: 'ABOUT ME',
            value: jobInfo?.aboutMe,
            hint: 'ADD YOUR JOB DESCRIPTION...',
            icon: Icons.description_outlined,
          ),
          CVInfoItem(
            label: 'SKILLS',
            value: jobInfo?.skillsTitles?.join(', ') ?? jobInfo?.skills?.join(', '),
            hint: '(اختيار من الموجود)',
            icon: Icons.star_border,
          ),
          CVInfoItem(
            label: 'MORE SKILLS',
            value: jobInfo?.moreSkills,
            hint: 'ادخال قائمة عناصر اضافية - بشكل حر',
            icon: Icons.add_circle_outline,
          ),
          
          // Experience Section
          _buildSectionTitle('EXPERIENCE'),
          if (jobInfo?.experiences != null && jobInfo!.experiences!.isNotEmpty)
            ...jobInfo.experiences!.map((exp) => _buildExperienceItem(exp))
          else
            const SizedBox.shrink(),
          
          // Portfolio Section
          _buildSectionTitle('PORTFOLIO'),
          if (jobInfo?.portfolios != null && jobInfo!.portfolios!.isNotEmpty)
            ...jobInfo.portfolios!.map((portfolio) => _buildPortfolioItem(portfolio))
          else
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CVInfoItem(label: 'اسم المشروع', value: null),
                CVInfoItem(label: 'وصف المشروع', value: null),
                CVInfoItem(label: 'رابط المشروع', value: null),
              ],
            ),
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
          Icon(Icons.work_outline, size: 18, color: Color(AppColors.secondaryButton)),
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

  Widget _buildExperienceItem(CVExperience exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: CVInfoItem(label: 'COMPANY NAME', value: exp.companyName)),
              const SizedBox(width: 8),
              Expanded(child: CVInfoItem(label: 'JOB TITLE', value: exp.jobTitle, isRequired: true)),
            ],
          ),
          Row(
            children: [
              Expanded(child: CVInfoItem(label: 'COUNTRY', value: exp.countryTitle ?? exp.countryId?.toString())),
              const SizedBox(width: 8),
              Expanded(child: CVInfoItem(label: 'GOVERNORATE/STATE', value: exp.stateTitle ?? exp.stateId?.toString(), isRequired: true)),
            ],
          ),
          Row(
            children: [
              Expanded(child: CVInfoItem(label: 'DATE FROM', value: exp.dateFrom)),
              const SizedBox(width: 8),
              Expanded(child: CVInfoItem(label: 'DATE TO (OR PRESENT)', value: exp.dateTo)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(CVPortfolio portfolio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: CVInfoItem(label: 'اسم المشروع', value: portfolio.projectName)),
              const SizedBox(width: 8),
              Expanded(child: CVInfoItem(label: 'رابط المشروع', value: portfolio.projectLink)),
            ],
          ),
          CVInfoItem(label: 'وصف المشروع', value: portfolio.projectDescription),
        ],
      ),
    );
  }
}

