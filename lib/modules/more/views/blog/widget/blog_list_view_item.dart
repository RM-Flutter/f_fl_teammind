import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_images.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:rmemp/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class BlogListViewItem extends StatefulWidget {
  final List blog;
  final int index;
  var type;
   BlogListViewItem({super.key, required this.blog, required this.index, this.type});

  @override
  State<BlogListViewItem> createState() => _BlogListViewItemState();
}

class _BlogListViewItemState extends State<BlogListViewItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if(widget.type == "rmnotifications"){
          setState(() {
            widget.blog[widget.index]['seen'] = true;
          });
          context.pushNamed(AppRoutes.notificationDetails.name,
              pathParameters: {'lang': context.locale.languageCode,
                "id" : "${widget.blog[widget.index]['id']}",
              });
        }else{
          context.pushNamed(AppRoutes.defaultSinglePage.name,
              pathParameters: {'lang': context.locale.languageCode,
                "id" : "${widget.blog[widget.index]['id']}",
                "type" : widget.type.toString()
              });
        }

      },
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSizes.s15, vertical: AppSizes.s12),
        decoration: BoxDecoration(
          color: const Color(AppColors.textC5),
          borderRadius: BorderRadius.circular(AppSizes.s15),
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                spreadRadius: 0,
                offset: Offset(0, 1),
                blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 63,
              height: 63,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3389EE)
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(63),
                  child: CachedNetworkImage(
                      imageUrl: (widget.blog[widget.index]['main_thumbnail'].isNotEmpty)?
                      widget.blog[widget.index]['main_thumbnail'][0]['file'] : "",
                      fit: BoxFit.cover,
                      height: 40,
                      width: 40,
                      placeholder: (context, url) => const ShimmerAnimatedLoading(
                        width: 63.0,
                        height: 63,
                        circularRaduis: 63,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported_outlined,
                      )),
                ),
              ),
            ),
            gapW8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 if (widget.blog[widget.index]['created_at'] != null) Text(
                  (widget.blog[widget.index]['created_at'] != null)?  "${widget.blog[widget.index]['created_at']}".toUpperCase() : "0",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff606060)),
                  ),
                  if (widget.blog[widget.index]['created_at'] != null)  gapH4,
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                        "${widget.blog[widget.index]['title'].toString()}".toUpperCase(),
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.blog[widget.index]['seen'] == false ?Color(AppColors.dark) : Colors.grey
                        ),
                    )
                    // Html(
                    //     shrinkWrap: true,
                    //     data: "${blog[index]['title']}".toUpperCase(),
                    //     style: {
                    //       "p" : Style(
                    //           fontSize: FontSize(12),maxLines: 2,padding: HtmlPaddings.all(0),margin: Margins.all(0),
                    //           fontWeight: FontWeight.w600,
                    //           color: Color(AppColors.dark)),
                    //     }
                    // ),

                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
