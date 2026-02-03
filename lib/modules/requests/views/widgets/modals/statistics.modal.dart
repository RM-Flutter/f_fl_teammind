import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/common_modules_widgets/request_card.widget.dart';
import 'package:rmemp/models/request.model.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:rmemp/services/requests.services.dart';
import '../../../../../common_modules_widgets/vocation_list.widget.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../models/settings/user_settings_2.model.dart';
import '../../../view_models/statistics.viewmodel.dart';

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
    return ChangeNotifierProvider(
      create: (_) => StatisticsViewModel(),
      child: Consumer<StatisticsViewModel>(
        builder: (context, viewModel, child) {
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
        },
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
