import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/modules/more/views/blog/controller/blog_controller.dart';
import 'package:rmemp/utils/gradient_bg_image.dart';
import 'package:rmemp/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:rmemp/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

class DefaultDetails extends StatelessWidget {
  String? id;
  String? type;
  DefaultDetails({required this.id, this.type});

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
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 1,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s15),
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
                                icon: const Icon(Icons.arrow_back, color: Color(AppColors.dark)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              Text(
                                  type == "rmnotifications" ? AppStrings.notifications.tr().toUpperCase():type.toString().tr().toUpperCase(),
                                style: const TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.transparent),
                                  onPressed: (){}
                              ),
                            ],
                          ),
                        ),
                        gapH16,
                        if(value.getOneBlogModel!.item!.mainThumbnail != null && value.getOneBlogModel!.item!.mainThumbnail!.isNotEmpty ) ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: CachedNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.225,
                            fit: BoxFit.cover,
                            imageUrl: value.getOneBlogModel!.item!.mainThumbnail![0].file ?? "",
                            placeholder: (context, url) =>
                            const ShimmerAnimatedLoading(),
                            errorWidget: (context, url, error) => const Icon(
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
                              style:  TextStyle(
                                  fontSize: AppSizes.s10,
                                  fontWeight: FontWeight.w400,
                                  color: Color(AppColors.dark)),
                            ),
                            const SizedBox(width: 20,),
                            if(value.getOneBlogModel!.item!.category != null && value.getOneBlogModel!.item!.category!.title != null)Row(
                              children: [
                                Icon(Icons.category, color: Colors.black,),
                                const SizedBox(width: 5,),
                                Text(
                                  value.getOneBlogModel!.item!.category!.title!.toUpperCase(),
                                  style:  TextStyle(
                                      fontSize: AppSizes.s10,
                                      fontWeight: FontWeight.w400,
                                      color: Color(AppColors.dark)),
                                ),
                              ],
                            )
                          ],
                        ),
                        gapH14,
                        Text(
                          value.getOneBlogModel!.item!.title ?? "",
                          style: const TextStyle(
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
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.225,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 12,
                          width: 150,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 16,
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 12,
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
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
