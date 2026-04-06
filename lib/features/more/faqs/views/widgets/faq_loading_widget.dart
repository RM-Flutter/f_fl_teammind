import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class FaqLoadingWidget extends StatelessWidget {
  const FaqLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.0.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 20.h,
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
              Container(
                width: double.infinity,
                height: 15.h,
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              ),
              Container(
                width: double.infinity,
                height: 15.h,
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
