import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/modules/payrolls/views/view_pdf_screen.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SecureScreen.enableSecureFlag();
    }); // هذا يمنع السكرين شوت

    viewModel = PayrollDetailsViewModel();
    // viewModel.initializePayrollDetailsScreen(
    //     context: context,
    //     payrollId: widget.payroll?.id?.toString(),
    //     empId: widget.payroll?.userId?.toString());
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
                          child:
                              PayrollDetailsBodyWidget(payroll: widget.payroll)),
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
