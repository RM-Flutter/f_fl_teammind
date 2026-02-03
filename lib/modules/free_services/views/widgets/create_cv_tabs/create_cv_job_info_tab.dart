import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../utils/animated_custom_dropdown/custom_dropdown.dart';
import '../../../view_models/create_cv.viewmodel.dart';
import '../../../models/cv_data.model.dart';

class CreateCVJobInfoTab extends StatelessWidget {
  final CreateCVViewModel viewModel;

  const CreateCVJobInfoTab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: viewModel.currentJobTitleController,
            label: AppStrings.currentJobTitle.tr(),
            isRequired: true,
            hint: AppStrings.enterYourCurrentJobTitle.tr(),
          ),
          const SizedBox(height: 16),
          
          _buildJobDropdown(),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: viewModel.aboutMeController,
            label: AppStrings.aboutMe.tr(),
            hint: AppStrings.addYourJobDescription.tr(),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          
          _buildSkillsMultiSelect(),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: viewModel.moreSkillsController,
            label: AppStrings.moreSkills.tr(),
            hint: AppStrings.enterAdditionalSkills.tr(),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          
          _buildExperiencesSection(context),
          const SizedBox(height: 24),
          
          _buildPortfoliosSection(),
          const SizedBox(height: 24),
          
          _buildLanguagesLevelsSection(),
          const SizedBox(height: 24),
          
          _buildSkillsLevelsSection(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
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
                color: Color(AppColors.dark),
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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildJobDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.job.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.dark),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: viewModel.jobId,
          decoration: InputDecoration(
            hintText: AppStrings.selectJob.tr(),
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(color: Color(AppColors.dark)),
          items: viewModel.jobs
              .map((job) => DropdownMenuItem(
                    value: job['id'] as int?,
                    child: Text(
                      job['title'] ?? '',
                      style: TextStyle(color: Color(AppColors.dark)),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            viewModel.jobId = value;
            viewModel.notifyListeners();
          },
        ),
      ],
    );
  }

  Widget _buildSkillsMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.skills.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.dark),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: viewModel.skills.map((skill) {
            final skillId = skill['id'] as int;
            final isSelected = viewModel.selectedSkills.contains(skillId);
            return FilterChip(
              label: Text(skill['title'] ?? ''),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  viewModel.selectedSkills.add(skillId);
                } else {
                  viewModel.selectedSkills.remove(skillId);
                }
                viewModel.notifyListeners();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExperiencesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.experience.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.dark),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                viewModel.addExperience();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...viewModel.experiences.asMap().entries.map((entry) {
          final index = entry.key;
          final experience = entry.value;
          return _buildExperienceItem(context, index, experience);
        }),
      ],
    );
  }

  Widget _buildExperienceItem(BuildContext context, int index, CVExperience experience) {
    final jobTitleController = TextEditingController(text: experience.jobTitle);
    DateTime? dateFrom = experience.dateFrom != null ? DateTime.tryParse(experience.dateFrom!) : null;
    DateTime? dateTo = experience.dateTo != null ? DateTime.tryParse(experience.dateTo!) : null;
    
    final selectedCountry = experience.countryId != null
        ? viewModel.countries.firstWhere(
            (c) => c['id'] == experience.countryId,
            orElse: () => {},
          )
        : null;
    
    // Use viewModel.states directly - they will be loaded when country is selected
    final experienceStates = experience.countryId != null
        ? viewModel.states.where((s) => (s['country_id'] ?? s['country']?['id']) == experience.countryId).toList()
        : <Map<String, dynamic>>[];
    
    final selectedState = experience.stateId != null && experienceStates.isNotEmpty
        ? experienceStates.firstWhere(
            (s) => s['id'] == experience.stateId,
            orElse: () => {},
          )
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.experience.tr()} ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.removeExperience(index);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: jobTitleController,
              decoration: InputDecoration(
                labelText: AppStrings.jobTitle.tr(),
                hintText: AppStrings.enterJobTitle.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                final updatedExp = CVExperience(
                  countryId: experience.countryId,
                  stateId: experience.stateId,
                  dateFrom: experience.dateFrom,
                  dateTo: experience.dateTo,
                  jobTitle: value,
                );
                viewModel.updateExperience(index, updatedExp);
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown.search(
              items: viewModel.countries,
              selectedValue: selectedCountry,
              nameKey: 'title',
              hintText: AppStrings.selectCountry.tr(),
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
              onChanged: (value) {
                if (value.isNotEmpty && value['id'] != null) {
                  final updatedExp = CVExperience(
                    countryId: value['id'] as int,
                    stateId: null,
                    dateFrom: experience.dateFrom,
                    dateTo: experience.dateTo,
                    jobTitle: jobTitleController.text,
                  );
                  viewModel.updateExperience(index, updatedExp);
                  // Load states for selected country
                  viewModel.loadStatesForItem(context, value['id'] as int);
                }
              },
            ),
            if (experience.countryId != null && experienceStates.isNotEmpty) ...[
              const SizedBox(height: 16),
              CustomDropdown.search(
                items: experienceStates,
                selectedValue: selectedState,
                nameKey: 'title',
                hintText: AppStrings.selectStateProvince.tr(),
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey),
                onChanged: (value) {
                  if (value.isNotEmpty && value['id'] != null) {
                    final updatedExp = CVExperience(
                      countryId: experience.countryId,
                      stateId: value['id'] as int,
                      dateFrom: experience.dateFrom,
                      dateTo: experience.dateTo,
                      jobTitle: jobTitleController.text,
                    );
                    viewModel.updateExperience(index, updatedExp);
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
                        final updatedExp = CVExperience(
                          countryId: experience.countryId,
                          stateId: experience.stateId,
                          dateFrom: DateFormat('yyyy-MM-dd').format(date),
                          dateTo: experience.dateTo,
                          jobTitle: jobTitleController.text,
                        );
                        viewModel.updateExperience(index, updatedExp);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
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
                        final updatedExp = CVExperience(
                          countryId: experience.countryId,
                          stateId: experience.stateId,
                          dateFrom: experience.dateFrom,
                          dateTo: DateFormat('yyyy-MM-dd').format(date),
                          jobTitle: jobTitleController.text,
                        );
                        viewModel.updateExperience(index, updatedExp);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
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

  Widget _buildPortfoliosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.portfolio.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.dark),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                viewModel.addPortfolio();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...viewModel.portfolios.asMap().entries.map((entry) {
          final index = entry.key;
          final portfolio = entry.value;
          return _buildPortfolioItem(index, portfolio);
        }),
      ],
    );
  }

  Widget _buildPortfolioItem(int index, CVPortfolio portfolio) {
    final projectNameController = TextEditingController(text: portfolio.projectName);
    final projectDescriptionController = TextEditingController(text: portfolio.projectDescription);
    final projectLinkController = TextEditingController(text: portfolio.projectLink);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.portfolio.tr()} ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.removePortfolio(index);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: projectNameController,
              decoration: InputDecoration(
                labelText: AppStrings.projectName.tr(),
                hintText: AppStrings.enterProjectName.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                final updatedPortfolio = CVPortfolio(
                  projectName: value,
                  projectDescription: portfolio.projectDescription,
                  projectLink: portfolio.projectLink,
                  images: portfolio.images,
                );
                viewModel.updatePortfolio(index, updatedPortfolio);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: projectDescriptionController,
              decoration: InputDecoration(
                labelText: AppStrings.projectDescription.tr(),
                hintText: AppStrings.enterProjectDescription.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              onChanged: (value) {
                final updatedPortfolio = CVPortfolio(
                  projectName: portfolio.projectName,
                  projectDescription: value,
                  projectLink: portfolio.projectLink,
                  images: portfolio.images,
                );
                viewModel.updatePortfolio(index, updatedPortfolio);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: projectLinkController,
              decoration: InputDecoration(
                labelText: AppStrings.projectLink.tr(),
                hintText: AppStrings.enterProjectLink.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                final updatedPortfolio = CVPortfolio(
                  projectName: portfolio.projectName,
                  projectDescription: portfolio.projectDescription,
                  projectLink: value,
                  images: portfolio.images,
                );
                viewModel.updatePortfolio(index, updatedPortfolio);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.languages.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.dark),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                viewModel.addLanguageLevel();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...viewModel.languagesLevels.asMap().entries.map((entry) {
          final index = entry.key;
          final languageLevel = entry.value;
          return _buildLanguageLevelItem(index, languageLevel);
        }),
      ],
    );
  }

  Widget _buildLanguageLevelItem(int index, CVLanguageLevel languageLevel) {
    final selectedLanguage = languageLevel.languageId != null
        ? viewModel.languages.firstWhere(
            (l) => l['id'] == languageLevel.languageId,
            orElse: () => {},
          )
        : null;

    final selectedLevel = languageLevel.levelId != null
        ? viewModel.levels.firstWhere(
            (l) => l['id'] == languageLevel.levelId,
            orElse: () => {},
          )
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.languages.tr()} ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.removeLanguageLevel(index);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomDropdown.search(
              items: viewModel.languages,
              selectedValue: selectedLanguage,
              nameKey: 'name',
              hintText: AppStrings.selectLanguage.tr(),
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
              onChanged: (value) {
                if (value.isNotEmpty && value['id'] != null) {
                  final updatedLang = CVLanguageLevel(
                    languageId: value['id'] as int,
                    levelId: languageLevel.levelId,
                  );
                  viewModel.updateLanguageLevel(index, updatedLang);
                }
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown.search(
              items: viewModel.levels,
              selectedValue: selectedLevel,
              nameKey: 'title',
              hintText: AppStrings.selectLevel.tr(),
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
              onChanged: (value) {
                if (value.isNotEmpty && value['id'] != null) {
                  final updatedLang = CVLanguageLevel(
                    languageId: languageLevel.languageId,
                    levelId: value['id'] as int,
                  );
                  viewModel.updateLanguageLevel(index, updatedLang);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.skillsLevels.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.dark),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                viewModel.addSkillLevel();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...viewModel.skillsLevels.asMap().entries.map((entry) {
          final index = entry.key;
          final skillLevel = entry.value;
          return _buildSkillLevelItem(index, skillLevel);
        }),
      ],
    );
  }

  Widget _buildSkillLevelItem(int index, CVSkillLevel skillLevel) {
    final selectedSkill = skillLevel.skillId != null
        ? viewModel.skills.firstWhere(
            (s) => s['id'] == skillLevel.skillId,
            orElse: () => {},
          )
        : null;

    final selectedLevel = skillLevel.levelId != null
        ? viewModel.levels.firstWhere(
            (l) => l['id'] == skillLevel.levelId,
            orElse: () => {},
          )
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.skillsLevels.tr()} ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.removeSkillLevel(index);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomDropdown.search(
              items: viewModel.skills,
              selectedValue: selectedSkill,
              nameKey: 'title',
              hintText: AppStrings.selectSkill.tr(),
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
              onChanged: (value) {
                if (value.isNotEmpty && value['id'] != null) {
                  final updatedSkill = CVSkillLevel(
                    skillId: value['id'] as int,
                    levelId: skillLevel.levelId,
                  );
                  viewModel.updateSkillLevel(index, updatedSkill);
                }
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown.search(
              items: viewModel.levels,
              selectedValue: selectedLevel,
              nameKey: 'title',
              hintText: AppStrings.selectLevel.tr(),
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
              onChanged: (value) {
                if (value.isNotEmpty && value['id'] != null) {
                  final updatedSkill = CVSkillLevel(
                    skillId: skillLevel.skillId,
                    levelId: value['id'] as int,
                  );
                  viewModel.updateSkillLevel(index, updatedSkill);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

