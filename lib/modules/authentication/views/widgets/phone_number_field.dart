import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart' as intl_phone_field;
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/platform/platform_is.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../general_services/localization.service.dart';

class PhoneNumberField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController countryCodeController;
  final String? initialCountry;
  final String? phoneError;
  final void Function()? triggerFunction;

  const PhoneNumberField({
    super.key,
    required this.controller,
    this.triggerFunction,
    this.phoneError,
    this.initialCountry ,
    required this.countryCodeController,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  int maxLength = 14;
  int minLength = 7;
  String? detectedCountryCode = CacheHelper.getString("flag");
  bool _isFiltering = false; // لمنع loop في listener

  @override
  void initState() {
    super.initState();
    widget.countryCodeController.text = CacheHelper.getString("flagCode");
    
    // على الويب، إضافة listener لمنع إدخال الحروف
    if (kIsWeb || PlatformIs.web) {
      widget.controller.addListener(_filterNonNumericOnWeb);
    }
  }
  
  @override
  void dispose() {
    // إزالة listener عند التخلص من الـ widget
    if (kIsWeb || PlatformIs.web) {
      widget.controller.removeListener(_filterNonNumericOnWeb);
    }
    super.dispose();
  }
  
  // دالة لتصفية الحروف على الويب
  void _filterNonNumericOnWeb() {
    if ((kIsWeb || PlatformIs.web) && !_isFiltering) {
      final text = widget.controller.text;
      final filteredText = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text != filteredText) {
        _isFiltering = true;
        // إذا كان هناك حروف، تحديث النص بدون الحروف
        final selectionOffset = widget.controller.selection.baseOffset;
        widget.controller.value = TextEditingValue(
          text: filteredText,
          selection: TextSelection.collapsed(
            offset: selectionOffset > filteredText.length 
                ? filteredText.length 
                : selectionOffset,
          ),
        );
        _isFiltering = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("detectedCountryCode is --> ${CacheHelper.getString("flag")}");
    print("detectedCountryCode is --> ${CacheHelper.getString("flagCode")}");
    return Directionality(
      textDirection: LocalizationService.isArabic(context: context)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: intl_phone_field.IntlPhoneField(
        controller: widget.controller,
        invalidNumberMessage: AppStrings.pleaseEnterValidPhoneNumber.tr(),
        languageCode: context.locale.languageCode,
        decoration: InputDecoration(
          errorText: widget.phoneError,
          hintText: AppStrings.yourPhone.tr(),
          counter: const SizedBox.shrink(),
        ),
        initialCountryCode: detectedCountryCode ?? widget.initialCountry ?? "EG",
        onChanged: (value) {
          // على الويب، التأكد من أن الرقم يحتوي على أرقام فقط
          if ((kIsWeb || PlatformIs.web) && !_isFiltering) {
            final phoneNumber = value.number.replaceAll(RegExp(r'[^0-9]'), '');
            if (phoneNumber != value.number) {
              _isFiltering = true;
              // إذا كان هناك حروف، تحديث الـ controller
              final currentText = widget.controller.text;
              final filteredText = currentText.replaceAll(RegExp(r'[^0-9]'), '');
              if (currentText != filteredText) {
                widget.controller.value = TextEditingValue(
                  text: filteredText,
                  selection: TextSelection.collapsed(offset: filteredText.length),
                );
              }
              _isFiltering = false;
            }
          }
          
          if (value.number.length >= minLength && value.number.length <= maxLength) {
            widget.triggerFunction?.call();
          }
        },
        validator: (val) {
          if (val == null || val.number.isEmpty) {
            return AppStrings.pleaseEnterValidPhoneNumber.tr();
          }
          // التحقق من أن الرقم يحتوي على أرقام فقط
          final phoneNumber = val.number.trim();
          if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
            return AppStrings.pleaseEnterValidPhoneNumber.tr();
          }
          if (phoneNumber.length < minLength || phoneNumber.length > maxLength) {
            return AppStrings.pleaseEnterValidPhoneNumber.tr();
          }
          return null;
        },
        onCountryChanged: (country) {
          setState(() {
            minLength = country.minLength;
            maxLength = country.maxLength;
          });
          widget.countryCodeController.text = '+${country.dialCode}';
        },
        disableAutoFillHints: false,
        disableLengthCheck: false,
        keyboardType: TextInputType.phone,
        flagsButtonMargin: const EdgeInsets.symmetric(
          horizontal: AppSizes.s12,
          vertical: AppSizes.s8,
        ),
        dropdownIcon: const Icon(
          Icons.arrow_drop_down,
        ),
        dropdownTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        dropdownIconPosition: intl_phone_field.IconPosition.trailing,
        showCursor: true,
        dropdownDecoration: BoxDecoration(
          border: LocalizationService.isArabic(context: context)
              ? const Border(
                  left: BorderSide(color: Color(0xffDFDFDF), width: 1.4))
              : const Border(
                  right: BorderSide(color: Color(0xffDFDFDF), width: 1.4),
                ),
        ),
        pickerDialogStyle: PickerDialogStyle(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
              vertical: AppSizes.s16, horizontal: AppSizes.s6),
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
