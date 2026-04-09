import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
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
      this.routeName});

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      appBar: AppBarWithBookmark(
        actions: actions,
        backgroundColor:
            backgroundColor ?? Theme.of(pageContext).scaffoldBackgroundColor,
        title: title,
        titleStyle: titleStyle ?? TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(AppColors.titleText)
        ),
        bottom: bottomAppbarWidget,
        routeName: routeName,
        defaultTitle: title,
        leading: context.canPop()
            ? Padding(
                padding: const EdgeInsets.all(AppSizes.s10),
                child: InkWell(
                  onTap: () => pageContext.pop(),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(AppColors.titleText)),
                    child: const Icon(
                      Icons.arrow_back_sharp,
                      color: Colors.white,
                      size: AppSizes.s18,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
      body: onRefresh != null
          ? RefreshIndicator.adaptive(
              onRefresh: onRefresh!,
              child: ListView(
                children: [
                  body,
                ],
              ),
            )
          : body,
    );
  }
}
