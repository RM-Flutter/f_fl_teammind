import 'dart:async';
import 'dart:convert';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/cache_constants.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/utils/base_page/mobile.scaffold.dart';
import 'package:app_test/core/utils/base_page/mobile_header.dart';
import 'package:app_test/core/utils/general_screen_message_widget.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/main_app_fab_widget/main_app_fab.widget.dart';
import 'package:app_test/features/home/data/models/home_widget_type.dart';
import 'package:app_test/features/home/views/widgets/bookmark_list_widget.dart';
import 'package:app_test/features/home/views/widgets/loading/home_appbar_loading.dart';
import 'package:app_test/features/home/views/widgets/loading/home_body_loading.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/my_requests_widget.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/notifications_section.dart';
import 'package:app_test/features/home/views/widgets/page_header_widgets/home_appbar.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/general_listener.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';

import '../../../core/constants/app_colors.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController viewModel;
  final generalListener = GeneralListener(); // instance
  List<HomeWidgetType> _widgetOrder = [];
  List<HomeWidgetType> _availableWidgets = [];
  Timer? _autoScrollTimer;
  bool _isDragging = false;

  static const String _widgetOrderCacheKey = "home_widget_order";

  @override
  void initState() {
    super.initState();
    viewModel = HomeController();
    viewModel.getHome(context);
    CacheConsts.initUSG();
    String? jsonString;
    Map<String, dynamic>? gCache;
    jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
    }
    final popups = gCache?['popups'];
    if (popups != null && popups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        generalListener.startAll(context, "home", popups);
      });
    }

    // Load widget order from cache
    _loadWidgetOrder();
  }

  void _loadWidgetOrder() {
    final orderJson = CacheHelper.getString(_widgetOrderCacheKey);
    if (orderJson.isNotEmpty) {
      try {
        final List<dynamic> orderList = jsonDecode(orderJson);
        _widgetOrder = orderList
            .map((e) => HomeWidgetType.fromJson(e as String))
            .whereType<HomeWidgetType>()
            .toList();
      } catch (e) {
        debugPrint('Error loading widget order: $e');
        _widgetOrder = HomeWidgetType.getDefaultOrder();
      }
    } else {
      _widgetOrder = HomeWidgetType.getDefaultOrder();
    }
  }

  Future<void> _saveWidgetOrder(List<HomeWidgetType> order) async {
    try {
      final orderJson = jsonEncode(order.map((e) => e.toJson()).toList());
      await CacheHelper.setString(key: _widgetOrderCacheKey, value: orderJson);
    } catch (e) {
      debugPrint('Error saving widget order: $e');
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    _isDragging = false;
    _autoScrollTimer?.cancel();
    setState(() {
      // Reorder the available widgets list
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _availableWidgets.removeAt(oldIndex);
      _availableWidgets.insert(newIndex, item);

      // Update _widgetOrder to match the new order
      // Create a new order list: available widgets first (in new order), then others
      final newOrder = <HomeWidgetType>[];

      // Add reordered available widgets first
      newOrder.addAll(_availableWidgets);

      // Add widgets that are not available (preserve their order)
      for (final widgetType in _widgetOrder) {
        if (!_availableWidgets.contains(widgetType)) {
          newOrder.add(widgetType);
        }
      }

      _widgetOrder = newOrder;
      _saveWidgetOrder(_widgetOrder);
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isDragging || !viewModel.homeScrollController.hasClients) return;

    final scrollController = viewModel.homeScrollController;
    final position = scrollController.position;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get pointer position
    final pointerY = event.position.dy;

    // Calculate distance from top and bottom of screen
    final distanceFromTop = pointerY;
    final distanceFromBottom = screenHeight - pointerY;

    // Auto-scroll threshold (150 pixels from edges)
    const scrollThreshold = 150.0;
    const scrollSpeed = 10.0;

    _autoScrollTimer?.cancel();

    if (distanceFromTop < scrollThreshold && position.pixels > position.minScrollExtent) {
      // Scroll up
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (!scrollController.hasClients || !mounted || !_isDragging) {
          timer.cancel();
          return;
        }

        final newPosition = (scrollController.position.pixels - scrollSpeed)
            .clamp(position.minScrollExtent, position.maxScrollExtent);

        if (newPosition <= position.minScrollExtent) {
          timer.cancel();
          return;
        }

        scrollController.jumpTo(newPosition);
      });
    } else if (distanceFromBottom < scrollThreshold && position.pixels < position.maxScrollExtent) {
      // Scroll down
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (!scrollController.hasClients || !mounted || !_isDragging) {
          timer.cancel();
          return;
        }

        final newPosition = (scrollController.position.pixels + scrollSpeed)
            .clamp(position.minScrollExtent, position.maxScrollExtent);

        if (newPosition >= position.maxScrollExtent) {
          timer.cancel();
          return;
        }

        scrollController.jumpTo(newPosition);
      });
    } else {
      _autoScrollTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>.value(
      value: viewModel,
      child: RefreshIndicator(
        onRefresh: () async {
          try {
            await viewModel.getHome(context);
          } catch (_) {}
          await Future.delayed(const Duration(milliseconds: 200));
        },
        child: CoreMobileScaffold(
          backgroundColor: Color(AppColors.scaffoldBackgroundColor),
          controller: viewModel.homeScrollController,
          headers: [
            CoreHeader.transform(
              // pinned: true,
              color: Color(AppColors.backgroundColor),
              shrinkHeight: AppSizes.s140,
              expandedHeight: AppSizes.s300,
              shrinkChild: Consumer<HomeController>(
                  builder: (context, viewModel, child) => HomeAppbarWidget(
                    requests: viewModel.myRequests,
                    isExpanded: false,
                  )),
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Consumer<HomeController>(
                      builder: (context, viewModel, child) => viewModel.isLoading
                          ? const HomeAppbarLoading()
                          : HomeAppbarWidget(
                        requests: viewModel.myRequests,
                      ))),
            )
          ],
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                LocalizationService.isArabic(context: context) ? 35 : 0),
            child: MainAppFabWidget(
                requests: false,
                viewRequest: true
            ),
          ),
          children: [
            Consumer<HomeController>(
              builder: (context, viewModel, child) => viewModel.isLoading
                  ? const HomeLoadingPage()
                  : Padding(
                padding: const EdgeInsets.only(top: AppSizes.s12),
                child: _buildReorderableWidgets(viewModel),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableWidgets(HomeController viewModel) {
    // Check if all data is null
    if ((viewModel.myRequests == null) &&
        (viewModel.myTeamRequests == null) &&
        (viewModel.otherDepartmentRequests == null) &&
        (viewModel.allCompanyRequests == null) &&
        (viewModel.notifications == null)) {
      return NoExistingPlaceholderScreen(
          height: LayoutService.getHeight(context) * 0.4,
          title: AppStrings.thereIsNoRequestsAndNotifications.tr());
    }

    // Build list of available widgets based on data
    _availableWidgets = <HomeWidgetType>[];
    final widgetsWithData = <HomeWidgetType>[];

    // First, collect all widgets that have data
    if (viewModel.myRequests != null &&
        viewModel.myRequests?.isNotEmpty == true) {
      widgetsWithData.add(HomeWidgetType.myRequests);
    }
    if (viewModel.myTeamRequests != null &&
        viewModel.myTeamRequests?.isNotEmpty == true) {
      widgetsWithData.add(HomeWidgetType.myTeamRequests);
    }
    if (viewModel.otherDepartmentRequests != null &&
        viewModel.otherDepartmentRequests?.isNotEmpty == true) {
      widgetsWithData.add(HomeWidgetType.otherDepartmentRequests);
    }
    if (viewModel.allCompanyRequests != null &&
        viewModel.allCompanyRequests?.isNotEmpty == true) {
      widgetsWithData.add(HomeWidgetType.allCompanyRequests);
    }
    if (viewModel.notifications != null &&
        viewModel.notifications?.isNotEmpty == true) {
      widgetsWithData.add(HomeWidgetType.notifications);
    }

    // Add widgets that have data, following the saved order
    for (final widgetType in _widgetOrder) {
      if (widgetsWithData.contains(widgetType)) {
        _availableWidgets.add(widgetType);
      }
    }

    // Add any widgets with data that weren't in the saved order (new widgets or missing from cache)
    for (final widgetType in widgetsWithData) {
      if (!_availableWidgets.contains(widgetType)) {
        _availableWidgets.add(widgetType);
      }
    }

    if (_availableWidgets.isEmpty) {
      return NoExistingPlaceholderScreen(
          height: LayoutService.getHeight(context) * 0.4,
          title: AppStrings.thereIsNoRequestsAndNotifications.tr());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
          child: GeneralScreenMessageWidget(screenId: '/'),
        ),
        const SizedBox(height: AppSizes.s12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.s16),
          child: BookmarkListWidget(),
        ),
        // Reorderable widgets
        Listener(
          onPointerMove: (event) {
            if (_isDragging) {
              _handlePointerMove(event);
            }
          },
          onPointerUp: (event) {
            _isDragging = false;
            _autoScrollTimer?.cancel();
          },
          onPointerCancel: (event) {
            _isDragging = false;
            _autoScrollTimer?.cancel();
          },
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _onReorder,
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              _isDragging = true;
              return Material(
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSizes.s12),
                child: child,
              );
            },
            children: List.generate(_availableWidgets.length, (index) {
              final widgetType = _availableWidgets[index];
              return _buildReorderableWidgetItem(widgetType, viewModel, index);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildReorderableWidgetItem(
      HomeWidgetType widgetType, HomeController viewModel, int index) {
    Widget content;
    switch (widgetType) {
      case HomeWidgetType.myRequests:
        content = RequestsWidget(
          requests: viewModel.myRequests!,
          requestType: GetRequestsTypes.mine,
        );
        break;
      case HomeWidgetType.myTeamRequests:
        content = RequestsWidget(
          requests: viewModel.myTeamRequests!,
          requestType: GetRequestsTypes.myTeam,
        );
        break;
      case HomeWidgetType.otherDepartmentRequests:
        content = RequestsWidget(
          requests: viewModel.otherDepartmentRequests!,
          requestType: GetRequestsTypes.otherDepartment,
        );
        break;
      case HomeWidgetType.allCompanyRequests:
        content = RequestsWidget(
          requests: viewModel.allCompanyRequests!,
          requestType: GetRequestsTypes.allCompany,
        );
        break;
      case HomeWidgetType.notifications:
        content = NotificationsSection(
          notifications: viewModel.notifications!,
        );
        break;
    }

    final isArabic = LocalizationService.isArabic(context: context);

    return Container(
      key: ValueKey(widgetType.id),
      margin: const EdgeInsets.only(
        bottom: AppSizes.s12,
        top: AppSizes.s8,
      ),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: Color(AppColors.navBarColor),
        shadowColor: Color(AppColors.shadowColor).withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.s12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.s12),
              child: content,
            ),
            Positioned(
              top: 8,
              right: isArabic ? null : 8,
              left: isArabic ? 8 : null,
              child: ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(AppColors.backgroundColor).withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(AppColors.shadowColor).withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.drag_handle,
                    color: Color(AppColors.dark),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
