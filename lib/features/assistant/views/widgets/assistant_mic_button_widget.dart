import 'package:app_test/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// زر الميكروفون: يتحول إلى زر إيقاف أثناء الاستماع.
class AssistantMicButtonWidget extends StatelessWidget {
  final bool listening;
  final VoidCallback onPressed;

  const AssistantMicButtonWidget({
    super.key,
    required this.listening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor:
            listening ? Colors.redAccent : Color(AppColors.secondaryButton),
      ),
      icon: Icon(listening ? Icons.stop : Icons.mic, color: Colors.white),
    );
  }
}
