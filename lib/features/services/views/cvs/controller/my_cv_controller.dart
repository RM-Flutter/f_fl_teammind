import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/features/services/views/cvs/data/models/cv_data_model.dart';
import 'package:flutter/material.dart';

import '../../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';

class MyCVViewModel extends ChangeNotifier {
  CVDataModel? cvData;
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool _disposed = false;
  String? errorMessage;
  int currentTabIndex = 0;

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
    } catch (e) {
      debugPrint('Error loading CV data: $e');
      errorMessage = e.toString();
    }

    if (!_disposed) {
      updateLoadingStatus(loadingValue: false);
    }
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
        var data = response.data['data'];
        if (data != null) {
          cvData = CVDataModel.fromJson(data as Map<String, dynamic>);
          
          // حفظ البيانات في الكاش
          await CacheHelper.setString(
            key: "CV_DATA",
            value: json.encode(cvData!.toJson()),
          );
        }
        notifyListeners();
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

      final response = await DioHelper.postData(
        url: "/emp_requests/v1/cv/update",
        context: context,
        query: {},
        data: updatedData.toJson(),
      );

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
}

