import 'package:app_test/core/constants/app_sizes.dart';
import 'dart:convert';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
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
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:app_test/features/approvables_details/views/widgets/overlapping_vacations_sheet.dart';
import 'package:app_test/features/requests/details/views/widgets/management_response_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RequestCard extends StatelessWidget {
  final dynamic request;
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

    final jsonString = CacheHelper.getString("US1");
    UserSettingsModel? userSettings;
    if (jsonString != null && jsonString.isNotEmpty) {
      final gCache = json.decode(jsonString) as Map<String, dynamic>;
      userSettings = UserSettingsModel.fromJson(gCache);
    }

    final bool isForDepartment = reqType == GetRequestsTypes.myTeam ||
        reqType == GetRequestsTypes.otherDepartment ||
        reqType == GetRequestsTypes.allCompany;

    final bool canShowManagementResponse = isForDepartment &&
        (request.status == 'waiting_seen' ||
            request.status == 'waiting_cancel' ||
            request.status == 'waiting') &&
        request.id != null &&
        (userSettings?.empId != null &&
            request.employeeId != null &&
            userSettings!.empId != request.employeeId);

    final bool showTakeActionBadge = (request.takeAction == true) ||
        (request.canTakeActionAsSomeoneElse == true);

    final Color statusColor = AppStatusBadge.colorForStatus(
      showTakeActionBadge
          ? 'action_required'
          : (request.status?.toString() ?? '').toLowerCase(),
    );

    final String title =
        AppSettingsService.getRequestTitleFromGenenralSettings(
              context: context,
              requestId:
                  request.typeId != null ? request.typeId?.toString() : "",
              fallbackTitle: request.typeName?.toString(),
            ) ??
            '';

    final String isAr =
        LocalizationService.isArabic(context: context) ? "ar" : "en";
    final String subtitle = (request.duration == 0)
        ? '${DateService.formatDate(isAr, context, request.from)}'
        : (DateFormat('yyyy-MM-dd').format(DateTime.parse(request.from)) ==
                DateFormat('yyyy-MM-dd').format(DateTime.parse(request.to)))
            ? '${DateService.formatDate(isAr, context, request.from)} (${request.duration} ${request.durationType.toString().tr()})'
            : '${DateService.formatDate(isAr, context, request.from)} : ${DateService.formatDate(isAr, context, request.to)} (${request.duration} ${request.durationType.toString().tr()})';

    final String empLine = isForDepartment
        ? [
            if (request.employeeName != null &&
                request.employeeName.toString().isNotEmpty)
              request.employeeName.toString(),
            if (request.departmentName != null &&
                request.departmentName.toString().isNotEmpty)
              request.departmentName.toString(),
          ].join(' · ')
        : '';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: AppSpacing.cardPadding,
      onTap: () async => reqType == null
          ? await context.pushNamed(
              AppRoutes.requestDetails.name,
              extra: request ?? [],
              pathParameters: {
                'lang': context.locale.languageCode,
                'id': request!.id.toString(),
                'type': reqType != null ? reqType!.name : "me",
              },
            )
          : await context.pushNamed(
              AppRoutes.requestDetails.name,
              extra: request,
              pathParameters: {
                'type': reqType!.name,
                'id': request!.id.toString(),
                'lang': context.locale.languageCode,
              },
            ),
      onLongPress: canShowManagementResponse
          ? () async {
              await ModalSheetHelper.showModalSheet(
                context: context,
                viewProfile: false,
                modalContent: ManagementResponseModal(
                  requestId: request.id.toString(),
                ),
                title: AppStrings.managementResponse.tr(),
                height: LayoutService.getHeight(context) * 0.5,
              );
            }
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCardLeadingAvatar(
            nameForInitials: empLine.isNotEmpty ? empLine : title,
            icon: empLine.isNotEmpty ? null : Icons.event_note_rounded,
            borderColor: statusColor,
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showTakeActionBadge) ...[
                  AppStatusBadge(
                    icon: Icons.gavel_rounded,
                    color: Color(AppColors.failureRed),
                    label: 'take_action'.tr(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s3),
                    fontSize: 10,
                    iconSize: 11,
                  ),
                  const SizedBox(height: AppSizes.s5),
                ],
                Text(
                  title,
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.s3),
                Text(
                  subtitle,
                  style: AppStyles.subtitleContent(context).copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (empLine.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s3),
                  Text(
                    empLine,
                    style: AppStyles.subtitleContent(context).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          if (isForDepartment &&
              request.id != null &&
              ((request.approvableType
                          ?.toString()
                          .toLowerCase()
                          .contains('vacation') ==
                      true) ||
                  (request.approvableType
                          ?.toString()
                          .toLowerCase()
                          .contains('employeerequest') ==
                      true) ||
                  (request.typeName
                          ?.toString()
                          .toLowerCase()
                          .contains('vacation') ==
                      true) ||
                  (request.typeName
                          ?.toString()
                          .toLowerCase()
                          .contains('إجازة') ==
                      true))) ...[
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                showOverlappingVacationsSheet(
                  context: context,
                  approvableId: request.id.toString(),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppSizes.s6),
                decoration: BoxDecoration(
                  color: AppColors.statusTones(Color(AppColors.warningYellow)).tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  color: AppColors.statusTones(Color(AppColors.warningYellow)).text,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.s8),
          ],
          RequestsServices.getRequestsStatusIcon(
            context: context,
            status: request.status,
          ),
        ],
      ),
    );
  }
}
