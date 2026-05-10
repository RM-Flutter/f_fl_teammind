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
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/general_listener.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../tasks/views/main_tasks_layout/widgets/task_list_tile_widget.dart';

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
      gCache = json.decode(jsonString)
          as Map<String, dynamic>; // Convert String back to JSON
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

    if (distanceFromTop < scrollThreshold &&
        position.pixels > position.minScrollExtent) {
      // Scroll up
      _autoScrollTimer =
          Timer.periodic(const Duration(milliseconds: 16), (timer) {
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
    } else if (distanceFromBottom < scrollThreshold &&
        position.pixels < position.maxScrollExtent) {
      // Scroll down
      _autoScrollTimer =
          Timer.periodic(const Duration(milliseconds: 16), (timer) {
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
          backgroundColor: Color(AppColors.scaffoldBackGround),
          controller: viewModel.homeScrollController,
          headers: [
            CoreHeader.transform(
              pinned: true,
              color: Colors.transparent,
              shrinkHeight: AppSizes.s140.h,
              expandedHeight: 300.0.h,
              shrinkChild: Consumer<HomeController>(
                  builder: (context, viewModel, child) => HomeAppbarWidget(
                        requests: viewModel.myRequests,
                        notifications: viewModel.notifications,
                        isExpanded: false,
                      )),
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Consumer<HomeController>(
                      builder: (context, viewModel, child) =>
                          viewModel.isLoading
                              ? const HomeAppbarLoading()
                              : HomeAppbarWidget(
                                  requests: viewModel.myRequests,
                                  notifications: viewModel.notifications,
                                ))),
            )
          ],
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    LocalizationService.isArabic(context: context) ? 35.w : 0),
            child: MainAppFabWidget(requests: false, viewRequest: true),
          ),
          children: [
            Consumer<HomeController>(
              builder: (context, viewModel, child) => viewModel.isLoading
                  ? const HomeLoadingPage()
                  : Padding(
                      padding: EdgeInsets.only(top: AppSizes.s12.h),
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
        (viewModel.notifications == null) &&
        (viewModel.myTasks == null)) {
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
    if (viewModel.myTasks != null && viewModel.myTasks?.isNotEmpty == true) {
      widgetsWithData.add(HomeWidgetType.myTasks);
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
        // General Screen Message Widget (always at top, not reorderable)
        // Shortcut actions (Replaces BookmarkList)
        _buildShortcutActions(context),
        SizedBox(height: AppSizes.s4.h),
        // const Center(
        //   child: Text(
        //     "welcome to employee main screeen",
        //     style: TextStyle(color: Colors.grey, fontSize: 12),
        //   ),
        // ),
        SizedBox(height: AppSizes.s4.h),
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
                shadowColor: Color(AppColors.shadow).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSizes.s12.r),
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

  Widget _buildReorderableWidgetItem(HomeWidgetType widgetType, HomeController viewModel, int index) {Widget content;
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
      case HomeWidgetType.myTasks:
        content = _buildTasksSection(context, viewModel.myTasks!);
        break;
    }

    return Container(
      key: ValueKey(widgetType.id),
      margin: EdgeInsets.only(
        bottom: AppSizes.s12.h,
        top: AppSizes.s8.h,
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            content,
            // Drag handle - only this can be used to drag
            Positioned(
              top: 8.h,
              right: 8.w,
              child: ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Color(AppColors.background).withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(AppColors.shadow).withValues(alpha: 0.15),
                        blurRadius: 6.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.drag_handle,
                    color: Color(AppColors.titleText),
                    size: 24.r,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget  _buildShortcutActions(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': AppStrings.addRequestsShortcut.tr(),
        'icon': 'assets/images/add-request.png',
        'onTap': () => context.pushNamed(AppRoutes.addRequest.name,
                pathParameters: {
                  'type': 'mine',
                  'lang': context.locale.languageCode
                })
      },
      {
        'title': AppStrings.viewTasksShortcut.tr(),
        'icon': 'assets/images/view-tasks.png',
        'onTap': () => context.pushNamed(AppRoutes.taskScreen.name,
            pathParameters: {'lang': context.locale.languageCode})
      },
      {
        'title': AppStrings.myTeamRequestsShortcut.tr(),
        'icon': 'assets/images/my-team-request.png',
        'onTap': () => context.pushNamed(AppRoutes.requests2.name,
            pathParameters: {
              'type': GetRequestsTypes.myTeam.name,
              'lang': context.locale.languageCode
            })
      },
      {
        'title': AppStrings.viewPayrollShortcut.tr(),
        'icon': 'assets/images/view-payroll.png',
        'onTap': () => context.pushNamed(AppRoutes.payrollsList.name,
            extra: {'employeeName': null, 'employeeId': null},
            pathParameters: {'lang': context.locale.languageCode})
      },
      {
        'title': AppStrings.viewArticlesShortcut.tr(),
        'icon': 'assets/images/view-articles.png',
        'onTap': () => context.pushNamed(AppRoutes.defaultPage.name,
            pathParameters: {
              'lang': context.locale.languageCode,
              'type': 'blogs'
            })
      },
    ];

    return SizedBox(
      height: 120.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: items[index]['onTap'],
            child: Container(
              width: 105.w,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                // color: Color(AppColors.cardBackground),
                color: const Color(0xFF090B60), // Dark Blue from Figma
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    items[index]['icon'],
                    height: 28.r,
                    width: 28.r,
                    // color: Color(AppColors.icon,),
                    color: Colors.white,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    items[index]['title'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: AppStyles.titleTextContent(context).copyWith(
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                        color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, List tasks) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.myTasksHeader.tr(),
                style: AppStyles.heading(context).copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.pushNamed(AppRoutes.taskScreen.name,
                    pathParameters: {'lang': context.locale.languageCode}),
                child: Text(
                  AppStrings.viewAll.tr(),
                  style: AppStyles.titleTextContent(context).copyWith(
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...tasks.take(3).map((task) {
            // Mapping the dynamic task from home API to the TaskListTileWidget
            // If the model is different, we adjust the fields
            return TaskListTileWidget(
              id: task['id']?.toString() ?? '',
              title: task['title']?.toString() ?? 'No Title',
              date: task['due_date']?.toString() ?? '',
              createdAt: task['created_at']?.toString() ?? '',
              complete: task['status']?.toString() ?? '',
              assetName: "assets/images/svg/tasks_icon.svg",
              // Default task icon
              onTap: () => context.pushNamed(AppRoutes.taskDetails.name,
                  pathParameters: {
                    'id': task['id'].toString(),
                    'lang': context.locale.languageCode
                  }),
            );
          }),
        ],
      ),
    );
  }
}
