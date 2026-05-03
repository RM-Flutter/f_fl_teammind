import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/animated_custom_dropdown/custom_dropdown.dart';
import 'package:app_test/features/services/models/cv_data.model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:app_test/features/services/view_models/create_cv.viewmodel.dart';

class CreateCVJobInfoTab extends StatelessWidget {
  final CreateCVViewModel viewModel;
  /// When false, hides CV-only sections (job dropdown, skills, languages/skills levels)
  /// so the tab can be reused for Smart Card update screens without extra fields.
  final bool showCvOnlySections;
  /// When true, we are in Smart Card Employee Update (not CV),
  /// so we show "Company Name" instead of "About Me" and
  /// we may hide Experiences/Portfolios based on premium flag.
  final bool isSmartCardEmployee;
  /// Smart Card premium flag for employee profile; when false
  /// we hide Experience & Portfolio sections in Smart Card mode.
  final bool isPremium;

  const CreateCVJobInfoTab({
    super.key,
    required this.viewModel,
    this.showCvOnlySections = true,
    this.isSmartCardEmployee = false,
    this.isPremium = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: viewModel.currentJobTitleController,
              label: AppStrings.currentJobTitle.tr(),
              isRequired: true,
              hint: AppStrings.enterYourCurrentJobTitle.tr(),
            ),
            const SizedBox(height: 16),

            if (showCvOnlySections) ...[
              _buildJobDropdown(),
              const SizedBox(height: 16),
            ],

            // In Smart Card Employee update: replace "About Me" with "Company Name"
            if (!isSmartCardEmployee)
              _buildTextField(
                controller: viewModel.aboutMeController,
                label: AppStrings.aboutMe.tr(),
                hint: AppStrings.addYourJobDescription.tr(),
                maxLines: 5,
              )
            else
              _buildTextField(
                controller: viewModel.companyNameController,
                label: AppStrings.companyName.tr(),
                hint: AppStrings.companyName.tr(),
              ),
            const SizedBox(height: 16),

            if (showCvOnlySections) ...[
              _buildSkillsMultiSelect(),
              const SizedBox(height: 16),

              _buildTextField(
                controller: viewModel.moreSkillsController,
                label: AppStrings.moreSkills.tr(),
                hint: AppStrings.enterAdditionalSkills.tr(),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
            ],

            // In Smart Card Employee, hide Experience/Portfolio completely when not premium.
            if (!isSmartCardEmployee ) ...[
              _buildExperiencesSection(context),
              const SizedBox(height: 24),
              _buildPortfoliosSection(),
            ],
            if(isSmartCardEmployee && isPremium)...[
              _buildExperiencesSection(context),
              const SizedBox(height: 24),
              _buildPortfoliosSection(),
            ],

            if (isSmartCardEmployee && isPremium == true) ...[
              const SizedBox(height: 24),
              _buildMediaGalleriesSection(context),
            ],
            if (showCvOnlySections) ...[
              const SizedBox(height: 24),
              _buildLanguagesLevelsSection(),
              const SizedBox(height: 24),
              _buildSkillsLevelsSection(),
            ],
          ],
        ),
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
          maxLines: maxLines,
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
                color: Color(AppColors.titleText),
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
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          items: viewModel.jobs
              .map((job) => DropdownMenuItem(
                    value: job['id'] as int?,
                    child: Text(
                      job['title'] ?? '',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
            color: Color(AppColors.titleText),
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

  /// عنصر الجاليري إما Map{id, file} أو String (base64) – نستخرج رابط/قيمة العرض
  static String? _mediaDisplayUrl(dynamic item) {
    if (item is Map) return (item['file'] ?? item['thumbnail'])?.toString();
    if (item is String) return item;
    return null;
  }

  Widget _buildMediaGalleriesSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.gallery.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.titleText),
          ),
        ),
        const SizedBox(height: 8),
        if (viewModel.worksGallery.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(viewModel.worksGallery.length, (i) {
              final value = viewModel.worksGallery[i];
              final urlOrBase64 = _mediaDisplayUrl(value);
              ImageProvider? provider;
              if (urlOrBase64 != null) {
                if (urlOrBase64.startsWith('http') || urlOrBase64.startsWith('https')) {
                  provider = NetworkImage(urlOrBase64);
                } else {
                  try {
                    provider = MemoryImage(base64Decode(urlOrBase64));
                  } catch (_) {}
                }
              }
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                      color: Colors.grey.shade200,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: provider != null
                        ? Image(image: provider, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () {
                      viewModel.removeWorksGalleryAt(i);
                    },
                  ),
                ],
              );
            }),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await _pickWorksImages(context);
          },
          icon: const Icon(Icons.photo_library),
          label: Text(
            AppStrings.gallery.tr(),
            style: const TextStyle(fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.videos.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.titleText),
          ),
        ),
        const SizedBox(height: 8),
        if (viewModel.videoGallery.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(viewModel.videoGallery.length, (i) {
              final value = viewModel.videoGallery[i];
              final urlOrBase64 = _mediaDisplayUrl(value);
              final isUrl = urlOrBase64 != null && urlOrBase64.startsWith('https');
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                      color: Colors.grey.shade200,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isUrl
                        ? Image.network(urlOrBase64, fit: BoxFit.cover)
                        : const Icon(Icons.videocam, size: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () {
                      viewModel.removeVideoGalleryAt(i);
                    },
                  ),
                ],
              );
            }),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await _pickVideos(context);
          },
          icon: const Icon(Icons.video_library),
          label: const Text(
            'Add video',
            style: TextStyle(fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Future<void> _pickWorksImages(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final List<String> files = [];
      for (final file in result.files) {
        if (file.bytes != null) {
          files.add(base64Encode(file.bytes!));
        }
      }
      if (files.isEmpty) return;
      viewModel.addWorksGalleryItems(files);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _pickVideos(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.video,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final List<String> files = [];
      for (final file in result.files) {
        if (file.bytes != null) {
          files.add(base64Encode(file.bytes!));
        }
      }
      if (files.isEmpty) return;
      viewModel.addVideoGalleryItems(files);
    } catch (_) {
      // ignore
    }
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
                color: Color(AppColors.titleText),
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

  Widget _buildExperienceItem(
      BuildContext context, int index, CVExperience experience) {
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
            // Company Name (Smart Card / CV-compatible – stored فقط محلياً في CVExperience)
            TextFormField(
              initialValue: experience.companyName ?? '',
              decoration: InputDecoration(
                labelText: AppStrings.companyName.tr(),
                hintText: AppStrings.companyName.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) {
                final updatedExp = CVExperience(
                  companyName: value,
                  countryId: experience.countryId,
                  stateId: experience.stateId,
                  dateFrom: experience.dateFrom,
                  dateTo: experience.dateTo,
                  jobTitle: experience.jobTitle,
                );
                viewModel.updateExperience(index, updatedExp);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: experience.jobTitle ?? '',
              decoration: InputDecoration(
                labelText: AppStrings.jobTitle.tr(),
                hintText: AppStrings.enterJobTitle.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) {
                final updatedExp = CVExperience(
                  companyName: experience.companyName,
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
              borderSide: const BorderSide(color: Colors.black),
              onChanged: (value) {
                if (value.isNotEmpty && value['id'] != null) {
                  final updatedExp = CVExperience(
                      companyName: experience.companyName,
                    countryId: value['id'] as int,
                    stateId: null,
                    dateFrom: experience.dateFrom,
                    dateTo: experience.dateTo,
                    jobTitle: experience.jobTitle,
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
                borderSide: const BorderSide(color: Colors.black),
                onChanged: (value) {
                  if (value.isNotEmpty && value['id'] != null) {
                    final updatedExp = CVExperience(
                      companyName: experience.companyName,
                      countryId: experience.countryId,
                      stateId: value['id'] as int,
                      dateFrom: experience.dateFrom,
                      dateTo: experience.dateTo,
                      jobTitle: experience.jobTitle,
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
                          companyName: experience.companyName,
                          countryId: experience.countryId,
                          stateId: experience.stateId,
                          dateFrom: DateFormat('yyyy-MM-dd').format(date),
                          dateTo: experience.dateTo,
                          jobTitle: experience.jobTitle,
                        );
                        viewModel.updateExperience(index, updatedExp);
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
                        final updatedExp = CVExperience(
                          companyName: experience.companyName,
                          countryId: experience.countryId,
                          stateId: experience.stateId,
                          dateFrom: experience.dateFrom,
                          dateTo: DateFormat('yyyy-MM-dd').format(date),
                          jobTitle: experience.jobTitle,
                        );
                        viewModel.updateExperience(index, updatedExp);
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
                color: Color(AppColors.titleText),
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
              initialValue: portfolio.projectName ?? '',
              decoration: InputDecoration(
                labelText: AppStrings.projectName.tr(),
                hintText: AppStrings.enterProjectName.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
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
              initialValue: portfolio.projectDescription ?? '',
              decoration: InputDecoration(
                labelText: AppStrings.projectDescription.tr(),
                hintText: AppStrings.enterProjectDescription.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
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
              initialValue: portfolio.projectLink ?? '',
              decoration: InputDecoration(
                labelText: AppStrings.projectLink.tr(),
                hintText: AppStrings.enterProjectLink.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
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
                color: Color(AppColors.titleText),
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
              borderSide: const BorderSide(color: Colors.black),
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
              borderSide: const BorderSide(color: Colors.black),
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
                color: Color(AppColors.titleText),
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
              borderSide: const BorderSide(color: Colors.black),
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
              borderSide: const BorderSide(color: Colors.black),
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

