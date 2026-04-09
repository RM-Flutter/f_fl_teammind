import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class BlogListViewItem extends StatelessWidget {
  final List blog;
  final int index;
  var type;
   BlogListViewItem({super.key, required this.blog, required this.index, this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(AppRoutes.defaultSinglePage.name,
            pathParameters: {'lang': context.locale.languageCode,
              "id" : "${blog[index]['id']}",
              "type" : type.toString()
            });
      },
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSizes.s15.w, vertical: AppSizes.s12.h),
        decoration: BoxDecoration(
          color: Color(AppColors.textC5),
          borderRadius: BorderRadius.circular(AppSizes.s15.r),
          boxShadow: [
            BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                spreadRadius: 0,
                offset: Offset(0, 1.h),
                blurRadius: 10.r)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 63.r,
              height: 63.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3389EE)
              ),
              child: Padding(
                padding: EdgeInsets.all(2.r),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(63.r),
                  child: CachedNetworkImage(
                      imageUrl: (blog[index]['main_thumbnail'].isNotEmpty)?
                      blog[index]['main_thumbnail'][0]['file'] : "",
                      fit: BoxFit.cover,
                      height: 40.r,
                      width: 40.r,
                      placeholder: (context, url) => ShimmerAnimatedLoading(
                        width: 63.0.r,
                        height: 63.r,
                        circularRaduis: 63.r,
                      ),
                      errorWidget: (context, url, error) =>  const Icon(
                        Icons.image_not_supported_outlined,
                      )),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 if (blog[index]['created_at'] != null) Text(
                  (blog[index]['created_at'] != null)?  "${blog[index]['created_at']}".toUpperCase() : "0",
                    style:  AppStyles.greyContent(context).copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400),
                  ),
                  if (blog[index]['created_at'] != null)  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                        blog[index]['title'].toString().toUpperCase(),
                        maxLines: 2,
                        style: AppStyles.heading(context).copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff0D3B6F)),
                    )
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
