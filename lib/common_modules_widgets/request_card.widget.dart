import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/modules/requests/view_models/filter_consts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../general_services/date.service.dart';
import '../general_services/layout.service.dart';
import '../general_services/settings.service.dart';
import '../routing/app_router.dart';
import '../services/requests.services.dart';
import '../utils/modal_sheet_helper.dart';
import 'package:rmemp/modules/requests/views/widgets/modals/management_response.modal.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'dart:convert';
import '../models/settings/user_settings.model.dart';

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
    
    // الحصول على معلومات المستخدم الحالي
    var jsonString = CacheHelper.getString("US1");
    var gCache;
    UserSettingsModel? userSettings;
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
      userSettings = UserSettingsModel.fromJson(gCache);
    }
    
    // التحقق من الصلاحيات لعرض Management Response Modal (نفس الشروط في request details)
    final bool canShowManagementResponse = 
        (reqType == GetRequestsTypes.myTeam || reqType == GetRequestsTypes.otherDepartment) &&
        (request.status == 'waiting_seen' || request.status == 'waiting_cancel' || request.status == 'waiting') &&
        request.id != null &&
        (userSettings?.empId != null && request.employeeId != null && userSettings!.empId != request.employeeId);
    
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
            color: Color(AppColors.lightGrey).withOpacity(0.5),
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
        onLongPress: canShowManagementResponse ? () async {
          // عرض نفس الـ bottom sheet الموجود في request details
          await ModalSheetHelper.showModalSheet(
            context: context,
            viewProfile: false,
            modalContent: ManagementResponseModal(
              requestId: request.id.toString(),
            ),
            title: AppStrings.managementResponse.tr(),
            height: LayoutService.getHeight(context) * 0.5,
          );
        } : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    AppSettingsService.getRequestTitleFromGenenralSettings(
                            context: context,
                            requestId: request.typeId != null ? request.typeId?.toString() : "") ??
                        '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppSizes.s16,
                      letterSpacing: 0.75,
                      color: Color(AppColors.black),
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  gapH4,
                  Opacity(
                    opacity: 0.5,
                    child: AutoSizeText(
                        (request.duration == 0)
                            ? '${DateService.formatDate(LocalizationService.isArabic(context: context) ? "ar" : "en", context, request.from)}'
                            : (DateFormat('yyyy-MM-dd').format(DateTime.parse(request.from)) == DateFormat('yyyy-MM-dd').format(DateTime.parse(request.to)))
                                ? '${DateService.formatDate(LocalizationService.isArabic(context: context) ? "ar" : "en", context, request.from)} (${request.duration} ${request.durationType.toString().tr()})'
                                : '${DateService.formatDate(LocalizationService.isArabic(context: context) ? "ar" : "en", context, request.from)} : ${DateService.formatDate(LocalizationService.isArabic(context: context) ? "ar" : "en", context, request.to)} (${request.duration} ${request.durationType.toString().tr()})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: AppSizes.s12,
                          letterSpacing: 0.5,
                          color: Color(AppColors.grey3B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ),
                  if (reqType == GetRequestsTypes.myTeam || reqType == GetRequestsTypes.otherDepartment) gapH4,
                  if (reqType == GetRequestsTypes.myTeam || reqType == GetRequestsTypes.otherDepartment)
                    Text(
                      "${request.employeeName ?? ""} - ${request.departmentName ?? ""}",
                      style: TextStyle(color: Color(AppColors.grey70), fontWeight: FontWeight.w600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.s8),
            RequestsServices.getRequestsStatusIcon(
                context: context, status: request.status),
          ],
        ),
      ),
    );
  }
}
