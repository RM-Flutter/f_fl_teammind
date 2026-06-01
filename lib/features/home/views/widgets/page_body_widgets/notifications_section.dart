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

class NotificationsSection extends StatelessWidget {
  final List<NotificationModel> notifications;
  final bool isFreeService;
  const NotificationsSection({super.key, required this.notifications, this.isFreeService = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            maxWidth: kIsWeb ? 1100 : double.infinity
        ),
        child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.s12.w, vertical: AppSizes.s20.h),
          // color: isFreeService ? Color(AppColors.secondaryButton) : Colors.transparent,
          color:  Color(AppColors.secondaryButton),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.myNotifications.tr(),
                      style: AppStyles.titleTextContent(context).copyWith(
                        fontSize: 16.sp, 
                        fontWeight: FontWeight.w700,
                        // color: isFreeService ? const Color(AppColors.pink) : null,
                        color: isFreeService ? const Color(AppColors.pink) : Colors.white,
                        letterSpacing: kIsWeb ? 0.3 : null,
                      )),
                  GestureDetector(
                    onTap: () {
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
                    child: Text(
                      AppStrings.viewAll.tr(),
                      style: AppStyles.titleTextContent(context).copyWith(
                        fontSize: 12.sp,
                        // color: isFreeService ? Colors.white.withValues(alpha: 0.8) : null,
                        color:  Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h,),
              ListView.separated(
                padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  reverse: false,
                  itemBuilder: (context, index) => NotificationCard(
                    notification: notifications[index],
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 8.h,),
                  itemCount: (notifications.length > 8)? 8 : notifications.length)
            ],
          ),
        ),
      ),
    );
  }
}
