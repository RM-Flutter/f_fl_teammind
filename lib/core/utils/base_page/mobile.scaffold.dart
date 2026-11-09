import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'mobile_header.dart';
import '../../widgets/hide_on_scroll_fab.widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart' as animation;

class CoreMobileScaffold extends StatelessWidget {
  final List<CoreHeader>? headers;
  final List<Widget>? children;
  final Widget? body;
  final bool bodyWithoutScroll;

  final TabBarView? tabBarViewBody;
  final Widget Function(BuildContext, int)? childrenBuilder;
  final int? childrenCount;
  final SliverAppBar? sliverAppBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final ScrollController controller;
  final Duration? animationDuration;
  final PreferredSizeWidget? appBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final AlignmentDirectional? persistentFooterAlignment;
  final void Function(bool)? onDrawerChanged;
  final Widget? endDrawer;
  final void Function(bool)? onEndDrawerChanged;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;

  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final bool drawerEnableOpenDragGesture;
  final double? drawerEdgeDragWidth;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  final EdgeInsets? padding;

  /// Hide [floatingActionButton] smoothly while scrolling down (layout rule 6).
  final bool hideFabOnScroll;

  const CoreMobileScaffold({
    super.key,
    this.padding,
    this.headers,
    this.children,
    this.body,
    this.tabBarViewBody,
    this.childrenBuilder,
    this.childrenCount,
    this.bodyWithoutScroll = false,
    this.sliverAppBar,
    this.animationDuration,
    required this.controller,
    this.floatingActionButton,
    this.appBar,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.persistentFooterAlignment,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEnableOpenDragGesture = true,
    this.drawerEdgeDragWidth,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.hideFabOnScroll = true,
  }) : assert(
            body != null ||
                children != null ||
                childrenBuilder != null ||
                tabBarViewBody != null,
            "body or childrenBuilder or children or tabBarViewBody cannot be null");

  @override
  Widget build(BuildContext context) {
    return HideOnScrollFabHost(
      enabled: hideFabOnScroll,
      builder: (context, wrapFab) => Scaffold(
      floatingActionButton: wrapFab(floatingActionButton),
      backgroundColor: backgroundColor,
      key: key,
      appBar: appBar,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterAlignment:
          persistentFooterAlignment ?? AlignmentDirectional.centerEnd,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
      body: Padding(
          padding: padding ?? const EdgeInsets.all(0.0),
          child: body != null && bodyWithoutScroll
              ? AppContentWidth(child: body!)
              : getChild()),
      ),
    );
  }

  Widget getChild() {
    Widget buildChildItem(BuildContext ctx, int i) {
      final raw = (childrenBuilder ??
              (children != null
                  ? ((_, idx) => children![idx])
                  : (_, idx) => const SizedBox()))
          .call(ctx, i);
      return AppContentWidth(child: raw);
    }

    if (tabBarViewBody != null) {
      return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            if (sliverAppBar != null) sliverAppBar!,
            // SliverOverlapAbsorber(
            //   handle:
            //       NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            //   sliver:,
            // ),
            if (headers != null)
              ...headers!.map(
                (e) => SliverPersistentHeader(
                  pinned: e.pinned ?? false,
                  floating: e.floating ?? false,
                  delegate: e.delegate,
                ),
              ),
          ];
        },
        body: AppContentWidth(child: tabBarViewBody ?? Container()),
      );
    } else {
      return CustomScrollView(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          if (sliverAppBar != null) sliverAppBar!,
          if (headers != null)
            ...headers!.map((e) => SliverPersistentHeader(
                  pinned: e.pinned ?? false,
                  floating: e.floating ?? false,
                  delegate: e.delegate,
                )),
          body ??
              (animationDuration == null
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                      buildChildItem,
                      childCount: childrenCount ?? children?.length ?? 0,
                    ))
                  : animation.LiveSliverList(
                      controller: controller,
                      showItemInterval: Duration(
                          milliseconds:
                              (animationDuration!.inMilliseconds * 0.1)
                                  .toInt()),
                      showItemDuration: animationDuration!,
                      itemCount: childrenCount ?? children?.length ?? 0,
                      itemBuilder: (context, index, animation) {
                        return FadeTransition(
                            opacity: Tween<double>(
                              begin: 0,
                              end: 1,
                            ).animate(animation),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-1.1, 1.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: buildChildItem(context, index),
                            ));
                      },
                    )),
        ],
      );
    }
  }
}
