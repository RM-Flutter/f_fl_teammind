import 'package:app_test/core/widgets/app_field_shell.widget.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/constants/app_design.dart';

Widget defaultTextFormField({
  TextEditingController? controller,
  String? hintText,
  Widget? suffixIcon,
  bool? hasShadows = true,
  Widget? prefixIcon,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  int maxLines = 1,
  context,
  void Function()? onTap,
  List<BoxShadow>? boxShadow,
  double? containerHeight,
  Color? borderColor,
  TextInputAction? textInputAction,
  void Function(String)? onFieldSubmitted,
  void Function(String)? onChanged,
}) {
  return Container(
    height: containerHeight ?? AppSizes.fieldHeight,
    alignment: Alignment.center,
    margin: const EdgeInsets.symmetric(vertical: AppSizes.s10),
    padding: EdgeInsets.symmetric(
        horizontal: AppSizes.s16, vertical: (maxLines > 1) ? 16 : 0),
    decoration: ShapeDecoration(
      color: AppThemeService.colorPalette.tertiaryColorBackground.color,
      shape: RoundedRectangleBorder(
        borderRadius: AppField.borderRadius,
        side: BorderSide(
          color: borderColor ?? AppField.borderColor,
          width: 1.0,
        ),
      ),
      shadows: (hasShadows == true)
          ? AppShadows.none
          : null,
    ),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      onTap: onTap,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: hintText ?? "Input",
        labelStyle: const TextStyle(
            
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff191C1F)),
        hintStyle: const TextStyle(
            
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff464646)),
        suffixIcon: suffixIcon is Icon ? AppFieldShell.icon((suffixIcon as Icon).icon!) : suffixIcon,
        prefixIcon: prefixIcon,
        border: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    ),
  );
}
Widget defaultDropdownField(
    {String? value,
    String? title,
    bool? isExpanded,
    Color? borderColor,
    IconData? icon,
    bool? hasShadows = false,
    required items,
    TextStyle? textStyle,
    context,
    required void Function(String?)? onChanged}) {
  // Same box, hint and arrow as every other field (rule 15). The arrow is the DropdownButton's
  // own icon so the whole field, up to the edge, opens the menu.
  return AppFieldShell(
    contentPadding: 0,
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppField.horizontalPadding),
        focusColor: Colors.transparent,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        icon: AppFieldShell.icon(icon ?? Icons.keyboard_arrow_down_rounded),
        isExpanded: isExpanded ?? true,
        value: value,
        style: AppField.valueStyle,
        hint: Text(title ?? '', style: AppField.hintStyle),
        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}

Widget defaultTextFormFieldPoints( {
  required focusNode,required onTap,
  TextEditingController? controller,
  String? hintText,
  Widget? suffixIcon,
  bool? hasShadows = true,
  Widget? prefixIcon,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  int maxLines = 1,
  context,
  List<BoxShadow>? boxShadow,
  double? containerHeight,
  Color? borderColor,
  TextInputAction? textInputAction,
  void Function(String)? onFieldSubmitted,
  void Function(String)? onChanged,
}) {
  return Container(
    height: containerHeight ?? AppSizes.fieldHeight,
    alignment: Alignment.center,
    margin: const EdgeInsets.symmetric(vertical: AppSizes.s10),
    padding: EdgeInsets.symmetric(
        horizontal: AppSizes.s16, vertical: (maxLines! > 1) ? 16 : 0),
    decoration: ShapeDecoration(
      color: AppThemeService.colorPalette.tertiaryColorBackground.color,
      shape: RoundedRectangleBorder(
        borderRadius: AppField.borderRadius,
        side: BorderSide(
          color: borderColor ?? AppField.borderColor,
          width: 1.0,
        ),
      ),
      shadows: (hasShadows == true)
          ? AppShadows.none
          : null,
    ),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: hintText ?? "Input",
        labelStyle: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff191C1F)),
        hintStyle: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xff464646)),
        suffixIcon: suffixIcon is Icon ? AppFieldShell.icon((suffixIcon as Icon).icon!) : suffixIcon,
        prefixIcon: prefixIcon,
        border: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    ),
  );
}

