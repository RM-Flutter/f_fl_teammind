import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';

/// The "Comments" title above every comments list: the word between two divider lines. One
/// widget for every screen (tasks, complaints, daily reports ...), so it never differs.
class CommentsTitle extends StatelessWidget {
  const CommentsTitle({super.key});

  @override
  Widget build(BuildContext context) {
    Widget line() => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(strokeAlign: 1, color: Color(AppColors.divider)),
              ),
            ),
          ),
        );
    return Row(
      children: [
        line(),
        Text(
          AppStrings.comments.tr(),
          style: AppStyles.primaryContent(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        line(),
      ],
    );
  }
}
