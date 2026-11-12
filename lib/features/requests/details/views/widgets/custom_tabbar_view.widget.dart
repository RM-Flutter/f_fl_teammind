import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'dart:convert';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/tracking/views/widgets/tracking_section_employee.dart';
import 'package:app_test/features/tracking/views/widgets/tracking_section_manager.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/services/localization_service.dart';
import 'package:app_test/core/constants/app_design.dart';

class CustomTabbarViewRequestDetails extends StatelessWidget {
  final request;
  const CustomTabbarViewRequestDetails({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final mainTextStyle = AppStyles.heading(context).copyWith(
        fontSize: 10.5, 
        fontWeight: FontWeight.bold
    );
    var jsonString = CacheHelper.getString("US1");
    UserSettingsModel? userSettings;
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final gCache = json.decode(jsonString) as Map<String, dynamic>;
        userSettings = UserSettingsModel.fromJson(gCache);
      } catch (_) {}
    }
    final bool isMyRequest = userSettings?.empId != null &&
        request.employeeId != null &&
        userSettings!.empId == request.employeeId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s12),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              width: double.infinity, // full-width bar, even when the tabs are fewer
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryButton),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s6),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s2),
                // Scrollable like the profile details tabs: each tab takes the width its
                // label needs (no "Manager Resp..."), starting from the start side, and the
                // bar scrolls sideways when the tabs do not fit.
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                indicator: BoxDecoration(
                  color: Color(AppColors.buttons),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                labelColor: Colors.white,
                labelStyle: mainTextStyle,
                unselectedLabelStyle: mainTextStyle,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.reason.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.managerResponse.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.information.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('tracking'.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.s8, vertical: AppSizes.s8),
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.only(top: AppSizes.s20, bottom: AppSizes.s20),
                        child: Text(
                          request.reason ?? '',
                          textAlign: TextAlign.center,
                          style: AppStyles.darkContent(context).copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: AppSizes.s20),
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
                                    style: AppStyles.darkContent(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 15,),
                                  Text(
                                    "${request.managerReply[index].replay ?? ""}",
                                    textAlign: TextAlign.center,
                                    style: AppStyles.darkContent(context).copyWith(fontSize: 12, fontWeight: FontWeight.w400),

                                  ),
                                ],
                              ), separatorBuilder: (context, index) => SizedBox(height: AppSizes.s20, child: const Divider(),),
                              itemCount: request.managerReply.length),
                        ):  Center(
                          child: Text(AppStrings.thereIsStillNoResponseFromTheManager.tr(),
                            style: AppStyles.darkContent(context).copyWith(
                                fontWeight: FontWeight.w400, fontSize: 12
                            ),
                          ),
                        )
                    ),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: AppSizes.s25,),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: AppSizes.s16),
                            padding:  EdgeInsets.symmetric(vertical: AppSizes.s12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${AppStrings.createdOn.tr()} : ",
                                  style: AppStyles.darkContent(context).copyWith(
                                      fontWeight: FontWeight.w400, fontSize: 12
                                  ),
                                ),
                                Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.createdAt.toString())),
                                  style:  AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold, fontSize: 13
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSizes.s12,),
                          if(request.seenAt != null && request.seenAt != "") Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: AppSizes.s16),
                            padding: EdgeInsets.symmetric(vertical: AppSizes.s12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${AppStrings.seenOn.tr()} : ",style: AppStyles.darkContent(context).copyWith(
                                    fontWeight: FontWeight.w400, fontSize: 12
                                ),),
                                Text(DateFormat('d-M-y | hh:mm a', LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.seenAt.toString())),
                                  style:  AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold, fontSize: 13
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSizes.s12,),
                          if(request.statusUpdate != null && request.statusUpdate != "") Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: AppSizes.s16),
                            padding: EdgeInsets.symmetric(vertical: AppSizes.s12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${AppStrings.statusUpdate.tr()} : ",style: AppStyles.darkContent(context).copyWith(
                                    fontWeight: FontWeight.w400, fontSize: 12
                                ),),
                                Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.statusUpdate.toString())),
                                  style:  AppStyles.primaryContent(context).copyWith(
                                      fontWeight: FontWeight.bold, fontSize: 13
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if(request.seenBy != null && request.seenBy.isNotEmpty) SizedBox(height: AppSizes.s25,),
                          if(request.seenBy != null && request.seenBy.isNotEmpty)Text(AppStrings.seenBy.tr(),style: AppStyles.darkContent(context).copyWith(
                              fontWeight: FontWeight.w400, fontSize: 12
                          ),),
                          if(request.seenBy != null && request.seenBy.isNotEmpty) SizedBox(height: 15,),
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
                                      fontWeight: FontWeight.w400, fontSize: 12
                                  ),),
                                  Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.seenBy[index].date.toString())),
                                    style: AppStyles.darkContent(context).copyWith(
                                        fontWeight: FontWeight.w400, fontSize: 12
                                    ),
                                  ),
                                ],
                              ), separatorBuilder: (context, index) => SizedBox(height: 15,),
                              itemCount: request.seenBy.length)
                        ],
                      ),
                    ),
                    // Tab 4: Tracking
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSizes.s8, bottom: AppSizes.s20),
                        child: isMyRequest
                            ? TrackingSectionEmployee(request: request)
                            : TrackingSectionManager(request: request),
                      ),
                    ),
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