import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_strings.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 120, // Forces the height to be exactly 120 pixels
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final items = [
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
          return items[index];
        },
      ),
    );
  }
}
