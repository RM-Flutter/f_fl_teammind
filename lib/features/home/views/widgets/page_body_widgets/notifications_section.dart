import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/notifications_model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/widgets/notification_card.widget.dart';
import 'package:app_test/features/main_layout/controllers/main_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NotificationsSection extends StatelessWidget {
  final List<NotificationModel> notifications;
  const NotificationsSection({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            maxWidth: kIsWeb ? 1100 : double.infinity
        ),
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.s12, vertical: AppSizes.s20),
          color: Color(AppColors.dark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.myNotifications.tr(),
                      style: TextStyle(
                        color: Color(AppColors.white), 
                        fontSize: 19, 
                        fontWeight: FontWeight.w700,
                        // تحسين الخطوط في الويب
                        letterSpacing: kIsWeb ? 0.3 : null,
                      )),
                  GestureDetector(
                    onTap: () {
                      Provider.of<MainLayoutController>(context, listen: false)
                          .onItemTapped(
                        context: context,
                        page: NavbarPages.page,
                      );
                    },
                    child: Text(
                      AppStrings.viewAll.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                AppThemeService.colorPalette.quinaryTextColor.color,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              ListView.separated(
                padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  reverse: false,
                  itemBuilder: (context, index) => NotificationCard(
                    notification: notifications[index],
                  ),
                  separatorBuilder: (context, index) => const SizedBox(height: 8,),
                  itemCount: (notifications.length > 8)? 8 : notifications.length)
            ],
          ),
        ),
      ),
    );
  }
}
