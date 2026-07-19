import 'dart:convert';
import 'dart:io';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/services/data/models/cv_data_model.dart';
import 'package:app_test/features/services/data/repos/cv_reference_data_service.dart';

enum ImageSourceType { profile, newImage, none }

/// مقارنة آمنة للـ id (int أو string من الـ API) عشان الدروب داون يلاقي العنصر المحدد
int? _parseId(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

bool _idMatch(dynamic itemId, int? targetId) {
  if (targetId == null) return false;
  final id = _parseId(itemId);
  return id != null && id == targetId;
}

class CreateCVViewModel extends ChangeNotifier {
  /// للاستخدام من الـ UI (الدروب داون) لمقارنة id عنصر مع targetId (يدعم int و string)
  static bool idMatch(dynamic itemId, int? targetId) {
    if (targetId == null) return false;
    final id = _parseId(itemId);
    return id != null && id == targetId;
  }
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  bool _disposed = false;
  
  // Image handling
  ImageSourceType imageSourceType = ImageSourceType.profile; // Default: use profile photo
  String? profilePhotoUrl; // URL from cache
  XFile? selectedImageFile; // New image file
  final ImagePicker _imagePicker = ImagePicker();

  // Reference Data
  List<Map<String, dynamic>> jobs = [];
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> levels = [];
  List<Map<String, dynamic>> languages = [];
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> nationalities = [];

  // Form Data
  final TextEditingController nameController = TextEditingController();
  String? familyStatus;
  DateTime? birthday;
  String? gender;
  final TextEditingController countryKeyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  int? nationalityId;
  int? countryId;
  int? stateId;
  int? cityId;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController currentJobTitleController = TextEditingController();
  int? jobId;
  final TextEditingController aboutMeController = TextEditingController();
  // Smart Card only – company_name for employee profile (لا تُستخدم في CV)
  final TextEditingController companyNameController = TextEditingController();
  // Smart Card only – media galleries for employee profile. List<dynamic>: Map{id, file} أو String base64 (نفس أسلوب company)
  List<dynamic> worksGallery = [];
  List<dynamic> videoGallery = [];
  final TextEditingController moreSkillsController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController behanceController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();

  List<int> selectedSkills = [];
  List<CVExperience> experiences = [];
  List<CVEducation> educations = [];
  List<CVPortfolio> portfolios = [];
  List<CVLanguageLevel> languagesLevels = [];
  List<CVSkillLevel> skillsLevels = [];

  // Selected values for dropdowns
  Map<String, dynamic>? selectedCountry;
  Map<String, dynamic>? selectedState;
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedJob;
  Map<String, dynamic>? selectedNationality;

  @override
  void dispose() {
    _disposed = true;
    nameController.dispose();
    countryKeyController.dispose();
    phoneController.dispose();
    addressController.dispose();
    currentJobTitleController.dispose();
    aboutMeController.dispose();
    companyNameController.dispose();
    moreSkillsController.dispose();
    emailController.dispose();
    linkedinController.dispose();
    behanceController.dispose();
    websiteController.dispose();
    whatsappController.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setSubmitting(bool value) {
    isSubmitting = value;
    notifyListeners();
  }

  /// Extract readable error messages from API response when `status == false`.
  /// Supports both:
  /// - `{ field: [msg] }`  →  `field: msg`
  /// - `[msg1, msg2]`      →  each message in a new line.
  String _extractApiErrors(Map<String, dynamic> responseData, {String fallback = 'Failed to submit data'}) {
    final errors = responseData['errors'];

    if (errors == null) {
      return responseData['message']?.toString() ?? fallback;
    }

    final List<String> messages = [];

    if (errors is Map) {
      errors.forEach((key, value) {
        // ex: "current_job_title": ["this field is required"]
        if (value is List && value.isNotEmpty) {
          for (final v in value) {
            messages.add('$key: ${v.toString()}');
          }
        } else if (value != null) {
          messages.add('$key: ${value.toString()}');
        }
      });
    } else if (errors is List) {
      messages.addAll(errors.map((e) => e.toString()));
    } else {
      messages.add(errors.toString());
    }

    if (messages.isEmpty) {
      return responseData['message']?.toString() ?? fallback;
    }

    // Join all messages in separate lines for the user.
    return messages.join('\n');
  }

  void setError(String? error) {
    errorMessage = error;
    notifyListeners();
  }

  /// Load all reference data
  Future<void> loadReferenceData(BuildContext context) async {
    setLoading(true);
    setError(null);

    try {
      await Future.wait([
        _loadJobs(context),
        _loadSkills(context),
        _loadLevels(context),
        _loadLanguages(context),
        _loadCountries(context),
        _loadNationalities(context),
      ]);
      _loadProfilePhoto();
    } catch (e) {
      setError('Error loading reference data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Load profile photo from cache
  void _loadProfilePhoto() {
    try {
      var jsonString = CacheHelper.getString("US1");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        var userCache = json.decode(jsonString) as Map<String, dynamic>;
        profilePhotoUrl = userCache['photo'] as String?;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading profile photo: $e');
    }
  }

  /// Set image source type
  void setImageSourceType(ImageSourceType type) {
    imageSourceType = type;
    if (type == ImageSourceType.newImage) {
      selectedImageFile = null;
    }
    notifyListeners();
  }

  /// Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );
      if (image != null) {
        selectedImageFile = image;
        imageSourceType = ImageSourceType.newImage;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (image != null) {
        selectedImageFile = image;
        imageSourceType = ImageSourceType.newImage;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
  }

  /// Compress image
  Future<File?> _compressImage(File file) async {
    try {
      if (kIsWeb || PlatformIs.web) {
        return file; // On web, return as is
      }

      final targetPath =
          "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 75,
        minWidth: 600,
        minHeight: 600,
      );
      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file;
    }
  }

  /// Get current image to display
  String? getCurrentImageUrl() {
    switch (imageSourceType) {
      case ImageSourceType.profile:
        return profilePhotoUrl;
      case ImageSourceType.newImage:
        return selectedImageFile?.path;
      case ImageSourceType.none:
        return null;
    }
  }

  /// Get default image path based on gender
  String getDefaultImagePath() {
    // Use placeholder as default, or you can create separate images for male/female
    return 'assets/images/profiles_images/placeholder.png';
  }

  Future<void> _loadJobs(BuildContext context) async {
    jobs = await CVReferenceDataService.getJobs(context);
    notifyListeners();
  }

  Future<void> _loadSkills(BuildContext context) async {
    skills = await CVReferenceDataService.getSkills(context);
    notifyListeners();
  }

  Future<void> _loadLevels(BuildContext context) async {
    levels = await CVReferenceDataService.getLevels(context);
    notifyListeners();
  }

  Future<void> _loadLanguages(BuildContext context) async {
    languages = await CVReferenceDataService.getLanguages(context);
    notifyListeners();
  }

  Future<void> _loadCountries(BuildContext context) async {
    countries = await CVReferenceDataService.getCountries(context);
    if (countries.isNotEmpty && countryId == null) {
      final egypt = countries.firstWhere(
        (c) => (c['title'] ?? c['name'] ?? '').toString().toLowerCase().contains('egypt') || 
               (c['title'] ?? c['name'] ?? '').toString().contains('مصر'),
        orElse: () => <String, dynamic>{},
      );
      if (egypt.isNotEmpty && egypt['id'] != null) {
        await loadStates(context, egypt['id'] as int, clearStateAndCity: false);
      }
    }
    notifyListeners();
  }

  Future<void> _loadNationalities(BuildContext context) async {
    // Use countries endpoint for nationalities
    nationalities = await CVReferenceDataService.getCountries(context);
    if (nationalities.isNotEmpty && nationalityId == null) {
      final egypt = nationalities.firstWhere(
        (c) => (c['title'] ?? c['name'] ?? '').toString().toLowerCase().contains('egypt') || 
               (c['title'] ?? c['name'] ?? '').toString().contains('مصر'),
        orElse: () => <String, dynamic>{},
      );
      if (egypt.isNotEmpty && egypt['id'] != null) {
        nationalityId = egypt['id'] as int;
      }
    }
    notifyListeners();
  }

  /// Load states when country is selected.
  /// [clearStateAndCity] when true (default) clears state/city selection (e.g. when user changes country).
  /// Set to false when loading existing CV data so state/city remain and can be used to load cities.
  Future<void> loadStates(BuildContext context, int countryId, {bool clearStateAndCity = true}) async {
    this.countryId = countryId;
    selectedCountry = countries.isNotEmpty
        ? countries.firstWhere(
            (c) => _idMatch(c['id'], countryId),
            orElse: () => <String, dynamic>{},
          )
        : null;
    if (selectedCountry != null && selectedCountry!.isEmpty) selectedCountry = null;
    // Set country_key from country phone_code
    if (selectedCountry != null && selectedCountry!.isNotEmpty) {
      final phoneCode = selectedCountry!['phone_code'];
      if (phoneCode != null) {
        countryKeyController.text = phoneCode.toString();
      }
    }
    states = await CVReferenceDataService.getStates(context, countryId);
    if (clearStateAndCity) {
      stateId = null;
      selectedState = null;
      cityId = null;
      selectedCity = null;
      cities = [];
    }
    notifyListeners();
  }

  /// Load cities when state is selected
  Future<void> loadCities(BuildContext context, int stateId) async {
    this.stateId = stateId;
    selectedState = states.isNotEmpty
        ? states.firstWhere(
            (s) => _idMatch(s['id'], stateId),
            orElse: () => <String, dynamic>{},
          )
        : null;
    if (selectedState != null && selectedState!.isEmpty) selectedState = null;
    cities = await CVReferenceDataService.getCities(context, stateId);

    // لو كان فيه مدينة متخزنة (مثلاً جاية من الـ API)، نختارها تلقائياً
    if (cityId != null && cities.isNotEmpty) {
      selectedCity = cities.firstWhere(
        (c) => _idMatch(c['id'], cityId),
        orElse: () => <String, dynamic>{},
      );
      if (selectedCity != null && selectedCity!.isEmpty) selectedCity = null;
    } else {
      selectedCity = null;
    }
    notifyListeners();
  }

  /// Load states for experience/education without updating personal tab values
  Future<void> loadStatesForItem(BuildContext context, int countryId) async {
    // Only load states if not already loaded for this country
    final existingStates = states.where((s) => (s['country_id'] ?? s['country']?['id']) == countryId).toList();
    if (existingStates.isEmpty) {
      final loadedStates = await CVReferenceDataService.getStates(context, countryId);
      // Add country_id to each state and merge with existing states (avoid duplicates)
      final existingIds = states.map((s) => s['id']).toSet();
      for (var state in loadedStates) {
        if (!existingIds.contains(state['id'])) {
          // Ensure country_id is set
          state['country_id'] = countryId;
          states.add(state);
        }
      }
      notifyListeners();
    }
  }

  /// Add Experience
  void addExperience() {
    experiences.add(CVExperience());
    notifyListeners();
  }

  /// Remove Experience
  void removeExperience(int index) {
    if (index >= 0 && index < experiences.length) {
      experiences.removeAt(index);
      notifyListeners();
    }
  }

  /// Update Experience
  void updateExperience(int index, CVExperience experience) {
    if (index >= 0 && index < experiences.length) {
      experiences[index] = experience;
      notifyListeners();
    }
  }

  /// Add Education
  void addEducation() {
    educations.add(CVEducation());
    notifyListeners();
  }

  /// Remove Education
  void removeEducation(int index) {
    if (index >= 0 && index < educations.length) {
      educations.removeAt(index);
      notifyListeners();
    }
  }

  /// Update Education
  void updateEducation(int index, CVEducation education) {
    if (index >= 0 && index < educations.length) {
      educations[index] = education;
      notifyListeners();
    }
  }

  /// Add Portfolio
  void addPortfolio() {
    portfolios.add(CVPortfolio());
    notifyListeners();
  }

  /// Remove Portfolio
  void removePortfolio(int index) {
    if (index >= 0 && index < portfolios.length) {
      portfolios.removeAt(index);
      notifyListeners();
    }
  }

  /// Update Portfolio
  void updatePortfolio(int index, CVPortfolio portfolio) {
    if (index >= 0 && index < portfolios.length) {
      portfolios[index] = portfolio;
      notifyListeners();
    }
  }

  /// Add Language Level
  void addLanguageLevel() {
    languagesLevels.add(CVLanguageLevel());
    notifyListeners();
  }

  /// Remove Language Level
  void removeLanguageLevel(int index) {
    if (index >= 0 && index < languagesLevels.length) {
      languagesLevels.removeAt(index);
      notifyListeners();
    }
  }

  /// Update Language Level
  void updateLanguageLevel(int index, CVLanguageLevel languageLevel) {
    if (index >= 0 && index < languagesLevels.length) {
      languagesLevels[index] = languageLevel;
      notifyListeners();
    }
  }

  /// Add Skill Level
  void addSkillLevel() {
    skillsLevels.add(CVSkillLevel());
    notifyListeners();
  }

  /// Remove Skill Level
  void removeSkillLevel(int index) {
    if (index >= 0 && index < skillsLevels.length) {
      skillsLevels.removeAt(index);
      notifyListeners();
    }
  }

  /// Update Skill Level
  void updateSkillLevel(int index, CVSkillLevel skillLevel) {
    if (index >= 0 && index < skillsLevels.length) {
      skillsLevels[index] = skillLevel;
      notifyListeners();
    }
  }

  // ─── Smart Card Employee Media Helpers (works_gallery / video_gallery) ───
  void addWorksGalleryItems(List<String> items) {
    if (items.isEmpty) return;
    worksGallery.addAll(items); // base64 strings for new uploads
    notifyListeners();
  }

  void removeWorksGalleryAt(int index) {
    if (index < 0 || index >= worksGallery.length) return;
    worksGallery.removeAt(index);
    notifyListeners();
  }

  void addVideoGalleryItems(List<String> items) {
    if (items.isEmpty) return;
    videoGallery.addAll(items); // base64 strings for new uploads
    notifyListeners();
  }

  void removeVideoGalleryAt(int index) {
    if (index < 0 || index >= videoGallery.length) return;
    videoGallery.removeAt(index);
    notifyListeners();
  }

  /// Submit CV Data
  Future<bool> submitCV(BuildContext context) async {
    setSubmitting(true);
    setError(null);

    try {
      // Filter out empty experiences, educations, portfolios, etc.
      final filteredExperiences = experiences.where((exp) => 
        exp.jobTitle != null && exp.jobTitle!.isNotEmpty ||
        exp.dateFrom != null && exp.dateFrom!.isNotEmpty ||
        exp.countryId != null
      ).toList();
      
      final filteredEducations = educations.where((edu) => 
        edu.institutionName != null && edu.institutionName!.isNotEmpty ||
        edu.certificateName != null && edu.certificateName!.isNotEmpty ||
        edu.dateFrom != null && edu.dateFrom!.isNotEmpty
      ).toList();
      
      final filteredPortfolios = portfolios.where((port) => 
        port.projectName != null && port.projectName!.isNotEmpty ||
        port.projectLink != null && port.projectLink!.isNotEmpty
      ).toList();
      
      final filteredLanguagesLevels = languagesLevels.where((lang) => 
        lang.languageId != null && lang.levelId != null
      ).toList();
      
      final filteredSkillsLevels = skillsLevels.where((skill) => 
        skill.skillId != null && skill.levelId != null
      ).toList();

      // Build request model
      final requestModel = CreateCVRequestModel(
        name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
        familyStatus: familyStatus,
        birthday: birthday != null ? _formatDate(birthday!) : null,
        gender: gender,
        countryKey: countryKeyController.text.trim().isEmpty ? null : countryKeyController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        nationalityId: nationalityId,
        countryId: countryId,
        stateId: stateId,
        cityId: cityId,
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        currentJobTitle: currentJobTitleController.text.trim().isEmpty ? null : currentJobTitleController.text.trim(),
        jobId: jobId,
        aboutMe: aboutMeController.text.trim().isEmpty ? null : aboutMeController.text.trim(),
        moreSkills: moreSkillsController.text.trim().isEmpty ? null : moreSkillsController.text.trim(),
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        linkedin: linkedinController.text.trim().isEmpty ? null : linkedinController.text.trim(),
        behance: behanceController.text.trim().isEmpty ? null : behanceController.text.trim(),
        whatsapp: whatsappController.text.trim().isEmpty ? null : whatsappController.text.trim(),
        skills: selectedSkills.isEmpty ? null : selectedSkills,
        experiences: filteredExperiences.isEmpty ? null : filteredExperiences,
        educations: filteredEducations.isEmpty ? null : filteredEducations,
        portfolios: filteredPortfolios.isEmpty ? null : filteredPortfolios,
        languagesLevels: filteredLanguagesLevels.isEmpty ? null : filteredLanguagesLevels,
        skillsLevels: filteredSkillsLevels.isEmpty ? null : filteredSkillsLevels,
      );

      // Check if we need to send image
      bool hasImage = imageSourceType == ImageSourceType.newImage && selectedImageFile != null;
      bool useProfilePhoto = imageSourceType == ImageSourceType.profile && profilePhotoUrl != null;

      Response response;

      if (hasImage) {
        // Send with FormData if new image is selected
        final formData = await _buildFormDataWithImage(requestModel);
        response = await DioHelper.postFormData(
          url: "/emp_requests/v1/cv",
          context: context,
          query: {},
          formdata: formData,
          data: {},
        );
      } else {
        // Send JSON data normally
        // If using profile photo, we might need to send the URL or let backend handle it
        final jsonData = requestModel.toJson();
        // if (useProfilePhoto) {
        //   jsonData['use_profile_photo'] = true;
        // } else if (imageSourceType == ImageSourceType.none) {
        //   jsonData['use_default_photo'] = true;
        // }
        
        response = await DioHelper.postData(
          url: "/emp_requests/v1/cv",
          context: context,
          query: {},
          data: jsonData,
        );
      }

      if (response.data['status'] == true) {
        setSubmitting(false);
        return true;
      } else {
        setError(_extractApiErrors(
          response.data as Map<String, dynamic>,
          fallback: 'Failed to create CV',
        ));
        setSubmitting(false);
        return false;
      }
    } catch (e) {
      setError('Error submitting CV: $e');
      setSubmitting(false);
      return false;
    }
  }

  /// Build FormData with image
  Future<FormData> _buildFormDataWithImage(CreateCVRequestModel requestModel) async {
    final jsonData = requestModel.toJson();
    
    // Convert JSON data to FormData
    final formDataMap = <String, dynamic>{};
    
    // Add all JSON fields to form data (only non-null and non-empty)
    jsonData.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          // Handle lists (experiences, educations, etc.) - only add if not empty
          if (value.isNotEmpty) {
            // Filter out empty objects from lists
            final filteredList = value.where((item) {
              if (item is Map) {
                return item.isNotEmpty; // Only include non-empty maps
              }
              return true;
            }).toList();
            if (filteredList.isNotEmpty) {
              formDataMap[key] = json.encode(filteredList);
            }
          }
        } else if (value is String) {
          // Only add non-empty strings
          if (value.isNotEmpty) {
            formDataMap[key] = value;
          }
        } else {
          // For numbers, booleans, etc.
          formDataMap[key] = value.toString();
        }
      }
    });

    // Add image file
    if (selectedImageFile != null) {
      if (kIsWeb || PlatformIs.web) {
        final bytes = await selectedImageFile!.readAsBytes();
        formDataMap['photo'] = MultipartFile.fromBytes(
          bytes,
          filename: selectedImageFile!.name,
        );
      } else {
        File? compressedFile = await _compressImage(File(selectedImageFile!.path));
        if (compressedFile != null) {
          formDataMap['photo'] = await MultipartFile.fromFile(
            compressedFile.path,
            filename: selectedImageFile!.name,
          );
        }
      }
    }

    return FormData.fromMap(formDataMap);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Load existing CV data into form fields.
  /// [skipFullReferenceData] true = من شاشة Update Employee: مبنستدعيش loadReferenceData تاني، بنستدعي فقط loadStates و loadCities.
  /// [responseState] و [responseCity] = من ريسبونس الـ API (مثلاً employee['state']) عشان نضيفهم للقائمة لو مش موجودين فالدروب داون يعرض القيمة.
  Future<void> loadExistingCVData(BuildContext context, CVDataModel cvData, {bool skipFullReferenceData = false, Map<String, dynamic>? responseState, Map<String, dynamic>? responseCity}) async {
    setLoading(true);
    try {
      if (!skipFullReferenceData) {
        await loadReferenceData(context);
      } else {
        // تحميل الدول فقط ثم المحافظات والمدن (لشاشة Update Employee — بدون استدعاء كل الـ endpoints)
        if (countries.isEmpty) {
          await _loadCountries(context);
        }
      }

      // Load personal data
      final personal = cvData.personal;
      if (personal != null) {
        nameController.text = personal.name ?? '';
        familyStatus = personal.familyStatus;
        if (personal.birthday != null) {
          try {
            birthday = DateTime.parse(personal.birthday!.split(' ')[0]);
          } catch (e) {
            debugPrint('Error parsing birthday: $e');
          }
        }
        gender = personal.gender;
        nationalityId = personal.nationalityId ?? nationalityId;
        countryId = personal.countryId ?? countryId;
        stateId = personal.stateId;
        cityId = personal.cityId;
        addressController.text = personal.address ?? '';

        // استدعاء endpoints الـ state والـ city عشان الدروب داون يعرض القيم من الريسبونس
        if (countryId != null) {
          await loadStates(context, countryId!, clearStateAndCity: false);
          if (responseState != null && stateId != null && states.every((s) => !_idMatch(s['id'], stateId))) {
            states = [...states, {'id': stateId, 'title': responseState['title']?.toString() ?? responseState['name']?.toString() ?? ''}];
            notifyListeners();
          }
          if (stateId != null) {
            await loadCities(context, stateId!);
            if (responseCity != null && cityId != null && cities.every((c) => !_idMatch(c['id'], cityId))) {
              cities = [...cities, {'id': cityId, 'title': responseCity['title']?.toString() ?? responseCity['name']?.toString() ?? ''}];
              notifyListeners();
            }
          }
        }
      }
      
      // Load contact data
      final contact = cvData.contact;
      if (contact != null) {
        phoneController.text = contact.phone ?? '';
        emailController.text = contact.email ?? '';
        linkedinController.text = contact.linkedin ?? '';
        behanceController.text = contact.behance ?? '';
        whatsappController.text = contact.whatsapp ?? '';
      }
      
      // Load job info
      final jobInfo = cvData.jobInfo;
      if (jobInfo != null) {
        currentJobTitleController.text = jobInfo.currentJobTitle ?? '';
        jobId = jobInfo.jobId;
        aboutMeController.text = jobInfo.aboutMe ?? '';
        moreSkillsController.text = jobInfo.moreSkills ?? '';
        selectedSkills = jobInfo.skills ?? [];
        experiences = jobInfo.experiences ?? [];
        portfolios = jobInfo.portfolios ?? [];
        languagesLevels = jobInfo.languagesLevels ?? [];
        skillsLevels = jobInfo.skillsLevels ?? [];
      }
      
      // Load education
      educations = cvData.education ?? [];
      
      notifyListeners();
    } catch (e) {
      setError('Error loading CV data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Update CV using PUT method
  Future<bool> updateCV(BuildContext context) async {
    setSubmitting(true);
    setError(null);

    try {
      // Filter out empty experiences, educations, portfolios, etc.
      final filteredExperiences = experiences.where((exp) => 
        exp.jobTitle != null && exp.jobTitle!.isNotEmpty ||
        exp.dateFrom != null && exp.dateFrom!.isNotEmpty ||
        exp.countryId != null
      ).toList();
      
      final filteredEducations = educations.where((edu) => 
        edu.institutionName != null && edu.institutionName!.isNotEmpty ||
        edu.certificateName != null && edu.certificateName!.isNotEmpty ||
        edu.dateFrom != null && edu.dateFrom!.isNotEmpty
      ).toList();
      
      final filteredPortfolios = portfolios.where((port) => 
        port.projectName != null && port.projectName!.isNotEmpty ||
        port.projectLink != null && port.projectLink!.isNotEmpty
      ).toList();
      
      final filteredLanguagesLevels = languagesLevels.where((lang) => 
        lang.languageId != null && lang.levelId != null
      ).toList();
      
      final filteredSkillsLevels = skillsLevels.where((skill) => 
        skill.skillId != null && skill.levelId != null
      ).toList();

      // Build request model
      final requestModel = CreateCVRequestModel(
        name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
        familyStatus: familyStatus,
        birthday: birthday != null ? _formatDate(birthday!) : null,
        gender: gender,
        countryKey: countryKeyController.text.trim().isEmpty ? null : countryKeyController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        nationalityId: nationalityId,
        countryId: countryId,
        stateId: stateId,
        cityId: cityId,
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        currentJobTitle: currentJobTitleController.text.trim().isEmpty ? null : currentJobTitleController.text.trim(),
        jobId: jobId,
        aboutMe: aboutMeController.text.trim().isEmpty ? null : aboutMeController.text.trim(),
        moreSkills: moreSkillsController.text.trim().isEmpty ? null : moreSkillsController.text.trim(),
        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        linkedin: linkedinController.text.trim().isEmpty ? null : linkedinController.text.trim(),
        behance: behanceController.text.trim().isEmpty ? null : behanceController.text.trim(),
        whatsapp: whatsappController.text.trim().isEmpty ? null : whatsappController.text.trim(),
        skills: selectedSkills.isEmpty ? null : selectedSkills,
        experiences: filteredExperiences.isEmpty ? null : filteredExperiences,
        educations: filteredEducations.isEmpty ? null : filteredEducations,
        portfolios: filteredPortfolios.isEmpty ? null : filteredPortfolios,
        languagesLevels: filteredLanguagesLevels.isEmpty ? null : filteredLanguagesLevels,
        skillsLevels: filteredSkillsLevels.isEmpty ? null : filteredSkillsLevels,
      );

      // Check if we need to send image
      bool hasImage = imageSourceType == ImageSourceType.newImage && selectedImageFile != null;
      bool useProfilePhoto = imageSourceType == ImageSourceType.profile && profilePhotoUrl != null;

      Response response;

      if (hasImage) {
        // Send with FormData if new image is selected
        final formData = await _buildFormDataWithImage(requestModel);
        // Use PUT with FormData
        final dio = Dio();
        final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
        final deviceUniqueId = appConfigServiceProvider.deviceInformation.deviceUniqueId;
        
        dio.options.headers = {
          'Accept': 'application/json',
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer ${appConfigServiceProvider.token}',
          'lang': CacheHelper.getString("lang") ?? "en",
          if (deviceUniqueId.isNotEmpty) 'device-unique-id': deviceUniqueId,
        };
        
        response = await dio.put(
          "${AppConstants.baseUrl}/emp_requests/v1/cv",
          queryParameters: {},
          data: formData,
        );
      } else {
        // Send JSON data with PUT
        final jsonData = requestModel.toJson();
        // if (useProfilePhoto) {
        //   jsonData['use_profile_photo'] = true;
        // } else if (imageSourceType == ImageSourceType.none) {
        //   jsonData['use_default_photo'] = true;
        // }
        
        response = await DioHelper.putData(
          url: "/emp_requests/v1/cv",
          context: context,
          query: {},
          data: jsonData,
        );
      }

      if (response.data['status'] == true) {
        setSubmitting(false);
        return true;
      } else {
        setError(_extractApiErrors(
          response.data as Map<String, dynamic>,
          fallback: 'Failed to update CV',
        ));
        setSubmitting(false);
        return false;
      }
    } catch (e) {
      setError('Error updating CV: $e');
      setSubmitting(false);
      return false;
    }
  }
}

