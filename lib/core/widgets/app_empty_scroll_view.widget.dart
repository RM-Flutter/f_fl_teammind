import 'package:flutter/material.dart';

import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';

/// An empty state that sits in the middle of the free space and can still be pulled to refresh.
/// Use it inside a `RefreshIndicator` instead of a `SingleChildScrollView` with a fixed-height
/// placeholder, which leaves the logo and text near the top.
class AppEmptyScrollView extends StatelessWidget {
  final String title;
  final String? message;
  const AppEmptyScrollView({super.key, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
          child: NoExistingPlaceholderScreen(title: title, message: message),
        ),
      ),
    );
  }
}
