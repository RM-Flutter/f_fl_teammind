import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_strings.dart';
import 'package:app_test/core/helpers/package_helper.dart';
import 'widgets/service_card_widget.dart';

class ServicesGridWidget extends StatelessWidget {
  final String? userPhotoUrl;
  final Function(String serviceId)? onServiceTap;

  const ServicesGridWidget({
    super.key,
    this.userPhotoUrl,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [
      if (PackageHelper.hasPackage('cv-hub'))
        ServiceCard(
          title: AppStrings.myCV.tr(),
          icon: Icons.description_outlined,
          iconColor: Color(AppColors.buttons),
          onTap: () => onServiceTap?.call('my_cv'),
        ),
      ServiceCard(
        title: AppStrings.smartCard.tr(),
        icon: Icons.credit_card,
        showProfileAvatar: false,
        avatarUrl: userPhotoUrl,
        iconColor: Color(AppColors.secondaryButton),
        onTap: () => onServiceTap?.call('smart_card'),
      ),
      if (PackageHelper.hasPackage('cv-hub'))
        ServiceCard(
          title: AppStrings.cvGenerator.tr(),
          icon: Icons.auto_fix_high,
          iconColor: const Color(AppColors.purple),
          onTap: () => onServiceTap?.call('cv_generator'),
        ),
      ServiceCard(
        title: AppStrings.salaryCalc.tr(),
        icon: Icons.calculate_outlined,
        showProfileAvatar: false,
        avatarUrl: userPhotoUrl,
        iconColor: const Color(AppColors.green),
        onTap: () => onServiceTap?.call('salary_calc'),
      ),
      ServiceCard(
        title: AppStrings.premiumTemplates.tr(),
        icon: Icons.stars_outlined,
        iconColor: Color(AppColors.warningYellow),
        onTap: () => onServiceTap?.call('premium_templates'),
      ),
      ServiceCard(
        title: AppStrings.jobOfferGenerator.tr(),
        icon: Icons.work_outline,
        iconColor: const Color(AppColors.lightBlue),
        onTap: () => onServiceTap?.call('job_offer_generator'),
      ),
      ServiceCard(
        title: AppStrings.vacationCalc.tr(),
        icon: Icons.beach_access_outlined,
        iconColor: const Color(AppColors.lightBlue),
        onTap: () => onServiceTap?.call('vacation_calc'),
      ),
      ServiceCard(
        title: AppStrings.personalityTest.tr(),
        icon: Icons.psychology_outlined,
        showProfileAvatar: false,
        avatarUrl: userPhotoUrl,
        iconColor: const Color(AppColors.pinkEE),
        onTap: () => onServiceTap?.call('personality_test'),
      ),
      ServiceCard(
        title: AppStrings.getTeamMindSystem.tr(),
        icon: Icons.groups_outlined,
        iconColor: Color(AppColors.secondaryButton),
        onTap: () => onServiceTap?.call('team_mind_system'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: AppResponsiveGrid(
        compact: 2,
        medium: 3,
        expanded: 4,
        rowHeight: 108,
        children: items,
      ),
    );
  }
}
