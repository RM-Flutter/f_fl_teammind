import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/constants/app_strings.dart';
import 'package:app_test/routing/app_router.dart';
import 'package:app_test/constants/app_colors.dart';
import 'package:app_test/constants/app_sizes.dart';
import 'package:app_test/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class ListViewItem extends StatelessWidget {
  final List blog;
  final int index;
  const ListViewItem({super.key, required this.blog, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(AppRoutes.blogDetails.name,
            pathParameters: {'lang': context.locale.languageCode,
              "id" : "${blog[index]['id']}",
              "title" : AppStrings.blogDetails.tr(),
              "type" : "blogs"
            });
      },
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSizes.s15, vertical: AppSizes.s12),
        decoration: BoxDecoration(
          color: Color(AppColors.textC5),
          borderRadius: BorderRadius.circular(AppSizes.s15),
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                spreadRadius: 0,
                offset: Offset(0, 1),
                blurRadius: 10)
          ],
        ),
        child: Container(
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
                  imageUrl: (blog[index]['main_thumbnail'].isNotEmpty)?
                  blog[index]['main_thumbnail'][0]['file'] : "",
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                  placeholder: (context, url) => const ShimmerAnimatedLoading(
                    width: 63.0,
                    height: 63,
                    circularRaduis: 63,
                  ),
                  errorWidget: (context, url, error) =>  const Icon(
                    Icons.image_not_supported_outlined,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
