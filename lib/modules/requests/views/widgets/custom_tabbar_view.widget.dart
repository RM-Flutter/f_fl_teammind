import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../models/request.model.dart';

class CustomTabbarViewRequestDetails extends StatelessWidget {
  final request;
  const CustomTabbarViewRequestDetails({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    print("SEEN IN ---> ${request.seenAt}");
    final mainTextStyle = Theme.of(context)
        .textTheme
        .headlineSmall
        ?.copyWith(fontSize: AppSizes.s10);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s8, vertical: AppSizes.s12),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(AppColors.dark),
                borderRadius: BorderRadius.circular(AppSizes.s30),
              ),
              height: AppSizes.s64,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.s6, vertical: AppSizes.s6),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(AppColors.primary),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                labelColor: Colors.white,
                labelStyle: mainTextStyle,
                unselectedLabelStyle: mainTextStyle,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: AppSizes.s6),
                      child:  Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                             AppStrings.reason.tr().toUpperCase(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      )),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSizes.s6),
                    child: Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.managerResponse.tr().toUpperCase(),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: AppSizes.s6),
                      child: Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.information.tr().toUpperCase(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.s8, vertical: AppSizes.s8),
                child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        request.reason ?? '',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child:request.managerReply.isNotEmpty ? Container(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        child: ListView.separated(
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${request.managerReply[index].jobTitle ?? ""} : ${request.managerReply[index].name.toString()} (${request.managerReply[index].createAt.toString()})",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                                const SizedBox(height: 15,),
                                Text(
                                  "${request.managerReply[index].replay ?? ""}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),

                                ),
                              ],
                            ), separatorBuilder: (context, index) => const SizedBox(height: 20, child: Divider(),),
                            itemCount: request.managerReply.length),
                      ):  Center(
                        child: Text(AppStrings.thereIsStillNoResponseFromTheManager.tr(),
                          style: const TextStyle(
                              color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                          ),
                        ),
                      )
                    ),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 25,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${AppStrings.createdOn.tr()} : ",
                              style: const TextStyle(
                                color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                              ),
                              ),
                              Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.createdAt.toString())),
                              style: const TextStyle(
                                color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                              ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 25,),
                          if(request.seenAt != null && request.seenAt != "")Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${AppStrings.seenOn.tr()} : ",style: const TextStyle(
                                  color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                              ),),
                              Text(DateFormat('d-M-y | hh:mm a', LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.seenAt.toString())),
                                style: const TextStyle(
                                    color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25,),
                          if(request.statusUpdate != null && request.statusUpdate != "")Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${AppStrings.statusUpdate.tr()} : ",style: const TextStyle(
                                  color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                              ),),
                              Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.statusUpdate.toString())),
                                style: const TextStyle(
                                    color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                                ),
                              ),
                            ],
                          ),
                          if(request.seenBy != null && request.seenBy.isNotEmpty) const SizedBox(height: 25,),
                          if(request.seenBy != null && request.seenBy.isNotEmpty)Text(AppStrings.seenBy.tr(),style: const TextStyle(
                              color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                          ),),
                          if(request.seenBy != null && request.seenBy.isNotEmpty) const SizedBox(height: 15,),
                          if(request.seenBy != null && request.seenBy.isNotEmpty)ListView.separated(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              reverse: false,
                              itemBuilder: (context, index) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(request.seenBy[index].managerName ?? "",style: const TextStyle(
                                      color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                                  ),),
                                  Text(DateFormat('d-M-y | hh:mm a',  LocalizationService.isArabic(context: context)? "ar": "en").format(DateTime.parse(request.seenBy[index].date.toString())),
                                    style: const TextStyle(
                                        color: Color(AppColors.c3),fontWeight: FontWeight.w400, fontSize: 12
                                    ),
                                  ),
                                ],
                              ), separatorBuilder: (context, index) => const SizedBox(height: 15,),
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
