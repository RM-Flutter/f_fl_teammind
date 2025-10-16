import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/controller/task_controller/task_view_model.dart';
import 'package:provider/provider.dart';

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
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child){
        return Row(
          children: [
            GestureDetector(
              onTap: (){
                viewModel.getTask(context, date: null);
              },
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Color(AppColors.primary),),
                alignment: Alignment.center,
                child:  Text(
                  AppStrings.all.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 100,
                color: Colors.white,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: monthDays.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final date = monthDays[index];
                    return GestureDetector(
                      onTap: () async{
                        setState(() {
                          selectIndex = index;
                        });
                        final formattedDate = DateFormat('y-M-d', "en").format(date);
                        print(formattedDate);
                       await viewModel.getTask(context, date: formattedDate.toString(), index: index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.E('${CacheHelper.getString("lang")}').format(date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: index == viewModel.selectedIndex ? Colors.blue : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat.d('${CacheHelper.getString("lang")}').format(date),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: index == viewModel.selectedIndex ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat.MMM('${CacheHelper.getString("lang")}').format(date),
                                  style: TextStyle(
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
              ),
            ),
          ],
        );
      }
    );
  }
}
