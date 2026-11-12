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
import 'package:app_test/core/constants/app_design.dart';

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

    final screenWidth = LayoutService.getWidth(context);
    final gap = (paddingBetweenVocations ?? AppSizes.s12).w;
    const horizontalPad = AppSizes.s32;
    final mobileBaseWidth = screenWidth.clamp(320.0, 430.0);
    final minItemWidth = (mobileBaseWidth - (horizontalPad + gap * 2)) / 3;

    double getResponsiveItemWidth(int itemCount) {
      final count = itemCount > 0 ? itemCount : 3;
      final distributedWidth =
          (screenWidth - horizontalPad - gap * (count - 1)) / count;
      return distributedWidth > minItemWidth ? distributedWidth : minItemWidth;
    }

    final filteredBalances = balance!
        .where((bal) {
          final bool isTaken = bal.max == -1 && bal.available == -1;
          if (!isTaken) {
            final availNum = num.tryParse(bal.available?.toString() ?? '');
            if (availNum != null && availNum < 0) {
              return false;
            }
          }
          return true;
        })
        .toList();

    final itemWidth = getResponsiveItemWidth(filteredBalances.length);

    List<Widget> balanceWidgets = filteredBalances
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key + 1;
      final bal = entry.value;

      return Padding(
        padding: EdgeInsets.only(
          right: entry.key < filteredBalances.length - 1 ? gap : 0,
        ),
        child: BalanceCard(
          balance: bal,
          empDepartmentId: empDepartmentId,
          sectionPadding: sectionPadding,
          paddingBetweenVocations: paddingBetweenVocations,
          cardWidth: itemWidth,
          employeeId: employeeId,
          requestTypeId: index.toString(), // 👈 Pass index as the key
        ),
      );
    }).toList();

    final shimmerItemWidth = getResponsiveItemWidth(3);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSizes.s32),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // cards share the height of the tallest one, so a long title never overflows or makes them uneven
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: balance == null
                  ? List.generate(
                      3,
                      (index) => Padding(
                          padding: EdgeInsets.only(right: index < 2 ? gap : 0),
                          child: ShimmerAnimatedLoading(
                            width: shimmerItemWidth,
                            height: AppSizes.s120,
                          )))
                  : balanceWidgets,
            ),
          ),
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
  final double? cardWidth;
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
      this.cardWidth,
      this.employeeId,
      this.empDepartmentId,
      this.requestTypeId,
      this.customBody});

  @override
  Widget build(BuildContext context) {
    double getResponsiveItemWidth(BuildContext context, {double? paddingBetweenVocations}) {
      final effectiveWidth = LayoutService.getWidth(context).clamp(320.0, 430.0);
      final totalPadding = AppSizes.s32 + ((paddingBetweenVocations ?? AppSizes.s0).w * 2);
      return (effectiveWidth - totalPadding) / 3;
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
        width: cardWidth ?? getResponsiveItemWidth(context, paddingBetweenVocations: paddingBetweenVocations),
        constraints: const BoxConstraints(minHeight: 140),
        padding: EdgeInsets.symmetric(vertical: AppSizes.s16, horizontal: AppSizes.s12),
        decoration: BoxDecoration(
          color:  Color(AppColors.secondaryButton),
          borderRadius: BorderRadius.circular(AppRadius.md),
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
                      ,
                  textAlign: TextAlign.center,
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    // fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: AppSizes.s4),
                // FittedBox (not AutoSizeText): the row above uses IntrinsicHeight, which can't measure a LayoutBuilder
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${isTaken ? (balance.take?.toString() ?? '0') : (balance.available?.toString() ?? '0')} ${balance.type.toString().tr()}'
                        ,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: AppStyles.whiteContent(context).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.s4),
                // Ensure the "FROM" line always takes space for alignment
                Text(
                  (balance.max != -1 && balance.available != -1)
                      ? '${AppStrings.from.tr()} ${(balance.max?.toString() ?? '0')}'
                          
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
