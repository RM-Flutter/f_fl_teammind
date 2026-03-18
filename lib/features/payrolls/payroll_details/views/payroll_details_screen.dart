import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/payrolls/payroll_details/views/widgets/view_pdf_screen.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../controller/payroll_details_controller.dart';
import 'widgets/payroll_details_body_widget.dart';
import 'widgets/payroll_details_header_widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayrollDetailsScreen extends StatefulWidget {
  final PayrollModel? payroll;
  const PayrollDetailsScreen({super.key, required this.payroll});

  @override
  State<PayrollDetailsScreen> createState() => _PayrollDetailsScreenState();
}

class _PayrollDetailsScreenState extends State<PayrollDetailsScreen> {
  late final PayrollDetailsViewModel viewModel;
  final LocalAuthentication _auth = LocalAuthentication();
  bool _authPassed = false;
  bool _isAuthenticating = false;
  String? _authError;

  @override
  void initState() {
    super.initState();
    
    // على الويب، تخطي التحقق من الهوية
    if (kIsWeb || PlatformIs.web) {
      _authPassed = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SecureScreen.enableSecureFlag();
      }); // هذا يمنع السكرين شوت

      // Require device authentication on screen entry (فقط على الموبايل)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requireAuthentication();
      });
    }

    viewModel = PayrollDetailsViewModel();
  }

  Future<void> _requireAuthentication() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authError = null;
    });

    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() {
          _authError = context.locale.languageCode == 'ar'
              ? 'لا توجد وسيلة للتحقق من الهوية (بصمة أو كلمة مرور) مفعلة على هذا الجهاز.'
              : 'No authentication method (biometrics or screen lock) is enabled on this device.';
          _isAuthenticating = false;
        });
        return;
      }

      bool didAuth = await _auth.authenticate(
        localizedReason: context.locale.languageCode == 'ar'
            ? 'الرجاء تأكيد هويتك لعرض كشف المرتب'
            : 'Please authenticate to view your payroll',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN/Pattern/Password
          stickyAuth: true,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );

      if (!mounted) return;

      if (didAuth) {
        setState(() {
          _authPassed = true;
          _isAuthenticating = false;
        });
      } else {
        setState(() {
          _isAuthenticating = false;
          _authError = context.locale.languageCode == 'ar'
              ? 'فشل التحقق من الهوية. يرجى المحاولة مرة أخرى.'
              : 'Authentication failed. Please try again.';
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric Auth Error: $e');
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _authError = context.locale.languageCode == 'ar'
            ? 'حدث خطأ أثناء التحقق من الهوية: ${e.message}'
            : 'An error occurred during authentication: ${e.message}';
      });
    } catch (e) {
      debugPrint('Unexpected Auth Error: $e');
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _authError = context.locale.languageCode == 'ar'
            ? 'حدث خطأ غير متوقع.'
            : 'An unexpected error occurred.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authPassed) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isAuthenticating) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    context.locale.languageCode == 'ar'
                        ? 'جارٍ التحقق من الهوية...'
                        : 'Authenticating...',
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ] else if (_authError != null) ...[
                  const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _authError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _requireAuthentication,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.locale.languageCode == 'ar' ? 'إعادة المحاولة' : 'Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: ChangeNotifierProvider<PayrollDetailsViewModel>(
          create: (_) => viewModel,
          child: Consumer<PayrollDetailsViewModel>(
              builder: (context, viewModel, child) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PayrollDetailsHeaderWidget(
                        payroll: widget.payroll,
                      ),
                      Expanded(
                          child:
                              Center(child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: kIsWeb ? 1100 : double.infinity,
                                  ),
                                  child: PayrollDetailsBodyWidget(payroll: widget.payroll)))),
                      const SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Center(
                            child: CustomElevatedButton(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                titleSize: AppSizes.s12,
                                title: AppStrings.downloadFile.tr().toUpperCase(),
                                onPressed: () async{
                                  await viewModel.downloadPdf(context, widget.payroll!.id.toString(),
                                  );
                                  if(viewModel.localFilePath != null){
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(viewModel.localFilePath)));
                                  }
                                }
                            )),
                      ),
                    ],
                  ))),
    );
  }
}

class SecureScreen {
  static const MethodChannel _channel = MethodChannel('com.rightminddev.rmemp/secure');

  static Future<void> enableSecureFlag() async {
    try {
      await _channel.invokeMethod('enableSecureFlag');
    } on PlatformException catch (e) {
      debugPrint("Failed to enable secure flag: '${e.message}'.");
    }
  }

  static Future<String?> getAndroidId() async {
    try {
      final id = await _channel.invokeMethod<String>('getAndroidId');
      return id;
    } on PlatformException catch (e) {
      debugPrint("Failed to get Android ID: '${e.message}'.");
      return null;
    }
  }
}
