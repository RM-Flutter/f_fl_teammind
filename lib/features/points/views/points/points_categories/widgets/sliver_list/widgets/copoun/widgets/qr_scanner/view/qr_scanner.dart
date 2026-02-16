import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:app_test/features/points/views/points/points_categories/widgets/sliver_list/widgets/copoun/widgets/qr_scanner/controller/qr_scanner_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatefulWidget {
  var points;
  QRScannerScreen(this.points, {super.key});
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QRScannerController(),
      child: Consumer<HomeController>(
        builder: (context, value, child) {
          return Consumer<QRScannerController>(
            builder: (context, provider, child) {
              if (provider.isSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_)async {
                  if (context.mounted) {
                    await value.initializeHomeScreen(context, null);
                    if(widget.points == true){
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }else{
                      Navigator.pop(context);
                    }
                  }
                });
                provider.isSuccess = false;
              }
              return Scaffold( resizeToAvoidBottomInset: false,
                appBar: AppBar(title: Text(AppStrings.qrCodeScanner.tr())),
                body: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      onDetect: (BarcodeCapture barcode) {
                        if (barcode.barcodes.isNotEmpty) {
                          String? code = barcode.barcodes.first.rawValue;
                          if (code != null && provider.isRequestSent == false) {
                            provider.isRequestSent = true; // Prevent multiple requests
                            barcode.barcodes.clear();
                            provider.addRedeemGift(
                              context: context,
                              serial: code.toString(),
                            ).then((_) {
                              setState(() {
                                provider.isRequestSent = true;
                              });// Reset flag after completion
                              print("isRequestSent success --> ${provider.isRequestSent}");
                              if(provider.status == false){
                                if(widget.points == true){
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }else{
                                  Navigator.pop(context);
                                }}
                            }).catchError((_) {
                              provider.isRequestSent = false; // Reset flag on error
                              print("isRequestSent error --> ${provider.isRequestSent}");
                              if(widget.points == true){
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }else{
                                Navigator.pop(context);
                              }
                            });
                          }
                        }
                      },
                    ),
                    if (provider.isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}