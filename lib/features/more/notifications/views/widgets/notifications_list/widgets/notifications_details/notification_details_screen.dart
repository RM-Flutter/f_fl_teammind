import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/widgets/comments/logic/controller.dart';
import 'package:app_test/core/widgets/comments/send_comment_widget.dart';
import 'package:app_test/core/widgets/full_image_screen.dart';
import 'package:app_test/features/complaints/controller/complaints_controller.dart';
import 'package:app_test/features/more/notifications/views/widgets/notifications_list/widgets/notifications_details/widgets/notification_details_appbar_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/more/notifications/controllers/notification_controller.dart';
import 'package:app_test/features/more/notifications/views/widgets/notifications_list/widgets/notifications_details/widgets/notification_details_loading_screen.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

import '../../../../../../../../core/widgets/comments/comments_widget.dart';




class NotificationDetailsScreen extends StatefulWidget {
  final dynamic id;
  const NotificationDetailsScreen({required this.id, super.key});

  @override
  State<NotificationDetailsScreen> createState() => _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  late NotificationProviderModel notificationProviderModel;
  late ScrollController _scrollController;
// Keep track of loaded pages
  final PageController _controller = PageController();
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      int newIndex = _controller.page?.round() ?? 0;
      if (_currentIndex != newIndex) {
        setState(() => _currentIndex = newIndex);
      }
    });
    notificationProviderModel = NotificationProviderModel();

    _scrollController = ScrollController();

  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the controller
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => NotificationProviderModel()..getNotificationSingle(context, widget.id)),
      ChangeNotifierProvider(create: (context) => ComplaintsController()),
      ChangeNotifierProvider(create: (context) => CommentProvider()..getComment(context, "rmnotifications", widget.id)),
    ],
      child: Consumer<ComplaintsController>(
        builder: (context, reqModel, child) {
          return Consumer<NotificationProviderModel>(
            builder: (context, value, child) {
              if(reqModel.isAddCommentSuccess){
                print("ADDED SUCCESS");
              }
              return Consumer<CommentProvider>(
                builder: (context, values, child) {
                  return Scaffold(
                    backgroundColor: Color(AppColors.background),
                    body: (value.notificationModel != null && value.isGetNotificationCommentLoading != true
                        &&!value.isGetNotificationCommentLoading)?SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          NotificationDetailsAppbarWidget(notificationSingleModel: value.notificationModel,),
                          SizedBox(height: 20.h),
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: kIsWeb ? 800.w : double.infinity
                              ),
                              child: Padding(padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Html(
                                        shrinkWrap: true,
                                        data: value.notificationModel!.content ?? "",
                                        style: {
                                          "body": Style(
                                            textAlign: TextAlign.center,
                                            margin: Margins.zero,
                                            padding: HtmlPaddings.zero,
                                          ),
                                          "p": Style(
                                            color: const Color(0xFF666666),
                                            lineHeight: const LineHeight(1.6),
                                            fontSize: FontSize(14.sp),
                                            fontWeight: FontWeight.w400,
                                            textAlign: TextAlign.center,
                                          ),
                                          "*": Style(
                                            color: const Color(0xFF666666),
                                            textAlign: TextAlign.center,
                                          ),
                                        }),
                                    SizedBox(height: 10.h),
                                    if(value.notificationModel!.mainThumbnail != null &&value.notificationModel!.mainThumbnail!.isNotEmpty)Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if(value.notificationModel!.mainThumbnail!.length > 1) Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            SizedBox(
                                              height: 300.h,
                                              child: PageView.builder(
                                                controller: _controller,
                                                itemCount: value.notificationModel!.mainThumbnail!.length,
                                                itemBuilder: (context, index) {
                                                  return  GestureDetector(
                                                    onTap: (){
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => FullScreenImageViewer(
                                                              imageUrls: value.notificationModel!.mainThumbnail!,
                                                              file: true,
                                                              initialIndex: index,
                                                              url: true,
                                                              thum: false,
                                                            ),
                                                          )
                                                      );
                                                    },
                                                    child: CachedNetworkImage(
                                                      width: 1.sw,
                                                      fit: BoxFit.contain,
                                                      imageUrl: value.notificationModel!.mainThumbnail![index].file ?? "",
                                                      placeholder: (context, url) =>
                                                      const ShimmerAnimatedLoading(),
                                                      errorWidget: (context, url, error) => Icon(
                                                        Icons.image_not_supported_outlined,
                                                        size: AppSizes.s32.r,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(bottom: 25.h, right: 40.w, left: 40.w),
                                                child: SizedBox(
                                                  height: 20.h,
                                                  child: ListView.separated(
                                                      shrinkWrap: true,
                                                      reverse: false,
                                                      physics: const ClampingScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (context, index) => AnimatedContainer(
                                                        duration: const Duration(milliseconds: 300),
                                                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                                                        width: _currentIndex == index ? 12.r : 8.r,
                                                        height: _currentIndex == index ? 12.r : 8.r,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: _currentIndex == index ? Color(AppColors.background) : Colors.grey,
                                                        ),
                                                      ), separatorBuilder: (context, index) => SizedBox(width: 5.w),
                                                      itemCount: value.notificationModel!.mainThumbnail!.length),
                                                )
                                            )
                                          ],
                                        ),
                                        if(value.notificationModel!.mainThumbnail!.length == 1) GestureDetector(
                                          onTap: (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FullScreenImageViewer(
                                                    imageUrls: const [""],
                                                    one:  true,
                                                    image: value.notificationModel!.mainThumbnail![0].file, initialIndex: 1, url: false,

                                                  ),
                                                )
                                            );
                                          },
                                          child: CachedNetworkImage(
                                            fit: BoxFit.contain,
                                            imageUrl: value.notificationModel!.mainThumbnail![0].file ?? "",
                                            placeholder: (context, url) =>
                                            const ShimmerAnimatedLoading(),
                                            errorWidget: (context, url, error) => Icon(
                                              Icons.image_not_supported_outlined,
                                              size: AppSizes.s32.r,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    CommentsWidget(
                                      "rmnotifications",
                                      id: widget.id,
                                      comments: values.comments,
                                      enable: value.notificationModel!.commentStatus!.key,
                                      // isNotificationDetails: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ): const NotificationDetailsLoadingScreen(),
                  );
                },
              );
            },
          );
        } ,
      ),
    );
  }
}
