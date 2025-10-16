import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

import '../constants/app_sizes.dart';

class CachedNetWorkImageWidget extends StatelessWidget {
  const CachedNetWorkImageWidget({
    super.key,
    this.url,
    this.height,
    this.width,
    this.boxFit,
    this.radius = 16,
    this.cacheKey,
    this.errorWidget,
    //  this.isShadowed = false,
  });
  final String? url;
  final String? cacheKey;
  final double? height;
  final double? width;
  final double radius;
  //final bool? isShadowed;
  final BoxFit? boxFit;
  final Widget? errorWidget;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url ?? '',
      width: width,
      height: height,
      cacheKey: cacheKey ?? url,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          const Center(child: CircularProgressIndicator()),
      fit: boxFit ?? BoxFit.cover,
      // color: AppColors.error500,
      alignment: Alignment.topCenter,
      filterQuality: FilterQuality.high,
      imageBuilder: (context, imageProvider) => AspectRatio(
        aspectRatio: 1.8,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(radius),
            image: DecorationImage(
              image: imageProvider,
              fit: boxFit ?? BoxFit.cover,
            ),
            // boxShadow: isShadowed == true
            //     ? [
            //         BoxShadow(
            //           color: AppColors.primary700,
            //           blurRadius: 4,
            //           offset: const Offset(0, 4),
            //           spreadRadius: 0,
            //         ),
            //       ]
            //     : [],
          ),
        ),
      ),
      placeholder: (context, url) =>
      const ShimmerAnimatedLoading(),
      errorWidget: (context, url, error) => const Icon(
        Icons.image_not_supported_outlined,
        size: AppSizes.s32,
        color: Colors.white,
      ),
    );
  }
}
