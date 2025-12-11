import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/common_modules_widgets/comments/list_comments.dart';
import 'package:rmemp/common_modules_widgets/comments/send_comment_widget.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../modules/complain_screen/widget/full_image_screen.dart';
import '../../modules/complain_screen/widget/request_audio_widget.dart';
import '../../utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class CommentsWidget extends StatefulWidget {
  final List<dynamic>? comments;
  final dynamic enable;
  final String slug;
  final int? pageNumber;
  final bool? loading;
  final ScrollController? scrollController;
  final dynamic id;

  const CommentsWidget(
    this.slug, {
    super.key,
    this.comments,
    this.enable,
    this.pageNumber,
    this.loading,
    this.scrollController,
    this.id,
  });

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  int _previousLength = 0;

  @override
  void initState() {
    super.initState();
    _previousLength = widget.comments?.length ?? 0;
  }

  @override
  void didUpdateWidget(covariant CommentsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int newLength = widget.comments?.length ?? 0;

    if (widget.scrollController != null &&
        widget.scrollController!.hasClients &&
        newLength > _previousLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final target =
              widget.scrollController!.position.minScrollExtent.clamp(
            widget.scrollController!.position.minScrollExtent,
            widget.scrollController!.position.maxScrollExtent,
          );
          widget.scrollController!.animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } catch (_) {
          // ignore any controller exceptions
        }
      });
    }

    _previousLength = newLength;
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.comments ?? [];
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.5,
      child: Column(
        children: [
          if (comments.isNotEmpty)
            SizedBox(
              height: comments.length >= 10
                  ? MediaQuery.sizeOf(context).height * 0.33
                  : MediaQuery.sizeOf(context).height * 0.4,
              child: ListView.separated(
                controller: widget.scrollController,
                shrinkWrap: true,
                reverse: true,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  DateTime utcDateTime =
                      DateTime.parse("${comments[index]['created_at']}");
                  String formattedDate = DateFormat(
                          "dd/MM/yyyy hh:mm a", context.locale.languageCode)
                      .format(utcDateTime);
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
                          color: Color(0x0C000000),
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
                          child: CachedNetworkImage(
                            width: 63,
                            height: 63,
                            fit: BoxFit.cover,
                            imageUrl: comments[index]['user']['avatar'] ?? "",
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
                                    comments[index]['user']['name'] ?? "",
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Color(AppColors.dark))),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.4,
                                child: Text(
                                  formattedDate,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Color(0xff5E5E5E)),
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (comments[index]['content'] != null)
                                Text(
                                  comments[index]['content'] ?? "",
                                  style: const TextStyle(
                                      color: Color(AppColors.black),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              if (comments[index]['images'].isNotEmpty)
                                Container(
                                  width: 94,
                                  height: 94,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: const Color(AppColors.primary),
                                        width: 2),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FullScreenImageViewer(
                                            initialIndex: 0,
                                            imageUrls: const [""],
                                            one: true,
                                            url: false,
                                            image: comments[index]['images'][0]
                                                ['file'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: comments[index]['images'][0]
                                          ['file'],
                                      fit: BoxFit.cover,
                                      width: 94,
                                      height: 94,
                                      placeholder: (context, url) =>
                                          const ShimmerAnimatedLoading(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: AppSizes.s32,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              if (comments[index]['sounds'].isNotEmpty)
                                VoiceMessageWidget(
                                  key: ValueKey('${comments[index]['id']}_voice'),
                                  audioUrl: comments[index]['sounds'][0]
                                      ['file'],
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                itemCount: comments.length,
              ),
            ),
          if (comments.isEmpty)
            Container(
              alignment: Alignment.center,
              height: MediaQuery.sizeOf(context).height * 0.3,
              child: Center(
                child: Text(
                  AppStrings.noCommentsFound.tr().toUpperCase(),
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          if (comments.length >= 10)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListCommentsScreen(
                            id: widget.id,
                            slug: widget.slug,
                          ),
                        ));
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.sizeOf(context).width * 0.3,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        border:
                            Border.all(color: const Color(AppColors.dark))),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.more.tr().toUpperCase(),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(AppColors.dark)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          if (widget.enable == "enable") SendCommentWidget(widget.id, widget.slug),
          if (widget.enable != "enable")
            Text(
              AppStrings.theCommentOnThisRequestHasBeenClosedByTheAdmin.tr(),
              style: const TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
