import 'dart:convert';

import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/features/more/blog/controllers/blog_controller.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/services/general_listener.dart';
import '../../more/blog/views/blog_list_view_item.dart';

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
            backgroundColor: Color(AppColors.white),
            appBar: AppBarWithBookmark(
              title: widget.type == "rmnotifications" ? AppStrings.notifications.tr().toUpperCase():widget.type.toString().tr().toUpperCase(),
              titleStyle: TextStyle(fontSize: 16,
                  color: Color(AppColors.dark), fontWeight: FontWeight.w700),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
            floatingActionButton: widget.type == "rmnotifications"? Container(
              padding: EdgeInsets.symmetric(
                  horizontal: LocalizationService.isArabic(context: context)
                      ? 35
                      : 0),
              width: double.infinity,
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: 'default_page_add_notification',
                onPressed: () async => await context.pushNamed(
                    AppRoutes.addNotification.name,
                    pathParameters: {
                      'lang': context.locale.languageCode
                    }), // Icon inside FAB
                backgroundColor: Color(
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