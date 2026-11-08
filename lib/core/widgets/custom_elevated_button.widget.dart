import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_design.dart';
import '../constants/app_sizes.dart';

class CustomElevatedButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String title;
  final ButtonStyle? buttonStyle;
  final Widget? titleWidget;
  final double? width;
  final double? height;
  @Deprecated('All buttons use AppButtonSize.fontSize; this value is ignored.')
  final double? titleSize;
  @Deprecated('All buttons are pill shaped (AppRadius.pill); this value is ignored.')
  final double? radius;
  final Color? backgroundColor;
  final Color? outlineColor;
  final bool? isFuture;
  final bool? isPrimaryBackground;
  final bool? isOutlined;
  final bool isDestructive;
  final bool isCompact;
  final IconData? icon;
  final Color? titleColor;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.titleColor,
    required this.title,
    this.buttonStyle,
    this.titleWidget,
    this.titleSize,
    this.backgroundColor,
    this.outlineColor,
    this.radius,
    this.width,
    this.height,
    this.isFuture = true,
    this.isPrimaryBackground = true,
    this.isOutlined = false,
    this.isDestructive = false,
    this.isCompact = false,
    this.icon,
  });

  @override
  CustomElevatedButtonState createState() => CustomElevatedButtonState();
}

class CustomElevatedButtonState extends State<CustomElevatedButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    if (!mounted) return;
    try {
      await _controller.forward();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    await widget.onPressed();

    if (mounted) {
      try {
        if (_controller.isAnimating || _controller.value > 0) {
          await _controller.reverse();
        }
      } catch (e) {
        // Controller might be disposed, ignore
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.isDestructive
        ? Color(AppColors.failureRed)
        : (widget.backgroundColor ?? Color(AppColors.buttons));
    final Color effectiveOutlineColor = widget.outlineColor ?? primaryColor;
    final Color effectiveTextColor = widget.titleColor ??
        (widget.isOutlined == true ? effectiveOutlineColor : Colors.white);
    final double effectiveHeight = widget.height ??
        (widget.isCompact ? AppButtonSize.compactHeight : AppButtonSize.height);

    final ButtonStyle baseStyle = ElevatedButton.styleFrom(
      backgroundColor:
          widget.isOutlined == true ? Colors.transparent : primaryColor,
      foregroundColor: effectiveTextColor,
      disabledForegroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: AppButtonSize.padding,
      side: widget.isOutlined == true
          ? BorderSide(color: effectiveOutlineColor, width: 1.5)
          : null,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
    );

    final ButtonStyle effectiveStyle = widget.buttonStyle != null
        ? widget.buttonStyle!.copyWith(
            elevation: const WidgetStatePropertyAll(0),
            shadowColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
          )
        : baseStyle;

    return LayoutBuilder(
      builder: (context, constraints) {
        double targetWidth = widget.width ?? AppSizes.s200;
        if (targetWidth == double.infinity) {
          targetWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isLoading ? effectiveHeight * 1.5 : targetWidth,
              height: effectiveHeight,
              child: ElevatedButton(
                style: effectiveStyle,
                onPressed: widget.isFuture == true
                    ? _isLoading
                        ? () {}
                        : _handlePressed
                    : widget.onPressed,
                child: widget.isFuture == true && _isLoading
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              effectiveTextColor,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: widget.titleWidget ??
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.icon != null) ...[
                                    Icon(
                                      widget.icon,
                                      size: 18,
                                      color: effectiveTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    widget.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontSize: AppButtonSize.fontSize,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4,
                                          color: effectiveTextColor,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
