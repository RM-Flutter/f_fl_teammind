import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/views/requests_by_balance_empid_modal.widget.dart';

class ProfileBalanceWidget extends StatelessWidget {
  final double? paddingBetweenVocations;
  final double? sectionPadding;
  final List<Balance>? balance;
  final String? employeeId;
  final String? empDepartmentId;
  const ProfileBalanceWidget(
      {super.key,
      this.paddingBetweenVocations = AppSizes.s12,
      this.sectionPadding = AppSizes.s32,
      required this.employeeId,
      required this.empDepartmentId,
      required this.balance});

  @override
  Widget build(BuildContext context) {
    if (balance == null && balance?.isEmpty == true) {
      return const SizedBox.shrink();
    }

    List<Widget> balanceWidgets = balance!.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final bal = entry.value;

      return Padding(
        padding: EdgeInsets.only(right: paddingBetweenVocations!.w),
        child: BalanceCard(
          balance: bal,
          empDepartmentId: empDepartmentId,
          sectionPadding: sectionPadding,
          paddingBetweenVocations: paddingBetweenVocations,
          employeeId: employeeId,
          requestTypeId: index.toString(), // 👈 Pass index as the key
        ),
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.s32),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: balance == null
              ? List.generate(
                  3,
                  (index) => Padding(
                      padding: EdgeInsets.only(right: paddingBetweenVocations!.w),
                      child: ShimmerAnimatedLoading(
                        width: (LayoutService.getWidth(context) -
                                (AppSizes.s32 +
                                    ((paddingBetweenVocations ?? AppSizes.s0).w *
                                        3))) /
                            3,
                        height: AppSizes.s120,
                      )))
              : balanceWidgets,
        ),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  final bool? isInRequestsPage;
  final double? sectionPadding;
  final Balance balance;
  final double? paddingBetweenVocations;
  final Widget? customBody;
  final String? employeeId;
  final String? empDepartmentId;
  final String? requestTypeId;

  const BalanceCard(
      {super.key,
      this.isInRequestsPage = false,
      this.sectionPadding,
      required this.balance,
      this.paddingBetweenVocations,
      this.employeeId,
      this.empDepartmentId,
      this.requestTypeId,
      this.customBody});

  @override
  Widget build(BuildContext context) {
    double getResponsiveItemWidth(BuildContext context, {double? paddingBetweenVocations}) {
      final screenWidth = LayoutService.getWidth(context);
      int crossAxisCount;

      if (kIsWeb) {
        if (screenWidth > 1400) {
          crossAxisCount = 6; // شاشات كبيرة جدًا
        } else if (screenWidth > 1000) {
          crossAxisCount = 5; // لابتوب
        } else {
          crossAxisCount = 4; // تابلت أو شاشة صغيرة
        }
      } else {
        if (screenWidth > 600) {
          crossAxisCount = 4; // تابلت
        } else {
          crossAxisCount = 3; // موبايل
        }
      }

      final totalPadding = AppSizes.s32 + ((paddingBetweenVocations ?? AppSizes.s0).w * 2);
      return (screenWidth - totalPadding) / crossAxisCount;
    }

    bool isTaken = balance.max == -1 && balance.available == -1;
    final mainTextStyle = AppStyles.whiteContent(context).copyWith(
      fontWeight: FontWeight.normal,
      fontSize: AppSizes.s12,
      height: 1.0,
    );
    return InkWell(
      //TODO: ADD REAL BALANCE ID AFTER ADDED FROM BACKEND
      onTap: employeeId != null && employeeId?.isNotEmpty == true
          ? () async => await ModalSheetHelper.showModalSheet(
              context: context,viewProfile: false,
              title: AppStrings.requests.tr(),
              modalContent: RequestsByBalanceAndEmployeeIdModal(
                empDepartmentId: empDepartmentId!,
                  employeeId: employeeId!, requestTypeId: requestTypeId),
              height: LayoutService.getHeight(context) * 0.7)
          : null,
      child: Container(
        width: getResponsiveItemWidth(context, paddingBetweenVocations: paddingBetweenVocations),
        height: 140,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color:  Color(AppColors.secondaryButton),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title section - Two lines close to each other
            Text(
              (LocalizationService.isArabic(context: context)
                      ? balance.title!.ar!
                      : balance.title!.en!)
                  .toUpperCase()
                  .replaceAll(' ', '\n'),
              textAlign: TextAlign.center,
              style: AppStyles.whiteContent(context).copyWith(
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w700,
                // fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
            ),
            // Value section
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (isTaken ? AppStrings.taken.tr() : AppStrings.remaining.tr())
                      .toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    // fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${isTaken ? (balance.take?.toString() ?? '0') : (balance.available?.toString() ?? '0')} ${balance.type.toString().tr()}'
                      .toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                // Ensure the "FROM" line always takes space for alignment
                Text(
                  (balance.max != -1 && balance.available != -1)
                      ? '${AppStrings.from.tr()} ${(balance.max?.toString() ?? '0')}'
                          .toUpperCase()
                      : '',
                  textAlign: TextAlign.center,
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
