import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/layout.service.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/get_one_request_model.dart';

import '../../../routing/app_router.dart';


class RequestDetailsAppbarWidget extends StatelessWidget {
  GetOneRequestModel? getOneRequestModel;
  RequestDetailsAppbarWidget({this.getOneRequestModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s220,
      clipBehavior: Clip.antiAlias,
      width: LayoutService.getWidth(context),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/png/home_back.png"),
            fit: BoxFit.fill,
            opacity: 0.4),
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s28),
            bottomRight: Radius.circular(AppSizes.s28)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop(); // هيرجع لورا
                          } else {
                            context.goNamed(AppRoutes.home.name,
                                pathParameters: {'lang': context.locale.languageCode,});
                          }
                        },
                        child: Icon(Icons.arrow_back, color: Color(0xffFFFFFF),)),
                    Spacer(),
                    Text(
                      AppStrings.myRequests.tr().toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Container(width: 20,),
                  ],
                ),
                SizedBox(height: 16,),
                Text(
                  getOneRequestModel!.complain!.subject!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      child: Text(
                       DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context)? "ar" : "en").format(DateTime.parse(getOneRequestModel!.complain!.createdAt.toString())).toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if(getOneRequestModel!.complain!.departmentName != null)  Row(
                      children: [
                        Icon(Icons.folder_open_outlined, color: Colors.white,),
                        SizedBox(width: 5,),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.25,
                          child: Text(
                              (getOneRequestModel!.complain!.departmentName != null)?
                              getOneRequestModel!.complain!.departmentName!.toUpperCase() : "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle
                          ),
                        ),
                        SizedBox(width: 5,),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.25,
                          child: Text(
                            getOneRequestModel!.complain!.pstatus!.tr().toUpperCase() ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16,),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
