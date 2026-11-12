import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

class PainterNotificationListViewItem extends StatefulWidget {
  final List notifications;
  final int index;
  const PainterNotificationListViewItem({super.key, required this.notifications, required this.index});

  @override
  State<PainterNotificationListViewItem> createState() => _PainterNotificationListViewItemState();
}

class _PainterNotificationListViewItemState extends State<PainterNotificationListViewItem> {
  @override
  Widget build(BuildContext context) {
    final notification = widget.notifications[widget.index];
    final bool seen = notification['seen'] == true;
    final String imageUrl = (notification['main_thumbnail'] is List &&
            (notification['main_thumbnail'] as List).isNotEmpty)
        ? ((notification['main_thumbnail'] as List)[0]['file'] ?? '')
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: AppCard(animateIn: true, 
        onTap: () {
          setState(() {
            notification['seen'] = true;
          });
          context.pushNamed(AppRoutes.notificationDetails.name,
              pathParameters: {
                'lang': context.locale.languageCode,
                'id': notification['id'].toString(),
              });
        },
        child: Row(
          children: [
            AppCardLeadingAvatar(
              imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
              icon: Icons.notifications_outlined,
              borderColor: seen
                  ? Colors.grey.shade400
                  : Color(AppColors.buttons),
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (notification['title'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context).copyWith(
                      fontWeight: seen ? FontWeight.w500 : FontWeight.w600,
                      color: seen
                          ? Colors.black.withOpacity(0.55)
                          : Color(AppColors.secondaryButton),
                    ),
                  ),
                  const SizedBox(height: AppSizes.s2),
                  Text(
                    DateFormat('dd/MM/yyyy', context.locale.languageCode)
                        .format(DateTime.parse(notification['created_at'])),
                    style: AppStyles.subtitleContent(context),
                  ),
                ],
              ),
            ),
            if (!seen) ...[
              const SizedBox(width: AppSizes.s8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(AppColors.buttons),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
