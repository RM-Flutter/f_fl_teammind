import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/string_convert.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../data/models/summary_report_model.dart';

class SummaryReportsModal extends StatelessWidget {
  final List<SummaryReportModel> summaryReports;
  const SummaryReportsModal({super.key, required this.summaryReports});

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        gapH16,
        Container(
          height: MediaQuery.sizeOf(context).height * 0.4,
          child: ListView.builder(
            itemCount: summaryReports.length,
            itemBuilder: (context, index) {
              final report = summaryReports[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.s8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(AppColors.lightGreyEF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.black,),
                        const SizedBox(width: 15,),
                        Text(
                          '${report.month.toString().tr() ?? ''} - ${LocalizationService.isArabic(context: context) ? StringConvert.sanitizeDateStringArabic(report.year.toString()) : StringConvert.sanitizeDateString(report.year.toString())}',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ),
                    trailing:
                    Text('${report.duration} ${AppStrings.days.tr()}',  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),),
                  ),
                ),
              );
            },
          ),
        ),
        gapH16
      ],
    );
  }
}
