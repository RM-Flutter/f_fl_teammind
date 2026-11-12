import 'package:app_test/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_test/core/constants/app_design.dart';

class FaqLoadingWidget extends StatelessWidget {
  const FaqLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSizes.s16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s10),
              ),
              Container(
                width: double.infinity,
                height: 15,
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s5),
              ),
              Container(
                width: double.infinity,
                height: 15,
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
