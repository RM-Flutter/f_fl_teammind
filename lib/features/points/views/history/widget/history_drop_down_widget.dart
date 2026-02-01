import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/localization_service.dart';

class HistoryDropDownWidget extends StatelessWidget {
  var notes;
  var code;
  HistoryDropDownWidget({super.key, this.code, this.notes});
  void copyToClipboard(BuildContext context, {text}) {
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
  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Push above keyboard
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
        gradient: LinearGradient(
          colors: [Color(0xffFDFDFD), Color(0xffF4F7FF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      width: double.infinity,
      height: notes != null && notes != "" ? MediaQuery.sizeOf(context).height * 0.45 : 220,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 if(code != null && code != "") Text(AppStrings.voucherCouponCode.tr().toUpperCase(), style: TextStyle(color: Color(AppColors.primary), fontWeight: FontWeight.w400, fontSize: 12),),
                  if(code != null && code != "")  const SizedBox(height: 15,),
                  if(code != null && code != "")   Container(
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
                        Text(code.toString(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color(AppColors.grey50)),),
                        const Spacer(),
                        GestureDetector(
                          onTap: (){
                            copyToClipboard(context, text: code.toString());
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
                  ),
                  if(notes != null && notes != "") const SizedBox(height: 30),
                 if(notes != null && notes != "") Text(AppStrings.notes.tr().toUpperCase(), style: TextStyle(color: Color(AppColors.primary), fontWeight: FontWeight.w400, fontSize: 12),),
                  if(notes != null && notes != "")  const SizedBox(height: 15,),
                  if(notes != null && notes != "")  Text(notes.toString(), style: TextStyle(color: Color(AppColors.grey50), fontWeight: FontWeight.w400, fontSize: 14)),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
