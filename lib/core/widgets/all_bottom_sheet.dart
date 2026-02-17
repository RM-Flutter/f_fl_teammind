import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/widgets/all_text_field.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/routing/app_router.dart';

import '../../features/authentication/shared/widgets/phone_number_field.dart';
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
Future<void> defaultActionBottomSheet2({
  required BuildContext context,
  required String title,
  required String subTitle,
  String? buttonText = "",
  String? buttonText2 = "",
  bool viewCheckIcon = false,
  bool view2Button = false,
  bool viewDropDownButton = false,
  String? dropDownValue,
  String? dropDownTitle,
  String? textFormFieldHint,
  required bool home,
  TextEditingController? textFormFieldController,
  bool? view = false,
  var code,
  required fieldFocusNode,
  bool? widgetTextFormField = false,
  bool? viewHeaderIcon = true,
  bool viewPhoneField = false,
  Widget? buttonWidget,
  Widget? widgets,
  List<DropdownMenuItem<String>>? dropDownItems,
  void Function(String?)? dropDownOnChanged,
  Widget? headerIcon,
  double? bottomSheetHeight,
  bool? enableDrag,
  countryCodeController,
  phoneController,
  bool? isDismissible,
  void Function()? onTapButton,
  void Function()? onTapButton2,
}) async {
  return await showModalBottomSheet(
    context: context,
    isDismissible: isDismissible ?? true,
    enableDrag: enableDrag ?? true,
    backgroundColor: Colors.transparent,
    // Make the background transparent
    isScrollControlled: true,
    // Allow full screen interaction
    builder: (BuildContext context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint("close1");
          if (home == true) {
            context.goNamed(AppRoutes.home.name,
                pathParameters: {'lang': context.locale.languageCode});
          } else {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  debugPrint("close2");
                  if (home == true) {
                    context.goNamed(AppRoutes.home.name,
                        pathParameters: {
                          'lang': context.locale.languageCode
                        });
                  } else {
                    Navigator.pop(context);
                  } // Close the bottom sheet when tapping outside
                },
                child: Container(
                  color: Colors.transparent, // Ensure taps are detected
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return GestureDetector(
                  onTap: () {},
                  // Prevent taps inside from closing the bottom sheet
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(35.0)),
                      gradient: LinearGradient(
                        colors: [Color(0xffFDFDFD), Color(0xffF4F7FF)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    width: double.infinity,
                    height: bottomSheetHeight ?? (viewDropDownButton || (code != null && code != "")? MediaQuery
                        .of(context)
                        .size
                        .height * 0.56
                        : MediaQuery
                        .of(context)
                        .size
                        .height * 0.52),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (viewHeaderIcon == true)Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    width: 88,
                                    height: 88,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xffE6007E)
                                          .withOpacity(0.05),
                                    ),
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xffE6007E),
                                        ),
                                        child: headerIcon),
                                  ),
                                  if (viewCheckIcon == true)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Color(0xff38CF71),
                                        child: Icon(
                                          Icons.check,
                                          color: Color(0xffFFFFFF),
                                          size: 12,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                              if (viewHeaderIcon == true) const SizedBox(
                                  height: 15),
                              Text(
                                title.toUpperCase(),
                                style:  const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: Color(0xffE6007E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if(subTitle != "")const SizedBox(height: 15),
                              if(subTitle != "")Text(
                                subTitle,
                                style:  const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff1B1B1B),
                                    fontFamily: "Poppins"),
                                textAlign: TextAlign.center,
                              ),
                              if(code != null && code != "") const SizedBox(
                                height: 15,),
                              if(code != null && code != "") Container(
                                height: 50,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    left: LocalizationService.isArabic(
                                        context: context) ? 0 : 16,
                                    right: LocalizationService.isArabic(
                                        context: context) ? 16 : 0),
                                decoration: ShapeDecoration(
                                  color: AppThemeService.colorPalette
                                      .tertiaryColorBackground.color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.s10),
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
                                    Text(code.toString(),
                                      style:  TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Color(AppColors.grey50)),),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        copyToClipboard(
                                            context, text: code.toString());
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius
                                                .circular(8),
                                            color: const Color(0xffE8E8E8)
                                        ),
                                        child: Text(AppStrings.copy.tr(),
                                          style:  const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if(subTitle == "") const SizedBox(height: 15),
                              if (viewDropDownButton == true)
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0.5),
                                      child: Container(
                                        height: 49,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffE6007E),
                                          borderRadius: BorderRadius.circular(
                                              8),
                                        ),
                                      ),
                                    ),
                                    defaultDropdownField(
                                        items: dropDownItems,
                                        title: dropDownTitle,
                                        value: dropDownValue,
                                        onChanged: dropDownOnChanged),
                                  ],
                                ),

                              if (viewPhoneField == true)
                                PhoneNumberField(
                                  controller: phoneController,
                                  countryCodeController: countryCodeController,
                                ),
                              if (widgetTextFormField ==
                                  true) defaultTextFormField(
                                  onTap: () {
                                    if (!fieldFocusNode.hasFocus) {
                                      fieldFocusNode.requestFocus();
                                    }
                                  },
                                  context: context,
                                  hintText: textFormFieldHint,
                                  controller: textFormFieldController),
                              const SizedBox(height: 30),
                              if (view == true)const Center(
                                  child: CircularProgressIndicator()),
                              if (view == false && view2Button == false &&
                                  widgets == null) GestureDetector(
                                onTap: onTapButton,
                                child: Container(
                                  height: 50,
                                  width: 225,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: const Color(0xff0D3B6F)),
                                  child: (buttonWidget != null)
                                      ? buttonWidget
                                      : Text(
                                    buttonText?.toUpperCase() ?? "",
                                    style:  const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xffFFFFFF),
                                        fontFamily: "Poppins"),
                                  ),
                                ),
                              ),
                              if(view2Button == true) Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: onTapButton,
                                      child: Container(
                                        height: 50,
                                        width: 225,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius
                                                .circular(50),
                                            color: const Color(0xff0D3B6F)),
                                        child: (buttonWidget != null)
                                            ? buttonWidget
                                            : Text(
                                          buttonText?.toUpperCase() ?? "",
                                          style:  const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffFFFFFF),
                                              fontFamily: "Poppins"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: onTapButton2,
                                      child: Container(
                                        height: 50,
                                        width: 225,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius
                                                .circular(50),
                                            color: const Color(0xffA60B0B)),
                                        child: (buttonWidget != null)
                                            ? buttonWidget
                                            : Text(
                                          buttonText2?.toUpperCase() ?? "",
                                          style:  const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffFFFFFF),
                                              fontFamily: "Poppins"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if(widgets != null)widgets
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
defaultActionBottomSheet(
        {required BuildContext? context,
        required String? title,
        required String? subTitle,
        String? buttonText,
        bool viewCheckIcon = false,
        bool viewPhoneField = false,
        bool viewDropDownButton = false,
        bool viewRefLinkButton = false,
        String? dropDownValue,
        String? refLink,
        String? dropDownTitle,
        String? textFormFieldHint,
        TextEditingController? textFormFieldController,
        bool? view = false,
        bool? widgetTextFormField = false,
        bool? viewHeaderIcon = true,
        Widget? buttonWidget,
        List<DropdownMenuItem<String>>? dropDownItems,
        void Function(String?)? dropDownOnChanged,
        void Function(String?)? textFieldOnChanged,
        Widget? headerIcon,
        double? bottomSheetHeight,
        countryCodeController,
        phoneController,
        void Function()? onTapButton}) =>
    showModalBottomSheet(
      context: context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
              color: Color(0xffFFFFFF)),
          width: double.infinity,
          height: (bottomSheetHeight != null)
              ? bottomSheetHeight
              : (viewDropDownButton == false)
                  ? MediaQuery.sizeOf(context).height * 0.5
                  : MediaQuery.sizeOf(context).height * 0.56,
          alignment: Alignment.center,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Container(
                  height: 5,
                  width: 63,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: const Color(0xffB9C0C9)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (viewHeaderIcon == true)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE93F81).withOpacity(0.05),
                            ),
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE93F81),
                                ),
                                child: headerIcon),
                          ),
                          if (viewCheckIcon == true)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Color(0xff38CF71),
                                child: Icon(
                                  Icons.check,
                                  color: Color(0xffFFFFFF),
                                  size: 12,
                                ),
                              ),
                            )
                        ],
                      ),
                    const SizedBox(height: 20),
                    Text(
                      title!.toUpperCase(),
                      style:  TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(AppColors.dark),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      subTitle!,
                      style:  const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(AppColors.black),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    if (viewDropDownButton == true)
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 0.5),
                            child: Container(
                              height: 49,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE93F81),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          defaultDropdownField(
                              items: dropDownItems,
                              title: dropDownTitle,
                              value: dropDownValue,
                              onChanged: dropDownOnChanged),
                        ],
                      ),
                    if (widgetTextFormField == true)
                      defaultTextFormField(
                          context: context,
                          onChanged: textFieldOnChanged,
                          hintText: textFormFieldHint,
                          controller: textFormFieldController),
                    if (viewRefLinkButton == true)
                      Container(
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                        child: Text(refLink!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xff5E5E5E)),),
                      ),
                    if (viewPhoneField == true)
                      PhoneNumberField(
                        controller: phoneController,
                        countryCodeController: countryCodeController,
                      ),
                    const SizedBox(height: 30),
                    if (view == true)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    if (view == false)
                      GestureDetector(
                        onTap: onTapButton,
                        child: Container(
                          height: 50,
                          width: 225,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Color(AppColors.primary)),
                          child: (buttonWidget != null)
                              ? buttonWidget
                              : Text(
                                  buttonText!.toUpperCase(),
                                  style:  const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffFFFFFF),
                                      ),
                                ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
Future<void> defaultActionBottomSheetPoints({
  required BuildContext context,
  required String title,
  required String subTitle,
  String? buttonText = "",
  String? buttonText2 = "",
  bool viewCheckIcon = false,
  bool view2Button = false,
  bool viewDropDownButton = false,
  String? dropDownValue,
  String? dropDownTitle,
  String? textFormFieldHint,
  required bool home,
  TextEditingController? textFormFieldController,
  bool? view = false,
  var code,
  required fieldFocusNode,
  bool? widgetTextFormField = false,
  bool? viewHeaderIcon = true,
  bool viewPhoneField = false,
  Widget? buttonWidget,
  Widget? widgets,
  List<DropdownMenuItem<String>>? dropDownItems,
  void Function(String?)? dropDownOnChanged,
  Widget? headerIcon,
  double? bottomSheetHeight,
  bool? enableDrag,
  countryCodeController,
  phoneController,
  bool? isDismissible,
  void Function()? onTapButton,
  void Function()? onTapButton2,
}) async {
  return await showModalBottomSheet(
    context: context,
    isDismissible: isDismissible ?? true,
    enableDrag: enableDrag ?? true,
    backgroundColor: Colors.transparent,
    // Make the background transparent
    isScrollControlled: true,
    // Allow full screen interaction
    builder: (BuildContext context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Navigator.pop(context);
          //
          // if (home == true) {
          //   context.goNamed(AppRoutes.eCommerceHomeScreen.name,
          //       pathParameters: {'lang': context.locale.languageCode});
          // }
          // else {
          //   Navigator.pop(context);
          // }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // debugPrint("close2");
                  // if (home == true) {
                  //   context.goNamed(AppRoutes.eCommerceHomeScreen.name,
                  //       pathParameters: {
                  //         'lang': context.locale.languageCode
                  //       });
                  // }
                  // else {
                  //   Navigator.pop(context);
                  // } // Close the bottom sheet when tapping outside
                },
                child: Container(
                  color: Colors.transparent, // Ensure taps are detected
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return GestureDetector(
                  onTap: () {},
                  // Prevent taps inside from closing the bottom sheet
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(35.0)),
                      gradient: LinearGradient(
                        colors: [Color(0xffFDFDFD), Color(0xffF4F7FF)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    width: double.infinity,
                    height: bottomSheetHeight ?? (viewDropDownButton || (code != null && code != "")? MediaQuery
                        .of(context).size
                        .height * 0.56
                        : MediaQuery
                        .of(context)
                        .size
                        .height * 0.52),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (viewHeaderIcon == true)Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    width: 88,
                                    height: 88,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xffE6007E)
                                          .withOpacity(0.05),
                                    ),
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xffE6007E),
                                        ),
                                        child: headerIcon),
                                  ),
                                  if (viewCheckIcon == true)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Color(0xff38CF71),
                                        child: Icon(
                                          Icons.check,
                                          color: Color(0xffFFFFFF),
                                          size: 12,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                              if (viewHeaderIcon == true) const SizedBox(
                                  height: 15),
                              Text(
                                title.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: Color(0xffE6007E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if(subTitle != "")const SizedBox(height: 15),
                              if(subTitle != "")Text(
                                subTitle,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff1B1B1B),
                                    fontFamily: "Poppins"),
                                textAlign: TextAlign.center,
                              ),
                              if(code != null && code != "") const SizedBox(
                                height: 15,),
                              if(code != null && code != "") Container(
                                height: 50,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    left: LocalizationService.isArabic(
                                        context: context) ? 0 : 16,
                                    right: LocalizationService.isArabic(
                                        context: context) ? 16 : 0),
                                decoration: ShapeDecoration(
                                  color: AppThemeService.colorPalette
                                      .tertiaryColorBackground.color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.s10),
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
                                    Text(code.toString(),
                                      style:  TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Color(AppColors.gray1)),),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        copyToClipboard(
                                            context, text: code.toString());
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius
                                                .circular(8),
                                            color: const Color(0xffE8E8E8)
                                        ),
                                        child: Text(AppStrings.copy.tr(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              if(subTitle == "") const SizedBox(height: 15),
                              if (viewDropDownButton == true)
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 0.5),
                                      child: Container(
                                        height: 49,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffE6007E),
                                          borderRadius: BorderRadius.circular(
                                              8),
                                        ),
                                      ),
                                    ),
                                    defaultDropdownField(
                                        items: dropDownItems,
                                        title: dropDownTitle,
                                        value: dropDownValue,
                                        onChanged: dropDownOnChanged),
                                  ],
                                ),

                              if (viewPhoneField == true)
                                PhoneNumberField(
                                  controller: phoneController,
                                  countryCodeController: countryCodeController,
                                ),
                              if (widgetTextFormField ==
                                  true) defaultTextFormFieldPoints( focusNode: fieldFocusNode,
                                  onTap: () {
                                    if (!fieldFocusNode.hasFocus) {
                                      fieldFocusNode.requestFocus();
                                    }
                                  },
                                  context: context,
                                  hintText: textFormFieldHint,
                                  controller: textFormFieldController),
                              const SizedBox(height: 30),
                              if (view == true)const Center(
                                  child: CircularProgressIndicator()),
                              if (view == false && view2Button == false &&
                                  widgets == null) GestureDetector(
                                onTap: onTapButton,
                                child: Container(
                                  height: 50,
                                  width: 225,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: const Color(0xff0D3B6F)),
                                  child: (buttonWidget != null)
                                      ? buttonWidget
                                      : Text(
                                    buttonText?.toUpperCase() ?? "",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xffFFFFFF),
                                        fontFamily: "Poppins"),
                                  ),
                                ),
                              ),
                              if(view2Button == true) Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: onTapButton,
                                      child: Container(
                                        height: 50,
                                        width: 225,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius
                                                .circular(50),
                                            color: const Color(0xff0D3B6F)),
                                        child: (buttonWidget != null)
                                            ? buttonWidget
                                            : Text(
                                          buttonText?.toUpperCase() ?? "",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffFFFFFF),
                                              fontFamily: "Poppins"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: onTapButton2,
                                      child: Container(
                                        height: 50,
                                        width: 225,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius
                                                .circular(50),
                                            color: const Color(0xffA60B0B)),
                                        child: (buttonWidget != null)
                                            ? buttonWidget
                                            : Text(
                                          buttonText2?.toUpperCase() ?? "",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffFFFFFF),
                                              fontFamily: "Poppins"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if(widgets != null)widgets
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
