import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import '../../../constants/user_consts.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../models/notification.model.dart';
import '../../../models/settings/user_settings.model.dart';

class FreeServicesViewModel extends ChangeNotifier {
  UserSettingsModel? userSettings;
  List<NotificationModel>? notifications;
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool _disposed = false;
  String? errorMessage;
  bool isVisitor = false;

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

  /// تحقق إذا كان المستخدم زائر
  bool _checkIfVisitor() {
    var jsonString = CacheHelper.getString("US1");
    return jsonString == null || jsonString.isEmpty || jsonString == "";
  }

  /// تحميل بيانات الصفحة الرئيسية
  Future<void> loadHomeData(BuildContext context) async {
    if (_disposed) return;
    updateLoadingStatus(loadingValue: true);

    // تحقق إذا كان زائر
    isVisitor = _checkIfVisitor();

    // تحميل بيانات المستخدم من الكاش (إذا كان مسجل)
    if (!isVisitor) {
      _loadUserSettingsFromCache();
      // تحميل الإشعارات (فقط للمستخدمين المسجلين)
      await _getNotifications(context);
    }

    if (!_disposed) {
      updateLoadingStatus(loadingValue: false);
    }
  }

  /// تحميل إعدادات المستخدم من الكاش
  void _loadUserSettingsFromCache() {
    try {
      var jsonString = CacheHelper.getString("US1");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        var gCache = json.decode(jsonString) as Map<String, dynamic>;
        UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
        userSettings = UserSettingsModel.fromJson(gCache);
      }
    } catch (e) {
      debugPrint('Error loading user settings from cache: $e');
    }
  }

  /// جلب الإشعارات من API
  Future<void> _getNotifications(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/home",
        context: context,
        query: null,
      );

      if (response.data['status'] == true) {
        var notificationData = response.data['notifications'] as List<dynamic>?;
        notifications = notificationData
            ?.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error getting notifications: $e');
    }
  }

  /// الحصول على اسم المستخدم المنسق
  String getFormattedUserName() {
    var jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      var cache = json.decode(jsonString) as Map<String, dynamic>;
      String fullName = cache['name'] ?? '';
      return _formatName(fullName);
    }
    return '';
  }

  String _formatName(String fullName) {
    List<String> names = fullName.split(" ");
    if (names.length < 2) return fullName;

    String firstName = names[0];
    String lastName = names.length > 1 ? names[1] : '';

    return "$firstName $lastName";
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
}
