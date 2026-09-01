import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/requests/shared/ui/widgets/custom_request_details_button.widget.dart';
import 'package:app_test/features/salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'package:app_test/features/salary_advance_requests/views/update_salary_advance_screen.dart';
import 'package:app_test/features/requests/details/controller/request_details_controller.dart';
import '../../cubit/approvable_details_cubit.dart';
import '../../data/models/approvable_details_model.dart';
import 'manager_take_action_modal.dart';
import 'overtime_update_dialog.dart';

class ApprovableBottomActionBar extends StatelessWidget {
  final ApprovableDetailsModel details;
  final String type;
  final String id;
  final UserSettingsModel? userSettings;
  final ApprovableDetailsCubit cubit;

  const ApprovableBottomActionBar({
    super.key,
    required this.details,
    required this.type,
    required this.id,
    required this.userSettings,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);

    final bool isApplicant = details.employeeId == null ||
        userSettings?.empId == null ||
        details.employeeId.toString() == userSettings?.empId.toString();

    final String statusLower = (details.status ?? '').toLowerCase().trim();

    final bool isCompleted = statusLower == 'approved' ||
        statusLower == 'canceled' ||
        statusLower == 'refused' ||
        statusLower == 'rejected';

    final List<Widget> actionButtons = [];

    void addButton(Widget btn) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(const SizedBox(width: 8));
      }
      actionButtons.add(btn);
    }

    if (isCompleted) {
      // RULE 1: If status is approved, canceled, or refused (Completed)
      // Only Complaint (for Employee) and Statistics (for Manager) can show.

      if (isApplicant) {
        addButton(
          CustomRequestDetailsButton(
            title: AppStrings.complaint.tr(),
            color: Colors.purple.shade700,
            onPressed: () async {
              context.pushNamed(
                AppRoutes.newComplainScreen.name,
                pathParameters: {'lang': context.locale.languageCode},
              );
            },
          ),
        );
      }

      if (!isApplicant && details.employeeId != null) {
        addButton(
          CustomRequestDetailsButton(
            title: AppStrings.statistics.tr(),
            color: Color(AppColors.buttons),
            onPressed: () async {
              await RequestDetailsViewModel().showAndGetEmployeeStatistics(
                context,
                details.employeeId.toString(),
                type: type,
              );
            },
          ),
        );
      }
    } else {
      // RULE 2: Status is Active / Pending (Not approved, Not canceled, Not refused)

      // A. Employee Actions: Ask Remember & Ask Ignore
      if (isApplicant) {
        addButton(
          CustomRequestDetailsButton(
            title: AppStrings.askRemember.tr(),
            color: Color(AppColors.buttons),
            onPressed: () async => await cubit.askRemember(context: context),
          ),
        );
        addButton(
          CustomRequestDetailsButton(
            title: AppStrings.askIgnore.tr(),
            color: Colors.blueGrey.shade700,
            onPressed: () async => await cubit.askIgnore(context: context),
          ),
        );
      }

      // B. Manager Action: Statistics Button
      if (!isApplicant && details.employeeId != null) {
        addButton(
          CustomRequestDetailsButton(
            title: AppStrings.statistics.tr(),
            color: Color(AppColors.buttons),
            onPressed: () async {
              await RequestDetailsViewModel().showAndGetEmployeeStatistics(
                context,
                details.employeeId.toString(),
                type: type,
              );
            },
          ),
        );
      }

      // C. Attribute-driven: Take Action (if take_action / can_take_action == true)
      if (details.takeAction == true) {
        addButton(
          CustomRequestDetailsButton(
            title: 'take_action'.tr(),
            color: const Color(0xFFD32F2F),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: ManagerTakeActionModal(details: details),
                ),
              );
            },
          ),
        );
      }

      // D. Attribute-driven: Take Action As Someone Else (if can_take_action_as_someone_else == true)
      if (details.canTakeActionAsSomeoneElse == true) {
        addButton(
          CustomRequestDetailsButton(
            title: isArabic ? 'اتخاذ إجراء نيابة عن موظف' : 'Act as Someone Else',
            color: const Color(0xFFD32F2F),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: ManagerTakeActionModal(details: details),
                ),
              );
            },
          ),
        );
      }

      // E. Attribute-driven: Edit / Update Approval (if can_update_approval == true)
      if (details.canUpdateApproval == true) {
        addButton(
          CustomRequestDetailsButton(
            title: isArabic ? 'تعديل الطلب' : 'Edit Request',
            color: Colors.orange.shade800,
            onPressed: () async {
              if (type == 'salary_advance') {
                final salaryModel = SalaryAdvanceRequestModel(
                  id: details.id,
                  total: details.moneyValue?.toString(),
                  howLongToPay: details.duration?.toString(),
                  from: details.dateFrom,
                  status: details.status,
                );
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UpdateSalaryAdvanceScreen(
                      existingRequest: salaryModel,
                    ),
                  ),
                );
                if (context.mounted) {
                  cubit.fetchDetails(context: context, type: type, id: id);
                }
              } else if (type == 'overtime') {
                OvertimeUpdateDialog.show(
                  context,
                  cubit: cubit,
                  id: id,
                  type: type,
                  currentOvertime: details.duration,
                );
              } else {
                OvertimeUpdateDialog.show(
                  context,
                  cubit: cubit,
                  id: id,
                  type: type,
                  currentOvertime: details.duration,
                );
              }
            },
          ),
        );
      }
    }

    if (actionButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 1100 : 1.sw,
        ),
        child: Container(
          height: kIsWeb ? 50 : 56,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 10,
          ),
          margin: const EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: 32,
            top: 8,
          ),
          width: 1.sw,
          decoration: BoxDecoration(
            color: Color(AppColors.secondaryButton),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: actionButtons,
          ),
        ),
      ),
    );
  }
}
