import 'package:app_test/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../../data/models/approvable_details_model.dart';
import '../required_approvals_table_widget.dart';

class ManagerResponseTab extends StatelessWidget {
  final List<RequiredApprovalModel>? requiredApprovals;

  const ManagerResponseTab({super.key, this.requiredApprovals});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSizes.s10, bottom: AppSizes.s4),
        child: (requiredApprovals != null && requiredApprovals!.isNotEmpty)
            ? RequiredApprovalsTableWidget(
                requiredApprovals: requiredApprovals!,
              )
            : Center(
                child: Text(
                  AppStrings.thereIsStillNoResponseFromTheManager.tr(),
                  style: AppStyles.darkContent(context).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
      ),
    );
  }
}
