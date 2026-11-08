import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'app_bar_with_bookmark.widget.dart';

class TemplatePage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final BuildContext pageContext;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottomAppbarWidget;
  final String? routeName;
  final TextStyle? titleStyle;
  final dynamic popResult;
  final bool showBookmark;

  /// used if you want to active [PULLTOREFRESH] option to page.
  final Future<void> Function()? onRefresh;
  const TemplatePage(
      {super.key,
      this.actions,
      this.bottomAppbarWidget,
      this.backgroundColor,
      required this.pageContext,
      required this.title,
      required this.body,
      this.floatingActionButton,
      this.titleStyle,
      this.onRefresh,
      this.popResult,
      this.showBookmark = true,
      this.routeName});

  @override
  Widget build(context) {
    final canPop = context.canPop() || Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      appBar: AppBarWithBookmark(
        actions: actions,
        backgroundColor: Colors.white,
        title: title,
        titleStyle: titleStyle ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(AppColors.secondaryButton),
            ),
        bottom: bottomAppbarWidget,
        routeName: routeName,
        defaultTitle: title,
        showBookmark: showBookmark,
        leading: canPop
            ? AppBackButton(
                onTap: () => pageContext.pop(popResult),
                popResult: popResult,
              )
            : const SizedBox.shrink(),
      ),
      body: onRefresh != null
          ? RefreshIndicator.adaptive(
              onRefresh: onRefresh!,
              child: ListView(
                clipBehavior: Clip.none,
                children: [
                  body,
                ],
              ),
            )
          : body,
    );
  }
}
