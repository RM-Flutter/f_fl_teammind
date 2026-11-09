import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/notifications_model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/widgets/notification_card.widget.dart';
import 'package:app_test/features/main_layout/controllers/main_controller.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:app_test/features/more/notifications/views/notification_screen.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';

class NotificationsSection extends StatelessWidget {
  final List<NotificationModel> notifications;
  final bool isFreeService;
  const NotificationsSection({super.key, required this.notifications, this.isFreeService = false});

  @override
  Widget build(BuildContext context) {
    // Show only unread notifications on the Home Screen
    final unreadNotifications = notifications.where((n) => n.seen != true && n.seen != 1 && n.seen != "1").toList();

    if (unreadNotifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ConstrainedBox(
        // Width on web is set by the home screen (same as the other sections)
        constraints: const BoxConstraints(maxWidth: double.infinity),
        child: Container(
          alignment: Alignment.topCenter,
          // Full-bleed dark block; content keeps the page padding so it lines up (rule 2).
          padding: AppSpacing.sectionPadding,
          color: Color(AppColors.secondaryButton),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: AppStrings.myNotifications.tr(),
                color: isFreeService ? const Color(AppColors.pink) : Colors.white,
                actionColor: Colors.white.withValues(alpha: 0.8),
                onViewAll: () {
                  if (isFreeService) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(true),
                      ),
                    );
                  } else {
                    Provider.of<MainLayoutController>(context, listen: false)
                        .onItemTapped(
                      context: context,
                      page: NavbarPages.page,
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sectionHeaderGap),
              // NotificationCard already adds AppSpacing.cardGap under itself.
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => NotificationCard(
                    notification: unreadNotifications[index],
                  ),
                  itemCount: (unreadNotifications.length > 8)? 8 : unreadNotifications.length)
            ],
          ),
        ),
      ),
    );
  }
}
