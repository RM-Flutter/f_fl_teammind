import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/features/overtime_requests/models/overtime_request_model.dart';
import 'package:app_test/features/salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'package:app_test/features/approvables_details/views/widgets/overlapping_vacations_sheet.dart';

class ApprovableCardWidget extends StatelessWidget {
  final dynamic request; // RequestModel, OvertimeRequestModel, SalaryAdvanceRequestModel
  final bool isForDepartment;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;

  const ApprovableCardWidget({
    Key? key,
    required this.request,
    required this.isForDepartment,
    required this.onTap,
    this.onLongPress,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.locale.languageCode == 'ar';

    // Extract generic fields safely
    bool showTakeAction = false;
    String? status;
    String title = '';
    String subtitle = '';
    String employeeName = '';

    try {
      if (request is OvertimeRequestModel) {
        final ot = request as OvertimeRequestModel;
        showTakeAction = ot.takeAction == true || ot.canTakeActionAsSomeoneElse == true;
        status = ot.status;
        employeeName = ot.employeeName ?? ot.employeeProfile?.name ?? "";

        final dateStr = (ot.date != null && ot.date!.length >= 10) ? ot.date!.substring(0, 10) : (ot.date ?? "");
        final formattedDate = (ot.date != null && ot.date!.isNotEmpty)
            ? (DateService.formatDate(isArabic ? "ar" : "en", context, ot.date) ?? dateStr)
            : dateStr;

        int totalMins = ot.overtime ?? 0;
        final hours = totalMins ~/ 60;
        final mins = totalMins % 60;
        String durationStr = "";
        if (hours == 0) {
          durationStr = '$mins ${isArabic ? "دقيقة" : "min"}';
        } else if (mins == 0) {
          durationStr = '$hours ${isArabic ? "ساعة" : "hr"}';
        } else {
          durationStr = isArabic
              ? '$hours ساعة و $mins دقيقة'
              : '$hours hr $mins min';
        }

        // Distinctive feature for overtime is the duration worked
        if (totalMins > 0) {
          title = durationStr;
          subtitle = formattedDate.isNotEmpty
              ? (isArabic ? "التاريخ: $formattedDate" : "Date: $formattedDate")
              : "";
        } else {
          title = formattedDate.isNotEmpty
              ? formattedDate
              : (isArabic ? "وقت إضافي" : "Overtime");
          subtitle = "";
        }
      } else if (request is SalaryAdvanceRequestModel) {
        final sa = request as SalaryAdvanceRequestModel;
        showTakeAction = sa.takeAction == true || sa.canTakeActionAsSomeoneElse == true;
        status = sa.status;
        employeeName = sa.employeeProfile?.name ?? "";

        String amount = sa.total?.toString() ?? "0";
        String months = sa.howLongToPay?.toString() ?? "1";

        // Distinctive feature for salary advance is the amount
        title = "$amount ${isArabic ? 'ج.م' : 'EGP'}";

        String durationText = isArabic
            ? "$months شهر"
            : "$months ${months == '1' ? 'month' : 'months'}";
        String details = "${isArabic ? 'مدة السداد' : 'Duration'}: $durationText";
        if (sa.from != null && sa.from!.isNotEmpty) {
          final formattedFrom = DateService.formatDate(isArabic ? "ar" : "en", context, sa.from) ?? sa.from!;
          details += " • ${isArabic ? 'من' : 'From'}: $formattedFrom";
        }
        subtitle = details;
      } else {
        // Assume RequestModel
        final dyn = request as dynamic;
        showTakeAction = dyn.takeAction == true || dyn.canTakeActionAsSomeoneElse == true;
        status = dyn.status;
        employeeName = dyn.employeeName ?? "";
        String? depName = dyn.departmentName;
        if (depName != null && depName.isNotEmpty) {
          employeeName = "$employeeName - $depName";
        }

        title = AppSettingsService.getRequestTitleFromGenenralSettings(
                context: context,
                requestId: dyn.typeId != null ? dyn.typeId?.toString() : "") ??
            '';

        final String fromDate = dyn.from != null ? (DateService.formatDate(isArabic ? "ar" : "en", context, dyn.from) ?? "") : "";
        final String toDate = dyn.to != null ? (DateService.formatDate(isArabic ? "ar" : "en", context, dyn.to) ?? "") : "";

        if (dyn.duration == 0) {
          subtitle = fromDate;
        } else if (fromDate == toDate || toDate.isEmpty) {
          subtitle = '$fromDate (${dyn.duration} ${dyn.durationType?.toString().tr()})';
        } else {
          subtitle = '$fromDate : $toDate (${dyn.duration} ${dyn.durationType?.toString().tr()})';
        }
      }
    } catch (_) {}

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: ShapeDecoration(
        color: Color(AppColors.cardBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Color(AppColors.disableButton).withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showTakeAction) ...[
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
                            isArabic ? "مطلوب اتخاذ إجراء" : "Take Action",
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
                    title,
                    style: AppStyles.titleTextContent(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.75,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Opacity(
                    opacity: 0.5,
                    child: AutoSizeText(
                      subtitle,
                      style: AppStyles.titleTextContent(context).copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                    if (isForDepartment && employeeName.isNotEmpty) const SizedBox(height: 4),
                    if (isForDepartment && employeeName.isNotEmpty)
                      Text(
                        employeeName,
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
              // Overlapping Vacations Icon for Managers
              if (isForDepartment)
                Builder(
                  builder: (context) {
                    bool isVac = false;
                    try {
                      final dyn = request as dynamic;
                      if (dyn.id != null) {
                        final String appType = dyn.approvableType?.toString().toLowerCase() ?? '';
                        final String tName = dyn.typeName?.toString().toLowerCase() ?? '';
                        isVac = appType.contains('employeerequest') || appType.contains('vacation') || tName.contains('vacation') || tName.contains('إجازة');
                      }
                    } catch (_) {}

                    if (isVac) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              showOverlappingVacationsSheet(
                                context: context,
                                approvableId: (request as dynamic).id.toString(),
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
                          const SizedBox(width: 8),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              if (status != null &&
                  status!.trim().isNotEmpty &&
                  status!.trim().toLowerCase() != 'null') ...[
                const SizedBox(width: 8),
                RequestsServices.getRequestsStatusIcon(
                    context: context, status: status),
              ],
            ],
          ),
        ),
      );
  }
}
