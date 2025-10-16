import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/modules/requests/view_models/filter_consts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../general_services/date.service.dart';
import '../general_services/settings.service.dart';
import '../models/request.model.dart';
import '../models/settings/user_settings.model.dart';
import '../routing/app_router.dart';
import '../services/requests.services.dart';

class RequestCard extends StatelessWidget {
  final request;
  final GetRequestsTypes? reqType;

  const RequestCard({
    required this.request,
    this.reqType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    FilterConsts.reqUsers.clear();
    FilterConsts.reqUsers.add({"employee": request.employeeName.toString()});
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s16),
      padding: const EdgeInsets.symmetric(
          vertical: AppSizes.s14, horizontal: AppSizes.s16),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Color(0xffC9CFD2).withOpacity(0.5),
            blurRadius: AppSizes.s5,
            spreadRadius: 1,
          )
        ],
      ),
      child: InkWell(
        onTap: () async => reqType == null
            ? await context.pushNamed(AppRoutes.requestDetails.name,
                extra: request ?? [],
                pathParameters: {'lang': context.locale.languageCode,
                  'id' : request!.id.toString(),
                  'type': reqType != null? reqType!.name : "me",})
            : await context.pushNamed(AppRoutes.requestDetails.name,
                extra: request,
                pathParameters: {
                    'type': reqType!.name,
                    'id' : request!.id.toString(),
                    'lang': context.locale.languageCode
                  }),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  AppSettingsService.getRequestTitleFromGenenralSettings(
                          context: context,
                          requestId: request.typeId != null ?request.typeId?.toString() : "") ??
                      '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppSizes.s16,
                    letterSpacing: 0.75,
                    color: Color(AppColors.c3),
                    height: 1.1,
                  ),
                ),
                gapH4,
                Opacity(
                  opacity: 0.5,
                  child: AutoSizeText(
                      (request.duration == 0)?
                      '${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,request.from)}' : (DateFormat('yyyy-MM-dd').format(DateTime.parse(request.from))  == DateFormat('yyyy-MM-dd').format(DateTime.parse(request.to)))?
                      '${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,request.from)} (${request.duration} ${request.durationType.toString().tr()})':
                      '${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,request.from)} : ${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,request.to)} (${request.duration} ${request.durationType.toString().tr()})' ,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppSizes.s12,
                      letterSpacing: 0.5,
                      color: Color(0xFF3B3B3B),
                    ),
                  ),
                ),
                if(reqType == GetRequestsTypes.myTeam ||reqType == GetRequestsTypes.otherDepartment) gapH4,
               if(reqType == GetRequestsTypes.myTeam||reqType == GetRequestsTypes.otherDepartment) Text("${request.employeeName ?? ""} - ${request.departmentName ?? ""}", style: const TextStyle(color: Color(0xff707070), fontWeight: FontWeight.w600,fontSize: 12),)
              ],
            ),
            const Spacer(),
            RequestsServices.getRequestsStatusIcon(
                context: context, status: request.status),
          ],
        ),
      ),
    );
  }
}
