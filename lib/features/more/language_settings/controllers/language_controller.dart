import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/features/more/language_settings/data/remote_data/language_repo.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

class LangControllerProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = true;
  String? errorMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> setDeviceSysLang({required BuildContext context, required String state, String? notiToken}) async {
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    isLoading = true;
    _safeNotifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_users/v1/device_sys",
        context: context,
        data: {
          "action": "set",
          "key": "language",
          "value": state,
          "default": state,
          "device_info": {
            "device_unique_id": appConfigServiceProvider.deviceInformation.deviceUniqueId,
            "operating_system": "android",
            "operating_system_version": "QSR1.190920.001",
            "type": "phone",
            "notification_token": notiToken
          }
        },
      );
      isLoading = false;
      isSuccess = true;
      print("i will put lang 2");
      CacheHelper.setString(key: "lang", value: state);
      print(response.data);
      _safeNotifyListeners();
    } catch (error) {
      isLoading = false;
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
      _safeNotifyListeners();
    }
  }
}