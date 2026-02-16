import 'package:app_test/core/constants/app_sizes.dart';
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
          gapH14,
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
    this.paddingBetweenVocations = AppSizes.s12,
    this.sectionPadding = AppSizes.s32,
  });

  @override
  Widget build(BuildContext context) {
    return vacationBalance == null || vacationBalance?.isEmpty == true
        ? const SizedBox.shrink()
        : Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s32),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: vacationBalance!
              .map((entry) => Padding(
            padding:
            EdgeInsets.only(right: paddingBetweenVocations!),
            child: VacationCard(
              userId: employeeId,
              tap: false,
              type: type,
              vocation: entry,
              sectionPadding: sectionPadding,
              paddingBetweenVocations: paddingBetweenVocations,
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}
