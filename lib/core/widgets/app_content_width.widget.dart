import 'package:flutter/material.dart';

import 'package:app_test/core/services/layout_service.dart';

/// Keeps page content from stretching across a wide window: on medium and expanded windows the
/// content is at most [LayoutService.contentMaxWidth] wide and centred; on phones it is returned
/// untouched. [TemplatePage] and [CoreMobileScaffold] already use it, so screens built on them
/// need nothing. The height stays tight, so `Expanded` / lists inside still fill the page.
class AppContentWidth extends StatelessWidget {
  final Widget child;
  const AppContentWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final maxWidth = LayoutService.contentMaxWidth(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) return child;
        return Center(
          child: SizedBox(
            width: maxWidth,
            height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
            child: child,
          ),
        );
      },
    );
  }
}
