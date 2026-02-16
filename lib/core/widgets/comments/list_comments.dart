
import 'dart:convert';

import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/comments/logic/controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../full_image_screen.dart';
import 'comments_audio_widget.dart';

class ListCommentsScreen extends StatefulWidget {
  var id;
  var slug;
  ListCommentsScreen({
    this.id,
    this.slug,
  });

  @override
  _ListCommentsScreenState createState() => _ListCommentsScreenState();
}

class _ListCommentsScreenState extends State<ListCommentsScreen> {
  final ScrollController _scrollController = ScrollController();
  late CommentProvider notificationProvider;
  bool value = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationProvider = Provider.of<CommentProvider>(context, listen: false);
      notificationProvider.getComment(context,widget.slug,widget.id, pages: 1, );
    });
    _scrollController.addListener(() {
      print("Current scroll position: ${_scrollController.position.pixels}");
      print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !notificationProvider.isGetCommentLoading &&
          notificationProvider.hasMore) {
        print("BOTTOM BOTTOM");
        notificationProvider.getComment(context,widget.slug,widget.id, pages: notificationProvider.pageNumber,);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentProvider>(
      builder: (context, value, child) {
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
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              title:  Text(AppStrings.comments.tr().toUpperCase(), style: TextStyle(fontSize: 16,
                  color: Color(AppColors.dark), fontWeight: FontWeight.w700),),
              backgroundColor: Colors.transparent,
            ),
            // floatingActionButton: (gCache['is_teamleader_in'].isNotEmpty ||
            //     gCache['is_manager_in'].isNotEmpty)?Container(
            //   padding: EdgeInsets.symmetric(
            //       horizontal: LocalizationService.isArabic(context: context)
            //           ? 35
            //           : 0),
            //   width: double.infinity,
            //   alignment: Alignment.bottomRight,
            //   child: FloatingActionButton(
            //     onPressed: () async => await context.pushNamed(
            //         AppRoutes.addNotification.name,
            //         pathParameters: {
            //           'lang': context.locale.languageCode
            //         }), // Icon inside FAB
            //     backgroundColor: const Color(
            //         AppColors.primary), // Optional: change color
            //     tooltip: 'Add',
            //     child: Center(
            //       child: Image.asset(
            //         AppImages.addFloatingActionButtonIcon,
            //         color: AppThemeService.colorPalette.fabIconColor.color,
            //         width: AppSizes.s16,
            //         height: AppSizes.s16,
            //       ),
            //     ),
            //   ),
            // ) : const SizedBox.shrink(),
            body: RefreshIndicator.adaptive(
              onRefresh: ()async{
                await value.getComment(context,widget.slug,widget.id, pages: 1, );
              },
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: kIsWeb ? 1100 : double.infinity
                  ),
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      const SizedBox(height: 15,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          reverse: false,
                          physics: const ClampingScrollPhysics(),
                          itemCount: value.isGetCommentLoading && value.comments.isEmpty
                              ? 12 // Show 5 loading items initially
                              : value.comments.length,
                          itemBuilder: (context, index) {
                            if (value.isGetCommentLoading == true && value.pageNumber == 1) {
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
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(AppColors.black),
                                      blurRadius: 10,
                                      offset: Offset(0, 1),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(63),
                                      child:  CachedNetworkImage(
                                        width: 63,
                                        height: 63,
                                        fit: BoxFit.cover,
                                        imageUrl: value.comments[index]['user']['avatar'] ?? "",
                                        placeholder: (context, url) =>
                                        const ShimmerAnimatedLoading(),
                                        errorWidget: (context, url, error) => const Icon(
                                          Icons.image_not_supported_outlined,
                                          size: AppSizes.s32,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.sizeOf(context).width * 0.4,
                                            child: Text(
                                                value.comments[index]['user']['name'] ?? "", maxLines: 1,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700, fontSize: 12,color: Color(AppColors.dark)
                                                )
                                            ),
                                          ),
                                          const SizedBox(height: 5,),SizedBox(
                                            width: MediaQuery.sizeOf(context).width * 0.4,
                                            child: Text(
                                                "${DateFormat("dd/MM/yyyy hh:mm a", context.locale.languageCode).format(DateTime.parse("${value.comments[index]['created_at']}"))}", maxLines: 1,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500, fontSize: 12,color: Color(AppColors.darkGrey)
                                                )
                                            ),
                                          ),
                                          const SizedBox(height: 5,),
                                          if(value.comments[index]['content'] != null)Text(
                                            value.comments[index]['content'] ?? "",
                                            style: const TextStyle(color: Color(AppColors.black), fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                          if(value.comments[index]['images'].isNotEmpty)Container(
                                              width: 94,
                                              height: 94,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Color(AppColors.primary),
                                                    width: 2
                                                ),
                                              ),
                                              child: GestureDetector(
                                                onTap: (){
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => FullScreenImageViewer(
                                                        initialIndex: 0,
                                                        imageUrls: [""],
                                                        one: true,
                                                        url: false,
                                                        image: value.comments[index]['images'][0]['file'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: CachedNetworkImage(
                                                  imageUrl: value.comments[index]['images'][0]['file'],
                                                  fit: BoxFit.cover,
                                                  width: 94,
                                                  height: 94,
                                                  placeholder: (context, url) =>
                                                  const ShimmerAnimatedLoading(),
                                                  errorWidget: (context, url, error) => const Icon(
                                                    Icons.image_not_supported_outlined,
                                                    size: AppSizes.s32,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                          ),
                                          if(value.comments[index]['sounds'].isNotEmpty)VoiceMessageWidget(
                                            audioUrl: value.comments[index]['sounds'][0]['file'] ,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      if(!value.isGetCommentLoading && value.comments.isEmpty) Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child:  NoExistingPlaceholderScreen(
                            height: LayoutService.getHeight(context) *
                                0.6,
                            title: AppStrings.thereIsNoComments.tr()),
                      ),
                      if (value.isGetCommentLoading && value.pageNumber != 1)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
