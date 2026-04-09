import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/features/more/notifications/controllers/notification_controller.dart';
import 'package:app_test/features/more/notifications/views/widgets/notifications_list/notification_list_view_item.dart';
import 'package:app_test/features/more/notifications/views/widgets/switch_row_notification.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/gradient_bg_image.dart';

class NotificationScreen extends StatefulWidget {
  final bool viewArrow;
  const NotificationScreen(this.viewArrow, {super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  late NotificationProviderModel notificationProvider;
  bool value = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("CacheHelper.getBool --> ${CacheHelper.getBool("value")}");
      notificationProvider = Provider.of<NotificationProviderModel>(context, listen: false);
      if(CacheHelper.getBool("value") != null){
        if(CacheHelper.getBool("value") == false){
          notificationProvider.getNotification(context, page: 1, forWho: "all");
        }else{
          notificationProvider.getNotification(context, page: 1, forWho: "department");
        }
      }else{
        notificationProvider.getNotification(context, page: 1, forWho: "all");
      }
    });
    _scrollController.addListener(() {
      debugPrint("Current scroll position: ${_scrollController.position.pixels}");
      debugPrint("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !notificationProvider.isGetNotificationLoading &&
          notificationProvider.hasMoreNotifications) {
        debugPrint("BOTTOM BOTTOM");
        if(CacheHelper.getBool("value") != null){
          if(CacheHelper.getBool("value") == false){
            notificationProvider.getNotification(context, page: notificationProvider.currentPage, forWho: "all");
          }else{
            notificationProvider.getNotification(context, page: notificationProvider.currentPage, forWho: "department");
          }
        }else{
          notificationProvider.getNotification(context, page: notificationProvider.currentPage, forWho: "department");
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProviderModel>(
      builder: (context, notificationProviderModel, child) {
        var jsonString;
        var gCache;
        jsonString = CacheHelper.getString("US1");
        if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
          gCache = json.decode(jsonString)
          as Map<String, dynamic>; // Convert String back to JSON
          UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
        }
        return Scaffold(
          backgroundColor: Color(AppColors.background),
          appBar: AppBarWithBookmark(
            surfaceTintColor: Colors.transparent,
            title: AppStrings.notifications.tr(),
            titleStyle: AppStyles.darkHeading(context).copyWith(
              fontSize: 15.sp, 
              fontWeight: FontWeight.w400
            ),
            backgroundColor: Colors.transparent,
            routeName: AppRoutes.notifications.name,
          ),
          floatingActionButton: (gCache['is_teamleader_in'].isNotEmpty ||
              gCache['is_manager_in'].isNotEmpty)?Container(
            padding: EdgeInsets.symmetric(
                horizontal: LocalizationService.isArabic(context: context)
                    ? 35.w
                    : 0),
            width: double.infinity,
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: 'notification_screen_add',
              onPressed: () async => await context.pushNamed(
                  AppRoutes.addNotification.name,
                  pathParameters: {
                    'lang': context.locale.languageCode
                  }), // Icon inside FAB
              backgroundColor: Color(AppColors.buttons), // Optional: change color
              tooltip: 'Add',
              child: Center(
                child: Image.asset(
                  AppImages.addFloatingActionButtonIcon,
                  color: AppThemeService.colorPalette.fabIconColor.color,
                  width: AppSizes.s16.r,
                  height: AppSizes.s16.r,
                ),
              ),
            ),
          ) : const SizedBox.shrink(),
          body: RefreshIndicator.adaptive(
            onRefresh: ()async{
              setState(() {
                CacheHelper.setBool("value", false);
              });
              await notificationProviderModel.getNotification(context, page: 1, forWho: "all");
            },
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: kIsWeb ? 1100.w : double.infinity
                ),
                child: ListView(
                  controller: _scrollController,
                  children: [
                    if((gCache != null && gCache['role'] is List && gCache['role'].isNotEmpty && gCache['role'].contains("personal"))) SizedBox(height: 5.h)
                    else  SwitchRowNotification(
                      isLoginPageStyle: false,
                      value: CacheHelper.getBool("value") ??value!,
                      onChanged: (newValue){
                        setState(() {
                          value = newValue;
                          CacheHelper.setBool("value", newValue);
                        });
                        notificationProviderModel.getNotification(context,
                            page: 1, forWho: (newValue == false)? "all" : "department"
                        );
                      },
                    ),
                    SizedBox(height: 25.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        reverse: false,
                        physics: const ClampingScrollPhysics(),
                        itemCount: notificationProviderModel.isGetNotificationLoading && notificationProviderModel.notifications.isEmpty
                            ? 12 // Show 5 loading items initially
                            : notificationProviderModel.notifications.length,
                        itemBuilder: (context, index) {
                          if (notificationProviderModel.isGetNotificationLoading && notificationProviderModel.currentPage == 1) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: AppSizes.s12.h),
                                padding: EdgeInsetsDirectional.symmetric(horizontal: AppSizes.s15.w, vertical: AppSizes.s12.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppSizes.s15.r),
                                ),
                                height: 100.h,
                              ),
                            );
                          } else {
                            return PainterNotificationListViewItem(
                              notifications: notificationProviderModel.notifications,
                              index: index,
                            );
                          }
                        },
                      ),
                    ),
                    if(!notificationProviderModel.isGetNotificationLoading && notificationProviderModel.notifications.isEmpty) Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child:  NoExistingPlaceholderScreen(
                          height: LayoutService.getHeight(context) *
                              0.6,
                          title: AppStrings.thereIsNoNotifications.tr()),
                    ),
                    SizedBox(height: 20.h),
                    if (notificationProviderModel.hasMoreNotifications && !notificationProviderModel.isGetNotificationLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 30.h),
                          child: ElevatedButton(
                            onPressed: () {
                              if(CacheHelper.getBool("value") != null){
                                if(CacheHelper.getBool("value") == false){
                                  notificationProviderModel.getNotification(context, page: notificationProviderModel.currentPage, forWho: "all");
                                }else{
                                  notificationProviderModel.getNotification(context, page: notificationProviderModel.currentPage, forWho: "department");
                                }
                              }else{
                                notificationProviderModel.getNotification(context, page: notificationProviderModel.currentPage, forWho: "department");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF000033), // Dark navy blue as in design
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: Text(
                              AppStrings.loadMore.tr().toUpperCase(),
                              style: AppStyles.whiteContent(context).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (notificationProviderModel.isGetNotificationLoading && notificationProviderModel.currentPage != 1)
                      Padding(
                        padding: EdgeInsets.only(bottom: 30.h),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
