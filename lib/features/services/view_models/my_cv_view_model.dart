import 'dart:convert';
import 'dart:io';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:flutter/material.dart';

import '../models/cv_data_model.dart';

enum ImageSourceType { profile, newImage, none }

class MyCVViewModel extends ChangeNotifier {
  CVDataModel? cvData;
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool _disposed = false;
  String? errorMessage;
  int currentTabIndex = 0;
  
  // Image handling
  ImageSourceType imageSourceType = ImageSourceType.profile; // Default: use profile photo
  String? profilePhotoUrl; // URL from cache
  XFile? selectedImageFile; // New image file
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _disposed = true;
    scrollController.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void updateLoadingStatus({required bool loadingValue}) {
    isLoading = loadingValue;
    notifyListeners();
  }

  void updateTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  /// تحميل بيانات الـ CV
  Future<void> loadCVData(BuildContext context) async {
    if (_disposed) return;
    updateLoadingStatus(loadingValue: true);

    try {
      // أولاً: محاولة جلب البيانات من الكاش
      _loadCVDataFromCache();

      // ثانياً: جلب البيانات من الـ API
      await _fetchCVDataFromAPI(context);
      
      // تحميل صورة البروفايل
      _loadProfilePhoto();
    } catch (e) {
      debugPrint('Error loading CV data: $e');
      errorMessage = e.toString();
    }

    if (!_disposed) {
      updateLoadingStatus(loadingValue: false);
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
    // Use placeholder as default
    return 'assets/images/profiles_images/placeholder.png';
  }

  /// تحميل بيانات الـ CV من الكاش
  void _loadCVDataFromCache() {
    try {
      // جلب بيانات المستخدم من الكاش لعرضها كبيانات أولية
      var jsonString = CacheHelper.getString("US1");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        var userCache = json.decode(jsonString) as Map<String, dynamic>;
        
        // تحويل بيانات المستخدم إلى بيانات CV
        cvData = CVDataModel(
          personal: CVPersonalData(
            name: userCache['name'],
            birthday: userCache['birthday'],
            // باقي الحقول ستأتي من API
          ),
          contact: CVContactData(
            phone: userCache['phone'],
            email: userCache['email'],
          ),
          jobInfo: CVJobInfoData(
            currentJobTitle: userCache['job_title'],
          ),
        );
      }

      // محاولة جلب بيانات CV الكاملة من الكاش
      var cvCacheString = CacheHelper.getString("CV_DATA");
      if (cvCacheString != null && cvCacheString.isNotEmpty) {
        var cvCache = json.decode(cvCacheString) as Map<String, dynamic>;
        cvData = CVDataModel.fromJson(cvCache);
      }
    } catch (e) {
      debugPrint('Error loading CV data from cache: $e');
    }
  }

  /// جلب بيانات الـ CV من الـ API
  Future<void> _fetchCVDataFromAPI(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/cv",
        context: context,
        query: {},
      );

      if (response.data['status'] == true) {
        // البيانات موجودة في 'cv' وليس 'data'
        var data = response.data['cv'] ?? response.data['data'];
        if (data != null) {
          debugPrint('CV Data received: ${data.toString()}');
          // تحويل البيانات من API response إلى CVDataModel
          cvData = _convertAPIResponseToCVDataModel(data as Map<String, dynamic>);
          debugPrint('CV Data converted: ${cvData?.personal?.name}, ${cvData?.personal?.countryTitle}');
          
          // حفظ البيانات في الكاش
          await CacheHelper.setString(
            key: "CV_DATA",
            value: json.encode(cvData!.toJson()),
          );
        } else {
          debugPrint('CV Data is null in response');
        }
        notifyListeners();
      } else {
        debugPrint('CV API response status is false: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error fetching CV data from API: $e');
      // في حالة الخطأ، نستخدم البيانات من الكاش إذا كانت موجودة
    }
  }

  /// الحصول على اسم المستخدم
  String getUserName() {
    return cvData?.personal?.name ?? '';
  }

  /// الحصول على صورة المستخدم
  String? getUserPhoto() {
    var jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      var cache = json.decode(jsonString) as Map<String, dynamic>;
      return cache['photo'];
    }
    return null;
  }

  /// تحديث بيانات الـ CV
  Future<bool> updateCVData(BuildContext context, CVDataModel updatedData) async {
    try {
      updateLoadingStatus(loadingValue: true);

      // Check if we need to send image
      bool hasImage = imageSourceType == ImageSourceType.newImage && selectedImageFile != null;
      bool useProfilePhoto = imageSourceType == ImageSourceType.profile && profilePhotoUrl != null;

      Response response;

      if (hasImage) {
        // Send with FormData if new image is selected
        final formData = await _buildFormDataWithImage(updatedData);
        response = await DioHelper.postFormData(
          url: "/emp_requests/v1/cv/update",
          context: context,
          query: {},
          formdata: formData,
          data: {},
        );
      } else {
        // Send JSON data normally
        final jsonData = updatedData.toJson();
        // if (useProfilePhoto) {
        //   jsonData['use_profile_photo'] = true;
        // } else if (imageSourceType == ImageSourceType.none) {
        //   jsonData['use_default_photo'] = true;
        // }
        
        response = await DioHelper.postData(
          url: "/emp_requests/v1/cv/update",
          context: context,
          query: {},
          data: jsonData,
        );
      }

      if (response.data['status'] == true) {
        cvData = updatedData;
        
        // تحديث الكاش
        await CacheHelper.setString(
          key: "CV_DATA",
          value: json.encode(cvData!.toJson()),
        );
        
        notifyListeners();
        updateLoadingStatus(loadingValue: false);
        return true;
      }
      
      updateLoadingStatus(loadingValue: false);
      return false;
    } catch (e) {
      debugPrint('Error updating CV data: $e');
      updateLoadingStatus(loadingValue: false);
      return false;
    }
  }

  /// Build FormData with image
  Future<FormData> _buildFormDataWithImage(CVDataModel updatedData) async {
    final jsonData = updatedData.toJson();
    
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
        } else if (value is Map) {
          // Handle nested objects - only add if not empty
          if (value.isNotEmpty) {
            formDataMap[key] = json.encode(value);
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

  /// تحويل API response إلى CVDataModel
  CVDataModel _convertAPIResponseToCVDataModel(Map<String, dynamic> json) {
    final nationality = json['nationality'] as Map<String, dynamic>?;
    final country = json['country'] as Map<String, dynamic>?;
    final state = json['state'] as Map<String, dynamic>?;
    final city = json['city'] as Map<String, dynamic>?;
    final job = json['job'] as Map<String, dynamic>?;
    final skills = json['skills'] as List<dynamic>?;
    
    return CVDataModel(
      personal: CVPersonalData(
        name: json['name'] as String?,
        familyStatus: json['family_status'] as String?,
        birthday: json['birthday'] as String?,
        gender: json['gender'] as String?,
        nationalityId: nationality?['id'] as int?,
        nationalityTitle: nationality?['title'] as String? ?? nationality?['name'] as String?,
        countryId: country?['id'] as int?,
        countryTitle: country?['title'] as String? ?? country?['name'] as String?,
        stateId: state?['id'] as int?,
        stateTitle: state?['title'] as String? ?? state?['name'] as String?,
        cityId: city?['id'] as int?,
        cityTitle: city?['title'] as String? ?? city?['name'] as String?,
        address: json['address'] as String?,
      ),
      contact: CVContactData(
        phone: json['phone']?.toString(),
        email: json['email'] as String?,
        linkedin: json['linkedin'] as String?,
        behance: json['behance'] as String?,
        whatsapp: json['whatsapp'] as String?,
      ),
      jobInfo: CVJobInfoData(
        currentJobTitle: json['current_job_title'] as String?,
        jobId: job?['id'] as int?,
        jobTitle: job?['title'] as String? ?? job?['name'] as String?,
        aboutMe: json['about_me'] as String?,
        moreSkills: json['more_skills'] as String?,
        skills: skills
            ?.map((s) => (s as Map<String, dynamic>)['id'] as int)
            .toList(),
        skillsTitles: skills
            ?.map((s) {
              final skillMap = s as Map<String, dynamic>;
              return skillMap['title'] as String? ?? skillMap['name'] as String? ?? '';
            })
            .where((title) => title.isNotEmpty)
            .toList(),
        experiences: (json['experiences'] as List<dynamic>?)
            ?.map((e) => CVExperience.fromJson(e as Map<String, dynamic>))
            .toList(),
        portfolios: (json['portfolios'] as List<dynamic>?)
            ?.map((p) => CVPortfolio.fromJson(p as Map<String, dynamic>))
            .toList(),
        languagesLevels: (json['languages_levels'] as List<dynamic>?)
            ?.map((l) => CVLanguageLevel.fromJson(l as Map<String, dynamic>))
            .toList(),
        skillsLevels: (json['skills_levels'] as List<dynamic>?)
            ?.map((s) => CVSkillLevel.fromJson(s as Map<String, dynamic>))
            .toList(),
      ),
      education: (json['educations'] as List<dynamic>?)
          ?.map((e) => CVEducation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

