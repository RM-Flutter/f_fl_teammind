import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/app_config_service.dart';
import '../data/repo/forgot_password_repo.dart';
import 'package:app_test/core/utils/app_styles.dart';

class ForgotPasswordController extends ChangeNotifier {
  bool goToChooseForgotMethod = false;
  bool codeSent = false;
  bool isPhoneLogin = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final GlobalKey<FormState> codeFormKey = GlobalKey<FormState>();
  Map<String, dynamic>? forgotPasswordMethods;
  String? uuid;
  String? sendType;

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    phoneController.dispose();
    countryCodeController.dispose();
    super.dispose();
  }

  void init(bool isPhoneLogin) {
    this.isPhoneLogin = (isPhoneLogin == true)? isPhoneLogin : true;  }

  void toggleLoginMethod(bool newValue) {
    isPhoneLogin = newValue;
    notifyListeners();
  }

  // First : prepare forgot password operation
  Future<void> prepeareForgotPassword(BuildContext context) async {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(context, listen: false);
    if ((isPhoneLogin && phoneController.text.isNotEmpty) ||
        (!isPhoneLogin && emailController.text.isNotEmpty)) {
      final result = await ForgotPasswordRepo.prepareForgetPassword(
          context: context,
          username: isPhoneLogin ? phoneController.text : emailController.text,
          deviceUniqueId:
          appConfigServiceProvider.deviceInformation.deviceUniqueId);
      if (result.success &&
          result.data != null &&
          result.data?['forgot_password_prepare'] == true &&
          (result.data?['uuid'] != null && result.data?['uuid'] != '') &&
          (result.data?['forgot_password_methods'] != null &&
              result.data?['forgot_password_methods'] != {})) {
        forgotPasswordMethods = result.data?['forgot_password_methods'];
        uuid = result.data?['uuid'];
        goToChooseForgotMethod = true;
        notifyListeners();
        return;
      } else {
        debugPrint("ERROR FROM ${result.message!}");
        Fluttertoast.showToast(
            msg: result.message!,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }
    } else {
      showToast(
        AppStrings.formIsInvalid.tr(),
        context: context,
        backgroundColor: Colors.red,
        textStyle: AppStyles.whiteContent(context),
        duration: const Duration(seconds: 5),
        position: StyledToastPosition.bottom,
      );
      return;
    }
  }

  // second : choose forgot password verification method
  Future<void> chooseForgotPasswordMethod(
      {required BuildContext context}) async {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(context, listen: false);
    if (uuid == null ||
        (uuid?.isEmpty ?? true) ||
        sendType == null ||
        (sendType?.isEmpty ?? true)) {
      AlertsService.error(
        title: AppStrings.error.tr(),
        context: context,
        message: AppStrings.invalidUUIDOrSentType.tr(),
      );
      return;
    }
    AlertsService.showLoading(context);
    final completePhoneNumber = (countryCodeController.text.isEmpty
        ? '+20${phoneController.text}'
        : countryCodeController.text + phoneController.text)
        .trim();
    final result = await ForgotPasswordRepo.forgetPassword(
        context: context,
        username: isPhoneLogin ? completePhoneNumber : emailController.text,
        sendType: sendType!,
        uuid: uuid!,
        deviceUniqueId:
        appConfigServiceProvider.deviceInformation.deviceUniqueId);
    Navigator.pop(context);

    if (result.success && result.data != null) {
      codeSent = true;
      notifyListeners();
      return;
    } else {
      debugPrint("ERROR FROM HERE");
      Fluttertoast.showToast(
          msg: result.message!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
  }

  // Finally send new password and forgot password verification code to reset forgotten password with the new password
  Future<void> resetNewPasswordWithCodeAndNewPassword(
      {required BuildContext context, mak}) async {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(context, listen: false);
    if (codeFormKey.currentState?.validate() == true) {
      final completePhoneNumber = (countryCodeController.text.isEmpty
          ? '+20${phoneController.text}'
          : countryCodeController.text + phoneController.text)
          .trim();
      final result = await ForgotPasswordRepo.codeNewPassword(
          context: context,
          code: codeController.text,
          newPassword: newPasswordController.text,
          username: isPhoneLogin ? completePhoneNumber : emailController.text,
          sendType: sendType!,
          uuid: uuid!,
          deviceUniqueId:
          appConfigServiceProvider.deviceInformation.deviceUniqueId);
      if (result.success && result.data != null) {
        if(mak == null) Navigator.pop(context, result);
        if(mak != null){ mak();}
      } else {
        Fluttertoast.showToast(
            msg: result.message!,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }
    }
  }
}
