import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../constants/app_colors.dart';
import '../../../models/cv_data.model.dart';
import '../../../view_models/my_cv.viewmodel.dart';
import 'cv_info_item.widget.dart';

class CVJobInfoTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVJobInfoTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyCVViewModel>(context, listen: true);
    final jobInfo = viewModel.cvData?.jobInfo ?? cvData?.jobInfo;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Separator line
          _buildSeparator(),
          
          CVInfoItem(
            label: 'CURRENT JOB TITLE',
            value: jobInfo?.currentJobTitle,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'JOB',
            value: jobInfo?.jobTitle ?? jobInfo?.jobId?.toString(),
            isRequired: true,
            hint: '(SELECT)',
          ),
          CVInfoItem(
            label: 'ABOUT ME - ADD YOUR JOB DESCRIPTION...',
            value: jobInfo?.aboutMe,
          ),
          CVInfoItem(
            label: 'SKILLS',
            value: jobInfo?.skillsTitles?.join(', ') ?? jobInfo?.skills?.join(', '),
            hint: '(اختيار من الموجود)',
          ),
          CVInfoItem(
            label: 'MORE SKILLS',
            value: jobInfo?.moreSkills,
            hint: 'ادخال قائمة عناصر اضافية - بشكل حر',
          ),
          
          // Separator line
          _buildSeparator(),
          
          // Experience Section
          _buildSectionTitle('EXPERIENCE'),
          if (jobInfo?.experiences != null && jobInfo!.experiences!.isNotEmpty)
            ...jobInfo.experiences!.map((exp) => _buildExperienceItem(exp))
          else
          
          // Separator line
          _buildSeparator(),
          
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
          color: Color(AppColors.dark),
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

  Widget _buildExperienceItem(CVExperience exp) {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CVInfoItem(label: 'COMPANY NAME', value: exp.companyName),
          CVInfoItem(label: 'JOB TITLE', value: exp.jobTitle, isRequired: true),
          CVInfoItem(label: 'COUNTRY ID', value: exp.countryId?.toString()),
          CVInfoItem(label: 'GOVERNORATE/STATE ID', value: exp.stateId?.toString(), isRequired: true),
          CVInfoItem(label: 'DATE FROM', value: exp.dateFrom),
          CVInfoItem(label: 'DATE TO (OR PRESENT)', value: exp.dateTo),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(CVPortfolio portfolio) {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CVInfoItem(label: 'اسم المشروع', value: portfolio.projectName),
          CVInfoItem(label: 'وصف المشروع', value: portfolio.projectDescription),
          CVInfoItem(label: 'رابط المشروع', value: portfolio.projectLink),
        ],
      ),
    );
  }
}

