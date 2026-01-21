import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app_test/constants/app_colors.dart';
import 'package:app_test/constants/app_sizes.dart';
import 'package:app_test/utils/custom_shimmer_loading/shimmer_animated_loading.dart';

Widget defaultProjectCard(String? title1, String? title2, src, {onTap}) {
  return GestureDetector(
    onTap: onTap ?? (){},
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                child:  CachedNetworkImage(
                  height: 135,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  imageUrl: src,
                  placeholder: (context, url) =>
                  const ShimmerAnimatedLoading(),
                  errorWidget: (context, url, error) =>  const Icon(
                    Icons.image_not_supported_outlined,
                    size: AppSizes.s32,
                    color: Colors.white,
                  ),
                ),), // Replace with project images
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(title1 ?? "".toUpperCase(),maxLines: 1, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Color(AppColors.primary))),
                  const SizedBox(height: 7,),
                  Text(title2 ?? "".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF090B60))),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}