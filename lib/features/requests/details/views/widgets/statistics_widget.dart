import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/models/requests_model.dart';
import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/widgets/vocation_list.widget.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/widgets/request_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class StatisticsModal extends StatelessWidget {
  final String employeeId;
  var type;
  List<RequestModel>? requests;
  final List<MapEntry<String, Balance>> empVocationBalance;
  StatisticsModal(
      {super.key,
        required this.employeeId,
        this.type,
        required this.empVocationBalance,
        this.requests});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatisticsBalanceList(
            vacationBalance: empVocationBalance,
            type: type,
            employeeId: employeeId,
          ),
          SizedBox(height: 14.h),
          ...requests!
              .map(
                (req) => RequestCard(
              reqType: type == "mine"
                  ? GetRequestsTypes.mine
                  : type == "myTeam"
                  ? GetRequestsTypes.myTeam
                  : type == "otherDepartment"
                  ? GetRequestsTypes.otherDepartment
                  : type == "allCompany"
                  ? GetRequestsTypes.allCompany
                  : GetRequestsTypes.myTeam,
              request: req,
            ),
          )
        ],
      ),
    );
  }
}

class StatisticsBalanceList extends StatelessWidget {
  final List<MapEntry<String, Balance>>? vacationBalance;
  final double? paddingBetweenVocations;
  final double? sectionPadding;
  final String? employeeId;
  var type;
  StatisticsBalanceList({
    this.vacationBalance,
    this.type,
    super.key,
    this.employeeId,
    this.paddingBetweenVocations,
    this.sectionPadding,
  });

  @override
  Widget build(BuildContext context) {
    final double pVocations = paddingBetweenVocations ?? 12.w;
    final double sPadding = sectionPadding ?? 32.w;

    return vacationBalance == null || vacationBalance?.isEmpty == true
        ? const SizedBox.shrink()
        : Padding(
      padding: EdgeInsets.only(bottom: 32.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: vacationBalance!
              .map((entry) => Padding(
            padding:
            EdgeInsets.only(right: pVocations),
            child: VacationCard(
              userId: employeeId,
              tap: false,
              type: type,
              vocation: entry,
              sectionPadding: sPadding,
              paddingBetweenVocations: pVocations,
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}
