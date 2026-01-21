import 'package:app_test/utils/helpers/media_query_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/constants/app_colors.dart';
import 'package:app_test/constants/app_sizes.dart';
import 'package:app_test/constants/app_strings.dart';
import 'package:app_test/general_services/app_theme.service.dart';
import 'package:app_test/general_services/localization.service.dart';
import '../../../utils/componentes/general_components/all_bottom_sheet.dart';

class PointsSuccessSheet{
 static void showConfirmationSheet(BuildContext context, {onTap}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                     AppStrings.areYouSureYouWantToMakeTransferPoints.tr(),
                    style:  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: const Color(0xff0D3B6F)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding:const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            AppStrings.no.tr().toUpperCase(),
                            style:const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff0D3B6F)
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xff0D3B6F),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            AppStrings.yes.tr().toUpperCase(),
                            style:const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xffFFFFFF)
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  static void copyToClipboard(BuildContext context, {text}) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
        msg: AppStrings.textCopiedToClipboard.tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
 static externalSuccess(fieldFocusNode, {context, redeemCode}){
    return  defaultActionBottomSheet2(
      fieldFocusNode: fieldFocusNode,
        context: context,
        home: false,
        view2Button: false,
        view: false,
        title: "${AppStrings.successful.tr().toUpperCase()} !",
        subTitle: redeemCode!= null && redeemCode != ""?
        AppStrings.yourRequestHasBeenSuccessfullyExecutedCopyTheFollowingCode.tr().toUpperCase():
        AppStrings.yourRequestHasBeenSuccessfully.tr().toUpperCase(),
        viewCheckIcon: true,
        widgets: redeemCode!= null && redeemCode != ""? Container(
          height: 50,
          alignment: Alignment.center,
          padding:  EdgeInsets.only(left:LocalizationService.isArabic(context: context) ?0 : 16 ,right: LocalizationService.isArabic(context: context) ?16 : 0),
          decoration: ShapeDecoration(
            color: AppThemeService.colorPalette.tertiaryColorBackground.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.s10),
              side: const BorderSide(
                color: Color(0xffE3E5E5),
                width: 1.0,
              ),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, 1),
                spreadRadius: 0,
              )
            ],
          ),
          child: Row(
            children: [
              Text(redeemCode.toString(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color(AppColors.grey50)),),
              const Spacer(),
              GestureDetector(
                onTap: (){
                  copyToClipboard(context, text: redeemCode.toString());
                },
                child: Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xffE8E8E8)
                  ),
                  child: Text(AppStrings.copy.tr(), style:  const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),),
                ),
              )
            ],
          ),
        ) : const SizedBox.shrink(),
        headerIcon: Image.asset("assets/images/png/bill_success.png", height: 42, width: 40,)
    );
  }
 static manualSuccess(fieldFocusNode,{context}){
    return defaultActionBottomSheet2(
      fieldFocusNode: fieldFocusNode,
        context: context,
        home: false,
        view2Button: false,
        widgets: Container(height: 1,color: Colors.transparent,),
        view: false,
        title: "${AppStrings.successful.tr().toUpperCase()} !",
        subTitle: AppStrings.yourRequestHasBeenSubmittedSuccessfullyYouWillBeRepliedToSoon.tr().toUpperCase(),
        viewCheckIcon: true,
        headerIcon: Image.asset("assets/images/png/bill_success.png", height: 42, width: 40,)
    );
  }
}