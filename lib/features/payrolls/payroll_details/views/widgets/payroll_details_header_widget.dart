import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/repos/payroll_service.dart';

class PayrollDetailsHeaderWidget extends StatelessWidget {
  final PayrollModel? payroll;
  const PayrollDetailsHeaderWidget({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s300,
      clipBehavior: Clip.antiAlias,
      width: 1.sw,
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/png/tasks-app-bar.png"),
            fit: BoxFit.fill,
            opacity: 0.4),
        color: Color(AppColors.secondaryButton),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s28),
            bottomRight: Radius.circular(AppSizes.s28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBarWithBookmark(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: "${AppStrings.payroll.tr()} - ${PayrollRepo.formatDate(payroll?.dateTo, context)}",
            titleStyle: AppStyles.whiteContent(context).copyWith(fontSize: 16, fontWeight: FontWeight.w400),
            centerTitle: true,
            routeName: AppRoutes.payrollDetails.name,
            defaultTitle: AppStrings.payroll.tr(),
            bookmarkIconColor: Colors.white,
            leading: Padding(
              padding: EdgeInsets.all(AppSizes.s10),
              child: InkWell(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2)),
                  child: Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.white,
                    size: AppSizes.s18,
                  ),
                ),
              ),
            ),
          ),
          gapH12,
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 1100 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                       '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.s22,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    gapH12,
                    if (payroll?.netPayable != null)
                      PayrollHeaderTileWidget(
                          title: AppStrings.netSalary.tr(),
                          subTitle:
                              '${payroll!.netPayable!.toString()} ${payroll?.currency ?? ''}',
                          icon: Icons.attach_money_outlined),
                    gapH12,
                    if (payroll?.dateTo != null)
                      PayrollHeaderTileWidget(
                          title: AppStrings.date.tr(),
                          subTitle:
                              PayrollRepo.formatDate(payroll?.dateTo, context) ?? '',
                          icon: Icons.calendar_month_outlined)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PayrollHeaderTileWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  const PayrollHeaderTileWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: !kIsWeb ? 0.6.sw : 0.4.sw,
      decoration: BoxDecoration(
          color: const Color(AppColors.navyBlue),
          borderRadius: BorderRadius.circular(AppSizes.s6)),
      padding: EdgeInsets.symmetric(
          horizontal: AppSizes.s6, vertical: AppSizes.s12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Color(AppColors.buttons),
            size: 20,
          ),
          gapW12,
          Expanded(
            child: AutoSizeText(
              title,
              style: AppStyles.whiteContent(context).copyWith(
                  fontSize: AppSizes.s12,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: AutoSizeText(
              subTitle,
              style: AppStyles.whiteContent(context).copyWith(
                  fontSize: AppSizes.s12,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
