
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/modules/authentication/views/widgets/phone_number_field.dart';
import 'package:provider/provider.dart';

import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/widgets/all_text_field.dart';
import '../view_models/points_cubit/points_provider.dart';
import 'bottom_sheet_external_success.dart';

class RayaAddDataBottomsheet extends StatelessWidget {
  var id;
  var needData;
  RayaAddDataBottomsheet(this.id, this.needData, {super.key});
  var keys;
  List values = [];
  FocusNode fieldFocusNode = FocusNode();
  FocusNode fieldFocusNode2 = FocusNode();
  FocusNode dataIdFocusNode = FocusNode();
  FocusNode dataNameFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => PointsProvider(),
        child: Consumer<PointsProvider>(builder: (context, value, child) {
          if(value.isRedeemSuccess == true){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if(value.redeemCode != null){
                Navigator.pop(context);
                PointsSuccessSheet.externalSuccess(fieldFocusNode,context: context, redeemCode: value.redeemCode.toString());
              }else{
                Navigator.pop(context);
                PointsSuccessSheet.manualSuccess(fieldFocusNode2,context: context);
              }
            });
            value.isRedeemSuccess = false;
          }
          values.clear();
          needData.forEach((e){
            print("e['value'] ---> ${e['value']}");
            values.add(e['key']);
            print("values --> $values");
          });
          print("values --> $values");
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Push above keyboard
            ),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
                  gradient: LinearGradient(
                    colors: [Color(0xffFDFDFD), Color(0xffF4F7FF)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.45,
                child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Center(
                        child: Container(
                          height: 5,
                          width: 63,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xffB9C0C9),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          if(values.contains("name"))  defaultTextFormField(
                                    onTap: () {
                                      if (!dataNameFocusNode.hasFocus) {
                                        dataNameFocusNode.requestFocus();
                                      }
                                    },
                                context: context,
                                keyboardType: TextInputType.text,
                                hintText: AppStrings.yourName.tr().toUpperCase(),
                                controller: value.dataNameController),
                            if(values.contains("phone") || values.contains("mobile")) PhoneNumberField(
                              controller: value.phoneController,
                              countryCodeController: value.countryCodeController,
                            ),
                            if(values.contains("national_id"))   defaultTextFormField(
                                    onTap: () {
                                      if (!dataIdFocusNode.hasFocus) {
                                        dataIdFocusNode.requestFocus();
                                      }
                                    },
                                context: context,
                                keyboardType: TextInputType.number,
                                hintText: AppStrings.nationalId.tr().toUpperCase(),
                                controller: value.dataIdController),
                            const SizedBox(height: 30),
                            if(value.isRedeemLoading) const Center(child: CircularProgressIndicator(),),
                            if(!value.isRedeemLoading) GestureDetector(
                              onTap: ()async{
                                value.postRedeemPrize(context,id: id, );
                              },
                              child: Container(
                                height: 50,
                                width: 225,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: const Color(0xff0D3B6F)),
                                child: Text(
                                  AppStrings.send.tr().toUpperCase(),
                                  style:  const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffFFFFFF),
                                      fontFamily: "Poppins"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },)
    );
  }
}
