import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/widgets/details_loading/details_loading.widget.dart';
import 'package:app_test/features/requests/details/views/widgets/request_details_header_widget.dart';
import 'package:app_test/features/salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'package:app_test/features/salary_advance_requests/views/update_salary_advance_screen.dart';
import 'package:app_test/features/overtime_requests/controllers/overtime_requests_controller.dart';
import '../cubit/approvable_details_cubit.dart';
import '../cubit/approvable_details_state.dart';
import 'widgets/custom_tabbar_view_approvable_details.dart';
import 'widgets/manager_take_action_modal.dart';

class ApprovableDetailsScreen extends StatelessWidget {
  final String type;
  final String id;

  const ApprovableDetailsScreen({
    super.key,
    required this.type,
    required this.id,
  });

  void _showOvertimeUpdateDialog(
      BuildContext context, ApprovableDetailsCubit cubit, dynamic currentOvertime) {
    final controller = TextEditingController(text: currentOvertime?.toString() ?? '');
    final isArabic = LocalizationService.isArabic(context: context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isArabic ? 'تحديث ساعات الأوفرتايم' : 'Update Overtime Duration'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: isArabic ? 'أدخل الساعات الجديدة' : 'Enter new hours',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.buttons),
              ),
              onPressed: () async {
                if (controller.text.isEmpty) return;
                Navigator.pop(dialogContext);
                final ovProvider = provider_pkg.Provider.of<OvertimeRequestsProvider>(
                    context,
                    listen: false);
                final success = await ovProvider.updateRequestDuration(
                    context, id, controller.text);
                if (success && context.mounted) {
                  AlertsService.success(
                    context: context,
                    message: isArabic ? 'تم التحديث بنجاح' : 'Updated successfully',
                    title: isArabic ? 'نجاح' : 'Success',
                  );
                  cubit.fetchDetails(context: context, type: type, id: id);
                }
              },
              child: Text(isArabic ? 'حفظ' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);

    UserSettingsModel? userSettings;
    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      try {
        final gCache = json.decode(jsonString) as Map<String, dynamic>;
        userSettings = UserSettingsModel.fromJson(gCache);
      } catch (_) {}
    }

    return Scaffold(
      body: BlocProvider<ApprovableDetailsCubit>(
        create: (context) => ApprovableDetailsCubit()
          ..fetchDetails(context: context, type: type, id: id),
        child: BlocConsumer<ApprovableDetailsCubit, ApprovableDetailsState>(
          listener: (context, state) {
            if (state is ApprovableActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor:  Color(AppColors.successGreen),
                ),
              );
            } else if (state is ApprovableActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor:  Color(AppColors.failureRed),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ApprovableDetailsLoading || state is ApprovableDetailsInitial) {
              return const DetailsLoadingWidget();
            }

            if (state is ApprovableDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ApprovableDetailsCubit>().fetchDetails(
                                context: context,
                                type: type,
                                id: id,
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppColors.buttons),
                        ),
                        child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cubit = context.read<ApprovableDetailsCubit>();
            final details = cubit.detailsModel;

            if (details == null) {
              return const SizedBox.shrink();
            }

            final bool canTakeAction = details.takeAction == true ||
                details.canTakeActionAsSomeoneElse == true;

            final bool isApplicant = details.employeeId == null ||
                userSettings?.empId == null ||
                details.employeeId.toString() == userSettings?.empId.toString();

            final bool isPendingOrWaiting = details.status == 'waiting_seen' ||
                details.status == 'waiting_cancel' ||
                details.status == 'waiting' ||
                details.status == 'pending';

            final bool isCompleted = details.status == 'approved' ||
                details.status == 'refused' ||
                details.status == 'canceled';

            // Clean, modern, distinct action buttons
            final List<Widget> actionButtons = [];

            // 1. Manager Take Action Button
            if (canTakeAction) {
              actionButtons.add(
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.gavel_rounded, size: 16, color: Colors.white),
                  label: Text(
                    details.canTakeActionAsSomeoneElse == true
                        ? (isArabic ? 'اتخاذ إجراء نيابة عن موظف' : 'Act as Someone Else')
                        : 'can_take_action'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              );
            }

            // 2. Applicant Pending Actions: Ask Remember & Ask Ignore
            if (isPendingOrWaiting && isApplicant) {
              actionButtons.add(
                OutlinedButton.icon(
                  onPressed: () async => await cubit.askRemember(context: context),
                  icon: Icon(Icons.notifications_active_outlined,
                      size: 16, color: Color(AppColors.buttons)),
                  label: Text(
                    AppStrings.askRemember.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.buttons),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(AppColors.buttons)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              );
              actionButtons.add(
                OutlinedButton.icon(
                  onPressed: () async => await cubit.askIgnore(context: context),
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                  label: Text(
                    AppStrings.askIgnore.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              );
            }

            // 3. Applicant Edit/Update Actions for Salary Advance & Overtime
            if (isPendingOrWaiting && isApplicant && (type == 'salary_advance' || type == 'overtime')) {
              actionButtons.add(
                ElevatedButton.icon(
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
                      _showOvertimeUpdateDialog(context, cubit, details.duration);
                    }
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.white),
                  label: Text(
                    isArabic ? 'تعديل الطلب' : 'Edit Request',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              );
            }

            // 4. Applicant Completed Action: Complaint
            if (isCompleted && isApplicant) {
              actionButtons.add(
                OutlinedButton.icon(
                  onPressed: () async {
                    context.pushNamed(
                      AppRoutes.newComplainScreen.name,
                      pathParameters: {'lang': context.locale.languageCode},
                    );
                  },
                  icon: const Icon(Icons.report_problem_outlined, size: 16, color: Colors.purple),
                  label: Text(
                    AppStrings.complaint.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Original Request Details Header (Purple Curved App Bar)
                RequestDetailsHeaderWidget(
                  uId: userSettings?.empId,
                  rId: details.employeeId,
                  height: kIsWeb ? 320 : 340,
                  request: details,
                ),

                // Original TabBar View Layout
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 1100 : 1.sw,
                      ),
                      child: CustomTabbarViewApprovableDetails(details: details),
                    ),
                  ),
                ),

                if (kIsWeb) const SizedBox(height: 20),

                // Modern Floating Action Bar
                if (actionButtons.isNotEmpty)
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 1100 : 1.sw,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 24,
                          top: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: actionButtons,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
