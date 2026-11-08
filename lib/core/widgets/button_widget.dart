import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_design.dart';
import '../constants/app_sizes.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double borderRadius;
  final BorderSide borderSide;
  final EdgeInsets? padding;
  final bool? isLoading;
  final String title;
  final String? svgIcon;
  final Color? svgIconColor;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final double? fontSize;

  const ButtonWidget({
    super.key,
    required this.onPressed,
    this.backgroundColor,
    this.borderRadius = AppRadius.pill,
    this.borderSide = BorderSide.none,
    this.padding,
    required this.title,
    this.isLoading = false,
    this.svgIcon,
    this.svgIconColor,
    this.fontColor,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? Color(AppColors.buttons);
    final effectiveFg = fontColor ?? Colors.white;

    return isLoading == false
        ? SizedBox(
            height: AppButtonSize.height,
            child: ElevatedButton(
              onPressed: isLoading == false ? onPressed : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: effectiveBg,
                foregroundColor: effectiveFg,
                minimumSize:
                    const Size(AppButtonSize.minWidth, AppButtonSize.height),
                padding: padding ?? AppButtonSize.padding,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                  side: borderSide,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (svgIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.s12),
                      child: SvgPicture.asset(
                        svgIcon!,
                        fit: BoxFit.scaleDown,
                        colorFilter: svgIconColor != null
                            ? ColorFilter.mode(svgIconColor!, BlendMode.srcIn)
                            : null,
                      ),
                    ),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: fontWeight ?? FontWeight.w600,
                      color: effectiveFg,
                      fontSize: fontSize ?? AppButtonSize.fontSize,
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox(
            height: AppButtonSize.height,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).progressIndicatorTheme.color ??
                    Color(AppColors.buttons),
              ),
            ),
          );
  }
}
