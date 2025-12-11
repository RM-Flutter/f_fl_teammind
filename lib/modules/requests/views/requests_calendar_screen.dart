import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/app_theme.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/platform/platform_is.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../common_modules_widgets/custom_floating_action_button.widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../models/request.model.dart';
import '../../../routing/app_router.dart';
import '../../../services/requests.services.dart';
import '../view_models/requests_calendar.viewmodel.dart';

class RequestsCalendarScreen extends StatelessWidget {
  final requests;
  final GetRequestsTypes requestType;
  const RequestsCalendarScreen(
      {super.key, this.requests, required this.requestType});

  List _buildCalendarAppointments(BuildContext context, List sourceRequests, Map<String, dynamic>? gCache) {
    final List combined = [...sourceRequests];
    // Append holidays as calendar items if present (from US2)
    try {
      final holidays = gCache?['holidays'] as List?;
      if (holidays != null && holidays.isNotEmpty) {
        final lang = context.locale.languageCode;
        for (final h in holidays) {
          final String? from = h['from']?.toString();
          final String? to = h['to']?.toString();
          if (from == null || to == null) continue;
          // In US2, name is a String, not a Map
          final String holidayName = h['name']?.toString() ?? 'Holiday';
          final String officialHolidayLabel =
              lang == 'ar' ? 'إجازة رسمية' : 'Official Holiday';
          combined.add({
            'from': from,
            'to': to,
            // Keep the same subject style as requests, but mark as official holiday
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
          return TemplatePage(
              pageContext: context,
              floatingActionButton: FloatingActionButton(
                onPressed: () async => await context
                    .pushNamed(AppRoutes.addRequest.name, pathParameters: {
                  'type': 'mine',
                  'lang': context.locale.languageCode
                }), // Icon inside FAB
                backgroundColor: const Color(AppColors.primary), // Optional: change color
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
                            height: MediaQuery.sizeOf(context).height  * 0.6,
                            child: SfCalendar(
                              backgroundColor: Colors.white,
                              key: UniqueKey(),
                              view: viewModel.calendarView ?? CalendarView.month,
                              dataSource: RequestDataSource(_buildCalendarAppointments(context, requests, gCache)),
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
                                  final title = appt['typeName']?.toString() ?? 'Holiday';
                                  return Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(
                                      minHeight: (kIsWeb || PlatformIs.web) ? 50 : 28,
                                    ),
                                    alignment: Alignment.center,
                                    padding: (kIsWeb || PlatformIs.web) 
                                        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 3)
                                        : const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSizes.s4),
                                      color: Colors.green,
                                    ),
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      maxLines: (kIsWeb || PlatformIs.web) ? 1 : 1,
                                  
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: (kIsWeb || PlatformIs.web) ? 12 : 13,
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
                                // تحديد لون النص بناءً على لون الخلفية
                                // إذا كانت الخلفية خضراء (approved) أو رمادية (waiting) -> نص أبيض
                                // خلاف ذلك -> النص الأزرق
                                final textColor = (backgroundColor == Colors.green || 
                                                  backgroundColor == const Color(0xff606060))
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary;

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
                                      minHeight: (kIsWeb || PlatformIs.web) ? 50 : 28,
                                    ),
                                    alignment: Alignment.center,
                                    padding: (kIsWeb || PlatformIs.web) 
                                        ? const EdgeInsets.symmetric(horizontal: 5, vertical: 3)
                                        : const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSizes.s4),
                                      color: backgroundColor,
                                    ),
                                    child: Text(
                                      request?.typeName ?? '',
                                      textAlign: TextAlign.center,
                                      maxLines: (kIsWeb || PlatformIs.web) ? 2 : 1,
                          
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: (kIsWeb || PlatformIs.web) ? 13 : 13,
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
                                      color: const Color(AppColors.dark),
                                      fontSize: 20
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...(gCache['holidays'] as List? ?? []).map(
                                        (holiday) => ListTile(
                                      leading: const Icon(Icons.event, color: Colors.green),
                                      title: Text(holiday['name']?.toString() ?? 'Holiday'),
                                      subtitle: Text(
                                        "${formatDateArabic(DateTime.parse(holiday['from'].toString()), context)} ${AppStrings.to.tr().toUpperCase()} ${formatDateArabic(DateTime.parse(holiday['to'].toString()), context)}",
                                      ),
                                    ),
                                  )
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
  RequestDataSource(List requests) {
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
      return item['typeName']?.toString() ?? '';
    }
    return item?.typeName ?? '';
  }

  @override
  Color getColor(int index) {
    final item = appointments![index];
    if (item is Map && item['_isHoliday'] == true) {
      return Colors.green; // Holiday color
    }
    switch ((item.status as String).toLowerCase().trim()) {
      case 'approved':
        return Colors.green;
      default:
        return const Color(0xff606060);
    }
  }
}
