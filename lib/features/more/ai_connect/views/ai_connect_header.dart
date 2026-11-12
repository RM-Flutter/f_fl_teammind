import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:flutter/material.dart';

/// Same header style as the other More sub-screens (back, centred title).
class AiConnectHeader extends StatelessWidget {
  final String title;
  const AiConnectHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppContentWidth(
      child: SizedBox(
        height: AppSizes.s64,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Color(AppColors.secondaryButton), size: 24),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.heading(context).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: AppSizes.s48),
          ],
        ),
      ),
    );
  }
}
