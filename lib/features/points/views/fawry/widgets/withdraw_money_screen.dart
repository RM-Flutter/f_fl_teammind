import 'dart:convert';
import 'package:app_test/features/points/controllers/fawry_controller/fawry_controller.dart';
import 'package:app_test/features/points/controllers/fawry_controller/fawry_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../../../core/services/validation_service.dart';
import '../../../../../core/utils/gradient_bg_image.dart';
import '../../../../../core/widgets/button_widget.dart';

class WithdrawMoneyScreen extends StatefulWidget {
  var pointsPerOne;
  WithdrawMoneyScreen(this.pointsPerOne);
  @override
  State<WithdrawMoneyScreen> createState() => _WithdrawMoneyScreenState();
}

class _WithdrawMoneyScreenState extends State<WithdrawMoneyScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int? selectIndex;
  var totalPoints;
  var pointsPerOne;
  var singlePrice;
  @override
  void initState() {
    pointsPerOne = widget.pointsPerOne?? "0";
    super.initState();
  }
  @override

  @override
  Widget build(BuildContext context) {
    print("per --> ${widget.pointsPerOne.toString()}");
    return ChangeNotifierProvider(
      create: (context) => FawryController(),
      child: Consumer<FawryController>(
        builder: (context, value, child) {
          final json2String = CacheHelper.getString("US2");
          var us2Cache;
          if (json2String != null && json2String != "") {
            us2Cache = json.decode(json2String)
            as Map<String, dynamic>; // Convert String back to JSON
          }
          final json1String = CacheHelper.getString("US1");
          var us1Cache;
          if (json1String != null && json1String != "") {
            us1Cache = json.decode(json1String)
            as Map<String, dynamic>; // Convert String back to JSON
          }
          if(value.phoneController.text.isEmpty && us1Cache != null && us1Cache['phone'] != null){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                value.phoneController.text = us1Cache['phone'].toString();
              });
            });

          }
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: const Color(0xffFFFFFF),
              leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0XFF224982),
                  )),
              title: Text(
                AppStrings.withdrawMoney.tr().toUpperCase(),
                style: TextStyle(
                    fontSize: AppSizes.s16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0XFF224982)),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFFFF007A).withOpacity(0.03),
                      const Color(0xFF00A1FF).withOpacity(0.03)
                    ],
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                child: Form(
                  key: formKey,
                  child: GradientBgImage(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Column(
                      children: [
                       if(us1Cache['phone'] != null) TextFormField(
                          controller: value.phoneController,
                         enabled: false,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: AppStrings.phoneNumber.tr().toUpperCase(),
                          ),
                        ),
                        if(us1Cache['phone'] == null) TextFormField(
                          controller: value.phoneController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: AppStrings.phoneNumber.tr().toUpperCase(),
                          ),
                        ),
                          const SizedBox(height: 15,),
                        TextFormField(
                          controller: value.nationalIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: AppStrings.nationalId.tr().toUpperCase(),
                          ),
                        ),
                          const SizedBox(height: 20,),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Color(0xffFFFFFF),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffC9CFD2).withOpacity(0.5),
                                  blurRadius: AppSizes.s5,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.35,
                                      child: TextFormField(
                                        focusNode: value.rechargeAmountFocusNode,
                                        onTap: () {
                                          if (!value.rechargeAmountFocusNode.hasFocus) {
                                            value.rechargeAmountFocusNode.requestFocus();
                                          }
                                        },
                                        enabled: (singlePrice != null && singlePrice != "noPrice") ? false : true,
                                        readOnly: (singlePrice != null && singlePrice != "noPrice") ? true : false,
                                        controller:
                                        value.rechargeAmountController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: AppStrings.rechargeAmount
                                              .tr()
                                              .toUpperCase(),
                                        ),
                                        validator: (value) => ValidationService
                                            .validateRequiredAmount(value),
                                        onChanged: (String? values) {
                                          if(values!.isEmpty){
                                            setState((){
                                              value.numberOfPointsController
                                                  .text = "0";
                                            });
                                          }else {
                                            setState(() {
                                              value.numberOfPointsController
                                                  .text =
                                              "${double.parse(
                                                  value.rechargeAmountController
                                                      .text.toString()) *
                                                  double.parse(
                                                      widget.pointsPerOne.toString())}";
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Spacer(),
                                    SvgPicture.asset(
                                        "assets/images/svg/transfer.svg"),
                                    Spacer(),
                                    SizedBox(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.35,
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        focusNode: value.numberOfPointsFocusNode,
                                        onTap: () {
                                          if (!value.numberOfPointsFocusNode.hasFocus) {
                                            value.numberOfPointsFocusNode.requestFocus();
                                          }
                                        },
                                        controller: value.numberOfPointsController,
                                        decoration: InputDecoration(
                                          hintText: AppStrings.numberOfPoints
                                              .tr()
                                              .toUpperCase(),
                                        ),
                                        onChanged: (String? values){
                                          if(values!.isEmpty){
                                            setState((){
                                              value.rechargeAmountController
                                                  .text = "0";
                                            });
                                          }else {
                                            setState(() {
                                              value.rechargeAmountController
                                                  .text =
                                              "${double.parse(
                                                  value.numberOfPointsController
                                                      .text.toString()) /
                                                  double.parse(
                                                      widget.pointsPerOne.toString())}";
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                // defaultTransferDetailsTexts(AppStrings.yourActualBalanceOnPhone.tr(), "345 ج.م"),
                                defaultTransferDetailsTexts(
                                    AppStrings.rechargeAmount.tr(),
                                    "${value.rechargeAmountController.text.isNotEmpty ? value.rechargeAmountController.text : 0} ج.م"),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.6,
                                  child: const Divider(
                                    color: Color(AppColors.oc1),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                defaultTransferDetailsTexts(
                                    AppStrings.yourAvailablePoints.tr(),
                                    "${us2Cache['points']['available']} ج.م"),
                                defaultTransferDetailsTexts(
                                    AppStrings.availablePointsAfterWithdrawal
                                        .tr(),
                                    "${double.parse(us2Cache['points']['available'].toString())-
                                        ((double.parse(value.rechargeAmountController.text.isNotEmpty ?
                                        value.rechargeAmountController.text : "0") +
                                            double.parse(value.cachedFee != null ? value.cachedFee.toStringAsFixed(0)
                                                : "0"))* double.parse(pointsPerOne.toString()))}")
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Container(
              height: 136,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xff000000).withOpacity(0.1),
                      blurRadius: 11,
                      spreadRadius: 0,
                      offset: const Offset(0, -4))
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: (value.isPostPayLoading == false)?ButtonWidget(
                title:
                "${AppStrings.pay.tr().toUpperCase()} ${value.numberOfPointsController.text.isNotEmpty? value.numberOfPointsController.text : "0"  } ${AppStrings.point.tr().toUpperCase()}",
                svgIcon: "assets/images/svg/wallet.svg",
                onPressed: () {
                  value.postPay(context,
                    withdraw: true,
                    inputsValues: value.inputValues,
                    payAmount: value.rechargeAmountController.text,
                  );
                },
                padding: EdgeInsets.zero,
                fontSize: 12,
              ) : const CircularProgressIndicator(),
            ),
          );
        },
      ),
    );

  }
  Widget defaultTransferDetailsTexts(t1, t2) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Text(
          t1,
          style: const TextStyle(
              color: Color(AppColors.oc1),
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          t2,
          style:  TextStyle(
              color: Color(AppColors.c3),
              fontSize: 12,
              fontWeight: FontWeight.w500),
        )
      ],
    ),
  );

}
