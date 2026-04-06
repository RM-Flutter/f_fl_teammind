import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/localization_service.dart';

import '../../../../../core/constants/app_strings.dart';


class CustomTabbarViewRequestDetails extends StatelessWidget {
  final request;
  const CustomTabbarViewRequestDetails({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final mainTextStyle = AppStyles.heading(context).copyWith(
        fontSize: 10.5.sp, 
        fontWeight: FontWeight.bold
    );
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 8.w, vertical: 12.h),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(AppColors.dark),
                borderRadius: BorderRadius.circular(30.r),
              ),
              height: 52.h,
              padding: EdgeInsets.symmetric(
                  horizontal: 8.w, vertical: 6.h),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 4.w),
                labelPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  color: const Color(0xFF3489EF),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                labelColor: Colors.white,
                labelStyle: mainTextStyle,
                unselectedLabelStyle: mainTextStyle,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Container(
                      margin: EdgeInsets.zero,
                      child:  Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            AppStrings.reason.tr().toUpperCase(),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.zero,
                    child: Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.managerResponse.tr().toUpperCase(),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.zero,
                      child: Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            AppStrings.information.tr().toUpperCase(),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 8.h),
                child: TabBarView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Text(
                        request.reason ?? '',
                        textAlign: TextAlign.center,
                        style: AppStyles.darkContent(context).copyWith(fontSize: 14.sp),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child:request.managerReply.isNotEmpty ? Container(
                          height: 0.4.sh,
                          child: ListView.separated(
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, index) => Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${request.managerReply[index].jobTitle ?? ""} : ${request.managerReply[index].name.toString()} (${request.managerReply[index].createAt.toString()})",
                                    textAlign: TextAlign.center,
                                    style: AppStyles.darkContent(context).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 15.h,),
                                  Text(
                                    "${request.managerReply[index].replay ?? ""}",
                                    textAlign: TextAlign.center,
                                    style: AppStyles.darkContent(context).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w400),

                                  ),
                                ],
                              ), separatorBuilder: (context, index) => SizedBox(height: 20.h, child: const Divider(),),
                              itemCount: request.managerReply.length),
                        ):  Center(
                          child: Text(AppStrings.thereIsStillNoResponseFromTheManager.tr(),
                            style: AppStyles.darkContent(context).copyWith(
                                fontWeight: FontWeight.w400, fontSize: 12.sp
                            ),
                          ),
                        )
                    ),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 25.h,),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding:  EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${AppStrings.createdOn.tr()} : ",
                                  style: AppStyles.darkContent(context).copyWith(
                                      fontWeight: FontWeight.w400, fontSize: 12.sp
                                  ),
                                ),
                                Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.createdAt.toString())),
                                  style:  AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold, fontSize: 13.sp
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h,),
                          if(request.seenAt != null && request.seenAt != "") Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${AppStrings.seenOn.tr()} : ",style: AppStyles.darkContent(context).copyWith(
                                    fontWeight: FontWeight.w400, fontSize: 12.sp
                                ),),
                                Text(DateFormat('d-M-y | hh:mm a', LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.seenAt.toString())),
                                  style:  AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold, fontSize: 13.sp
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h,),
                          if(request.statusUpdate != null && request.statusUpdate != "") Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${AppStrings.statusUpdate.tr()} : ",style: AppStyles.darkContent(context).copyWith(
                                    fontWeight: FontWeight.w400, fontSize: 12.sp
                                ),),
                                Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.statusUpdate.toString())),
                                  style:  AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold, fontSize: 13.sp
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if(request.seenBy != null && request.seenBy.isNotEmpty) SizedBox(height: 25.h,),
                          if(request.seenBy != null && request.seenBy.isNotEmpty)Text(AppStrings.seenBy.tr(),style: AppStyles.darkContent(context).copyWith(
                              fontWeight: FontWeight.w400, fontSize: 12.sp
                          ),),
                          if(request.seenBy != null && request.seenBy.isNotEmpty) SizedBox(height: 15.h,),
                          if(request.seenBy != null && request.seenBy.isNotEmpty)ListView.separated(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              reverse: false,
                              itemBuilder: (context, index) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(request.seenBy[index].managerName ?? "",style: AppStyles.darkContent(context).copyWith(
                                      fontWeight: FontWeight.w400, fontSize: 12.sp
                                  ),),
                                  Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.seenBy[index].date.toString())),
                                    style: AppStyles.darkContent(context).copyWith(
                                        fontWeight: FontWeight.w400, fontSize: 12.sp
                                    ),
                                  ),
                                ],
                              ), separatorBuilder: (context, index) => SizedBox(height: 15.h,),
                              itemCount: request.seenBy.length)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}