import 'dart:async';
import 'package:app_test/core/services/bookmark_service.dart';
import 'dart:convert';
import 'package:app_test/core/helpers/package_helper.dart';
import 'package:app_test/core/widgets/fade_slide_in.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/general_listener.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../tasks/views/main_tasks_layout/widgets/task_list_tile_widget.dart';
import '../../tracking/views/widgets/tracking_home_preview_banner.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';

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
  bool _isEditMode = false;
  List<String> _hiddenWidgets = [];

  static const String _widgetOrderCacheKey = "home_widget_order";
  static const String _hiddenWidgetsCacheKey = "home_hidden_widgets";

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<HomeController>(context, listen: false);
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

    final hiddenJson = CacheHelper.getString(_hiddenWidgetsCacheKey);
    if (hiddenJson.isNotEmpty) {
      try {
        final List<dynamic> hiddenList = jsonDecode(hiddenJson);
        _hiddenWidgets = hiddenList.map((e) => e.toString()).toList();
      } catch (e) {
        debugPrint('Error loading hidden widgets: $e');
      }
    }
  }

  Future<void> _saveHiddenWidgets() async {
    try {
      final hiddenJson = jsonEncode(_hiddenWidgets);
      await CacheHelper.setString(key: _hiddenWidgetsCacheKey, value: hiddenJson);
    } catch (e) {
      debugPrint('Error saving hidden widgets: $e');
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
              shrinkHeight: AppSizes.s140,
              expandedHeight: 300.0,
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
          floatingActionButton: Consumer<HomeController>(
            builder: (context, viewModel, child) => Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      LocalizationService.isArabic(context: context) ? 35 : 0),
              child: MainAppFabWidget(requests: false, viewRequest: true),
            ),
          ),
          children: [
            Consumer<HomeController>(
              builder: (context, viewModel, child) => viewModel.isLoading
                  ? const HomeLoadingPage()
                  : Padding(
                      // No extra bottom room: the FAB hides on scroll and the last
                      // section already ends with its AppSpacing.section margin.
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: _buildReorderableWidgets(viewModel),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableWidgets(HomeController viewModel) {
    // Build list of available widgets based on data
    _availableWidgets = <HomeWidgetType>[];
    final widgetsWithData = <HomeWidgetType>[];

    var jsonString = CacheHelper.getString("US1");
    if (jsonString.isNotEmpty) {
      try {
        var gCache = json.decode(jsonString) as Map<String, dynamic>;
        UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
      } catch (e) {
        debugPrint('Error decoding US1: $e');
      }
    }

    bool isManager = UserSettingConst.userSettings?.isManagerIn?.isNotEmpty == true;
    bool isTeamLeader = UserSettingConst.userSettings?.isTeamleaderIn?.isNotEmpty == true;
    bool isHR = UserSettingConst.userSettings?.isHr == true;
    bool topManagement = UserSettingConst.userSettings?.topManagement == true;
    bool canSeeTeamRequests = isManager || isHR || topManagement || isTeamLeader;

    // First, collect all widgets that have data
    if (PackageHelper.hasPackage('emp-requests')) {
      if (viewModel.myRequests != null &&
          viewModel.myRequests?.isNotEmpty == true) {
        widgetsWithData.add(HomeWidgetType.myRequests);
      }
      if (canSeeTeamRequests && viewModel.myTeamRequests != null &&
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
    }
    if (viewModel.notifications != null &&
        viewModel.notifications?.isNotEmpty == true) {
      widgetsWithData.add(HomeWidgetType.notifications);
    }
    if (viewModel.myTasks != null && viewModel.myTasks?.isNotEmpty == true) {
      widgetsWithData.add(HomeWidgetType.myTasks);
    }
    // Bookmarks only appear once the user has some (otherwise the section would be empty)
    if (BookmarkService.getAllBookmarks().isNotEmpty) {
      widgetsWithData.add(HomeWidgetType.bookmarks);
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

    // Hidden sections stay in the list: outside edit mode they show as a slim row with a green
    // plus to bring them back.

    return Column(
      children: [
        // Tracking Preview Banner (Quick access for design review)
        // const TrackingHomePreviewBanner(),

        // Customize Button Row
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, 0, AppSpacing.page, AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isEditMode = !_isEditMode;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isEditMode ? Colors.red.withValues(alpha: 0.1) : Color(AppColors.secondaryButton).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isEditMode ? Icons.close : Icons.tune,
                        size: 16,
                        color: _isEditMode ? Colors.red : Color(AppColors.secondaryButton),
                      ),
                      gapW4,
                      Text(
                        _isEditMode 
                          ? ('done'.tr())
                          : ('customize'.tr()),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isEditMode ? Colors.red : Color(AppColors.secondaryButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_availableWidgets.isEmpty && !_isEditMode && PackageHelper.hasPackage('emp-requests'))
          NoExistingPlaceholderScreen(
              height: LayoutService.getHeight(context) * 0.4,
              title: AppStrings.thereIsNoRequestsAndNotifications.tr())
        else
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
            child: Center(
              child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: _onReorder,
              padding: EdgeInsets.zero,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                _isDragging = true;
                return Material(
                  elevation: AppElevation.overlay,
                  shadowColor: Color(AppColors.shadow).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: child,
                );
              },
              children: List.generate(_availableWidgets.length, (index) {
                final widgetType = _availableWidgets[index];
                return _buildReorderableWidgetItem(widgetType, viewModel, index);
              }),
            ),
            ),
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
          onActionTaken: () => viewModel.getHome(context),
        );
        break;
      case HomeWidgetType.myTeamRequests:
        content = RequestsWidget(
          requests: viewModel.myTeamRequests!,
          requestType: GetRequestsTypes.myTeam,
          onActionTaken: () => viewModel.getHome(context),
        );
        break;
      case HomeWidgetType.otherDepartmentRequests:
        content = RequestsWidget(
          requests: viewModel.otherDepartmentRequests!,
          requestType: GetRequestsTypes.otherDepartment,
          onActionTaken: () => viewModel.getHome(context),
        );
        break;
      case HomeWidgetType.allCompanyRequests:
        content = RequestsWidget(
          requests: viewModel.allCompanyRequests!,
          requestType: GetRequestsTypes.allCompany,
          onActionTaken: () => viewModel.getHome(context),
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
      case HomeWidgetType.bookmarks:
        content = const BookmarkListWidget();
        break;
    }

    final isHidden = _hiddenWidgets.contains(widgetType.id);

    if (isHidden && !_isEditMode) {
      return Container(
        key: ValueKey(widgetType.id),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.page, vertical: AppSpacing.xs),
        child: Row(
          children: [
            _editCircleButton(widgetType, isHidden: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _sectionTitle(widgetType),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: ValueKey(widgetType.id),
      // One rule for the space between home sections (rule 3).
      margin: const EdgeInsets.only(bottom: AppSpacing.section),
      child: FadeSlideIn(
        delay: Duration(milliseconds: 90 * index),
        offsetY: 0.02,
        beginScale: 1,
        child: Material(
          color: Colors.transparent,
          child: _wrapEditFrame(
            widgetType: widgetType,
            index: index,
            isHidden: isHidden,
            child: Stack(
              children: [
                Opacity(
                  opacity: isHidden ? 0.5 : 1.0,
                  child: content,
                ),
                // Disable tapping inside the section while customizing
                if (_isEditMode)
                  Positioned.fill(
                    child: Container(color: Colors.transparent),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _sectionTitle(HomeWidgetType type) {
    switch (type) {
      case HomeWidgetType.myRequests:
        return AppStrings.mineRequests.tr();
      case HomeWidgetType.myTeamRequests:
        return AppStrings.teamRequests.tr();
      case HomeWidgetType.otherDepartmentRequests:
        return AppStrings.otherDepartmentRequests.tr();
      case HomeWidgetType.allCompanyRequests:
        return AppStrings.allCompanyRequests.tr();
      case HomeWidgetType.myTasks:
        return AppStrings.tasks.tr();
      case HomeWidgetType.notifications:
        return AppStrings.myNotifications.tr();
      case HomeWidgetType.bookmarks:
        return AppStrings.myBookmarks.tr();
    }
  }

  /// Small round hide (red minus) / show (green plus) button.
  Widget _editCircleButton(HomeWidgetType widgetType, {required bool isHidden}) {
    final color = isHidden ? Colors.green : Colors.red;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        setState(() {
          if (isHidden) {
            _hiddenWidgets.remove(widgetType.id);
          } else {
            _hiddenWidgets.add(widgetType.id);
          }
          _saveHiddenWidgets();
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isHidden ? Icons.add_rounded : Icons.remove_rounded,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  /// Controls shown above a section while customizing: no background, just the round button on
  /// the start and the drag icon on the end. Same widget structure in both modes (keyed children)
  /// so toggling edit mode doesn't remount the section and replay its animations.
  Widget _wrapEditFrame({
    required HomeWidgetType widgetType,
    required int index,
    required bool isHidden,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isEditMode)
          KeyedSubtree(
            key: const ValueKey('edit-controls'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page, vertical: AppSpacing.xs / 2),
              child: Row(
                children: [
                  _editCircleButton(widgetType, isHidden: isHidden),
                  // The whole remaining row is the drag area
                  Expanded(
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        height: 36,
                        color: Colors.transparent,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          color: isHidden
                              ? Colors.grey.shade400
                              : Color(AppColors.secondaryButton),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        KeyedSubtree(key: const ValueKey('section-content'), child: child),
      ],
    );
  }

  Widget  _buildShortcutActions(BuildContext context) {
    var jsonString = CacheHelper.getString("US1");
    if (jsonString.isNotEmpty) {
      try {
        var gCache = json.decode(jsonString) as Map<String, dynamic>;
        UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
      } catch (e) {
        debugPrint('Error decoding US1: $e');
      }
    }

    bool isManager = UserSettingConst.userSettings?.isManagerIn?.isNotEmpty == true;
    bool isTeamLeader = UserSettingConst.userSettings?.isTeamleaderIn?.isNotEmpty == true;
    bool isHR = UserSettingConst.userSettings?.isHr == true;
    bool topManagement = UserSettingConst.userSettings?.topManagement == true;
    bool canSeeTeamRequests = isManager || isHR || topManagement || isTeamLeader;

    final List<Map<String, dynamic>> items = [
      if (PackageHelper.hasPackage('emp-requests'))
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
      if (canSeeTeamRequests && PackageHelper.hasPackage('emp-requests'))
        {
          'title': AppStrings.myTeamRequestsShortcut.tr(),
          'icon': 'assets/images/my-team-request.png',
          'onTap': () => context.pushNamed(AppRoutes.requests2.name,
              pathParameters: {
                'type': GetRequestsTypes.myTeam.name,
                'lang': context.locale.languageCode
              })
        },
      if (PackageHelper.hasPackage('emp-payroll'))
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
      height: 120,
      child: ListView.separated(
        padding: AppSpacing.pagePadding,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: items[index]['onTap'],
            child: Container(
              width: 105,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                // color: Color(AppColors.cardBackground),
                color: Color(AppColors.secondaryButton), // Dark Blue from Figma
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    items[index]['icon'],
                    height: 28,
                    width: 28,
                    // color: Color(AppColors.icon,),
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    items[index]['title'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: AppStyles.titleTextContent(context).copyWith(
                      fontSize: 12.0,
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
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: AppStrings.myTasksHeader.tr(),
            onViewAll: () => context.pushNamed(AppRoutes.taskScreen.name,
                pathParameters: {'lang': context.locale.languageCode}),
          ),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
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
