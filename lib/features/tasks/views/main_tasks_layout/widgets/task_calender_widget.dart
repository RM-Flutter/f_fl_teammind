import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../controllers/tasks_controller.dart';
import 'package:app_test/core/constants/app_design.dart';

class HorizontalCalendar extends StatefulWidget {
  @override
  _HorizontalCalendarState createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {

  late final List<DateTime> monthDays;
  int? selectIndex;
  @override
  void initState() {
    super.initState();

    Intl.defaultLocale = CacheHelper.getString("lang") ?? "en";
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final totalDays = 30;
    monthDays = List.generate(totalDays, (i) => firstDay.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksController>(
      builder: (context, viewModel, child){
        // "All" is the first item of the same list as the days, so it gets the same page padding
        // and the same 10 gap, and scrolls with them (it used to sit outside, glued to the edge).
        return Container(
          height: 100,
          color: Colors.white,
          child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.pagePadding,
                  itemCount: monthDays.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSizes.s10),
                  itemBuilder: (context, listIndex) {
                    if (listIndex == 0) {
                      final selected = viewModel.selectedIndex == null;
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            viewModel.getTask(context, date: null);
                          },
                          child: Container(
                            height: 60,
                            width: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              color: selected ? Color(AppColors.buttons) : Colors.white,
                              border: selected ? null : Border.all(color: Colors.grey.shade300),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              AppStrings.all.tr(),
                              style: AppStyles.blackContent(context).copyWith(
                                color: selected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final index = listIndex - 1;
                    final date = monthDays[index];
                    return GestureDetector(
                      onTap: () async{
                        setState(() {
                          selectIndex = index;
                        });
                        final formattedDate = DateFormat('y-M-d', "en").format(date);
                        debugPrint(formattedDate);
                       await viewModel.getTask(context, date: formattedDate.toString(), index: index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.E('${CacheHelper.getString("lang")}').format(date),
                            style: AppStyles.greyContent(context).copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: AppSizes.s6),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: AppSizes.s6, horizontal: AppSizes.s12),
                            decoration: BoxDecoration(
                              color: index == viewModel.selectedIndex ? Colors.blue : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat.d('${CacheHelper.getString("lang")}').format(date),
                                  style: AppStyles.blackContent(context).copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: index == viewModel.selectedIndex ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat.MMM('${CacheHelper.getString("lang")}').format(date),
                                  style: AppStyles.greyContent(context).copyWith(
                                    fontSize: 12,
                                    color: index == viewModel.selectedIndex ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      }
    );
  }
}
