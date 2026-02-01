import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/app_theme_service.dart';

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
    height: containerHeight ?? 50,
    alignment: Alignment.center,
    margin: const EdgeInsets.symmetric(vertical: AppSizes.s10),
    padding: EdgeInsets.symmetric(
        horizontal: 16, vertical: (maxLines > 1) ? 16 : 0),
    decoration: ShapeDecoration(
      color: AppThemeService.colorPalette.tertiaryColorBackground.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.s8),
        side: BorderSide(
          color: borderColor ?? const Color(0xffE3E5E5),
          width: 1.0,
        ),
      ),
      shadows: (hasShadows == true)
          ? const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, 1),
                spreadRadius: 0,
              )
            ]
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
        suffixIcon: suffixIcon,
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
    required items,
    required void Function(String?)? onChanged}) {
  return Container(
    height: 60,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    decoration: ShapeDecoration(
      color: AppThemeService.colorPalette.tertiaryColorBackground.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.s10),
        side: BorderSide(
          color: borderColor ?? const Color(0xffE3E5E5),
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
    child: DropdownButton<String>(
        dropdownColor: Colors.white,
        icon:  Icon(
          Icons.arrow_drop_down_sharp,
          color: Color(AppColors.primary),
        ),
        isExpanded: isExpanded ?? true,
        value: value,
        hint: Text(
          title!,
          style:  const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xff464646)),
        ),
        items: items,
        underline: const SizedBox.shrink(),
        onChanged: onChanged),
  );
}

