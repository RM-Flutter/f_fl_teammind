import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/filter_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/widgets/widget/view/managment_widget.dart';
import 'package:app_test/features/requests/details/views/widgets/management_response_widget.dart';
import 'package:app_test/features/approvables_details/views/widgets/overlapping_vacations_sheet.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

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
        (reqType == GetRequestsTypes.myTeam || reqType == GetRequestsTypes.otherDepartment || reqType == GetRequestsTypes.allCompany) &&
            (request.status == 'waiting_seen' || request.status == 'waiting_cancel' || request.status == 'waiting') &&
            request.id != null &&
            (userSettings?.empId != null && request.employeeId != null && userSettings!.empId != request.employeeId);

    final bool showTakeActionBadge = (request.takeAction == true) ||
        (request.canTakeActionAsSomeoneElse == true);

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.s16),
      padding: EdgeInsets.symmetric(
          vertical: AppSizes.s14, horizontal: AppSizes.s16),
      decoration: ShapeDecoration(
        color: Color(AppColors.cardBackground),
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
                  if (showTakeActionBadge) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFEF5350).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 13,
                            color: Color(0xFFD32F2F),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            LocalizationService.isArabic(context: context)
                                ? "مطلوب اتخاذ إجراء"
                                : "Take Action",
                            style: const TextStyle(
                              color: Color(0xFFD32F2F),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  AutoSizeText(
                    AppSettingsService.getRequestTitleFromGenenralSettings(
                        context: context,
                        requestId: request.typeId != null ? request.typeId?.toString() : "") ??
                        '',
                    style: AppStyles.titleTextContent(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.s16,
                      letterSpacing: 0.75,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Opacity(
                    opacity: 0.5,
                    child: AutoSizeText(
                      (request.duration == 0)
                          ? '${DateService.formatDate(LocalizationService.isArabic(context: context) ? "ar" : "en", context, request.from)}'
                          : (DateFormat('yyyy-MM-dd').format(DateTime.parse(request.from)) == DateFormat('yyyy-MM-dd').format(DateTime.parse(request.to)))
                          ? '${DateService.formatDate(LocalizationService.isArabic(context: context) ? "ar" : "en", context, request.from)} (${request.duration} ${request.durationType.toString().tr()})'
                          : '${DateService.formatDate(LocalizationService.isArabic(context: context) ? "ar" : "en", context, request.from)} : ${DateService.formatDate(LocalizationService.isArabic(context: context) ? "ar" : "en", context, request.to)} (${request.duration} ${request.durationType.toString().tr()})',
                      style: AppStyles.titleTextContent(context).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: AppSizes.s12,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (reqType == GetRequestsTypes.myTeam || reqType == GetRequestsTypes.otherDepartment || reqType == GetRequestsTypes.allCompany) SizedBox(height: 4),
                  if (reqType == GetRequestsTypes.myTeam || reqType == GetRequestsTypes.otherDepartment || reqType == GetRequestsTypes.allCompany)
                    Text(
                      "${request.employeeName ?? ""} - ${request.departmentName ?? ""}",
                      style: AppStyles.titleTextContent(context).copyWith(
                        fontWeight: FontWeight.w600, 
                        fontSize: 12
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.s8),
            // Overlapping Vacations Icon for Managers
            if ((reqType == GetRequestsTypes.myTeam || reqType == GetRequestsTypes.otherDepartment || reqType == GetRequestsTypes.allCompany) &&
                request.id != null &&
                ((request.approvableType?.toString().toLowerCase().contains('vacation') == true) ||
                 (request.approvableType?.toString().toLowerCase().contains('employeerequest') == true) ||
                 (request.typeName?.toString().toLowerCase().contains('vacation') == true) ||
                 (request.typeName?.toString().toLowerCase().contains('إجازة') == true))) ...[
              InkWell(
                onTap: () {
                  showOverlappingVacationsSheet(
                    context: context,
                    approvableId: request.id.toString(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(AppColors.warningYellow).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_alt_rounded, color: Color(AppColors.warningYellow), size: 20),
                ),
              ),
              SizedBox(width: 8),
            ],
            RequestsServices.getRequestsStatusIcon(
                context: context, status: request.status),
          ],
        ),
      ),
    );
  }
}