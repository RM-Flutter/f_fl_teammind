import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../controllers/tasks_controller.dart';

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
        return Row(
          children: [
            GestureDetector(
              onTap: (){
                viewModel.getTask(context, date: null);
              },
              child: Container(
                height: 60.h,
                width: 50.w,
                margin: EdgeInsets.only(left: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: viewModel.selectedIndex == null ? Theme.of(context).primaryColor : Colors.white,
                  border: viewModel.selectedIndex == null ? null : Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppStrings.all.tr(),
                  style: AppStyles.blackContent(context).copyWith(
                    color: viewModel.selectedIndex == null ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 100.h,
                color: Colors.white,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: monthDays.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
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
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: index == viewModel.selectedIndex ? Colors.blue : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat.d('${CacheHelper.getString("lang")}').format(date),
                                  style: AppStyles.blackContent(context).copyWith(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: index == viewModel.selectedIndex ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat.MMM('${CacheHelper.getString("lang")}').format(date),
                                  style: AppStyles.greyContent(context).copyWith(
                                    fontSize: 12.sp,
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
              ),
            ),
          ],
        );
      }
    );
  }
}
