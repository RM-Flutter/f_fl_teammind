import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/requests/calender/controller/requests_calendar_controller.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// يستخرج النص حسب اللغة: إن كان القيمة Map فيها en/ar يُرجع القيمة المناسبة للغة الحالية فقط.
String _titleByLang(dynamic value, String lang) {
  if (value == null) return '';
  if (value is Map) {
    final v = value[lang] ?? value['en'] ?? value['ar'];
    return v?.toString() ?? '';
  }
  return value.toString();
}

class RequestsCalendarScreen extends StatelessWidget {
  final requests;
  final GetRequestsTypes requestType;
  const RequestsCalendarScreen(
      {super.key, this.requests, required this.requestType});

  List _buildCalendarAppointments(BuildContext context, List sourceRequests, Map<String, dynamic>? gCache) {
    final List combined = [...sourceRequests];
    final lang = context.locale.languageCode;
    // Append holidays as calendar items if present (from US2)
    try {
      final holidays = gCache?['holidays'] as List?;
      if (holidays != null && holidays.isNotEmpty) {
        for (final h in holidays) {
          final String? from = h['from']?.toString();
          final String? to = h['to']?.toString();
          if (from == null || to == null) continue;
          // name قد يكون String أو Map { en, ar } → نعرض ar فقط في العربي و en فقط في الإنجليزي
          final String holidayName = _titleByLang(h['name'], lang).isEmpty ? 'Holiday' : _titleByLang(h['name'], lang);
          final String officialHolidayLabel =
          lang == 'ar' ? 'إجازة رسمية' : 'Official Holiday';
          combined.add({
            'from': from,
            'to': to,
            'typeName': '$holidayName - $officialHolidayLabel',
            'status': 'approved',
            '_isHoliday': true,
          });
        }
      }
    } catch (_) {
      // ignore parse errors
    }
    return combined;
  }
  @override
  Widget build(BuildContext context) {
    final currentLang = context.locale.languageCode;
    Intl.defaultLocale = currentLang;

    return ChangeNotifierProvider<RequestsCalendarViewModel>(
        create: (_) => RequestsCalendarViewModel(),
        child: Consumer<RequestsCalendarViewModel>(
            builder: (context, viewModel, child) {
              var gCache;
              final jsonString = CacheHelper.getString("US2");
              if (jsonString != null && jsonString != "") {
                gCache = json.decode(jsonString) as Map<String, dynamic>;
              }
              return TemplatePage(
                  pageContext: context,
                  floatingActionButton: FloatingActionButton(
                    heroTag: 'requests_calendar_add',
                    onPressed: () async => await context
                        .pushNamed(AppRoutes.addRequest.name, pathParameters: {
                      'type': 'mine',
                      'lang': context.locale.languageCode
                    }), // Icon inside FAB
                    backgroundColor: Color(AppColors.buttons), // Optional: change color
                    tooltip: 'Add',
                    child: Center(
                      child: Image.asset(
                        AppImages.addFloatingActionButtonIcon,
                        color: AppThemeService.colorPalette.fabIconColor.color,
                        width: 16.r,
                        height: 16.r,
                      ),
                    ),
                  ),
                  title: AppStrings.calendar.tr(),
                  actions: [
                    PopupMenuButton<CalendarView>(
                      initialValue: viewModel.calendarView,
                      onSelected: (val) => viewModel.updateCalendarView(val),
                      itemBuilder: (BuildContext context) {
                        return viewModel.calendarViews
                            .map((Map<String, dynamic> view) {
                          return PopupMenuItem<CalendarView>(
                            value: view['value'],
                            child: Text(
                              view['name'],
                              style: AppStyles.darkContent(context).copyWith(
                                  color: viewModel.calendarView == view['value']
                                      ? Color(AppColors.secondaryButton)
                                      : Color(AppColors.buttons),
                                  fontSize: 14.sp,
                                  fontWeight:
                                  viewModel.calendarView == view['value']
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                          );
                        }).toList();
                      },
                      icon: Icon(
                        Icons.preview_outlined,
                        size: 32.r,
                        color: Color(AppColors.buttons),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                  body: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: kIsWeb ? 1100.w : 1.sw
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 0.6.sh,
                                child: SfCalendar(
                                  backgroundColor: Color(AppColors.background),
                                  key: UniqueKey(),
                                  view: viewModel.calendarView ?? CalendarView.month,
                                  dataSource: RequestDataSource(_buildCalendarAppointments(context, requests, gCache), context.locale.languageCode),
                                  monthViewSettings: MonthViewSettings(
                                    appointmentDisplayMode:
                                    MonthAppointmentDisplayMode.appointment,
                                    showAgenda: false,
                                    appointmentDisplayCount: (kIsWeb || PlatformIs.web) ? 2 : 1,
                                    showTrailingAndLeadingDates: true,
                                  ),
                                  showNavigationArrow: true,
                                  appointmentBuilder: (context, details) {
                                    final appt = details.appointments.first;
                                    // Render holidays (Map) differently
                                    if (appt is Map && appt['_isHoliday'] == true) {
                                      final title = _titleByLang(appt['typeName'], currentLang);
                                      final displayTitle = title.isEmpty ? 'Holiday' : title;
                                      return Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(
                                          minHeight: (kIsWeb || PlatformIs.web) ? 50.h : 28.h,
                                        ),
                                        alignment: Alignment.center,
                                        padding: (kIsWeb || PlatformIs.web)
                                            ? EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h)
                                            : EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4.r),
                                          color: const Color(AppColors.green),
                                        ),
                                        child: Text(
                                          displayTitle,
                                          textAlign: TextAlign.center,
                                          maxLines: (kIsWeb || PlatformIs.web) ? 1 : 1,
                                          overflow: TextOverflow.visible,
                                          style: AppStyles.whiteContent(context).copyWith(
                                            fontSize: (kIsWeb || PlatformIs.web) ? 12.sp : 13.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }

                                    final request = appt;
                                    final status = request?.status?.toLowerCase()?.trim();
                                    final canShow = status == "approved" || status == "waiting_seen" || status == "waiting";
                                    if (!canShow) return const SizedBox.shrink();

                                    final backgroundColor = viewModel.getStatusColor(status);
                                    final textColor = (backgroundColor == const Color(AppColors.green) ||
                                        backgroundColor == Color(0xff606060))
                                        ? Colors.white
                                        : Color(AppColors.buttons);

                                    return GestureDetector(
                                      onTap: () async {
                                        await context.pushNamed(
                                          AppRoutes.requestDetails.name,
                                          extra: request,
                                          pathParameters: {
                                            'type': RequestsServices.getRequestsTypeStr(type: requestType),
                                            'id': CacheHelper.getInt("id").toString(),
                                            'lang': context.locale.languageCode,
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(
                                          minHeight: (kIsWeb || PlatformIs.web) ? 50.h : 28.h,
                                        ),
                                        alignment: Alignment.center,
                                        padding: (kIsWeb || PlatformIs.web)
                                            ? EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h)
                                            : EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4.r),
                                          color: backgroundColor,
                                        ),
                                        child: Text(
                                          _titleByLang(request?.typeName, currentLang),
                                          textAlign: TextAlign.center,
                                          maxLines: (kIsWeb || PlatformIs.web) ? 2 : 1,

                                          overflow: TextOverflow.visible,
                                          style: AppStyles.content(context).copyWith(
                                            color: textColor,
                                            fontSize: (kIsWeb || PlatformIs.web) ? 13.sp : 13.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 15.h,),
                              Card(
                                margin: EdgeInsets.all(16.r),
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                child: Padding(
                                  padding: EdgeInsets.all(16.r),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "📅 ${AppStrings.publicHolidays.tr()}",
                                        style: AppStyles.heading(context).copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.sp
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      ...(gCache['holidays'] as List? ?? []).map(
                                              (holiday) {
                                            final name = _titleByLang(holiday['name'], context.locale.languageCode);
                                            return ListTile(
                                              leading: const Icon(Icons.event, color: Color(AppColors.green)),
                                              title: Text(name.isEmpty ? 'Holiday' : name, style: AppStyles.darkContent(context).copyWith(fontWeight: FontWeight.bold),),
                                              subtitle: Text(
                                                "${formatDateArabic(DateTime.parse(holiday['from'].toString()), context)} ${AppStrings.to.tr().toUpperCase()} ${formatDateArabic(DateTime.parse(holiday['to'].toString()), context)}",
                                                style: AppStyles.greyContent(context).copyWith(fontSize: 12.sp),
                                              ),
                                            );
                                          }).toList(),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
            }));
  }

  String formatDateArabic(DateTime date, context) {
    final DateFormat formatter = DateFormat('d MMMM y', LocalizationService.isArabic(context: context)?'ar' : 'en');
    return formatter.format(date);
  }
}

class RequestDataSource extends CalendarDataSource {
  final String _lang;
  RequestDataSource(List requests, this._lang) {
    appointments = requests;
  }

  @override
  DateTime getStartTime(int index) {
    final item = appointments![index];
    if (item is Map) {
      return DateTime.parse(item['from'].toString());
    }
    return DateTime.parse(item.from!);
  }

  @override
  DateTime getEndTime(int index) {
    final item = appointments![index];
    if (item is Map) {
      return DateTime.parse(item['to'].toString());
    }
    return DateTime.parse(item.to!);
  }

  @override
  String getSubject(int index) {
    final item = appointments![index];
    if (item is Map) {
      return _titleByLang(item['typeName'], _lang);
    }
    return _titleByLang(item?.typeName, _lang);
  }

  @override
  Color getColor(int index) {
    final item = appointments![index];
    if (item is Map && item['_isHoliday'] == true) {
      return const Color(AppColors.green); // Holiday color
    }
    switch ((item.status as String).toLowerCase().trim()) {
      case 'approved':
        return const Color(AppColors.green);
      default:
        return Color(0xff606060);
    }
  }
}
