import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/utils/styles.dart';
import 'package:app_test/features/more/general_data/controller/general_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class GeneralDataScreen extends StatelessWidget {
  GeneralDataScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => GeneralController()..getGeneralData(context),
      child: Consumer<GeneralController>(
        builder: (context, value, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color(AppColors.white),
            body: (!value.isLoading)?Container(
                width: 1.sw,
                height: 1.sh,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.s15.w),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.transparent,
                        height: 90.h,
                        width: double.infinity,
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Color(AppColors.dark), size: 24.r,),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Text(
                              value.dataTitle.toUpperCase(),
                              style: AppStyles.darkHeading(context).copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                            IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.transparent),
                                onPressed: (){}
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      if(value.dataimage != null) ClipRRect(
                        borderRadius: BorderRadius.circular(25.r),
                        child: CachedNetworkImage(
                          width: 1.sw,
                          height: 0.225.sh,
                          fit: BoxFit.fill,
                          imageUrl: value.dataimage,
                          placeholder: (context, url) =>
                          const ShimmerAnimatedLoading(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.image_not_supported_outlined,
                            size: AppSizes.s32.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if(value.dataimage != null)  SizedBox(height: 24.h),
                      Html(
                          data: value.dataContent,
                          style: TextsStyles.htmlStyle),
                    ],
                  ),
                )):
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 150.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: 200.w,
                    height: 20.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
