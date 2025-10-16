import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/app_theme.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RequestsCalendarViewModel>(
        create: (_) => RequestsCalendarViewModel(),
        child: Consumer<RequestsCalendarViewModel>(
            builder: (context, viewModel, child) {
              var gCache;
              final jsonString = CacheHelper.getString("USG");
              if (jsonString != null && jsonString != "") {
                gCache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
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
                          dataSource: RequestDataSource(requests!),
                          monthViewSettings: const MonthViewSettings(
                            appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment,
                            showAgenda: false,
                            appointmentDisplayCount: 1,
                          ),
                          showNavigationArrow: true,
                          appointmentBuilder: (context, details) {
                            final request = details.appointments.first;
                            return (request!.status == "approved" ||
                                request!.status == "waiting_seen"|| request!.status == "waiting") ? GestureDetector(
                              onTap: () async {
                                await context.pushNamed(
                                  AppRoutes.requestDetails.name,
                                  extra: request,
                                  pathParameters: {
                                    'type': RequestsServices.getRequestsTypeStr(
                                        type: requestType),
                                    'id' : CacheHelper.getInt("id").toString(),
                                    'lang': context.locale.languageCode,
                                  },
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSizes.s4),
                                  color: viewModel.getStatusColor(
                                      request!.status!.toLowerCase().trim()),
                                ),
                                child: Center(
                                        child: AutoSizeText(
                                         request?.typeName ??
                                              '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                      ),
                              ),
                            ) : const SizedBox.shrink();
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
                              ...gCache['holidays'].map(
                                    (holiday) => ListTile(
                                  leading: const Icon(Icons.event, color: Colors.green),
                                  title: Text(holiday['name']["${context.locale.languageCode}"]),
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
    return DateTime.parse(appointments![index].from!);
  }

  @override
  DateTime getEndTime(int index) {
    return DateTime.parse(appointments![index].to!);
  }

  @override
  String getSubject(int index) {
    return appointments?[index]?.typeName ?? '';
  }

  @override
  Color getColor(int index) {
    switch (
        (appointments![index].status as String).toLowerCase().trim()) {
      case 'approved':
        return Colors.green;
      default:
        return const Color(0xff606060);
    }
  }
}
