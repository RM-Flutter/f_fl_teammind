import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/services/layout_service.dart';

/// Lays simple cards out in 1 column on phones, 2 on medium and 3 on expanded windows, with
/// [AppSpacing.cardGap] between them. It does not scroll by itself: put it inside the page's
/// scroll view. Use it for lists of small, same-shaped cards (team members, reports, files).
/// Wide cards (requests with long dates) should stay one column.
class AppAdaptiveWrap extends StatelessWidget {
  final List<Widget> children;
  const AppAdaptiveWrap({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final columns = LayoutService.listColumns(context);
    if (columns == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.cardGap),
            children[i],
          ],
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - AppSpacing.cardGap * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.cardGap,
          runSpacing: AppSpacing.cardGap,
          children: [
            for (final child in children) SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
