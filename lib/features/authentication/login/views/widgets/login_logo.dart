import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/platform/platform_is.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final logoUrl = AppImages.logo;
    final isNetworkImage = logoUrl.startsWith('http://') || logoUrl.startsWith('https://');

    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        height: (kIsWeb || PlatformIs.web) ? AppSizes.s100 : AppSizes.s100.h,
        width: (kIsWeb || PlatformIs.web) ? AppSizes.s100 : AppSizes.s100.w,
        fit: BoxFit.contain,
        placeholder: (context, url) => Image.asset(
          AppImages.defaultLogo,
          height: (kIsWeb || PlatformIs.web) ? AppSizes.s100 : AppSizes.s100.h,
          width: (kIsWeb || PlatformIs.web) ? AppSizes.s100 : AppSizes.s100.w,
          fit: BoxFit.contain,
        ),
        errorWidget: (context, url, error) => Image.asset(
          AppImages.defaultLogo,
          height: (kIsWeb || PlatformIs.web) ? AppSizes.s100 : AppSizes.s100.h,
          width: (kIsWeb || PlatformIs.web) ? AppSizes.s100 : AppSizes.s100.w,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Image.asset(
        logoUrl,
        height: (kIsWeb || PlatformIs.web) ? AppSizes.s100 : AppSizes.s100.h,
        width: (kIsWeb || PlatformIs.web) ? AppSizes.s100 : AppSizes.s100.w,
        fit: BoxFit.contain,
      );
    }
  }
}
