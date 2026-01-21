import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_test/constants/app_colors.dart';
import 'package:app_test/constants/app_sizes.dart';
import 'package:app_test/constants/app_strings.dart';
import 'package:app_test/general_services/layout.service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common_modules_widgets/button_widget.dart';
import '../../../utils/gradient_bg_image.dart';
import '../../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../logic/fawry_cubit/fawry_provider.dart';

class PayBillScreen extends StatefulWidget {
  var title;
  var phone;
  var totalPoints;
  var us2Cache;
  var pointsPerOne;
  var id;  var serviceObject;
  List? fawryInqury = [];
  var inquiryId;
  var inputsValues;
  PayBillScreen(this.title,this.phone,this.id, {super.key, 
    this.pointsPerOne,this.fawryInqury,this.inputsValues,this.us2Cache,this.totalPoints,this.serviceObject,
  });
  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController numberOfPointsController = TextEditingController();
  TextEditingController withdrawalAmountController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FawryProviderModel? fawryProviderModel;
  var inquiryId;
  var payAmount;
  @override
  Widget build(BuildContext context) {
    amountController.text = widget.phone;
    return ChangeNotifierProvider(create: (context) => FawryProviderModel(),
    child: Consumer<FawryProviderModel>(
        builder: (context, value, child) {
          return Form(
            key: formKey,
            child: Scaffold( resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: const Color(0xffFFFFFF),
                leading:GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:  const Icon(
                      Icons.arrow_back,
                      color: Color(0XFF224982),
                    )),
                title: Text(
                  widget.title.toString().toUpperCase(),
                  style:  const TextStyle(
                      fontSize: AppSizes.s16,
                      fontWeight: FontWeight.w700,
                      color: Color(0XFF224982)),
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
              body: SizedBox(
                height: MediaQuery.sizeOf(context).height * 1,
                child: GradientBgImage(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

                    child: Column(
                      children: [
                        if(widget.phone != "" || widget.phone.toString().isNotEmpty)TextFormField(
                          readOnly: true,
                          enabled: false,
                          controller: amountController,
                          decoration: InputDecoration(
                            hintText: AppStrings.enterPhoneNumber.tr().toUpperCase(),
                          ),
                          onChanged: (String? value){
                            setState(() {
                              amountController.text = widget.phone.toString();
                            });
                          },
                        ),
                        if(widget.phone != "" || widget.phone.toString().isNotEmpty) const SizedBox(height: 20,),
                        if(widget.fawryInqury!.isEmpty)Container(
                          height: MediaQuery.sizeOf(context).height * 0.8,
                          alignment: Alignment.center,
                          child: NoExistingPlaceholderScreen(
                              height: LayoutService.getHeight(context) * 0.4,
                              title: AppStrings.noInquiriesAvailable.tr()),
                        ),
                        if(widget.fawryInqury!.isNotEmpty)ListView.separated(
                          padding: EdgeInsets.zero,
                            reverse: false,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) =>value.isGetFawryCategoryLoading == true?
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 100, // Adjust height based on your UI
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8), // Adjust as needed
                                ),
                              ),
                            )
                                :Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: const Color(0xffFFFFFF),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xffC9CFD2).withOpacity(0.5),
                                    blurRadius: AppSizes.s5,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            value.selectIndix = index;
                                            payAmount = widget.fawryInqury![index]['amount'];
                                            inquiryId = widget.fawryInqury![index]['inquiryId'];
                                            value.rechargeAmountController.text = widget.fawryInqury![index]['amount'].toString();
                                            value.updateFee(widget.serviceObject, double.parse(widget.fawryInqury![index]['amount'].toString().isNotEmpty?widget.fawryInqury![index]['amount'].toString() : "0"));
                                            value.numberOfPointsController.text = "${double.parse(value.rechargeAmountController.text.toString()) * double.parse(widget.totalPoints.toString())}";
                                          });
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Color(AppColors.primary)),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: value.selectIndix == index?Color(AppColors.primary) :Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10,),
                                      Text(widget.title ?? "", style: TextStyle(color: Color(AppColors.primary),fontSize: 14, fontWeight: FontWeight.w700),),
                                    ],
                                  ),
                                  const SizedBox(height: 15,),
                                  defaultTransferDetailsTexts(AppStrings.withdrawalAmount.tr(), "${widget.fawryInqury![index]['amount']} ج.م"),
                                  defaultTransferDetailsTexts(AppStrings.fees.tr(), "${value.calcFees(widget.serviceObject, double.parse(widget.fawryInqury![index]['amount'].toString()))} ج.م"),
                                  defaultTransferDetailsTexts(AppStrings.total.tr(), "${double.parse(value.calcFees(widget.serviceObject, double.parse(widget.fawryInqury![index]['amount'].toString())).toStringAsFixed(0)) + double.parse(widget.fawryInqury![index]['amount'].toString())} ج.م"),
                                 ],
                              ),
                            ),
                            separatorBuilder: (context, index) => const SizedBox(height: 15,),
                            itemCount:value.isGetFawryCategoryLoading == true? 3 : widget.fawryInqury!.length),
                        if(widget.fawryInqury!.isNotEmpty)const SizedBox(height: 15,),
                        if(widget.fawryInqury!.isNotEmpty)Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color(0xffFFFFFF),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xffC9CFD2).withOpacity(0.5),
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
                                    width: MediaQuery.sizeOf(context).width * 0.35,
                                    child: TextFormField(
                                      enabled: false,
                                      readOnly: true,
                                      keyboardType: TextInputType.number,
                                      controller: value.rechargeAmountController,
                                      decoration: InputDecoration(
                                        hintText: AppStrings.withdrawalAmount.tr().toUpperCase(),
                                      ),
                                      onChanged: (String? values){
                                        setState(() {
                                          value.numberOfPointsController.text = "${double.parse(value.rechargeAmountController.text.toString()) * double.parse(widget.totalPoints.toString())}";
                                          value.updateFee(widget.serviceObject, double.parse(values.toString().isNotEmpty?values.toString() : "0"));
                                        });
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  SvgPicture.asset("assets/images/svg/transfer.svg"),
                                  const Spacer(),
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width * 0.35,
                                    child: TextFormField(
                                      enabled: false,
                                      readOnly: true,
                                      controller: value.numberOfPointsController,
                                      decoration: InputDecoration(
                                        hintText: AppStrings.numberOfPoints.tr().toUpperCase(),
                                      ),
                                      onChanged: (String? values){
                                        setState(() {
                                          value.numberOfPointsController.text = "${double.parse(value.rechargeAmountController.text.toString()) * double.parse(widget.totalPoints.toString())}";
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              // defaultTransferDetailsTexts(AppStrings.yourActualBalanceOnPhone.tr(), "345 ج.م"),
                              defaultTransferDetailsTexts(AppStrings.withdrawalAmount.tr(), "${value.rechargeAmountController.text.isNotEmpty? value.rechargeAmountController.text : 0} ج.م"),
                              defaultTransferDetailsTexts(AppStrings.fees.tr(), "${value.cachedFee} ج.م"),
                              defaultTransferDetailsTexts(AppStrings.total.tr(), "${double.parse(value.rechargeAmountController.text.isNotEmpty? value.rechargeAmountController.text : "0") + double.parse(value.cachedFee.toStringAsFixed(0))} ج.م"),
                              SizedBox(width: MediaQuery.sizeOf(context).width * 0.6,
                                child: Divider(color: Color(AppColors.primary),),
                              ),
                              const SizedBox(height: 10,),
                              defaultTransferDetailsTexts(AppStrings.yourAvailablePoints.tr(), "${widget.us2Cache['points']['available']} ج.م"),
                              defaultTransferDetailsTexts(
                                AppStrings.availablePointsAfterWithdrawal.tr(),
                                "${(
                                    (double.parse(widget.us2Cache['points']['available'].toString())
                                        - (
                                            double.parse(
                                                value.rechargeAmountController.text.isNotEmpty
                                                    ? value.rechargeAmountController.text
                                                    : "0"
                                            )
                                                + double.parse(
                                                value.cachedFee.toStringAsFixed(0)
                                            )
                                        )* double.parse(widget.pointsPerOne.toString())
                                    )
                                ).toStringAsFixed(0)} ج.م",
                              )


                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                height: 136,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:const Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow:  [
                    BoxShadow(
                        color:const Color(0xff000000).withOpacity(0.1),
                        blurRadius: 11,
                        spreadRadius: 0,
                        offset:const Offset(0, -4)
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: value.isPostPayLoading == false ?ButtonWidget(
                  title: "${AppStrings.pay.tr().toUpperCase()} ${double.parse((payAmount != null)?payAmount.toStringAsFixed(0) : "0") * double.parse((widget.pointsPerOne != null)?widget.pointsPerOne : "0")} ${AppStrings.point.tr().toUpperCase()}",
                  svgIcon: "assets/images/svg/wallet.svg",
                  onPressed: () {
                    value.postPay(
                        context, id: widget.id,
                      payAmount: payAmount,
                      inquiryId: inquiryId,
                        inputsValues : widget.inputsValues
                    );
                  },
                  padding: EdgeInsets.zero,
                  fontSize: 12,
                ) : const CircularProgressIndicator(),
              ),
            ),
          );
        },
    ),
    );
  }

  Widget defaultTransferDetailsTexts(t1, t2)=>Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Text(t1, style: TextStyle(color: Color(AppColors.primary),fontSize: 12, fontWeight: FontWeight.w600),),
        const Spacer(),
        Text(t2, style: TextStyle(color: Color(AppColors.c3),fontSize: 12, fontWeight: FontWeight.w500),)
      ],
    ),
  );
}
