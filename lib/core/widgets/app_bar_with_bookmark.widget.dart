import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/backend_services/api_service/dio_api_service/shared.dart';
import 'bookmark_widgets/bookmark_button.widget.dart';

/// Helper widget to create an AppBar with bookmark button automatically added
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

  const AppBarWithBookmark({
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
  }) : assert(title != null || titleWidget != null, 'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final currentRouteName = routeName ?? routerState.name ?? '';
    final currentRoutePath = routerState.uri.toString();
    final bookmarkTitle = defaultTitle ?? title ?? '';

    // Collect filter state for requests screen
    Map<String, dynamic>? finalStateData = stateData;
    if (currentRouteName.contains('requests') || currentRoutePath.contains('requests')) {
      finalStateData ??= {};
      // Collect filter data from CacheHelper
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
    
    // Add bookmark button
    allActions.add(
      BookmarkButton(
        routeName: currentRouteName,
        routePath: currentRoutePath,
        defaultTitle: bookmarkTitle,
        stateData: finalStateData,
        iconColor: bookmarkIconColor,
      ),
    );
    
    // Add custom actions if any
    if (actions != null) {
      allActions.addAll(actions!);
    }

    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!, style: titleStyle) : null),
      leading: leading,
      actions: allActions.isEmpty ? null : allActions,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      elevation: elevation,
      bottom: bottom,
      surfaceTintColor: surfaceTintColor,
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

