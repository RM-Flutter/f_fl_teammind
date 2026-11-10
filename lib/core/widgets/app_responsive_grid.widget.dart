import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:flutter/material.dart';

/// Lays [children] out in equal-width columns that follow the window width (see
/// [LayoutService.columns]) with [AppSpacing.md] between them, both ways. The last row, when it
/// is not full, stays on the start side and keeps the same cell width as the others.
///
/// Pass [rowHeight] for tiles of one fixed height (service tiles); without it each card keeps its
/// own height and the cards of a row are aligned at the top. It is a plain Column of Rows, so it
/// works inside any scroll view.
class AppResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? compact;
  final int? medium;
  final int? expanded;
  final double? rowHeight;
  final double gap;

  const AppResponsiveGrid({
    super.key,
    required this.children,
    this.compact,
    this.medium,
    this.expanded,
    this.rowHeight,
    this.gap = AppSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    final cols = LayoutService.columns(
      context,
      compact: compact ?? 1,
      medium: medium ?? 2,
      expanded: expanded ?? 3,
    );
    if (cols <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            rowHeight != null ? SizedBox(height: rowHeight, child: children[i]) : children[i],
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += cols) {
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < cols; c++) ...[
            if (c > 0) SizedBox(width: gap),
            Expanded(
              child: i + c < children.length
                  ? (rowHeight != null
                      ? SizedBox(height: rowHeight, child: children[i + c])
                      : children[i + c])
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}
