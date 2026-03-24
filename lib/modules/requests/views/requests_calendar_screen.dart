import 'dart:convert';

import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/general_services/app_theme.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/platform/platform_is.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../routing/app_router.dart';
import '../../../services/requests.services.dart';
import '../view_models/requests_calendar.viewmodel.dart';

/// يستخرج النص حسب اللغة: إن كان القيمة Map فيها en/ar يُرجع القيمة المناسبة للغة الحالية فقط.
String _titleByLang(dynamic value, String lang) {
  if (value == null) return '';
  if (value is Map) {
    final v = value[lang] ?? value['en'] ?? value['ar'];
    return v?.toString() ?? '';
  }
  return value.toString();
}

/// يستخرج اسم نوع الطلب من عنصر (Map من API يستخدم type_name أو كائن يستخدم typeName).
dynamic _requestTypeName(dynamic request) {
  if (request == null) return null;
  if (request is Map) return request['type_name'] ?? request['typeName'];
  return request.typeName;
}

/// يفسّر تاريخ الـ API كتاريخ محلي (تاريخ فقط) لتفادي انزياح التوقيت — مثلاً "2026-04-05 02:00:00" → 5 أبريل 2026.
DateTime _parseCalendarDate(String dateStr, {bool endOfDay = false}) {
  final s = dateStr.toString().trim();
  if (s.length >= 10) {
    final datePart = s.substring(0, 10);
    final dt = DateTime.parse(datePart);
    if (endOfDay) {
      return DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);
    }
    return DateTime(dt.year, dt.month, dt.day);
  }
  final parsed = DateTime.parse(s);
  return endOfDay
      ? DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59, 999)
      : DateTime(parsed.year, parsed.month, parsed.day);
}

class RequestsCalendarScreen extends StatelessWidget {
  final requests;
  final GetRequestsTypes requestType;
  const RequestsCalendarScreen(
      {super.key, this.requests, required this.requestType});

  List _buildCalendarAppointments(BuildContext context, List sourceRequests, Map<String, dynamic>? gCache) {
    // استبعاد الطلبات التي لا تحتوي على from/to صالحة حتى لا يتعطل الكاليندر
    final List combined = sourceRequests.where((r) {
      if (r is Map) {
        final from = r['from']?.toString();
        final to = r['to']?.toString();
        if (from == null || to == null || from.isEmpty || to.isEmpty) return false;
        try {
          DateTime.parse(from);
          DateTime.parse(to);
          return true;
        } catch (_) {
          return false;
        }
      }
      final from = r.from?.toString();
      final to = r.to?.toString();
      if (from == null || to == null || from.isEmpty || to.isEmpty) return false;
      try {
        DateTime.parse(from);
        DateTime.parse(to);
        return true;
      } catch (_) {
        return false;
      }
    }).toList();
    final lang = context.locale.languageCode;
    // Append holidays as calendar items (from US2 or USG — العطل غالباً في general_settings)
    try {
      final holidays = gCache?['holidays'] as List?;
      if (holidays != null && holidays.isNotEmpty) {
        for (final h in holidays) {
          if (h is! Map) continue;
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
    // ضبط locale للأرقام بناءً على لغة التطبيق
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
              final json2String = CacheHelper.getString("USG");
              var gCache2;
              if (json2String != null && json2String != "") {
                gCache2 = json.decode(json2String) as Map<String, dynamic>;
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
                backgroundColor: Color(AppColors.primary), // Optional: change color
                tooltip: 'Add',
                child: Center(
                  child: Image.asset(
                    AppImages.addFloatingActionButtonIcon,
                    color: AppThemeService.colorPalette.fabIconColor.color,
                    width: AppSizes.s16,
                    height: AppSizes.s16,
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
                          style: TextStyle(
                              color: viewModel.calendarView == view['value']
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                              fontSize: AppSizes.s14,
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
                    size: AppSizes.s32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.s12),
                  ),
                ),
              ],
              body: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 1100 : double.infinity
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.s12),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.sizeOf(context).height * 0.72,
                            child: SfCalendar(
                              backgroundColor: Color(AppColors.white),
                              key: UniqueKey(),
                              view: viewModel.calendarView ?? CalendarView.month,
                              dataSource: RequestDataSource(_buildCalendarAppointments(context, requests, gCache2), context.locale.languageCode),
                              monthViewSettings: MonthViewSettings(
                                appointmentDisplayMode:
                                    MonthAppointmentDisplayMode.appointment,
                                showAgenda: false,
                                appointmentDisplayCount: 2,
                                showTrailingAndLeadingDates: true,
                              ),
                              showNavigationArrow: true,
                              appointmentBuilder: (context, details) {
                                final appt = details.appointments.first;
                                final bounds = details.bounds;

                                // عطلات رسمية (مضافة من الكاش)
                                if (appt is Map && appt['_isHoliday'] == true) {
                                  final title = _titleByLang(appt['typeName'], currentLang);
                                  final displayTitle = title.isEmpty ? 'Holiday' : title;
                                  return Container(
                                    width: bounds.width,
                                    height: bounds.height,
                                    alignment: Alignment.center,
                                    padding: (kIsWeb || PlatformIs.web)
                                        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 3)
                                        : const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSizes.s4),
                                      color: Color(AppColors.green),
                                    ),
                                    child: Text(
                                      displayTitle,
                                      textAlign: TextAlign.center,
                                      maxLines: (kIsWeb || PlatformIs.web) ? 1 : 1,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        color: Color(AppColors.white),
                                        fontSize: (kIsWeb || PlatformIs.web) ? 12 : 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }

                                // باقي الطلبات
                                final request = appt;
                                final rawStatus =
                                    (request is Map ? request['status'] : request?.status)?.toString();
                                final status =
                                    rawStatus?.toLowerCase().trim().replaceAll(' ', '_');

                                // نعرض فقط الحالات المطلوبة
                                final canShow = status == "approved" ||
                                    status == "waiting_seen" ||
                                    status == "waiting" ||
                                    status == "waiting_cancel";
                                if (!canShow) return const SizedBox.shrink();

                                final backgroundColor = viewModel.getStatusColor(status);
                                // تحديد لون النص بناءً على لون الخلفية
                                final textColor =
                                    (backgroundColor == Color(AppColors.green) || backgroundColor == Color(AppColors.darkGrey))
                                        ? Color(AppColors.white)
                                        : Theme.of(context).colorScheme.primary;

                                // استخرج رقم الطلب (id) من الماب أو من الموديل
                                final requestId = (request is Map
                                        ? (request['id'] ?? request['requestId'])
                                        : request?.id)
                                    ?.toString();

                                return GestureDetector(
                                  onTap: () async {
                                    if (requestId == null) return;
                                    await context.pushNamed(
                                      AppRoutes.requestDetails.name,
                                      extra: request,
                                      pathParameters: {
                                        // نستخدم اسم الـ enum مباشرة زي RequestCard (mine / myTeam / otherDepartment)
                                        'type': (requestType ?? GetRequestsTypes.mine).name,
                                        'id': requestId,
                                        'lang': context.locale.languageCode,
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: bounds.width,
                                    height: bounds.height,
                                    alignment: Alignment.center,
                                    padding: (kIsWeb || PlatformIs.web)
                                        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 3)
                                        : const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSizes.s4),
                                      color: backgroundColor,
                                    ),
                                    child: Text(
                                      _titleByLang(_requestTypeName(request), currentLang),
                                      textAlign: TextAlign.center,
                                      maxLines: (kIsWeb || PlatformIs.web) ? 2 : 1,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: (kIsWeb || PlatformIs.web) ? 13 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 15,),
                          Card(
                            margin: EdgeInsets.all(16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "📅 ${AppStrings.publicHolidays.tr()}",
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Color(AppColors.dark),
                                      fontSize: 20
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...(gCache2['holidays'] as List? ?? []).where((h) => h is Map).map(
                                        (holiday) {
                                      final name = _titleByLang(holiday['name'], context.locale.languageCode);
                                      return ListTile(
                                      leading: Icon(Icons.event, color: Color(AppColors.green)),
                                      title: Text(name.isEmpty ? 'Holiday' : name),
                                      subtitle: Text(
                                        "${formatDateArabic(DateTime.parse(holiday['from'].toString()), context)} ${AppStrings.to.tr().toUpperCase()} ${formatDateArabic(DateTime.parse(holiday['to'].toString()), context)}",
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
      return _parseCalendarDate(item['from'].toString());
    }
    return _parseCalendarDate(item.from!);
  }

  @override
  DateTime getEndTime(int index) {
    final item = appointments![index];
    if (item is Map) {
      return _parseCalendarDate(item['to'].toString(), endOfDay: true);
    }
    return _parseCalendarDate(item.to!, endOfDay: true);
  }

  @override
  String getSubject(int index) {
    final item = appointments![index];
    return _titleByLang(_requestTypeName(item), _lang);
  }

  @override
  Color getColor(int index) {
    final item = appointments![index];
    if (item is Map && item['_isHoliday'] == true) {
      return Color(AppColors.green); // Holiday color
    }
    final status = (item is Map ? item['status'] : item.status)?.toString().toLowerCase().trim();
    switch (status) {
      case 'approved':
        return Color(AppColors.green);
      case 'waiting_seen':
      case 'waiting_cancel':
      case 'waiting':
      default:
        return Color(AppColors.darkGrey);
    }
  }
}
