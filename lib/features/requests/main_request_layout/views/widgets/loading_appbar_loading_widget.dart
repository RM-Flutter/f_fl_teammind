import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:flutter/material.dart';

class RequestsAppbarLoading extends StatelessWidget {
  const RequestsAppbarLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Row(
                children: List.generate(
                    3,
                        (index) => Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: ShimmerAnimatedLoading(
                          width: (1.sw -
                              (32.w + (12.w * 3))) /
                              3,
                          height: 120.h,
                        )))),
            SizedBox(height: 32.h),
          ],
        ),
      ],
    );
  }
}