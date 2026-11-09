import 'package:flutter/material.dart';

import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';

/// An empty state that sits in the middle of the SCREEN (not just of the free space under the
/// header) and can still be pulled to refresh. Use it inside a `RefreshIndicator` instead of a
/// `SingleChildScrollView` with a fixed-height placeholder, which leaves the logo near the top.
///
/// The space above the widget (app bar, switches...) is measured once and added underneath, so
/// the content lands on the middle of the whole screen.
class AppEmptyScrollView extends StatefulWidget {
  final String title;
  final String? message;
  const AppEmptyScrollView({super.key, required this.title, this.message});

  @override
  State<AppEmptyScrollView> createState() => _AppEmptyScrollViewState();
}

class _AppEmptyScrollViewState extends State<AppEmptyScrollView> {
  double _top = 0;

  void _measure() {
    final box = context.findRenderObject();
    if (!mounted || box is! RenderBox || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if ((top - _top).abs() > 1) setState(() => _top = top);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
          child: Padding(
            padding: EdgeInsets.only(bottom: _top),
            child: NoExistingPlaceholderScreen(
                title: widget.title, message: widget.message),
          ),
        ),
      ),
    );
  }
}
