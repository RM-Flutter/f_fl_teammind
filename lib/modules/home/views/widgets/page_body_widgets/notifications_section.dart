import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/routing/app_router.dart';
import '../../../../../common_modules_widgets/notification_card.widget.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../general_services/app_theme.service.dart';
import '../../../../../models/notification.model.dart';

class NotificationsSection extends StatelessWidget {
  final List<NotificationModel> notifications;
  const NotificationsSection({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: kIsWeb ? 1100 : double.infinity
        ),
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.s12, vertical: AppSizes.s20),
          color: const Color(AppColors.dark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.myNotifications.tr(),
                      style: TextStyle(
                        color: const Color(0xffFFFFFF), 
                        fontSize: 19, 
                        fontWeight: FontWeight.w700,
                        // تحسين الخطوط في الويب
                        letterSpacing: kIsWeb ? 0.3 : null,
                      )),
                  GestureDetector(
                    onTap: (){
                      CacheHelper.deleteData(key: "value");
                      context.pushNamed(AppRoutes.notification.name,
                          pathParameters: {'lang': context.locale.languageCode,
                          });
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
