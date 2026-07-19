import 'dart:convert';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/cv_generator/views/common_ui/create_cv_education_tab.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/cv_generator/views/common_ui/create_cv_job_info_tab.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/cv_generator/views/common_ui/create_cv_personal_tab.dart';
import 'package:app_test/features/services/data/models/cv_data_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/cv_generator/controllers/create_cv_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/tab_bar_widget.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/models/smart_card_profile_models.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/repos/repo/smart_card_repo.dart';

class UpdateEmployeeInfoScreen extends StatefulWidget {
  final Map<String, dynamic> employee;
  final bool isPersonal;
  final int? companyId;

  const UpdateEmployeeInfoScreen({
    super.key,
    required this.employee,
    required this.isPersonal,
    this.companyId,
  });

  @override
  State<UpdateEmployeeInfoScreen> createState() =>
      _UpdateEmployeeInfoScreenState();
}

class _UpdateEmployeeInfoScreenState extends State<UpdateEmployeeInfoScreen>
    with SingleTickerProviderStateMixin {
  late final CreateCVViewModel viewModel;
  int selectIndex = 0;
  bool _isPremium = true;
  /// بيانات الموظف من آخر GET (لو فشل الـ GET نستخدم widget.employee)
  Map<String, dynamic>? _employeeData;
  // صورة الموظف – نفس أسلوب logo في company (مفتاح الباك: photo)
  List<dynamic> _photo = [];
  // Smart Card employee – more phones (UI فقط هنا، مش في CV)
  final List<TextEditingController> _morePhonesControllers = [];
  List<String> taps = [
    AppStrings.personal.tr().toUpperCase(),
    AppStrings.contact.tr().toUpperCase(),
    AppStrings.jopInfo.tr().toUpperCase(),
    AppStrings.education.tr().toUpperCase(),
  ];

  @override
  void initState() {
    super.initState();
    viewModel = CreateCVViewModel();
    _loadEmployeeData();
  }

  static int? _parseId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool _parseBool(dynamic v, {bool defaultVal = true}) {
    if (v == null) return defaultVal;
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return defaultVal;
  }

  /// Build CVDataModel from Smart Card employee map to pre-fill the form (مع country/state/city من الريسبونس)
  CVDataModel _employeeToCVDataModel(Map<String, dynamic> emp) {
    final name = emp['name']?.toString() ??
        emp['full_name']?.toString() ??
        emp['email']?.toString();
    return CVDataModel(
      personal: CVPersonalData(
        name: name,
        address: emp['address']?.toString(),
        countryKey: emp['country_key']?.toString(),
        countryId: _parseId(emp['country_id']) ?? _parseId(emp['country']?['id']),
        stateId: _parseId(emp['state_id']) ?? _parseId(emp['state']?['id']),
        cityId: _parseId(emp['city_id']) ?? _parseId(emp['city']?['id']),
      ),
      contact: CVContactData(
        phone: emp['phone']?.toString(),
        email: emp['email']?.toString(),
        linkedin: emp['linkedin']?.toString(),
        behance: emp['behance']?.toString(),
        whatsapp: emp['whatsapp']?.toString(),
      ),
      jobInfo: CVJobInfoData(
        currentJobTitle: emp['job_title']?.toString() ??
            emp['current_job_title']?.toString(),
        // In Smart Card update we don't use about_me; keep it only for CV compatibility.
        aboutMe: emp['about_me']?.toString(),
      ),
      education: null,
    );
  }

  /// بعض الـ endpoints بترجع الموظف جوا key زي data أو employee – الدالة دي بتظبطه لـ Map واحدة جاهزة للاستخدام
  Map<String, dynamic> _normalizeEmployeeMap(Map<String, dynamic> res) {
    final data = res['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    final emp = res['employee'];
    if (emp is Map) {
      return Map<String, dynamic>.from(emp);
    }
    return res;
  }

  Future<void> _loadEmployeeData() async {
    viewModel.setLoading(true);
    viewModel.setError(null);
    try {
      for (final c in _morePhonesControllers) {
        c.dispose();
      }
      _morePhonesControllers.clear();

      await viewModel.loadReferenceData(context);
      // جلب بيانات الموظف من الـ API (GET) ثم استخدام الريسبونس
      Map<String, dynamic> employeeMap = Map<String, dynamic>.from(widget.employee);
      if (widget.isPersonal) {
        final res = await SmartCardRepo.getEmployeeProfile(context);
        if (res.isNotEmpty) {
          final normalized = _normalizeEmployeeMap(res);
          _employeeData = normalized;
          employeeMap = normalized;
        }
      } else {
        final cId = widget.companyId;
        final eId = widget.employee['id'];
        if (cId != null && eId != null) {
          final id = eId is int ? eId : int.tryParse(eId.toString());
          if (id != null) {
            final res = await SmartCardRepo.getEmployeeInCompany(
              context,
              companyId: cId,
              employeeId: id,
            );
            if (res.isNotEmpty) {
              final normalized = _normalizeEmployeeMap(res);
              _employeeData = normalized;
              employeeMap = normalized;
            }
          }
        }
      }
      if (mounted) setState(() {});

      final cvData = _employeeToCVDataModel(employeeMap);
      final stateFromRes = employeeMap['state'] is Map ? Map<String, dynamic>.from(employeeMap['state'] as Map) : null;
      final cityFromRes = employeeMap['city'] is Map ? Map<String, dynamic>.from(employeeMap['city'] as Map) : null;
      await viewModel.loadExistingCVData(
        context,
        cvData,
        skipFullReferenceData: true,
        responseState: stateFromRes,
        responseCity: cityFromRes,
      );
      // Smart Card premium flag – when false we will hide Experience & Portfolio sections.
      _isPremium = _parseBool(employeeMap['is_premium'], defaultVal: true);
      // Initialise Smart Card media from employee profile (photo، works_gallery / video_gallery)
      final existing = SmartCardEmployeeProfileModel.fromMap(employeeMap);
      _photo = existing.photo ?? [];
      viewModel.worksGallery = existing.worksGallery ?? [];
      viewModel.videoGallery = existing.videoGallery ?? [];
      viewModel.websiteController.text = existing.website ?? '';
      viewModel.companyNameController.text = existing.companyName ?? '';
      viewModel.experiences = (existing.experiences ?? []).map((e) => CVExperience(
        companyName: e.companyName,
        countryId: e.countryId,
        stateId: e.stateId,
        dateFrom: e.dateFrom,
        dateTo: e.dateTo,
        jobTitle: e.jobTitle,
      )).toList();
      viewModel.portfolios = (existing.portfolios ?? []).map((e) => CVPortfolio(
        projectName: e.projectName,
        projectDescription: e.projectDescription,
        projectLink: e.projectLink,
        images: null,
      )).toList();
      final existingMorePhones = existing.morePhones ?? [];
      for (final p in existingMorePhones) {
        _morePhonesControllers.add(
          TextEditingController(text: p.phone?.toString() ?? ''),
        );
      }
      if (mounted) setState(() {});
    } catch (e) {
      viewModel.setError(e.toString());
    } finally {
      viewModel.setLoading(false);
    }
  }

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  /// URL أو base64 للعرض – العنصر إما Map{id, file} أو String (base64)
  String? _mediaDisplayUrl(dynamic item) {
    if (item is Map) return (item['file'] ?? item['thumbnail'])?.toString();
    if (item is String) return item;
    return null;
  }

  Future<void> _pickPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (xFile == null) return;
      final bytes = await xFile.readAsBytes();
      final encoded = base64Encode(bytes);
      setState(() => _photo = [encoded]);
    } catch (e) {
      debugPrint('Failed to pick photo: $e');
    }
  }

  Future<void> _saveToSmartCard() async {
    viewModel.setSubmitting(true);
    viewModel.setError(null);
    try {
      final vm = viewModel;
      final name = vm.nameController.text.trim();
      if (name.isEmpty) {
        viewModel.setError(AppStrings.pleaseEnterAtLeastName.tr());
        viewModel.setSubmitting(false);
        return;
      }
      // الـ API يتوقع الموديل كامل – نستخدم بيانات الـ GET إن وُجدت
      final existing = SmartCardEmployeeProfileModel.fromMap(_employeeData ?? widget.employee);
      final morePhones = _morePhonesControllers
          .map((c) => c.text.trim())
          .where((v) => v.isNotEmpty)
          .map((v) => SmartCardMorePhone(phone: v))
          .toList();
      final otherLinks = existing.otherLinks ?? [];
      final experiences = vm.experiences
          .map((e) => SmartCardExperienceItem(
        companyName: e.companyName,
        countryId: e.countryId,
        stateId: e.stateId,
        dateFrom: e.dateFrom,
        dateTo: e.dateTo,
        jobTitle: e.jobTitle,
      ))
          .toList();
      final portfolios = vm.portfolios
          .map((e) => SmartCardPortfolioItem(
        projectName: e.projectName,
        projectDescription: e.projectDescription,
        projectLink: e.projectLink,
      ))
          .toList();
      // تعليم – نفس المفتاح والبنية كما في Create CV (educations)
      final filteredEducations = vm.educations
          .where((e) =>
              (e.institutionName != null && e.institutionName!.isNotEmpty) ||
              (e.certificateName != null && e.certificateName!.isNotEmpty) ||
              e.countryId != null ||
              e.stateId != null ||
              e.dateFrom != null ||
              e.dateTo != null)
          .map((e) => e.toJson())
          .where((j) => j.isNotEmpty)
          .toList();
      final fullModel = SmartCardEmployeeProfileModel(
        photo: _photo.isEmpty ? null : _photo,
        name: name,
        business: existing.business,
        currentJobTitle: vm.currentJobTitleController.text.trim().isEmpty ? null : vm.currentJobTitleController.text.trim(),
        companyName: vm.companyNameController.text.trim().isEmpty
            ? existing.companyName
            : vm.companyNameController.text.trim(),
        countryId: vm.countryId ?? existing.countryId,
        stateId: vm.stateId ?? existing.stateId,
        cityId: vm.cityId ?? existing.cityId,
        address: vm.addressController.text.trim().isEmpty ? null : vm.addressController.text.trim(),
        countryKey: vm.countryKeyController.text.trim().isEmpty ? null : vm.countryKeyController.text.trim(),
        phone: vm.phoneController.text.trim().isEmpty ? null : vm.phoneController.text.trim(),
        email: vm.emailController.text.trim().isEmpty ? null : vm.emailController.text.trim(),
        // Smart Card expects full model – keep existing more_phones for now;
        // (CV UI لا تدير more_phones حالياً، فمش هنضيف حقول جديدة هنا عشان ما نلخبطش الـ CV).
        morePhones: morePhones.isEmpty ? null : morePhones,
        linkedin: vm.linkedinController.text.trim().isEmpty ? null : vm.linkedinController.text.trim(),
        behance: vm.behanceController.text.trim().isEmpty ? null : vm.behanceController.text.trim(),
        website: vm.websiteController.text.trim().isEmpty ? null : vm.websiteController.text.trim(),
        whatsapp: vm.whatsappController.text.trim().isEmpty ? null : vm.whatsappController.text.trim(),
        otherLinks: otherLinks.isEmpty ? null : otherLinks,
        portfolios: portfolios.isEmpty ? null : portfolios,
        experiences: experiences.isEmpty ? null : experiences,
        educations: filteredEducations.isEmpty ? null : filteredEducations,
        // works_gallery & video_gallery: نستخدم القيم الموجودة في الـ ViewModel (بعد التعديل من الشاشة)
        // API يتوقع Array بنفس المفاتيح works_gallery / video_gallery
        worksGallery: vm.worksGallery,
        videoGallery: vm.videoGallery,
      );
      final body = fullModel.toFullJson();
      body.remove('business'); // update employee info فقط – لا نرسل business للباك إند
      if (widget.isPersonal) {
        await SmartCardRepo.updateEmployee(context, body: body);
      } else {
        final cId = widget.companyId;
        final eId = _parseId((_employeeData ?? widget.employee)['id']);
        if (cId == null || eId == null) {
          viewModel.setError(AppStrings.missingCompanyOrEmployeeId.tr());
          viewModel.setSubmitting(false);
          return;
        }
        await SmartCardRepo.updateEmployeeInCompany(
          context,
          companyId: cId,
          employeeId: eId,
          body: body,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.updatedSuccessfully.tr())),
      );
      GoRouter.of(context).pop();
    } catch (e) {
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      viewModel.setError(msg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) viewModel.setSubmitting(false);
    }
  }

  @override
  void dispose() {
    for (final c in _morePhonesControllers) {
      c.dispose();
    }
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateCVViewModel>.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWithBookmark(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryButton),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
            onPressed: _goBack,
          ),
          title: AppStrings.updateMyInfo.tr(),
          titleStyle: TextStyle(
            color: Color(AppColors.secondaryButton),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          routeName: AppRoutes.updateEmployeeInfoScreen.name,
        ),
        body: Consumer<CreateCVViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTabBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectIndex == 0) ...[
                           if(_isPremium) SizedBox(height: 15,),
                           if(_isPremium) Center(
                              child: GestureDetector(
                                onTap: _pickPhoto,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        ImageProvider? provider;
                                        if (_photo.isNotEmpty) {
                                          final urlOrBase64 = _mediaDisplayUrl(_photo.first);
                                          if (urlOrBase64 != null) {
                                            if (urlOrBase64.startsWith('http') || urlOrBase64.startsWith('https')) {
                                              provider = NetworkImage(urlOrBase64);
                                            } else {
                                              try {
                                                provider = MemoryImage(base64Decode(urlOrBase64));
                                              } catch (_) {}
                                            }
                                          }
                                        }
                                        return CircleAvatar(
                                          radius: 70,
                                          backgroundColor: Colors.grey.shade200,
                                          backgroundImage: provider,
                                          child: provider == null
                                              ? const Icon(Icons.image, size: 32, color: Colors.grey)
                                              : null,
                                        );
                                      },
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Color(AppColors.secondaryButton),
                                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CreateCVPersonalTab(
                              viewModel: vm,
                              showCvDemographics: false,
                            ),
                          ],
                          if (selectIndex == 1) _buildEmployeeContactTab(vm),
                          if (selectIndex == 2)
                            CreateCVJobInfoTab(
                              viewModel: vm,
                              showCvOnlySections: false,
                              isSmartCardEmployee: true,
                              isPremium: _isPremium,
                            ),
                          if (selectIndex == 3)
                            CreateCVEducationTab(viewModel: vm),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: vm.isSubmitting ? null : _saveToSmartCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.secondaryButton),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: vm.isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                          : Text(
                        AppStrings.update.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton),
        borderRadius: BorderRadius.circular(AppSizes.s30),
      ),
      height: AppSizes.s55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s6, vertical: AppSizes.s6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: defaultTapBarItem(
          isVertical: false,
          items: taps,
          tapBarItemsWidth: MediaQuery.sizeOf(context).width * 0.95,
          selectIndex: selectIndex,
          enableScroll: kIsWeb ? false : true,
          onTapItem: (index) {
            setState(() => selectIndex = index);
          },
        ),
      ),
    );
  }

  /// Contact tab for Smart Card Employee (phone + more_phones + links)
  Widget _buildEmployeeContactTab(CreateCVViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactField(
            controller: vm.phoneController,
            label: AppStrings.phone.tr(),
            isRequired: true,
            hint: AppStrings.enterYourPhoneNumber.tr(),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          ...List.generate(_morePhonesControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _morePhonesControllers[i],
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: '${AppStrings.phone.tr()} ${i + 2}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      if (i >= 0 && i < _morePhonesControllers.length) {
                        _morePhonesControllers[i].dispose();
                        _morePhonesControllers.removeAt(i);
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            );
          }),
          if (_morePhonesControllers.isNotEmpty) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _morePhonesControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add),
              label: Text(
                '${AppStrings.phone.tr()} (${AppStrings.addOne.tr()})',
                style: const TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildContactField(
            controller: vm.emailController,
            label: AppStrings.email.tr(),
            isRequired: true,
            hint: AppStrings.enterYourEmail.tr(),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildContactField(
            controller: vm.linkedinController,
            label: AppStrings.linkedin.tr(),
            hint: AppStrings.enterYourLinkedInProfileURL.tr(),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          _buildContactField(
            controller: vm.behanceController,
            label: AppStrings.behance.tr(),
            hint: AppStrings.enterYourBehanceProfileURL.tr(),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          _buildContactField(
            controller: vm.websiteController,
            label: AppStrings.website.tr(),
            hint: 'https://...',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          _buildContactField(
            controller: vm.whatsappController,
            label: AppStrings.whatsapp.tr(),
            hint: AppStrings.enterYourWhatsAppNumber.tr(),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildContactField({
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
                color: Color(AppColors.secondaryButton),
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
