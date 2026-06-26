import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/payrolls/payroll_details/views/widgets/view_pdf_screen.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../controller/payroll_details_controller.dart';
import 'widgets/payroll_details_body_widget.dart';
import 'widgets/payroll_details_header_widget.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';

class PayrollDetailsScreen extends StatefulWidget {
  final PayrollModel? payroll;
  const PayrollDetailsScreen({super.key, required this.payroll});

  @override
  State<PayrollDetailsScreen> createState() => _PayrollDetailsScreenState();
}

class _PayrollDetailsScreenState extends State<PayrollDetailsScreen> {
  late final PayrollDetailsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PayrollDetailsViewModel();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: kIsWeb ? 1100 : double.infinity,
                    ),
                    child: PayrollDetailsBodyWidget(payroll: widget.payroll),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Center(
                  child: CustomElevatedButton(
                    backgroundColor: Color(AppColors.secondaryButton),
                    titleSize: AppSizes.s12,
                    title: AppStrings.downloadFile.tr().toUpperCase(),
                    onPressed: () async {
                      await viewModel.downloadPdf(
                        context,
                        widget.payroll!.id.toString(),
                      );
                      if (viewModel.localFilePath != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              PdfViewerScreen(viewModel.localFilePath),
                        ));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecureScreen {
  static const MethodChannel _channel =
      MethodChannel('com.rightminddev.rmemp/secure');

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
