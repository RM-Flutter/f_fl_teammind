import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/repos/payroll_service.dart';

class PayrollListItemWidget extends StatelessWidget {
  final PayrollModel payroll;
  const PayrollListItemWidget({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async => await context.pushNamed(
              AppRoutes.payrollDetails.name,
              extra: payroll,
              pathParameters: {'lang': context.locale.languageCode}),
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: AppSizes.s14.h, horizontal: AppSizes.s16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                )
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                gapW8,
                 Image.asset(
                  "assets/images/new-cale.png",
                  color: Colors.black,
                  width: 24.r,
                  height: 24.r,
                ),
                gapW12,
                Expanded(
                  child: Text(
                    PayrollRepo.formatDate(payroll.dateTo, context) ?? '',
                    style: AppStyles.blackContent(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.s14.sp,
                    ),
                  ),
                ),
                gapW8,
                Container(
                  height: AppSizes.s28.r,
                  width: AppSizes.s28.r,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary),
                  child: Icon(
                    Icons.arrow_forward_outlined,
                    color: Colors.white,
                    size: AppSizes.s12.r,
                  ),
                ),
              ],
            ),
          ),
        ),
        gapH20
      ],
    );
  }
}
