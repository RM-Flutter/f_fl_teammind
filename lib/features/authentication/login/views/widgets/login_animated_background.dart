import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';

class LoginAnimatedBackground extends StatefulWidget {
  const LoginAnimatedBackground({super.key});

  @override
  State<LoginAnimatedBackground> createState() => _LoginAnimatedBackgroundState();
}

class _LoginAnimatedBackgroundState extends State<LoginAnimatedBackground> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController = AnimationController(
       duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final bgUrl = !kIsWeb ? AppImages.loginBackground : AppImages.loginBackgroundWeb;
        final isNetworkImage = bgUrl.startsWith('http://') || bgUrl.startsWith('https://');

        return FractionallySizedBox(
          widthFactor: AppSizes.s4,
          alignment: Alignment((animation.value * 2) - 1, 0),
          child: isNetworkImage
              ? CachedNetworkImage(
                  imageUrl: bgUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Image.asset(
                    !kIsWeb ? AppImages.defaultLoginBackground : AppImages.defaultLoginBackgroundWeb,
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    !kIsWeb ? AppImages.defaultLoginBackground : AppImages.defaultLoginBackgroundWeb,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  bgUrl,
                  fit: BoxFit.cover,
                ),
        );
      },
    );
  }
}
