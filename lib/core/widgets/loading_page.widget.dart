import 'package:flutter/material.dart';

import '../utils/custom_shimmer_loading/app_shimmer_list.dart';

/// Loading state of a list page. Kept for the existing call sites; it is just an
/// [AppShimmerList] (cards shaped like [AppCard.listItem]) so every list loads the same way.
///
/// [height] and [reverse] are ignored now (all placeholders share one shape) and only kept so
/// old call sites still compile.
class LoadingPageWidget extends StatelessWidget {
  final double? height;
  final bool? reverse;

  /// Padding around the placeholders. Defaults to the page padding; pass [EdgeInsets.zero]
  /// when the parent already pads the page.
  final EdgeInsetsGeometry? padding;

  const LoadingPageWidget({super.key, this.height, this.reverse, this.padding});

  @override
  Widget build(BuildContext context) {
    return padding == null
        ? const AppShimmerList()
        : AppShimmerList(padding: padding!);
  }
}
