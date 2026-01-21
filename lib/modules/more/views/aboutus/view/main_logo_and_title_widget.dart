import 'package:flutter/material.dart';
import 'package:app_test/common_modules_widgets/dynamic_image_widget.dart';
import 'package:app_test/constants/app_images.dart';

class MainLogoAndTitleWidget extends StatelessWidget {
  const MainLogoAndTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: SizedBox(
            height: 177,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(60),
                bottomLeft: Radius.circular(60),
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
