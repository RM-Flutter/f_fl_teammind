import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/more/blog/controllers/blog_controller.dart';
import 'package:app_test/core/utils/gradient_bg_image.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

class DefaultDetails extends StatelessWidget {
  String? id;
  String? type;
  DefaultDetails({super.key, required this.id, this.type});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => BlogProviderModel()..getOneBlog(context,type: type, id: id.toString()),
      child: Consumer<BlogProviderModel>(
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor: const Color(0xffFFFFFF),
            body: GradientBgImage(
              padding: EdgeInsets.zero,
              child: Container(
                  width: 1.sw,
                  height: 1.sh,
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.s15),
                  child: (value.getOneBlogModel != null)? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.transparent,
                          height: 90,
                          width: double.infinity,
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: const Color(0xff224982), size: 24,),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              Text(
                                type == "rmnotifications" ? AppStrings.notifications.tr().toUpperCase() : type.toString().tr().toUpperCase(),
                                style: AppStyles.heading(context).copyWith(color: const Color(0xff224982), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                  icon: Icon(Icons.arrow_back, color: Colors.transparent, size: 24,),
                                  onPressed: (){}
                              ),
                            ],
                          ),
                        ),
                        gapH16,
                        if(value.getOneBlogModel!.item!.mainThumbnail != null && value.getOneBlogModel!.item!.mainThumbnail!.isNotEmpty ) ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: CachedNetworkImage(
                            width: 1.sw,
                            height: 0.225.sh,
                            fit: BoxFit.cover,
                            imageUrl: value.getOneBlogModel!.item!.mainThumbnail![0].file ?? "",
                            placeholder: (context, url) =>
                            const ShimmerAnimatedLoading(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported_outlined,
                              size: AppSizes.s32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if(value.getOneBlogModel!.item!.mainThumbnail != null && value.getOneBlogModel!.item!.mainThumbnail!.isNotEmpty)   gapH24,
                        Row(
                          children: [
                            Text(
                              (value.getOneBlogModel!.item!.createdAt != null )?value.getOneBlogModel!.item!.createdAt! : "",
                              style: AppStyles.c1Content(context).copyWith(
                                  fontSize: AppSizes.s10,
                                  fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 20,),

                                if(value.getOneBlogModel!.item!.category!.title
                                != null) Row(
                              children: [
                                Icon(Icons.category, color: Colors.black,
                                  size: 16,),
                                SizedBox(width: 5,),
                                Text(
                                  value.getOneBlogModel!.item!.category!.title!
                                      .toUpperCase(),
                                  style: AppStyles.c1Content(context).copyWith(
                                    fontSize: AppSizes.s10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                                )
                              ],
                            ),
                        gapH14,
                        Text(
                          value.getOneBlogModel!.item!.title ?? "",
                          style: AppStyles.heading(context).copyWith(
                              fontSize: AppSizes.s16,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.c1)),
                        ),
                        gapH14,
                        Html(
                            data:   value.getOneBlogModel!.item!.content ?? "",
                            style: TextsStyles.htmlStyle),
                      ],
                    ),
                  ): Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 90,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 0.225.sh,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 24),
                        Container(
                          height: 12,
                          width: 150,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 14),
                        Container(
                          height: 16,
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 14),
                        Container(
                          height: 12,
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 12,
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  )),
            ),
          );
        },
      ),
    );
  }
}
