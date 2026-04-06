import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import '../../../../core/widgets/app_bar_with_bookmark.widget.dart';
import '../../controller/complaints_controller.dart';

class ComplainScreen extends StatefulWidget {
 const ComplainScreen({super.key});

 @override
 State<ComplainScreen> createState() => _ComplainScreenState();
}

class _ComplainScreenState extends State<ComplainScreen> {
 final ScrollController _scrollController = ScrollController();
 late ComplaintsController requestController;

 @override
 void initState() {
  super.initState();
  requestController = ComplaintsController();
  WidgetsBinding.instance.addPostFrameCallback((_) {
   requestController = Provider.of<ComplaintsController>(context, listen: false);
   requestController.getRequest(context, page: 1,);
   requestController.getRequestMine(context, page: 1,);
  });
  _scrollController.addListener(() {
   print("Current scroll position: ${_scrollController.position.pixels}");
   print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

   if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
     !requestController.isGetRequestLoading &&
     requestController.hasMoreRequests) {
    print("BOTTOM BOTTOM");
    requestController.getRequest(context, page: requestController.currentPage);
   }
  });

 }

 @override
 Widget build(BuildContext context) {
  return Consumer<ComplaintsController>(
   builder: (context, value, child) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
     gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
     UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return Scaffold(
     backgroundColor: Colors.white,
     appBar: AppBarWithBookmark(
      title: AppStrings.ticketSystem.tr().toUpperCase(),
      titleStyle: AppStyles.darkHeading(context).copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold),
      centerTitle: true,
      backgroundColor: Color(AppColors.white),
      elevation: 0,
      routeName: AppRoutes.complainScreen.name),
     floatingActionButton: FloatingActionButton(
      heroTag: 'complains_new',
      onPressed: ()async {
       await context.pushNamed(AppRoutes.newComplainScreen.name,
         pathParameters: {'lang': context.locale.languageCode,});
       await value.getRequest(context, page: 1);
       await value.getRequestMine(context, page: 1);
      },
      backgroundColor: Color(AppColors.primary),
      child: const Icon(Icons.add, color: Colors.white)),
     body: (value.isGetRequestLoading == true && value.currentPage == 1)
       ? ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: false,
      itemCount: 7,
      itemBuilder:(context, index) => Shimmer.fromColors(
       baseColor: Colors.grey[300]!,
       highlightColor: Colors.grey[100]!,
       child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSizes.s12.h,),
        padding: EdgeInsetsDirectional.symmetric(horizontal: AppSizes.s15.w, vertical: AppSizes.s12.h,),
        decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(AppSizes.s15.r),
        ),
        height: 100,
       ),
      )):
     SafeArea(
      child: (value.requests.isNotEmpty || value.requestsTeam.isNotEmpty)? Container(
       height: MediaQuery.sizeOf(context).height * 1,
       alignment: Alignment.topCenter,
       child: Center(
        child: ConstrainedBox(
         constraints: const BoxConstraints(
           maxWidth: kIsWeb ? 1100 : double.infinity
         ),
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: RefreshIndicator.adaptive(
           onRefresh: ()async{
            await value.getRequest(context, page: 1);
            await value.getRequestMine(context, page: 1);
           },
           child: Container(
            height: MediaQuery.sizeOf(context).height * 1,
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               const SizedBox(height: 15,),
               ListView.builder(
                itemCount: value.requests.length,
                reverse: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                 var request = value.requests[index];
                 var statusKey = request['pstatus'];
                 if (statusKey == "hold") {
                  return defaultRequestContainer(
                    "mine",
                    id: request['id'],
                    title: request['subject'],
                    containerColor: Color(AppColors.primary),
                    date: DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                      .format(DateTime.parse(request['created_at'].toString()))
                      .toString(),
                    status: request['pstatus'].toString().tr(),
                    statusColor: Color(AppColors.white)
                  );
                 }else{
                  return defaultRequestContainer(
                    "mine",
                    id: request['id'],
                    containerColor: Color(AppColors.white),
                    title: request['subject'],
                    date: DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                      .format(DateTime.parse(request['created_at'].toString()))
                      .toString(),
                    status: request['pstatus'].toString().tr(),
                    titleColor: Color(AppColors.primary),
                    dateColor: Color(AppColors.darkGrey),
                    statusColor: statusKey == "closed"
                      ? const Color(AppColors.red)
                      : Color(AppColors.primary)
                  );
                 }
                 return const SizedBox.shrink(); // Return nothing for non-hold items in this section
                },
               ),
               // "Other Requests" Text
               if(value.requestsTeam.isNotEmpty && (gCache['is_hr'] == true || gCache['top_management'] == true)) Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                 AppStrings.otherRequests.tr().toUpperCase(),
                 style: AppStyles.blackContent(context).copyWith(fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(AppColors.dark))),
               ),
               if(value.requestsTeam.isNotEmpty && (gCache['is_hr'] == true || gCache['top_management'] == true)) ListView.builder(
                itemCount: value.requestsTeam.length,
                reverse: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                 var request = value.requestsTeam[index];
                 var statusKey = request['pstatus'];
                 return defaultRequestContainer(
                   "myTeam",
                   id: request['id'],
                   containerColor: Color(AppColors.white),
                   title: request['subject'],
                   date: DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                     .format(DateTime.parse(request['created_at'].toString()))
                     .toString(),
                   status: request['pstatus'].toString().tr(),
                   titleColor: Color(AppColors.primary),
                   dateColor: Color(AppColors.darkGrey),
                   statusColor: statusKey == "closed"
                     ? const Color(AppColors.red)
                     : Color(AppColors.primary)
                 );
                },
               ),

              ],
             ),
            ),
           ),
          ),
         ),
        ),
       ),
      ) : Center(
       child: NoExistingPlaceholderScreen(
         height: LayoutService.getHeight(context) * 0.6,
         title: AppStrings.thereIsNoComplains.tr()),
      ),
     ),
    );
   } ,
  );
 }
 defaultRequestContainer(type,{title, containerColor, statusColor, status, date, titleColor, dateColor , id})=>
   GestureDetector(
    onTap: ()async{
     await context.pushNamed(AppRoutes.complainDetails.name,
       pathParameters: {'lang': context.locale.languageCode,
        'id' : "${id}",
        'type' : "$type"
       });
    },
    child: Container(
     padding: const EdgeInsets.all(12),
     margin: const EdgeInsets.only(bottom: 16),

     decoration: BoxDecoration(
      boxShadow:  const [
       BoxShadow(
        blurRadius: AppSizes.s8,
        spreadRadius: 1,
       )
      ],
      color: containerColor,
      borderRadius: BorderRadius.circular(12),
     ),
     child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Text(
        "$title".toUpperCase(),
        style: AppStyles.content(context).copyWith(fontSize: 14.sp,
         fontWeight: FontWeight.w500,
         color: titleColor??Color(AppColors.white))),
       const SizedBox(height: 8),
       Row(
        children: [
         Icon(Icons.circle, color: statusColor, size: 10),
         const SizedBox(width: 6),
         Text(
          "$status".toUpperCase(),
          style: AppStyles.content(context).copyWith(fontSize: 12.sp,
           fontWeight: FontWeight.w500,
           color: titleColor??Color(AppColors.white))),
         const SizedBox(width: 30,),
         Text(
          "$date".toUpperCase(),
          style: AppStyles.content(context).copyWith(color: dateColor??Color(AppColors.grey50), fontWeight: FontWeight.w500, fontSize: 12.sp)),
        ],
       ),
      ],
     ),
    ),
   );

}