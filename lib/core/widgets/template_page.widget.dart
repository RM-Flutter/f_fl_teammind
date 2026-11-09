import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_design.dart';
import '../constants/app_images.dart';
import 'app_bar_with_bookmark.widget.dart';
import 'app_content_width.widget.dart';
import 'hide_on_scroll_fab.widget.dart';

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

  /// Hide [floatingActionButton] smoothly while scrolling down (layout rule 6).
  final bool hideFabOnScroll;

  /// Use the home header look: navy background with the header texture, rounded bottom
  /// corners and white title / icons. Good for tab pages with a carousel in [bottomAppbarWidget].
  final bool brandedHeader;

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
      this.hideFabOnScroll = true,
      this.brandedHeader = false,
      this.routeName});

  static const BorderRadius _headerRadius = BorderRadius.only(
    bottomLeft: Radius.circular(AppRadius.xl),
    bottomRight: Radius.circular(AppRadius.xl),
  );

  @override
  Widget build(context) {
    final canPop = context.canPop() || Navigator.of(context).canPop();
    final navy = Color(AppColors.secondaryButton);
    return HideOnScrollFabHost(
      enabled: hideFabOnScroll,
      builder: (context, wrapFab) => Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: wrapFab(floatingActionButton),
      appBar: AppBarWithBookmark(
        actions: actions,
        backgroundColor: brandedHeader ? navy : Colors.white,
        title: title,
        titleStyle: titleStyle ??
            TextStyle(
              fontSize: brandedHeader ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: brandedHeader ? Colors.white : navy,
            ),
        bookmarkIconColor: brandedHeader ? Colors.white : null,
        shape: brandedHeader
            ? const RoundedRectangleBorder(borderRadius: _headerRadius)
            : null,
        systemOverlayStyle:
            brandedHeader ? SystemUiOverlayStyle.light : null,
        flexibleSpace: brandedHeader
            ? ClipRRect(
                borderRadius: _headerRadius,
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    AppImages.brandedHeaderBackground,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              )
            : null,
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
      body: AppContentWidth(
        child: onRefresh != null
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
      ),
      ),
    );
  }
}
