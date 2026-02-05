import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_sizes.dart';
import '../services/layout_service.dart';
import '../utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class LoadingPageWidget extends StatelessWidget {
  final double? height;
  final bool? reverse;
  const LoadingPageWidget({super.key, this.height, this.reverse});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: List.generate(
            5,
            (index) => Container(
                  height: height,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.s14, horizontal: AppSizes.s16),
                  margin: const EdgeInsets.only(bottom: AppSizes.s16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.s10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(
                    children: reverse == true
                        ? [
                            const ShimmerAnimatedLoading(
                              width: AppSizes.s40,
                              height: AppSizes.s40,
                              circularRaduis: AppSizes.s40,
                            ),
                            gapW8,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShimmerAnimatedLoading(
                                  height: AppSizes.s18,
                                  width: LayoutService.getWidth(context) / 2,
                                ),
                                gapH4,
                                ShimmerAnimatedLoading(
                                  height: AppSizes.s18,
                                  width: LayoutService.getWidth(context) / 2,
                                ),
                              ],
                            ),
                          ]
                        : [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShimmerAnimatedLoading(
                                  height: AppSizes.s18,
                                  width: LayoutService.getWidth(context) / 2,
                                ),
                                gapH4,
                                ShimmerAnimatedLoading(
                                  height: AppSizes.s18,
                                  width: LayoutService.getWidth(context) / 2,
                                ),
                              ],
                            ),
                            const Spacer(),
                            const ShimmerAnimatedLoading(
                              width: AppSizes.s40,
                              height: AppSizes.s40,
                              circularRaduis: AppSizes.s40,
                            )
                          ],
                  ),
                )));
  }
}


class FancyLoadingScreen extends StatefulWidget {
  const FancyLoadingScreen({super.key});

  @override
  State<FancyLoadingScreen> createState() => _FancyLoadingScreenState();
}

class _FancyLoadingScreenState extends State<FancyLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.3).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.pinkAccent, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}



class NewHomeShimmer extends StatelessWidget {
  const NewHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Slider shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 400,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Title shimmer
            _shimmerBox(width: 260, height: 16),
            const SizedBox(height: 15),

            // 🔹 Horizontal cards shimmer
            SizedBox(
              height: 200,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return _shimmerBox(width: 180, height: 200, radius: 16);
                },
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Action cards shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: _shimmerBox(height: 140, radius: 16)),
                  const SizedBox(width: 16),
                  Expanded(child: _shimmerBox(height: 140, radius: 16)),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: _shimmerBox(height: 140, radius: 16)),
                  const SizedBox(width: 16),
                  Expanded(child: _shimmerBox(height: 140, radius: 16)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Close deals shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _shimmerBox(height: 250, radius: 16),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _shimmerBox({
    double width = double.infinity,
    required double height,
    double radius = 12,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

