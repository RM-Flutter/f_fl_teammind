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
      titleStyle: AppStyles.heading(context).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
      centerTitle: true,
      backgroundColor: Color(AppColors.background),
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
      backgroundColor: Color(AppColors.buttons),
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
        margin: EdgeInsets.symmetric(vertical: AppSizes.s12,),
        padding: EdgeInsetsDirectional.symmetric(horizontal: AppSizes.s15, vertical: AppSizes.s12,),
        decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(AppSizes.s15),
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
                 return defaultRequestContainer(
                    "mine",
                    id: request['id'],
                    containerColor: Colors.white,
                    title: request['subject'],
                    date: DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                      .format(DateTime.parse(request['created_at'].toString())),
                    status: request['pstatus'].toString().tr(),
                    statusColor: Colors.transparent, // Handled internally
                  );
                },
               ),
               // "Other Requests" Text
               if(value.requestsTeam.isNotEmpty && (gCache['is_hr'] == true || gCache['top_management'] == true)) Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                 AppStrings.otherRequests.tr().toUpperCase(),
                 style: AppStyles.blackContent(context).copyWith(fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(AppColors.secondaryButton))),
               ),
               if(value.requestsTeam.isNotEmpty && (gCache['is_hr'] == true || gCache['top_management'] == true)) ListView.builder(
                itemCount: value.requestsTeam.length,
                reverse: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                 var request = value.requestsTeam[index];
                 return defaultRequestContainer(
                    "myTeam",
                    id: request['id'],
                    containerColor: Colors.white,
                    title: request['subject'],
                    date: DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                      .format(DateTime.parse(request['created_at'].toString())),
                    status: request['pstatus'].toString().tr(),
                    statusColor: Colors.transparent, // Handled internally
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
  Widget defaultRequestContainer(String type, {
    required dynamic title,
    required Color containerColor,
    required Color statusColor,
    required String status,
    required String date,
    Color? titleColor,
    Color? dateColor,
    required dynamic id,
  }) {
    IconData statusIcon;
    Color iconColor;

    // Map status to icons and colors
    switch (status.toLowerCase()) {
      case 'hold':
      case 'معلق':
        statusIcon = Icons.pause_circle_filled_rounded;
        iconColor = Colors.orange;
        break;
      case 'closed':
      case 'مغلق':
        statusIcon = Icons.cancel_rounded;
        iconColor = Colors.red;
        break;
      case 'open':
      case 'مفتوح':
        statusIcon = Icons.info_outline_rounded;
        iconColor = Color(AppColors.buttons);
        break;
      default:
        statusIcon = Icons.info_outline_rounded;
        iconColor = Color(AppColors.buttons);
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.s16),
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.s14,
        horizontal: AppSizes.s16,
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Color(AppColors.disableButton).withOpacity(0.5),
            blurRadius: AppSizes.s5,
            spreadRadius: 1,
          )
        ],
      ),
      child: InkWell(
        onTap: () async {
          await context.pushNamed(
            AppRoutes.complainDetails.name,
            pathParameters: {
              'lang': context.locale.languageCode,
              'id': "$id",
              'type': type
            },
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$title",
                    style: AppStyles.blackContent(context).copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: AppSizes.s16,
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        status,
                        style: AppStyles.greyContent(context).copyWith(
                          fontSize: 12,
                          color: iconColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("|", style: TextStyle(color: Colors.grey.withOpacity(0.3))),
                      ),
                      Opacity(
                        opacity: 0.7,
                        child: Text(
                          date,
                          style: AppStyles.greyContent(context).copyWith(
                            color: Color(AppColors.divider),
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.s8),
            Icon(
              statusIcon,
              color: iconColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

}