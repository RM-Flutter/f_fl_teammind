import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import '../../controller/customer_service_controller.dart';

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({super.key});

  @override
  State<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  final ScrollController _scrollController = ScrollController();
  late CustomerRequestController requestController;

  @override
  void initState() {
    super.initState();
    requestController = CustomerRequestController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestController = Provider.of<CustomerRequestController>(context, listen: false);
      // requestController.getRequestMine(context, page: 1,);
      requestController.getRequest(context, page: 1,);
    });
    _scrollController.addListener(() {
      print("Current scroll position: ${_scrollController.position.pixels}");
      print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !requestController.isGetRequestLoading && requestController.getMore == true) {
        print("BOTTOM BOTTOM");
        requestController.getRequest(context, page: requestController.currentPage);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerRequestController>(
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
          appBar: AppBar(
            title: Text(
              AppStrings.requests.tr().toUpperCase(),
              style:  TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: true,
            backgroundColor: Color(0xffFFFFFF),
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async{
              await context.pushNamed(AppRoutes.newCusomterService.name,
                  pathParameters: {'lang': context.locale.languageCode,
                    "type" : "no",
                    "details" : "no",
                    "subject" : "no",
                  });
              await requestController.getRequest(context, page: 1, );
            },
            backgroundColor:  Color(AppColors.primary),
            child: const Icon(Icons.add, color: Colors.white),
          ),
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
                margin: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSizes.s15, vertical: AppSizes.s12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.s15),
                ),
                height: 100,
              ),
            ), ):
          GradientBgImage(
            padding: EdgeInsets.all(0),
            child: SafeArea(
              child: RefreshIndicator.adaptive(
                onRefresh: ()async{
                  await requestController.getRequest(context, page: 1, );
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: (value.requests.isNotEmpty)? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: kIsWeb ? 1100 : double.infinity,
                            ),
                            child: ListView.builder(
                              itemCount: value.requests.length,
                              reverse: false,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                var request = value.requests[index];
                                var statusKey = request['pstatus']['key'];
                                if (statusKey == "hold") {
                                  return defaultRequestContainer(
                                      context,
                                      "mine",
                                      id: request['id'],
                                      title: request['title'],
                                      containerColor: Color(AppColors.primary),
                                      date: DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                                          .format(DateTime.parse(request['created_at'].toString()))
                                          .toString(),
                                      status: request['pstatus']['key'].toString().tr(),
                                      statusColor: Color(0xffFFFFFF)
                                  );
                                }else{
                                  return defaultRequestContainer(
                                      context,
                                      "mine",
                                      id: request['id'],
                                      containerColor: Color(0xffFFFFFF),
                                      title: request['title'],
                                      date: DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                                          .format(DateTime.parse(request['created_at'].toString()))
                                          .toString(),
                                      status: request['pstatus']['key'].toString().tr(),
                                      titleColor: Color(AppColors.primary),
                                      dateColor: Color(0xff5E5E5E),
                                      statusColor: statusKey == "closed"
                                          ? Color(AppColors.red)
                                          : Color(AppColors.primary)
                                  );
                                }
// Return nothing for non-hold items in this section
                              },
                            ),
                          ),
                        ),
                        if(value.isGetRequestLoading == true && value.currentPage != 1)   const SizedBox(height: 15,),
                        if(value.isGetRequestLoading == true && value.currentPage != 1)   const Center( child: CircularProgressIndicator(),),
                        const SizedBox(height: 10,),
                      ],
                    ),
                  ) : Center(
                    child: NoExistingPlaceholderScreen(
                        height: LayoutService.getHeight(context) * 0.6,
                        title: AppStrings.thereIsNoRequests.tr()),
                  ),
                ),
              ),
            ),
          ),
        );
      } ,
    );
  }

  Widget defaultRequestContainer(BuildContext parentContext,type,{title, containerColor, statusColor, status, date, titleColor, dateColor , id})=>
      GestureDetector(
        onTap: (){
          parentContext.pushNamed(AppRoutes.customerServiceDetailsScreen.name,
              pathParameters: {'lang': parentContext.locale.languageCode,
                'id' : "${id}",
              });

        },
        child: Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 16),

          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor??Color(0xffFFFFFF),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.circle, color: statusColor, size: 10),
                  SizedBox(width: 6),
                  Text(
                    "$status".toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: titleColor??Color(0xffFFFFFF),
                    ),
                  ),
                  SizedBox(width: 30,),
                  Text(
                    "$date".toUpperCase(),
                    style: TextStyle(color: dateColor??Color(AppColors.grey50), fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
