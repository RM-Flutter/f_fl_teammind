import 'package:app_test/features/services/models/cv_data.model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/animated_custom_dropdown/custom_dropdown.dart';
import '../../../view_models/create_cv.viewmodel.dart';

class CreateCVEducationTab extends StatelessWidget {
  final CreateCVViewModel viewModel;

  const CreateCVEducationTab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.education.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.titleText),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  viewModel.addEducation();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...viewModel.educations.asMap().entries.map((entry) {
            final index = entry.key;
            final education = entry.value;
            return _buildEducationItem(context, index, education);
          }),
        ],
      ),
    );
  }

  Widget _buildEducationItem(
      BuildContext context, int index, CVEducation education) {
    DateTime? dateFrom = education.dateFrom != null ? DateTime.tryParse(education.dateFrom!) : null;
    DateTime? dateTo = education.dateTo != null ? DateTime.tryParse(education.dateTo!) : null;
    
    final selectedCountry = education.countryId != null
        ? viewModel.countries.firstWhere(
            (c) => c['id'] == education.countryId,
            orElse: () => {},
          )
        : null;
    
    final educationStates = education.countryId != null
        ? viewModel.states.where((s) => (s['country_id'] ?? s['country']?['id']) == education.countryId).toList()
        : <Map<String, dynamic>>[];
    
    final selectedState = education.stateId != null && educationStates.isNotEmpty
        ? educationStates.firstWhere(
            (s) => s['id'] == education.stateId,
            orElse: () => {},
          )
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.education.tr()} ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.removeEducation(index);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: education.institutionName ?? '',
              decoration: InputDecoration(
                labelText: AppStrings.institutionName.tr(),
                hintText: AppStrings.enterInstitutionName.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) {
                final updatedEdu = CVEducation(
                  institutionName: value,
                  certificateName: education.certificateName,
                  countryId: education.countryId,
                  stateId: education.stateId,
                  dateFrom: education.dateFrom,
                  dateTo: education.dateTo,
                );
                viewModel.updateEducation(index, updatedEdu);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: education.certificateName ?? '',
              decoration: InputDecoration(
                labelText: AppStrings.certificateName.tr(),
                hintText: AppStrings.enterCertificateName.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) {
                final updatedEdu = CVEducation(
                  institutionName: education.institutionName,
                  certificateName: value,
                  countryId: education.countryId,
                  stateId: education.stateId,
                  dateFrom: education.dateFrom,
                  dateTo: education.dateTo,
                );
                viewModel.updateEducation(index, updatedEdu);
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown.search(
              items: viewModel.countries,
              selectedValue: selectedCountry,
              nameKey: 'title',
              hintText: AppStrings.selectCountry.tr(),
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
              onChanged: (value) {
                if (value.isNotEmpty && value['id'] != null) {
                  final updatedEdu = CVEducation(
                    institutionName: education.institutionName,
                    certificateName: education.certificateName,
                    countryId: value['id'] as int,
                    stateId: null,
                    dateFrom: education.dateFrom,
                    dateTo: education.dateTo,
                  );
                  viewModel.updateEducation(index, updatedEdu);
                  viewModel.loadStatesForItem(context, value['id'] as int);
                }
              },
            ),
            if (education.countryId != null && educationStates.isNotEmpty) ...[
              const SizedBox(height: 16),
              CustomDropdown.search(
                items: educationStates,
                selectedValue: selectedState,
                nameKey: 'title',
                hintText: AppStrings.selectStateProvince.tr(),
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black),
                onChanged: (value) {
                  if (value.isNotEmpty && value['id'] != null) {
                    final updatedEdu = CVEducation(
                      institutionName: education.institutionName,
                      certificateName: education.certificateName,
                      countryId: education.countryId,
                      stateId: value['id'] as int,
                      dateFrom: education.dateFrom,
                      dateTo: education.dateTo,
                    );
                    viewModel.updateEducation(index, updatedEdu);
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dateFrom ?? DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        final updatedEdu = CVEducation(
                          institutionName: education.institutionName,
                          certificateName: education.certificateName,
                          countryId: education.countryId,
                          stateId: education.stateId,
                          dateFrom: DateFormat('yyyy-MM-dd').format(date),
                          dateTo: education.dateTo,
                        );
                        viewModel.updateEducation(index, updatedEdu);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dateFrom != null ? DateFormat('yyyy-MM-dd').format(dateFrom) : AppStrings.selectDateFrom.tr(),
                              style: TextStyle(color: dateFrom != null ? Colors.black : Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dateTo ?? DateTime.now(),
                        firstDate: dateFrom ?? DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        final updatedEdu = CVEducation(
                          institutionName: education.institutionName,
                          certificateName: education.certificateName,
                          countryId: education.countryId,
                          stateId: education.stateId,
                          dateFrom: education.dateFrom,
                          dateTo: DateFormat('yyyy-MM-dd').format(date),
                        );
                        viewModel.updateEducation(index, updatedEdu);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dateTo != null ? DateFormat('yyyy-MM-dd').format(dateTo) : AppStrings.selectDateTo.tr(),
                              style: TextStyle(color: dateTo != null ? Colors.black : Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

