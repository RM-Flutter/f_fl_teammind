import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_test/modules/points/fawry_view/pay_bill_screen.dart';
import 'package:app_test/modules/points/fawry_view/widget/charge_phone_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization.service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/button_widget.dart';
import 'package:app_test/core/utils/gradient_bg_image.dart';
import 'package:app_test/core/widgets/text_form_widget.dart';
import '../controllers/fawry_cubit/fawry_provider.dart';

class ChargePhoneScreen extends StatefulWidget {
  var service;
  ChargePhoneScreen(this.service, {super.key});
  @override
  State<ChargePhoneScreen> createState() => _ChargePhoneScreenState();
}

class _ChargePhoneScreenState extends State<ChargePhoneScreen> {
  late FawryProviderModel fawryProviderModel;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int? selectIndex;

  List inputs = [];
  var totalPoints;
  var serviceObject;
  var serviceId;
  var serviceTitle;
  var pointsPerOne;
  var singlePrice;
  bool? inquiry;
  @override
  void initState() {
    fawryProviderModel = FawryProviderModel();
    if (widget.service['services'].isNotEmpty &&
        widget.service['services'][0]['inquiry'] != null) {
      inquiry = widget.service['services'][0]['inquiry'];
      inputs = widget.service['services'][0]['inputs'];
      serviceObject = widget.service['services'][0];
      totalPoints = widget.service['services'][0]['points_per_one'] ?? "0";
      serviceId = widget.service['services'][0]['id'];
      serviceTitle = widget.service['services'][0]['title'];
      singlePrice = widget.service['services'][0]['single_price'] ?? "noPrice";
      pointsPerOne = widget.service['services'][0]['points_per_one'] ?? "0";
      for (var input in inputs) {
        String key = input['key'];
        fawryProviderModel.controllers[key] = TextEditingController();
        fawryProviderModel.focusNodes[key] = FocusNode();
      }
    }
    if(inquiry != null && inputs.isNotEmpty &&
        serviceObject != null && totalPoints != null &&serviceId != null && serviceTitle != null
        &&singlePrice != null && pointsPerOne != null){
      selectIndex = 0;
    }
    super.initState();
  }
  bool _didCalculateFee = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didCalculateFee) {
      _didCalculateFee = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // ✅ الحماية هنا
        fawryProviderModel.updateFee(
          serviceObject,
          double.parse(
            fawryProviderModel.rechargeAmountController.text.isNotEmpty
                ? fawryProviderModel.rechargeAmountController.text
                : "0",
          ),
        );
        print("FFES IS --> ${fawryProviderModel.cachedFee}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: fawryProviderModel,
      child: Consumer<FawryProviderModel>(
        builder: (context, value, child) {
          if(singlePrice != null && singlePrice != "noPrice"){
            value.rechargeAmountController.text = singlePrice.toString();
            value.numberOfPointsController
                .text =
            "${double.parse(value.rechargeAmountController.text.toString()) * double.parse(totalPoints.toString())}";
          }
          final json2String = CacheHelper.getString("US2");
          Map<String, dynamic> us2Cache = {};
          if (json2String != null && json2String != "") {
            us2Cache = json.decode(json2String)
                as Map<String, dynamic>; // Convert String back to JSON
          }
          if(value.isGetInquerySuccess == true){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PayBillScreen(
                      serviceTitle.toString(),
                      pointsPerOne: pointsPerOne,
                      totalPoints: totalPoints,
                      fawryInqury: value.fawryInqury,
                      "",
                      inputsValues: value.inputValues,
                      serviceId.toString(),
                      serviceObject: serviceObject,
                      us2Cache: us2Cache,

                    ),
                  ));
            });
            value.isGetInquerySuccess = false;
          }
          return Scaffold(
            resizeToAvoidBottomInset: true,
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
                widget.service['title'].toString().toUpperCase(),
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
            body: SafeArea(
              child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

                child: Form(
                  key: formKey,
                  child: GradientBgImage(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.selectServiceProvider
                                      .tr()
                                      .toUpperCase(),
                                  style:  const TextStyle(
                                      fontSize: AppSizes.s14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0XFF224982)),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 120,
                                  child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.horizontal,
                                      reverse: false,
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemBuilder: (context, index) =>
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectIndex = index;
                                                inquiry =
                                                    widget.service['services']
                                                        [index]['inquiry'];
                                                singlePrice =
                                                    widget.service['services']
                                                        [index]['single_price'];
                                                pointsPerOne =
                                                    widget.service['services']
                                                        [index]['points_per_one'];
                                                inputs =
                                                    widget.service['services']
                                                        [index]['inputs'];
                                                serviceObject = widget
                                                    .service['services'][index];
                                                serviceId =
                                                    widget.service['services']
                                                        [index]['id'];
                                                serviceTitle =
                                                    widget.service['services']
                                                        [index]['title'];
                                                if(singlePrice != null){
                                                  value.rechargeAmountController.text = singlePrice.toString();
                                                  value.numberOfPointsController
                                                      .text =
                                                  "${double.parse(value.rechargeAmountController.text.toString()) * double.parse(totalPoints.toString())}";
                                                  value.updateFee(
                                                      serviceObject,
                                                      double.parse(
                                                          value.rechargeAmountController.text.isNotEmpty
                                                              ? value.rechargeAmountController.text
                                                              : "0"));
                                                }
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 80,
                                                  width: 90,
                                                  padding: EdgeInsets.zero,
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13),
                                                      border: Border.all(
                                                          color: selectIndex ==
                                                                  index
                                                              ?  Color(
                                                                  AppColors.primary)
                                                              : Colors
                                                                  .transparent)),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    child: CachedNetworkImage(
                                                      height: 80,
                                                      width: 90,
                                                      fit: BoxFit.contain,
                                                      imageUrl: widget
                                                              .service[
                                                                  'services']
                                                                  [index]
                                                                  ['logo']
                                                              .isNotEmpty
                                                          ? widget.service[
                                                                      'services']
                                                                  [index][
                                                              'logo'][0]['file']
                                                          : "",
                                                      placeholder: (context,
                                                              url) =>
                                                          const ShimmerAnimatedLoading(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                        Icons
                                                            .image_not_supported_outlined,
                                                        size: AppSizes.s50,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 13,
                                                ),
                                                Text(
                                                  widget.service['services']
                                                      [index]['title'],
                                                  style:  const TextStyle(
                                                      fontSize: AppSizes.s10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0XFF224982)),
                                                ),
                                              ],
                                            ),
                                          ),
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                            width: 15,
                                          ),
                                      itemCount:
                                          widget.service['services'].length),
                                )
                              ],
                            )),
                        if (inputs.isNotEmpty) Column(
                          children: inputs.map<Widget>((input) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: buildInputWidget(input, value),
                          ))
                              .toList(),
                        ),
                        if (inquiry == true)
                          const SizedBox(
                            height: 35,
                          ),
                        if (inquiry == true && value.isGetFawryCategoryLoading == false)
                          ButtonWidget(
                            title:
                                AppStrings.proceedToPayment.tr().toUpperCase(),
                            svgIcon: "assets/images/svg/wallet.svg",
                            onPressed: () {
                              // if (inputs
                              //     .any((element) => element['type'] == 'S')){
                              //   if(value.selectOption == null){
                              //     AlertsService.error(
                              //         context: context,
                              //         message: "${LocalizationService.isArabic(
                              //             context: context)
                              //             ? inputs.firstWhere((element) =>
                              //         element['key'] == 'select')['title_ar']
                              //             : inputs.firstWhere((element) =>
                              //         element['key'] ==
                              //             'select')['title_en']} ${AppStrings.isRequired.tr()}",
                              //         title: AppStrings.failed.tr());
                              //     return;
                              //   }
                              // }
                              if(formKey.currentState!.validate()){
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  value.getInquryCategory(context,
                                      id: serviceId,

                                  );
                                });
                              }
                            },
                            padding: EdgeInsets.zero,
                            fontSize: 12,
                          ),
                        if (inquiry == true && value.isGetFawryCategoryLoading == true)const Center(
                          child: CircularProgressIndicator(),
                        ),
                        if (inquiry == false)
                          const SizedBox(
                            height: 25,
                          ),
                        if (inquiry == false)
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 15),
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
                                                      totalPoints.toString())}";
                                              value.updateFee(
                                                  serviceObject,
                                                  double.parse(
                                                      values
                                                          .toString()
                                                          .isNotEmpty
                                                          ? values.toString()
                                                          : "0"));
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                    SvgPicture.asset(
                                        "assets/images/svg/transfer.svg"),
                                    const Spacer(),
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
                                        enabled: (singlePrice != null && singlePrice != "noPrice") ? false : true,
                                        readOnly: (singlePrice != null && singlePrice != "noPrice") ? true : false,
                                        controller:
                                            value.numberOfPointsController,
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
                                                      totalPoints.toString())}";
                                              value.updateFee(
                                                  serviceObject,
                                                  double.parse(
                                                      values
                                                          .toString()
                                                          .isNotEmpty
                                                          ? values.toString()
                                                          : "0"));
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
                                defaultTransferDetailsTexts(
                                    AppStrings.fees.tr(),
                                    "${value.cachedFee} ج.م"),
                                defaultTransferDetailsTexts(
                                    AppStrings.total.tr(),
                                    "${double.parse(value.rechargeAmountController.text.isNotEmpty ? value.rechargeAmountController.text : "0") + double.parse(value.cachedFee.toStringAsFixed(0))} ج.م"),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.6,
                                  child: Divider(
                                    color: Color(AppColors.primary),
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
                                          double.parse(value.cachedFee.toStringAsFixed(0)))* double.parse(pointsPerOne.toString()))}")
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: (inquiry == false)
                ? ChargePhoneBottomBar(serviceId: serviceId,)
                : const SizedBox.shrink(),
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
              style:  TextStyle(
                  color: Color(AppColors.primary),
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
  Widget buildInputWidget(Map<String, dynamic> input, value) {
    final String key = input['key'];
    final String type = input['type'];
    final bool isRequired = input['required'] == true;
    final String title = LocalizationService.isArabic(context: context)
        ? input['title_ar']
        : input['title_en'];
    switch (type) {
      case 'S': // Dropdown
        return defaultDropdownField(
          value: value.dropdownValues[key],
          title: value.dropdownTitles[key] ?? title,
          items: (input['options'] as List).map<DropdownMenuItem<String>>((e) {
            return DropdownMenuItem<String>(
              value: e['key'].toString(),
              child: Text(LocalizationService.isArabic(context: context)
                  ? e['title_ar']
                  : e['title_en'],
                style:  const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: (selectedKey) {
            final selectedItem = (input['options'] as List)
                .firstWhere((e) => e['key'].toString() == selectedKey);
            setState(() {
              value.dropdownValues[key] = selectedKey;
              value.dropdownTitles[key] = LocalizationService.isArabic(context: context)
                  ? selectedItem['title_ar']
                  : selectedItem['title_en'];
              value.setInputValue(key, selectedKey); // ✅ هنا نخزن key المختار فقط
            });
          },
        );


      case 'D':
        return TextFormField(
          readOnly: true,
          controller: value.controllers[key],
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2101),
              locale: Locale(LocalizationService.isArabic(context: context) ? 'ar' : 'en'),
            );

            if (picked != null) {
              final outputFormat = DateFormat('yyyy-MM-dd');
              final outputDate = outputFormat.format(picked);

              value.controllers[key]?.text = outputDate; // ✅ ده اللي بيظهر في الفورم
              value.inputValues[key] = outputDate;       // ✅ ده اللي بيتبعت للسيرفر

              print("✅ اخترت $key = $outputDate");
            }
          },
          decoration: InputDecoration(hintText: title),
          validator: (val) {
            if (isRequired && (val == null || val.isEmpty)) {
              return AppStrings.dataIsRequired.tr();
            }
            return null;
          },
        );

      case 'N': // رقم
      default:
        return TextFormField(
          controller: value.controllers[key],
          focusNode: value.focusNodes[key],
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: title),
          onChanged: (val) => value.setInputValue(key, val),
          validator: (val) {
            if (isRequired && (val == null || val.isEmpty)) {
              return "$title ${AppStrings.isRequired.tr()}";
            }
            return null;
          },
        );
    }
  }


}
