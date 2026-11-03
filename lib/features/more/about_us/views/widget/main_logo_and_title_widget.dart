import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/widgets/dynamic_image_widget.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_design.dart';

class MainLogoAndTitleWidget extends StatelessWidget {
  const MainLogoAndTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Center(
          child: SizedBox(
            height: 177,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(AppRadius.pill),
                bottomLeft: Radius.circular(AppRadius.pill),
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
