import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/app_theme_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../models/overtime_request_model.dart';
import '../../requests/calender/controller/requests_calendar_controller.dart';
import 'package:app_test/core/constants/app_design.dart';

String _formatDuration(int? totalMinutes, bool isArabic) {
  if (totalMinutes == null || totalMinutes == 0) {
    return '0_min'.tr();
  }
  final hours = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;
  if (hours == 0) return "$mins ${'min'.tr()}";
  if (mins == 0) return "$hours ${'hr'.tr()}";
  return 'hr_min_2'.tr(namedArgs: {'hours': '$hours', 'mins': '$mins'});
}

class OvertimeCalendarScreen extends StatelessWidget {
  final List<OvertimeRequestModel> requests;
  final String title;
  final bool isForDepartment;

  const OvertimeCalendarScreen({
    super.key,
    required this.requests,
    required this.title,
    required this.isForDepartment,
  });

  List<OvertimeRequestModel> _filterOvertimeAppointments() {
    final List<OvertimeRequestModel> valid = [];
    for (var r in requests) {
      if (r.date != null && r.date!.isNotEmpty) {
        try {
          DateTime.parse(r.date!);
          valid.add(r);
        } catch (_) {}
      }
    }
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = context.locale.languageCode;
    final bool isArabic = currentLang == 'ar';
    final validAppointments = _filterOvertimeAppointments();

    return ChangeNotifierProvider<RequestsCalendarViewModel>(
      create: (_) => RequestsCalendarViewModel(),
      child: Consumer<RequestsCalendarViewModel>(
        builder: (context, viewModel, child) {
          return TemplatePage(
            pageContext: context,
            title: title,
            floatingActionButton: FloatingActionButton(
              heroTag: 'overtime_calendar_add',
              onPressed: () async {
                await context.pushNamed(
                  AppRoutes.addOvertimeRequestScreen.name,
                  pathParameters: {'lang': context.locale.languageCode},
                );
              },
              backgroundColor: Color(AppColors.buttons),
              tooltip: 'add_overtime'.tr(),
              child: Center(
                child: Image.asset(
                  AppImages.addFloatingActionButtonIcon,
                  color: AppThemeService.colorPalette.fabIconColor.color,
                  width: 16,
                  height: 16,
                ),
              ),
            ),
            actions: [
              PopupMenuButton<CalendarView>(
                initialValue: viewModel.calendarView,
                onSelected: (val) => viewModel.updateCalendarView(val),
                itemBuilder: (BuildContext context) {
                  return viewModel.calendarViews.map((Map<String, dynamic> view) {
                    return PopupMenuItem<CalendarView>(
                      value: view['value'],
                      child: Text(
                        view['name'],
                        style: AppStyles.darkContent(context).copyWith(
                          color: viewModel.calendarView == view['value']
                              ? Color(AppColors.secondaryButton)
                              : Color(AppColors.buttons),
                          fontSize: 14,
                          fontWeight: viewModel.calendarView == view['value']
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList();
                },
                icon: Icon(
                  Icons.preview_outlined,
                  size: 32,
                  color: Color(AppColors.buttons),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ],
            body: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: double.infinity),
                  child: Padding(
                    padding: AppSpacing.pageAll,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height > 800 ? 0.75.sh : 650,
                          child: SfCalendar(
                            backgroundColor: Color(AppColors.background),
                            key: UniqueKey(),
                            view: viewModel.calendarView ?? CalendarView.month,
                            dataSource: _OvertimeDataSource(
                              validAppointments,
                              isForDepartment,
                              isArabic,
                            ),
                            monthViewSettings: MonthViewSettings(
                              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                              showAgenda: false,
                              appointmentDisplayCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                              showTrailingAndLeadingDates: true,
                            ),
                            showNavigationArrow: true,
                            appointmentBuilder: (context, details) {
                              if (details.isMoreAppointmentRegion) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          backgroundColor: Color(AppColors.background),
                                          title: Text(
                                            '${details.date.day}/${details.date.month}/${details.date.year}',
                                            style: AppStyles.heading(context),
                                          ),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              itemCount: details.appointments.length,
                                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                                              itemBuilder: (ctx, index) {
                                                final ot = details.appointments.elementAt(index) as OvertimeRequestModel;
                                                return _buildAppointmentTile(context, ot, isArabic);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(AppColors.buttons).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(AppRadius.xs),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '+${details.appointments.length}',
                                      style: TextStyle(
                                        color: Color(AppColors.buttons),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final ot = details.appointments.first as OvertimeRequestModel;
                              final durationText = _formatDuration(ot.overtime, isArabic);
                              final empName = ot.employeeName ?? ot.employeeProfile?.name ?? '';
                              final displayTitle = (isForDepartment && empName.isNotEmpty)
                                  ? '$empName ($durationText)'
                                  : durationText;

                              final status = ot.status?.toLowerCase().trim();
                              Color bgColor = Color(AppColors.buttons);
                              if (status == 'approved') {
                                bgColor = const Color(AppColors.green);
                              } else if (status == 'refused' || status == 'rejected' || status == 'cancelled' || status == 'canceled') {
                                bgColor = Colors.red.shade400;
                              }

                              return GestureDetector(
                                onTap: () {
                                  _navigateToDetails(context, ot);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(AppRadius.xs),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    displayTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                            onTap: (CalendarTapDetails tapDetails) {
                              if (tapDetails.targetElement == CalendarElement.appointment &&
                                  tapDetails.appointments != null &&
                                  tapDetails.appointments!.isNotEmpty) {
                                final ot = tapDetails.appointments!.first as OvertimeRequestModel;
                                _navigateToDetails(context, ot);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentTile(BuildContext context, OvertimeRequestModel ot, bool isArabic) {
    final durationText = _formatDuration(ot.overtime, isArabic);
    final empName = ot.employeeName ?? ot.employeeProfile?.name ?? '';
    final status = ot.status?.toLowerCase().trim();
    Color bgColor = Color(AppColors.buttons);
    if (status == 'approved') {
      bgColor = const Color(AppColors.green);
    } else if (status == 'refused' || status == 'rejected' || status == 'cancelled' || status == 'canceled') {
      bgColor = Colors.red.shade400;
    }

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      tileColor: bgColor.withOpacity(0.1),
      leading: Icon(Icons.access_time_rounded, color: bgColor),
      title: Text(
        (isForDepartment && empName.isNotEmpty) ? '$empName - $durationText' : durationText,
        style: AppStyles.content(context).copyWith(
          color: bgColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        ot.date ?? '',
        style: AppStyles.greyContent(context).copyWith(fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        Navigator.pop(context);
        _navigateToDetails(context, ot);
      },
    );
  }

  void _navigateToDetails(BuildContext context, OvertimeRequestModel ot) {
    context.pushNamed(
      AppRoutes.overtimeRequestDetailsScreen.name,
      pathParameters: {'lang': context.locale.languageCode},
      extra: ot,
    );
  }
}

class _OvertimeDataSource extends CalendarDataSource {
  final bool isForDepartment;
  final bool isArabic;

  _OvertimeDataSource(List<OvertimeRequestModel> source, this.isForDepartment, this.isArabic) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final ot = appointments![index] as OvertimeRequestModel;
    try {
      return DateTime.parse(ot.date!);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  DateTime getEndTime(int index) {
    final ot = appointments![index] as OvertimeRequestModel;
    try {
      final start = DateTime.parse(ot.date!);
      final mins = ot.overtime ?? 60;
      return start.add(Duration(minutes: mins > 0 ? mins : 60));
    } catch (_) {
      return DateTime.now().add(const Duration(hours: 1));
    }
  }

  @override
  bool isAllDay(int index) {
    return true;
  }

  @override
  String getSubject(int index) {
    final ot = appointments![index] as OvertimeRequestModel;
    final durationText = _formatDuration(ot.overtime, isArabic);
    final empName = ot.employeeName ?? ot.employeeProfile?.name ?? '';
    if (isForDepartment && empName.isNotEmpty) {
      return '$empName ($durationText)';
    }
    return durationText;
  }

  @override
  Color getColor(int index) {
    final ot = appointments![index] as OvertimeRequestModel;
    final status = ot.status?.toLowerCase().trim();
    if (status == 'approved') {
      return const Color(AppColors.green);
    } else if (status == 'refused' || status == 'rejected' || status == 'cancelled' || status == 'canceled') {
      return Colors.red.shade400;
    } else {
      return  Color(AppColors.buttons);
    }
  }
}
