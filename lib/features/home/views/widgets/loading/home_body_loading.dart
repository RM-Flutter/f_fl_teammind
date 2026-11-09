import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';
import 'package:flutter/material.dart';

/// Home body while loading: two sections (title row + cards) shaped exactly like the loaded
/// sections, with the same page padding.
class HomeLoadingPage extends StatelessWidget {
  const HomeLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppShimmerList(
            count: 3,
            showHeader: true,
            padding: AppSpacing.pagePadding,
          ),
          SizedBox(height: AppSpacing.section),
          AppShimmerList(
            count: 2,
            showHeader: true,
            padding: AppSpacing.pagePadding,
          ),
        ],
      ),
    );
  }
}
