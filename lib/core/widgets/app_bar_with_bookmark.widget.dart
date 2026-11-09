import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../services/backend_services/api_service/dio_api_service/shared.dart';
import '../utils/app_styles.dart';
import 'bookmark_widgets/bookmark_button.widget.dart';

/// The single unified back button used in every AppBar across the app.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final dynamic popResult;

  const AppBackButton({
    super.key,
    this.onTap,
    this.onPressed,
    this.popResult,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.s10),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ??
            onPressed ??
            () {
              if (context.canPop()) {
                context.pop(popResult);
              } else {
                Navigator.of(context).maybePop(popResult);
              }
            },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(AppColors.secondaryButton),
          ),
          child: const Icon(
            Icons.arrow_back_sharp,
            color: Colors.white,
            size: AppSizes.s18,
          ),
        ),
      ),
    );
  }
}

/// Helper widget to create an AppBar with bookmark button and unified back button automatically added
class AppBarWithBookmark extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool centerTitle;
  final double elevation;
  final String? routeName;
  final String? defaultTitle;
  final Map<String, dynamic>? stateData;
  final PreferredSizeWidget? bottom;
  final Color? surfaceTintColor;
  final Color? bookmarkIconColor;
  final bool showBookmark;
  final bool automaticallyImplyLeading;

  /// Optional shape (e.g. rounded bottom corners) and background layer for branded headers.
  final ShapeBorder? shape;
  final Widget? flexibleSpace;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const AppBarWithBookmark({
    this.shape,
    this.flexibleSpace,
    this.systemOverlayStyle,
    super.key,
    this.title,
    this.titleWidget,
    this.titleStyle,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation = 0,
    this.routeName,
    this.defaultTitle,
    this.stateData,
    this.bottom,
    this.surfaceTintColor,
    this.bookmarkIconColor,
    this.showBookmark = true,
    this.automaticallyImplyLeading = true,
  }) : assert(title != null || titleWidget != null, 'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    GoRouterState? routerState;
    try {
      routerState = GoRouterState.of(context);
    } catch (e) {
      // Ignore if GoRouterState is not available (e.g. when pushed via normal Navigator)
    }

    final currentRouteName = routeName ?? routerState?.name ?? '';
    final currentRoutePath = routerState?.uri.toString() ?? '';
    final bookmarkTitle = defaultTitle ?? title ?? '';

    // Collect filter state for requests screen
    Map<String, dynamic>? finalStateData = stateData;
    if (currentRouteName.contains('requests') || currentRoutePath.contains('requests')) {
      finalStateData ??= {};
      final reqId = CacheHelper.getString("reqId");
      final empId = CacheHelper.getString("empId");
      final depId = CacheHelper.getString("depId");
      final selectStatus = CacheHelper.getString("selectStatus");
      final from = CacheHelper.getString("from");
      final to = CacheHelper.getString("to");

      if (reqId.isNotEmpty) finalStateData['reqId'] = reqId;
      if (empId.isNotEmpty) finalStateData['empId'] = empId;
      if (depId.isNotEmpty) finalStateData['depId'] = depId;
      if (selectStatus.isNotEmpty) finalStateData['selectStatus'] = selectStatus;
      if (from.isNotEmpty) finalStateData['from'] = from;
      if (to.isNotEmpty) finalStateData['to'] = to;
    }

    final allActions = <Widget>[];

    // Add bookmark button only if showBookmark is true
    if (showBookmark) {
      allActions.add(
        BookmarkButton(
          routeName: currentRouteName,
          routePath: currentRoutePath,
          defaultTitle: bookmarkTitle,
          stateData: finalStateData,
          iconColor: bookmarkIconColor,
        ),
      );
    }

    // Add custom actions if any
    if (actions != null) {
      allActions.addAll(actions!);
    }

    final canPop = context.canPop() || Navigator.of(context).canPop();
    final effectiveLeading = leading ??
        (automaticallyImplyLeading && canPop
            ? const AppBackButton()
            : const SizedBox.shrink());

    final effectiveTitleStyle = titleStyle ??
        AppStyles.heading(context).copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(AppColors.secondaryButton),
        );

    return AppBar(
      title: titleWidget ??
          (title != null ? Text(title!, style: effectiveTitleStyle) : null),
      leading: effectiveLeading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: allActions.isEmpty ? null : allActions,
      backgroundColor: backgroundColor ?? Colors.white,
      centerTitle: centerTitle,
      elevation: elevation,
      bottom: bottom,
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      shape: shape,
      flexibleSpace: flexibleSpace,
      systemOverlayStyle: systemOverlayStyle,
      toolbarHeight: bottom != null ? kToolbarHeight : null,
      actionsIconTheme: const IconThemeData(size: 24),
    );
  }

  @override
  Size get preferredSize {
    if (bottom != null) {
      return Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}
