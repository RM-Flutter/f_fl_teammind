import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/app_config.service.dart';
import 'package:app_test/features/more/language_settings/data/remote_data/language_repo.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

class LangControllerProvider extends ChangeNotifier{
  bool isLoading = false;
  bool isSuccess = true;
  String? errorMessage;
  setDeviceSysLang({context, state, notiToken}) async {
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    isLoading = true;
    notifyListeners();
    try {
      final response = await LanguageRepo.setDeviceLanguage(
        context: context,
        state: state,
        notiToken: notiToken,
        deviceInfo: {
          "device_unique_id": appConfigServiceProvider.deviceInformation.deviceUniqueId,
          "operating_system": "android",
          "operating_system_version": "QSR1.190920.001",
          "type": "phone",
        },
      );
      isLoading = false;
      isSuccess = true;
      debugPrint("i will put lang 2");
      CacheHelper.setString(key: "lang", value: state);
      debugPrint(response.data);
      notifyListeners();
    } catch (error) {
      isLoading = false;
      notifyListeners();
      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }
  }
}
