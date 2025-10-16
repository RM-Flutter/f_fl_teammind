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
import 'package:rmemp/modules/more/views/blog/controller/blog_controller.dart';
import 'package:rmemp/modules/more/views/blog/controller/blog_controller.dart';
import 'package:rmemp/modules/more/views/blog/controller/blog_controller.dart';
import 'package:rmemp/modules/more/views/notification/logic/notification_provider.dart';
import 'package:rmemp/modules/more/views/notification/view/notification_list_view_item.dart';
import 'package:rmemp/modules/more/views/notification/view/widget/switch_row_notification.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:rmemp/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/general_listener.dart';
import '../more/views/blog/widget/blog_list_view_item.dart';

class DefaultPage extends StatefulWidget {
  var type;
  DefaultPage(this.type,);

  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  final ScrollController _scrollController = ScrollController();
  final generalListener = GeneralListener(); // instance
  late BlogProviderModel provider;
  bool value = false;
  @override
  void initState() {
    super.initState();
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
    }
    final popups = gCache?['popups'];
    if (popups != null && popups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        generalListener.startAll(context, widget.type == "blogs" ?"blog" : "notification", popups);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<BlogProviderModel>(context, listen: false);
      if(CacheHelper.getBool("value") != null){
        if(CacheHelper.getBool("value") == false){
          provider.getBlog(context,"${widget.type}", page: 1,);
        }else{
          provider.getBlog(context,"${widget.type}", page: 1,);
        }
      }else{
        provider.getBlog(context,"${widget.type}", page: 1,);
      }
    });
    _scrollController.addListener(() {
      print("Current scroll position: ${_scrollController.position.pixels}");
      print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !provider.isGetBlogLoading &&
          provider.hasMoreBlogs) {
        print("BOTTOM BOTTOM");
        if(CacheHelper.getBool("value") != null){
          if(CacheHelper.getBool("value") == false){
            provider.getBlog(context,widget.type, page: provider.currentPage);
          }else{
            provider.getBlog(context,widget.type, page: provider.currentPage);
          }
        }else{
          provider.getBlog(context,widget.type, page: provider.currentPage);
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlogProviderModel>(
      builder: (context, provider, child) {
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
              title:  Text(widget.type == "rmnotifications" ? AppStrings.notifications.tr().toUpperCase():widget.type.toString().tr().toUpperCase(), style: const TextStyle(fontSize: 16,
                  color: Color(AppColors.dark), fontWeight: FontWeight.w700),),
              backgroundColor: Colors.transparent,
            ),
            floatingActionButton: widget.type == "rmnotifications"? Container(
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
            )
                :SizedBox.shrink(),
            body: RefreshIndicator.adaptive(
              onRefresh: ()async{
                setState(() {
                  CacheHelper.setBool("value", false);
                });
                await provider.getBlog(context,widget.type, page: 1);
              },
              child: ListView(
                controller: _scrollController,
                children: [
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      reverse: false,
                      physics: const ClampingScrollPhysics(),
                      itemCount: provider.isGetBlogLoading && provider.blogs.isEmpty
                          ? 12 // Show 5 loading items initially
                          : provider.blogs.length,
                      itemBuilder: (context, index) {
                        if (provider.isGetBlogLoading && provider.currentPage == 1) {
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
                          return BlogListViewItem(
                            blog: provider.blogs,
                            index: index,
                            type: widget.type,
                          );
                        }
                      },
                    ),
                  ),
                  if(!provider.isGetBlogLoading && provider.blogs.isEmpty) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child:  NoExistingPlaceholderScreen(
                        height: LayoutService.getHeight(context) *
                            0.6,
                        title: AppStrings.thereIsNoNotifications.tr()),
                  ),
                  if (provider.isGetBlogLoading && provider.currentPage != 1)
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
