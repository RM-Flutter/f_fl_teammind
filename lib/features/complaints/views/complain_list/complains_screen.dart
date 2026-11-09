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
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import '../../../../core/widgets/app_bar_with_bookmark.widget.dart';
import '../../controller/complaints_controller.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:app_test/core/widgets/hide_on_scroll_fab.widget.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';

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
    return HideOnScrollFabHost(builder: (context, wrapFab) => Scaffold(
     backgroundColor: Colors.white,
     appBar: AppBarWithBookmark(
      title: AppStrings.ticketSystem.tr(),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      routeName: AppRoutes.complainScreen.name),
     floatingActionButton: wrapFab(FloatingActionButton(
      heroTag: 'complains_new',
      onPressed: ()async {
       await context.pushNamed(AppRoutes.newComplainScreen.name,
         pathParameters: {'lang': context.locale.languageCode,});
       await value.getRequest(context, page: 1);
       await value.getRequestMine(context, page: 1);
      },
      backgroundColor: Color(AppColors.buttons),
      child: const Icon(Icons.add, color: Colors.white))),
     body: (value.isGetRequestLoading == true && value.currentPage == 1)
       ? Center(
      child: ConstrainedBox(
       constraints: LayoutService.contentConstraints(context),
       child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.md),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        reverse: false,
        itemCount: 7,
        itemBuilder:(context, index) => const Padding(padding: EdgeInsets.only(bottom: AppSpacing.cardGap), child: AppShimmerCard())),
      )):
     SafeArea(
      child: (value.requests.isNotEmpty || value.requestsTeam.isNotEmpty)? Container(
       height: MediaQuery.sizeOf(context).height * 1,
       alignment: Alignment.topCenter,
       child: Center(
        child: ConstrainedBox(
         constraints: LayoutService.contentConstraints(context),
         child: RefreshIndicator.adaptive(
           onRefresh: ()async{
            await value.getRequest(context, page: 1);
            await value.getRequestMine(context, page: 1);
           },
           child: Container(
            height: MediaQuery.sizeOf(context).height * 1,
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               ListView.builder(
                itemCount: value.requests.length,
                reverse: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                 var request = value.requests[index];
                 final String? reqType = request['type']?.toString();
                 final String? relTo = request['related_to']?.toString();
                 final String? target = relTo == 'person'
                     ? (request['related_profile'] != null ? request['related_profile']['name']?.toString() : null)
                     : request['department_name']?.toString();

                 return defaultRequestContainer(
                    "mine",
                    id: request['id'],
                    containerColor: Colors.white,
                    title: request['subject'],
                    requestType: reqType,
                    relatedTo: relTo,
                    targetName: target,
                    date: DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                      .format(DateTime.parse(request['created_at'].toString())),
                    status: request['pstatus'].toString().tr(),
                    statusColor: Colors.transparent, // Handled internally
                  );
                },
               ),
               // "Other Requests" Text
               if(value.requestsTeam.isNotEmpty && (gCache['is_hr'] == true || gCache['top_management'] == true)) Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Text(
                 AppStrings.otherRequests.tr(),
                 style: AppStyles.blackContent(context).copyWith(fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(AppColors.secondaryButton))),
               ),
               if(value.requestsTeam.isNotEmpty && (gCache['is_hr'] == true || gCache['top_management'] == true)) ListView.builder(
                itemCount: value.requestsTeam.length,
                reverse: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                 var request = value.requestsTeam[index];
                 final String? reqType = request['type']?.toString();
                 final String? relTo = request['related_to']?.toString();
                 final String? target = relTo == 'person'
                     ? (request['related_profile'] != null ? request['related_profile']['name']?.toString() : null)
                     : request['department_name']?.toString();

                 return defaultRequestContainer(
                    "myTeam",
                    id: request['id'],
                    containerColor: Colors.white,
                    title: request['subject'],
                    requestType: reqType,
                    relatedTo: relTo,
                    targetName: target,
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
      ) : Center(
       child: NoExistingPlaceholderScreen(
         height: LayoutService.getHeight(context) * 0.6,
         title: AppStrings.thereIsNoComplains.tr()),
      ),
     ),
    ));
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
    String? requestType,
    String? relatedTo,
    String? targetName,
  }) {
    IconData statusIcon;
    Color iconColor;

    // Map status to icons and colors
    switch (status.toLowerCase()) {
      case 'hold':
      case 'معلق':
        statusIcon = Icons.pause_circle_outline_rounded;
        iconColor = const Color(0xFFE65100);
        break;
      case 'closed':
      case 'مغلق':
        statusIcon = Icons.cancel_outlined;
        iconColor = const Color(0xFFC62828);
        break;
      case 'open':
      case 'مفتوح':
      default:
        statusIcon = Icons.info_outline_rounded;
        iconColor = Color(AppColors.buttons);
    }

    IconData leadingIcon;
    String? typeLabel;
    switch (requestType?.toLowerCase()) {
      case 'suggestion':
        leadingIcon = Icons.lightbulb_outline;
        typeLabel = AppStrings.suggestion.tr();
        break;
      case 'other':
        leadingIcon = Icons.more_horiz;
        typeLabel = AppStrings.other.tr();
        break;
      case 'complaint':
        leadingIcon = Icons.report_problem_outlined;
        typeLabel = AppStrings.complaint.tr();
        break;
      default:
        leadingIcon = Icons.confirmation_number_outlined;
        typeLabel = null;
        break;
    }

    final subtitleParts = <String>[
      if (typeLabel != null && typeLabel.isNotEmpty) typeLabel,
      if (targetName != null && targetName.isNotEmpty) targetName,
      if (date.isNotEmpty) date,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: AppCard(
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
            AppCardLeadingAvatar(
              name: targetName,
              icon: leadingIcon,
              borderColor: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$title",
                    style: AppStyles.heading(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' · '),
                      style: AppStyles.subtitleContent(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(
              label: status,
              color: iconColor,
              icon: statusIcon,
            ),
          ],
        ),
      ),
    );
  }
}