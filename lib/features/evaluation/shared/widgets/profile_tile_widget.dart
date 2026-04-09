import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  final Widget? icon;
  final double? marginBottom;
  List? weekends;
  bool? isList = false;
  ProfileTile({
    super.key,
    this.icon,
    this.isList,
    this.weekends,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          bottom: marginBottom?.h ?? AppSizes.s12.h, left: 8.w, right: 8.w),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            )
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05))),
      child: isTitleOnly == true
          ? Center(
              child: Text(title.toString(),
              style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
              ),
            )
          : icon != null && trailingTitle != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    icon ?? const SizedBox.shrink(),
                    SizedBox(width: 12.w),
                    Text(title,
                    style: AppStyles.primaryContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                    const Spacer(),
                    if(isList == false)
                      AutoSizeText(
                        trailingTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
                        textAlign: TextAlign.end,
                      ),
                    if(isList == true)Container(
                      alignment: Alignment.centerRight,
                      height: 15.h,
                      child: ListView.separated(
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          reverse: false,
                          itemBuilder: (context, index) => AutoSizeText(
                            weekends![index] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.blackContent(context).copyWith(
                                fontWeight: FontWeight.w700, fontSize: 14.sp),
                            textAlign: TextAlign.end,
                          ),
                          separatorBuilder: (context, index) => SizedBox(width: 4.w,child: Text(index == weekends!.length - 1 ? "" : ",", style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),),),
                          itemCount: weekends!.length),
                    )
                  ],
                )
              : const SizedBox.shrink(),
    );
  }
}
class ProfileTileEva extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  var url;
  var eva;
  var createAt;
  var totalPoints;
  var gainedPoints;
  final double? marginBottom;
  ProfileTileEva({
    super.key,
    this.totalPoints,
    this.eva,
    this.gainedPoints,
    this.icon,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()async{
        showEvaluationBottomSheet(context);
      }
      ,
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom?.h ?? AppSizes.s12.h),
        padding: EdgeInsets.symmetric(
            vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              )
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.05))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon ?? const SizedBox.shrink(),
                      SizedBox(width: 12.w),
                      Text(title,style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                      SizedBox(width: 12.w),
                      if(isViewArrow == true) const Spacer(),
                     if(isViewArrow == true) CircleAvatar(
                        backgroundColor: Color(AppColors.buttonSecondary),
                        radius: 12.r,
                        child: Icon(Icons.arrow_forward_sharp,color: Colors.white, size: 10.sp,),
                      )
                    ],
                  ),
      ),
    );
  }
  void showEvaluationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          height: MediaQuery.sizeOf(context).height * 0.6,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppStrings.evaluationsInfo.tr(),style: AppStyles.blackHeading(context).copyWith(fontSize: 20.sp, fontWeight: FontWeight.w600),),
               SizedBox(height: 15.h,),
               Container(
                 width: double.infinity,
                 alignment: Alignment.center,
                 height: 40.h,
                 decoration: BoxDecoration(
                   color: Color(AppColors.buttonSecondary),
                   borderRadius: BorderRadius.circular(10.r)
                 ),
                 child: Text(
                   DateFormat('MMMM yyyy', LocalizationService.isArabic(context: context)? "ar" : "en").format(DateTime.parse(createAt)).toString(),
                   style: AppStyles.whiteContent(context).copyWith(
                     fontSize: 18.sp,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
              SizedBox(height: 30.h),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: ListView.separated(
                    shrinkWrap: true,
                    reverse: false,
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) =>eva[index]['gained_points'] != null? Column(
                      children: [
                        Text("${eva[index]['employee_name']} (${eva[index]['created_at']})", style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 12.sp),),
                        SizedBox(height: 10.h,),
                        Text("${AppStrings.totalEvalutaions.tr().toUpperCase()} : ${eva[index]['gained_points']?.toString() ?? 0}/${eva[index]['total_points']?.toString() ?? 0}", style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w500, fontSize: 12.sp),),
                      ],
                    ): const SizedBox.shrink(), separatorBuilder: (context, index) => SizedBox(height: 20.h,),
                    itemCount: eva.length),
              )
            ],
          ),
        );
      },
    );
  }

}
class ProfileTileNotTap extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  var url;
  var eva;
  var createAt;
  var totalPoints;
  var gainedPoints;
  final double? marginBottom;
  ProfileTileNotTap({
    super.key,
    this.totalPoints,
    this.eva,
    this.gainedPoints,
    this.icon,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom?.h ?? AppSizes.s12.h),
      padding: EdgeInsets.symmetric(
          vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            )
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon ?? const SizedBox.shrink(),
          SizedBox(width: 12.w),
          Text(title,style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp)),
          SizedBox(width: 12.w),
          if(isViewArrow == true) const Spacer(),
          if(isViewArrow == true) CircleAvatar(
            backgroundColor: Color(AppColors.buttonSecondary),
            radius: 12.r,
            child: Icon(Icons.arrow_forward_sharp,color: Colors.white, size: 10.sp,),
          )
        ],
      ),
    );
  }
}
class ProfileTileEvaReq extends StatelessWidget {
  final String title;
  final String? empName;
  final String? department;
  final String? name;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  var url;
  var createAt;
  final double? marginBottom;
  ProfileTileEvaReq({
    super.key,
    this.empName,
    this.department,
    this.name,
    this.icon,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()async{
        if(url != null){
          await launchUrl(Uri.parse(url));
        }
      }
      ,
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom?.h ?? AppSizes.s12.h),
        padding: EdgeInsets.symmetric(
            vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              )
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.05))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon ?? const SizedBox.shrink(),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                Text("${AppStrings.employeeName.tr()} : ${empName ?? ''}",style: AppStyles.greyContent(context).copyWith(fontWeight: FontWeight.w500, fontSize: 11.sp)),
                Text("${AppStrings.department.tr()} : ${department ?? ''}",style: AppStyles.greyContent(context).copyWith(fontWeight: FontWeight.w500, fontSize: 11.sp)),
                Text("${AppStrings.createdAt.tr()} : ${createAt ?? ''}",style: AppStyles.greyContent(context).copyWith(fontWeight: FontWeight.w500, fontSize: 11.sp)),
              ],
            ),
            SizedBox(width: 12.w),
            if(isViewArrow == true) const Spacer(),
            if(isViewArrow == true) CircleAvatar(
              backgroundColor: Color(AppColors.buttonSecondary),
              radius: 12.r,
              child: Icon(Icons.arrow_forward_sharp,color: Colors.white, size: 10.sp,),
            )
          ],
        ),
      ),
    );
  }
}
class ProfileTilePay extends StatelessWidget {
  final String title;
  final String? empName;
  final String? name;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  var url;
  var createAt;
  final double? marginBottom;
  ProfileTilePay({
    super.key,
    this.empName,
    this.name,
    this.icon,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()async{
        if(url != null){
          await launchUrl(Uri.parse(url));
        }
      }
      ,
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom?.h ?? AppSizes.s12.h),
        padding: EdgeInsets.symmetric(
            vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              )
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.05))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon ?? const SizedBox.shrink(),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                Text("${AppStrings.employeeName.tr()} : ${empName ?? ''}",style: AppStyles.greyContent(context).copyWith(fontWeight: FontWeight.w500, fontSize: 11.sp)),
                Text("${AppStrings.createdAt.tr()} : ${createAt ?? ''}",style: AppStyles.greyContent(context).copyWith(fontWeight: FontWeight.w500, fontSize: 11.sp)),
              ],
            ),
            SizedBox(width: 12.w),
            if(isViewArrow == true) const Spacer(),
            if(isViewArrow == true) CircleAvatar(
              backgroundColor: Color(AppColors.buttonSecondary),
              radius: 12.r,
              child: Icon(Icons.arrow_forward_sharp,color: Colors.white, size: 10.sp,),
            )
          ],
        ),
      ),
    );
  }
}
