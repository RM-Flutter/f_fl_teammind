import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_images.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/app_theme.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/layout.service.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/modules/more/views/notification/logic/notification_provider.dart';
import 'package:rmemp/modules/more/views/notification/view/notification_list_view_item.dart';
import 'package:rmemp/modules/more/views/notification/view/widget/switch_row_notification.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:rmemp/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:shimmer/shimmer.dart';

class NotificationScreen extends StatefulWidget {
  final bool viewArrow;
  NotificationScreen(this.viewArrow);

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
      print("CacheHelper.getBool --> ${CacheHelper.getBool("value")}");
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
      print("Current scroll position: ${_scrollController.position.pixels}");
      print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !notificationProvider.isGetNotificationLoading &&
          notificationProvider.hasMoreNotifications) {
        print("BOTTOM BOTTOM");
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
        return SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xffFFFFFF),
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              title:  Text(AppStrings.notifications.tr().toUpperCase(), style: const TextStyle(fontSize: 16,
                  color: Color(AppColors.dark), fontWeight: FontWeight.w700),),
              backgroundColor: Colors.transparent,
            ),
            floatingActionButton: (gCache['is_teamleader_in'].isNotEmpty ||
                gCache['is_manager_in'].isNotEmpty)?Container(
              padding: EdgeInsets.symmetric(
                  horizontal: LocalizationService.isArabic(context: context)
                      ? 35
                      : 0),
              width: double.infinity,
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () async => await context.pushNamed(
                    AppRoutes.addNotification.name,
                    pathParameters: {
                      'lang': context.locale.languageCode
                    }), // Icon inside FAB
                backgroundColor: const Color(
                    AppColors.primary), // Optional: change color
                tooltip: 'Add',
                child: Center(
                  child: Image.asset(
                    AppImages.addFloatingActionButtonIcon,
                    color: AppThemeService.colorPalette.fabIconColor.color,
                    width: AppSizes.s16,
                    height: AppSizes.s16,
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
                // if(CacheHelper.getBool("value") != null){
                //   if(CacheHelper.getBool("value") == false){
                //     await notificationProviderModel.getNotification(context, page: 1, forWho: "all");
                //   }else{
                //     await notificationProviderModel.getNotification(context, page: 1, forWho: "department");
                //   }
                // }else{
                //   await notificationProviderModel.getNotification(context, page: 1, forWho: "department");
                // }
              },
              child: ListView(
                controller: _scrollController,
                children: [
                  SwitchRowNotification(
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
                  const SizedBox(height: 25,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                              margin: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSizes.s15, vertical: AppSizes.s12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppSizes.s15),
                              ),
                              height: 100,
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
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child:  NoExistingPlaceholderScreen(
                        height: LayoutService.getHeight(context) *
                            0.6,
                        title: AppStrings.thereIsNoNotifications.tr()),
                  ),
                  if (notificationProviderModel.isGetNotificationLoading && notificationProviderModel.currentPage != 1)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
