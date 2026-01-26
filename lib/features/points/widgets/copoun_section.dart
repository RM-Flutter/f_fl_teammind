// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:app_test/core/constants/app_images.dart';
// import 'package:app_test/core/constants/app_sizes.dart';
// import 'package:app_test/core/constants/app_strings.dart';
// import 'package:app_test/core/utils/media_query_values.dart';
// import 'package:provider/provider.dart';
//
// import '../../../controller/home_model/home_model.dart';
// import 'package:app_test/features/points/core/functions/show_progress_indicator.dart';
// import '../logic/prize_cubit/prize_provider.dart';
//
//
// class CopounSection extends StatelessWidget {
//   CopounSection({super.key});
//   TextEditingController copounCodeController = TextEditingController();
//   FocusNode copounCodeFocusNode = FocusNode();
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeController>(
//         builder: (context, value, child) {
//           return Consumer<PrizeProvider>(
//             builder: (context, provider, child) {
//               if(provider.successSend == true){
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   if (context.mounted) {
//                     provider.startLoading();
//                   }
//                 });
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   if (context.mounted) {
//                     value.initializeHomeScreen(context, null);
//                   }
//                 });
//                 provider.successSend = false;
//               }
//               return Padding(
//                 padding: EdgeInsets.only(right: 23 , left: 23,bottom: context.viewInsets.bottom),
//                 child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         AppStrings.aboutPointsProgram.tr(),
//                         style:  TextStyle(
//                           fontSize: 14,
//                           color: Color(0xffE6007E),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         AppStrings.enterYourCouponCodeHereToGetPointsFromOrientPaintsProducts.tr(),
//                         style:  TextStyle(
//                           fontSize: 12,
//                           color: Color(0xff464646),
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       gapH20,
//                        Center(
//                           child: Container(
//                             width: double.infinity,
//                             alignment: Alignment.center,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'assets/images/png/logo_white.png',
//                                   fit: BoxFit.cover,
//                                 ),
//                                 SizedBox(width: 10,),
//                                 Text(AppStrings.couponCode.tr().toUpperCase(),
//                                 style:  TextStyle(fontSize: 17,
//                                 color: Color(0xffE6007E),
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 )
//                               ],
//                             ),
//                           )
//                           // Image(
//                           //   image: AssetImage('assets/images/png/coupon.png'),
//                           //   height: 120,
//                           //   width: 181,
//                           //   fit: BoxFit.contain,
//                           // )
//                       ),
//                       gapH20,
//                       Column(
//                         children: [
//                           const SizedBox(height: 20,),
//                           if(provider.isLoading)const Center(
//                             child: CircularProgressIndicator(),
//                           ),
//                           if(!provider.isLoading)Container(
//                             height: 50,
//                             width: 224,
//                             decoration: BoxDecoration(
//                               color: Color(0xFF0D3B6F),
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: MaterialButton(onPressed: () {
//                               provider.sendCopoun(copounCode: copounCodeController.text).then((value) {
//                                 if(provider.isLoading == true){
//                                   showProgressIndicator(context);
//                                 }
//                                 else {
//                                   if (provider.copounModel!.status == true) {
//                                     Fluttertoast.showToast(
//                                         msg: provider.copounModel!.message!,
//                                         toastLength: Toast.LENGTH_SHORT,
//                                         gravity: ToastGravity.BOTTOM,
//                                         timeInSecForIosWeb: 1,
//                                         backgroundColor: Colors.green,
//                                         textColor: Colors.white,
//                                         fontSize: 16.0
//                                     );
//                                     copounCodeController.clear();
//                                   }
//                                   else {
//                                     Fluttertoast.showToast(
//                                         msg: provider.copounModel!.message!,
//                                         toastLength: Toast.LENGTH_SHORT,
//                                         gravity: ToastGravity.BOTTOM,
//                                         timeInSecForIosWeb: 1,
//                                         backgroundColor: Colors.red,
//                                         textColor: Colors.white,
//                                         fontSize: 16.0
//                                     );
//                                     copounCodeController.clear();
//                                   }
//                                 }
//                               },);
//                             },
//                               child:  Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   SvgPicture.asset("assets/images/png/verified.svg"),
//                                   gapW4,
//                                   Text(AppStrings.sendCoupon.tr(),style:  TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white,
//                                   ),)
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Align(
//                               alignment: Alignment.topCenter,
//                               child: SvgPicture.asset('assets/images/png/coinImage.svg', height: 260,width: double.infinity,fit: BoxFit.cover)
//                           )
//                           //Image(image: AssetImage('assets/images/png/coinImage.svg'),height: 260,width: double.infinity,fit: BoxFit.fill,)),
//                         ],
//                       ),
//
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//     );
//   }
// }
//
// class _NumberInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     String text = newValue.text.replaceAll('-', '');
//     if (text.length > 16) text = text.substring(0, 16);
//     String formattedText = '';
//     for (int i = 0; i < text.length; i++) {
//       formattedText += text[i];
//       if ((i + 1) % 4 == 0 && i + 1 != text.length) {
//         formattedText += '-';
//       }
//     }
//     return TextEditingValue(
//       text: formattedText,
//       selection: TextSelection.collapsed(offset: formattedText.length),
//     );
//   }
// }
//
// // class QRScannerScreen extends StatefulWidget {
// //   var points;
// //   QRScannerScreen(this.points);
// //   @override
// //   State<QRScannerScreen> createState() => _QRScannerScreenState();
// // }
//
// // class _QRScannerScreenState extends State<QRScannerScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return ChangeNotifierProvider(
// //       create: (context) => HomeController(),
// //       child: Consumer<HomeController>(
// //         builder: (context, value, child) {
// //           return Consumer<HomeController>(
// //             builder: (context, provider, child) {
// //               if (provider.is) {
// //                 WidgetsBinding.instance.addPostFrameCallback((_)async {
// //                   if (context.mounted) {
// //                     await value.initializeHomeScreen(context, null);
// //                     if(widget.points == true){
// //                       Navigator.pop(context);
// //                       Navigator.pop(context);
// //                     }else{
// //                       Navigator.pop(context);
// //                     }
// //                   }
// //                 });
// //                 provider.isSuccess = false;
// //               }
// //               return Scaffold( resizeToAvoidBottomInset: true,
// //                 appBar: AppBar(title: Text(AppStrings.qrCodeScanner.tr())),
// //                 body: Stack(
// //                   alignment: Alignment.center,
// //                   children: [
// //                     MobileScanner(
// //                       onDetect: (BarcodeCapture barcode) {
// //                         if (barcode.barcodes.isNotEmpty) {
// //                           String? code = barcode.barcodes.first.rawValue;
// //                           if (code != null && provider.isRequestSent == false) {
// //                             provider.isRequestSent = true; // Prevent multiple requests
// //                             barcode.barcodes.clear();
// //                             provider.addRedeemGift(
// //                               context: context,
// //                               serial: code.toString(),
// //                             ).then((_) {
// //                               setState(() {
// //                                 provider.isRequestSent = true;
// //                               });// Reset flag after completion
// //                               print("isRequestSent success --> ${provider.isRequestSent}");
// //                               if(provider.status == false){
// //                                 if(widget.points == true){
// //                                   Navigator.pop(context);
// //                                   Navigator.pop(context);
// //                                 }else{
// //                                   Navigator.pop(context);
// //                                 }}
// //                             }).catchError((_) {
// //                               provider.isRequestSent = false; // Reset flag on error
// //                               print("isRequestSent error --> ${provider.isRequestSent}");
// //                               if(widget.points == true){
// //                                 Navigator.pop(context);
// //                                 Navigator.pop(context);
// //                               }else{
// //                                 Navigator.pop(context);
// //                               }
// //                             });
// //                           }
// //                         }
// //                       },
// //                     ),
// //                     if (provider.isLoading)
// //                       const Center(child: CircularProgressIndicator()),
// //                   ],
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }