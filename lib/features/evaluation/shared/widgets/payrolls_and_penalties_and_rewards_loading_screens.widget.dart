import 'package:flutter/material.dart';

import '../../../../core/utils/custom_shimmer_loading/app_shimmer_list.dart';

/// Loading state shared by payrolls, rewards & penalties, evaluations, commissions, salary
/// advances and expense claims. Uses the app-wide [AppShimmerList] so it matches every other
/// list in the app.
class PayrollsAndPenaltiesRewardsLoadingScreensWidget extends StatelessWidget {
  /// Padding around the placeholders. Defaults to the page padding; pass [EdgeInsets.zero]
  /// when the parent already pads the page.
  final EdgeInsetsGeometry? padding;

  const PayrollsAndPenaltiesRewardsLoadingScreensWidget({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return padding == null
        ? const AppShimmerList()
        : AppShimmerList(padding: padding!);
  }
}
