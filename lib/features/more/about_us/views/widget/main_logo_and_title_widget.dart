import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/widgets/dynamic_image_widget.dart';
import 'package:app_test/core/constants/app_images.dart';

class MainLogoAndTitleWidget extends StatelessWidget {
  const MainLogoAndTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30.h),
        Center(
          child: SizedBox(
            height: 177.h,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(60.r),
                bottomLeft: Radius.circular(60.r),
              ),
              child: DynamicImageWidget(
                imageUrl: AppImages.logo,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
