import 'package:app_test/core/constants/app_sizes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/models/requests_model.dart';
import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/widgets/vocation_list.widget.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/widgets/request_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';
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
          SizedBox(height: AppSizes.s14),
          ...requests!
              .map(
                (req) => ApprovableCardWidget(
                  request: req,
                  isForDepartment: false,
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.approvableDetails.name,
                      pathParameters: {
                        'type': 'requests', // Vacation
                        'id': req.id.toString(),
                        'lang': context.locale.languageCode,
                      },
                    );
                  },
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
    final double pVocations = paddingBetweenVocations ?? 12;
    final double sPadding = sectionPadding ?? 32;

    return vacationBalance == null || vacationBalance?.isEmpty == true
        ? const SizedBox.shrink()
        : Padding(
      padding: EdgeInsets.only(bottom: AppSizes.s32),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: vacationBalance!
              .where((entry) {
                final b = entry.value;
                final bool isTaken = b.max == -1 && b.available == -1;
                if (!isTaken) {
                  final availNum = num.tryParse(b.available?.toString() ?? '');
                  if (availNum != null && availNum < 0) {
                    return false;
                  }
                }
                return true;
              })
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
