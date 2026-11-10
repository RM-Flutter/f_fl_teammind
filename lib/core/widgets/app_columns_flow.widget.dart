import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:flutter/material.dart';

/// A drop-in replacement for a `Column` of form fields / info cards. On phones and tablets it is
/// that Column; from 1024 wide it spreads the children over two columns (row by row: 1st left,
/// 2nd right, 3rd left ...), so the page fills the width instead of one very wide column.
///
/// The first [fullWidthCount] children (a photo block, a title) stay full width on top.
/// The [crossAxisAlignment] / [mainAxisSize] parameters exist so a `Column(...)` can be renamed
/// to `AppColumnsFlow(...)` without touching its arguments.
class AppColumnsFlow extends StatelessWidget {
  final List<Widget> children;
  final int fullWidthCount;
  final int expandedColumns;

  /// Gap between two items of the same column on wide screens. Plain `SizedBox(height: n)`
  /// spacers inside [children] are dropped there and replaced by this gap.
  final double itemGap;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const AppColumnsFlow({
    super.key,
    required this.children,
    this.fullWidthCount = 0,
    this.expandedColumns = 2,
    this.itemGap = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final cols = LayoutService.columns(context,
        compact: 1, medium: 1, expanded: expandedColumns);
    if (cols <= 1) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }
    bool isSpacer(Widget w) =>
        w is SizedBox && w.child == null && w.width == null && w.height != null;
    final real = children.where((w) => !isSpacer(w)).toList();
    final head = real.take(fullWidthCount).toList();
    final rest = real.skip(fullWidthCount).toList();
    final columns = List.generate(cols, (_) => <Widget>[]);
    for (var i = 0; i < rest.length; i++) {
      columns[i % cols].add(rest[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...head,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < cols; c++) ...[
              if (c > 0) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < columns[c].length; i++) ...[
                      if (i > 0 && itemGap > 0) SizedBox(height: itemGap),
                      columns[c][i],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
