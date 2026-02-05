import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';

import '../../widgets/dynamic_image_widget.dart';

class NoExistingPlaceholderScreen extends StatelessWidget {
  final String title;
  final double? height;
  const NoExistingPlaceholderScreen(
      {super.key, required this.title, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DynamicImageWidget(
            imageUrl: AppImages.logo,
            width: AppSizes.s100,
            height: AppSizes.s100,
            fit: BoxFit.cover,
            errorWidget: Image.asset(
              'assets/images/general_images/logo.png',
              color: Colors.grey,
              width: AppSizes.s100,
              height: AppSizes.s100,
              fit: BoxFit.cover,
            ),
          ),
          gapH16,
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
