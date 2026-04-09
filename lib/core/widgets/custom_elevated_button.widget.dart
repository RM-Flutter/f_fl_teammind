import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class CustomElevatedButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String title;
  final ButtonStyle? buttonStyle;
  final Widget? titleWidget;
  final double? width;
  final double? titleSize;
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isLoading ? AppSizes.s75 : widget.width ?? AppSizes.s200,
          height: AppSizes.s50,
          child: ElevatedButton(
            style: widget.buttonStyle ??
                ElevatedButton.styleFrom(
                  backgroundColor: widget.isOutlined == true
                      ? Colors.transparent // 👈 Transparent
                      : widget.backgroundColor ?? Theme.of(context).primaryColor,
                  foregroundColor: widget.isOutlined == true
                      ? Theme.of(context).primaryColor // 👈 Text بلون الـ primary
                      : Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: widget.isOutlined == true ? 0 : 2,
                  side: widget.isOutlined == true
                      ? BorderSide(color: widget.outlineColor ??Theme.of(context).primaryColor, width: 2)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      _isLoading ? AppSizes.s26 : widget.radius ?? AppSizes.s28,
                    ),
                  ),
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
                      style: widget.titleSize == null ?
                      widget.titleColor != null ? Theme.of(context).textTheme.headlineSmall!.copyWith(color:widget.titleColor):
                      Theme.of(context).textTheme.headlineSmall!
                          : Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: widget.titleSize, color: widget.titleColor ),
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
  }
}
