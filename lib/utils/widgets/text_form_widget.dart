import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/general_services/app_theme.service.dart';

class TextFormWidget extends StatelessWidget {
  final TextStyle? textStyle;
  final String? Function(String?)? validatorFunc;
  final Function(String)? onChanged;
  final TextEditingController? textEditingController;
  final TextInputType textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final int? minLines;
  final int? maxLines;
  final Color? fillColor;
  final bool obscure;
  final bool autofocus;
  final String? hint;
  final Widget? icon;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final InputBorder? border;
  final void Function()? onTap;
  final bool readOnly;
  final EdgeInsets? contentPadding;
  const TextFormWidget({
    super.key,
    this.validatorFunc,
    this.textEditingController,
    this.textInputType = TextInputType.text,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 1,
    this.obscure = false,
    this.autofocus = false,
    this.hint,
    this.icon,
    this.prefix,
    this.suffix,
    this.border,
    this.contentPadding,
    this.enabled = true,
    this.textStyle,
    this.focusNode,
    this.fillColor,
    this.onChanged,
    this.onFieldSubmitted,
    this.initialValue,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter>? getInputFormatters() {
      return inputFormatters;
    }

    return TextFormField(
      enableInteractiveSelection: true,
      // contextMenuBuilder: (context, editableTextState) {
      //   final List<ContextMenuButtonItem> buttonItems =
      //       editableTextState.contextMenuButtonItems;
      //    buttonItems.map((ContextMenuButtonItem buttonItem) {
      //     return buttonItem. == ContextMenuButtonType.cut;
      //   });
      //   return AdaptiveTextSelectionToolbar.buttonItems(
      //     anchors: editableTextState.contextMenuAnchors,
      //     buttonItems: buttonItems,
      //   );
      // },
      cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
      // cursorErrorColor: AppColors.error500,
      onTap: () {
        FocusScope.of(context).requestFocus(focusNode);
        onTap != null ? onTap!() : null;
      },

      //  selectionControls: TextSelectionControls(),
      enabled: enabled,
      style: textStyle ?? Theme.of(context).inputDecorationTheme.labelStyle,
      initialValue: initialValue,
      validator: validatorFunc,
      focusNode: focusNode,
      obscureText: obscure,
      autofocus: autofocus,
      controller: textEditingController,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: textInputType,
      readOnly: readOnly,
      inputFormatters: getInputFormatters(),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,

      decoration: InputDecoration(
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        filled: true,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(vertical: 18, horizontal: 26),
        hintText: hint ?? '',
        // fillColor: fillColor ??
        //     (enabled ? AppColors.neutral0 : AppColors.neutral25),
        prefixIcon: prefix,
        suffixIcon: suffix,
        icon: icon,
        errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
        errorMaxLines: 2,
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
        border: border ?? Theme.of(context).inputDecorationTheme.border,

        enabledBorder:
            border ?? Theme.of(context).inputDecorationTheme.enabledBorder,
        focusedBorder:
            border ?? Theme.of(context).inputDecorationTheme.focusedBorder,

        errorBorder:
            border ?? Theme.of(context).inputDecorationTheme.errorBorder,
        focusedErrorBorder:
            border ?? Theme.of(context).inputDecorationTheme.focusedErrorBorder,

        disabledBorder:
            border ?? Theme.of(context).inputDecorationTheme.disabledBorder,
      ),
    );
  }
}
Widget defaultDropdownField(
    {String? value,
      String? title,
      bool? isExpanded,
      Color? borderColor,
      required items,
      required void Function(String?)? onChanged}) {
  return Container(
    height: 65,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    decoration: ShapeDecoration(
      color: Colors.white,
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
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(AppColors.black),
        ),
        isExpanded: isExpanded ?? true,
        value: value,
        hint: Text(
          title!,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xff191C1F)),
        ),
        items: items,
        underline: const SizedBox.shrink(),
        onChanged: onChanged),
  );
}
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
        horizontal: 16, vertical: (maxLines! > 1) ? 16 : 0),
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