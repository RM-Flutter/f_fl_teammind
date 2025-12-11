import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/modules/payrolls/views/view_pdf_screen.dart';
import 'package:rmemp/platform/platform_is.dart';
import 'package:rmemp/routing/app_router.dart';
import '../models/payroll.model.dart';
import '../view_models/payroll_details.viewmodel.dart';
import 'widgets/payroll_details_body.widget.dart';
import 'widgets/payroll_details_header.widget.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _requireAuthentication();
      });
    }

    viewModel = PayrollDetailsViewModel();
    // viewModel.initializePayrollDetailsScreen(
    //     context: context,
    //     payrollId: widget.payroll?.id?.toString(),
    //     empId: widget.payroll?.userId?.toString());
  }

  Future<void> _requireAuthentication() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();
      final bool canCheck = await _auth.canCheckBiometrics;

      // Some devices return false negatives; we still try authenticate with device credentials allowed
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

      // Retry once after a short delay if it failed unexpectedly
      if (!didAuth && (isSupported || canCheck)) {
        await Future.delayed(const Duration(milliseconds: 300));
        didAuth = await _auth.authenticate(
          localizedReason: context.locale.languageCode == 'ar'
              ? 'الرجاء تأكيد هويتك لعرض كشف المرتب'
              : 'Please authenticate to view your payroll',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
            sensitiveTransaction: true,
            useErrorDialogs: true,
          ),
        );
      }
      if (!mounted) return;
      if (!didAuth) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _authPassed = true;
        });
      }
    } on PlatformException catch (e) {
      // Some devices throw even when credentials exist; do not pop immediately
      if (!mounted) return;
      // Try a final fallback attempt allowing device credentials
      try {
        final bool didAuth = await _auth.authenticate(
          localizedReason: context.locale.languageCode == 'ar'
              ? 'الرجاء تأكيد هويتك لعرض كشف المرتب'
              : 'Please authenticate to view your payroll',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
            sensitiveTransaction: true,
            useErrorDialogs: true,
          ),
        );
        if (!mounted) return;
        if (!didAuth) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _authPassed = true;
          });
        }
      } catch (_) {
        // Show message but keep user on page to avoid instant back navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.locale.languageCode == 'ar'
                  ? 'لا يمكن التحقق من الهوية على هذا الجهاز. يرجى التأكد من إعداد بصمة أو كلمة مرور للجهاز.'
                  : 'Authentication is not available. Please ensure device biometrics or screen lock is set up.',
            ),
          ),
        );
      }
    } catch (_) {
      // Any other unexpected error: do not pop automatically
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!_authPassed) {
      // White screen while waiting for authentication
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                context.locale.languageCode == 'ar'
                    ? 'جارٍ التحقق من الهوية...'
                    : 'Authenticating...',
                style: const TextStyle(color: Colors.black),
              ),
            ],
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
                                  constraints: BoxConstraints(
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
                              // await context
                              //     .pushNamed(AppRoutes.payrollsList.name, extra: {
                              //   'employeeName': employee?.name,
                              //   'employeeId': employee?.id?.toString()
                              // }, pathParameters: {
                              //   'lang': context.locale.languageCode
                              // })
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
      print("Failed to enable secure flag: '${e.message}'.");
    }
  }

  static Future<String?> getAndroidId() async {
    try {
      final id = await _channel.invokeMethod<String>('getAndroidId');
      return id;
    } on PlatformException catch (e) {
      print("Failed to get Android ID: '${e.message}'.");
      return null;
    }
  }
}
