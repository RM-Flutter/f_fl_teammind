import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/evaluation/shared/widgets/profile_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssetsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  AssetsSectionWidget({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH4,
          Text(AppStrings.assets.tr().toUpperCase(),
          style: AppStyles.subtitleContent(context).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
          gapH12,
          ListView.separated(
              reverse: false,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) =>  ProfileTileNotTap(
                url: null,
                createAt: null,
                gainedPoints: null,
                totalPoints: null,
                isViewArrow: false,
                title: "${employee!.assets![index].assets}",
                icon: Icon(Icons.check_circle_outline, color: Colors.black, size: 20.sp,),
              ),
              separatorBuilder: (context, index) => SizedBox(height: 15.h,),
              itemCount: employee!.assets!.length),
          SizedBox(height: 20.h,),
          Text(AppStrings.customData.tr().toUpperCase(), style: AppStyles.subtitleContent(context).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w700),),
          gapH12,
          ListView.separated(
              reverse: false,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.only(bottom:AppSizes.s12.h),
                padding: EdgeInsets.symmetric(
                    vertical: AppSizes.s12.h, horizontal: AppSizes.s10.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.s8.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  Icon(Icons.check_circle_outline, color: Colors.black, size: 20.sp,),
                    SizedBox(width: 4.w),
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.75,
                        child: Text("${employee!.empCustomData![index].item}",style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w500, fontSize: 14.sp))),
                  ],
                ),
              ),
              separatorBuilder: (context, index) => SizedBox(height: 15.h,),
              itemCount: employee!.empCustomData!.length)
        ],
      ),
    );
  }
}
