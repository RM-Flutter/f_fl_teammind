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
  final bool? isOutlined; // 👈 الجديد
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
    this.isOutlined = false, // 👈 default false
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
      // Controller might be disposed
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    await widget.onPressed();
    
    // Check if widget is still mounted and controller is not disposed before using controller
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
              width: _isLoading ? AppButtonSize.height * 1.5 : targetWidth,
              height: widget.height ?? AppButtonSize.height,
          child: ElevatedButton(
            style: widget.buttonStyle ??
                ElevatedButton.styleFrom(
                  backgroundColor: widget.isOutlined == true
                      ? Colors.transparent // 👈 Transparent
                      : widget.backgroundColor ?? Color(AppColors.buttons),
                  foregroundColor: widget.isOutlined == true
                      ? Color(AppColors.buttons) // 👈 Text بلون الـ primary
                      : Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: AppButtonSize.padding,
                  side: widget.isOutlined == true
                      ? BorderSide(color: widget.outlineColor ?? Color(AppColors.buttons), width: 1.5)
                      : null,
                  // Same shape for every button in the app
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
            onPressed: widget.isFuture == true
                ? _isLoading
                ? () {}
                : _handlePressed
                : widget.onPressed,
            child: widget.isFuture == true && _isLoading
                ? const Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Center(
              child: widget.titleWidget ??
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontSize: AppButtonSize.fontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: widget.titleColor ??
                                (widget.isOutlined == true ? Color(AppColors.buttons) : null),
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
