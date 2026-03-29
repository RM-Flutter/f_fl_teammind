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
                    backgroundColor: Color(AppColors.white),
                    body: (value.notificationModel != null && value.isGetNotificationCommentLoading != true
                        &&!value.isGetNotificationCommentLoading)?SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          NotificationDetailsAppbarWidget(notificationSingleModel: value.notificationModel,),
                          SizedBox(height: 20,),
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: kIsWeb ? 800 : double.infinity
                              ),
                              child: Padding(padding: EdgeInsets.symmetric(horizontal: 15),
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
                                            fontSize: FontSize(14),
                                            fontWeight: FontWeight.w400,
                                            textAlign: TextAlign.center,
                                          ),
                                          "*": Style(
                                            color: const Color(0xFF666666),
                                            textAlign: TextAlign.center,
                                          ),
                                        }),
                                    SizedBox(height: 10,),
                                    if(value.notificationModel!.mainThumbnail != null &&value.notificationModel!.mainThumbnail!.isNotEmpty)Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if(value.notificationModel!.mainThumbnail!.length > 1) Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            SizedBox(
                                              height: 300,
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
                                                      width: MediaQuery.of(context).size.width,
                                                      fit: BoxFit.contain,
                                                      imageUrl: value.notificationModel!.mainThumbnail![index].file ?? "",
                                                      placeholder: (context, url) =>
                                                      const ShimmerAnimatedLoading(),
                                                      errorWidget: (context, url, error) => const Icon(
                                                        Icons.image_not_supported_outlined,
                                                        size: AppSizes.s32,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(bottom: 25, right: 40, left: 40),
                                                child: SizedBox(
                                                  height: 20,
                                                  child: ListView.separated(
                                                      shrinkWrap: true,
                                                      reverse: false,
                                                      physics: ClampingScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (context, index) => AnimatedContainer(
                                                        duration: Duration(milliseconds: 300),
                                                        margin: EdgeInsets.symmetric(horizontal: 4),
                                                        width: _currentIndex == index ? 12 : 8,
                                                        height: _currentIndex == index ? 12 : 8,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: _currentIndex == index ? Color(AppColors.white) : Colors.grey,
                                                        ),
                                                      ), separatorBuilder: (context, index) => SizedBox(width: 5,),
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
                                                    imageUrls: [""],
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
                                            errorWidget: (context, url, error) => const Icon(
                                              Icons.image_not_supported_outlined,
                                              size: AppSizes.s32,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    _buildSectionHeader(AppStrings.comments.tr()),
                                    const SizedBox(height: 15),
                                    _buildCommentsList(values.comments),
                                    const SizedBox(height: 30),
                                    _buildSectionHeader(AppStrings.addNewComment.tr()),
                                    const SizedBox(height: 20),
                                    if (value.notificationModel!.commentStatus!.key == "enable")
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: SendCommentWidget(widget.id, "rmnotifications"),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Text(
                                          AppStrings.theCommentOnThisRequestHasBeenClosedByTheAdmin.tr(),
                                          style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE8ECF0), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            title.toUpperCase(),
            style:  TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: (Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE8ECF0), thickness: 1)),
      ],
    );
  }

  Widget _buildCommentsList(List<dynamic> comments) {
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            AppStrings.noCommentsFound.tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        DateTime utcDateTime = DateTime.parse("${comment['created_at']}");
        String formattedDate = DateFormat("dd/MM/yyyy hh:mm:ss a", context.locale.languageCode).format(utcDateTime);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF1F4F7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4), // Increased padding for better white ring
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF1F4F7), width: 1),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: CachedNetworkImageProvider(comment['user']['avatar'] ?? ""),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['content'] ?? "",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A4A4A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB0B7C3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
