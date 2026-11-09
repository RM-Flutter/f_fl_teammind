import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../constants/app_sizes.dart';
import '../models/notifications_model.dart';
import '../routing/app_router.dart';
import '../services/date_service.dart';
import '../services/localization_service.dart';
import '../utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'cached_network_image_widget.dart';
import 'package:app_test/features/more/notifications/controllers/notification_controller.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

class NotificationCard extends StatefulWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    final bool seen = widget.notification.seen == true;
    final String? imageUrl = (widget.notification.mainThumbnail != null &&
            widget.notification.mainThumbnail!.isNotEmpty)
        ? widget.notification.mainThumbnail![0].file
        : null;
    final String dateText = DateService.formatDate(
            LocalizationService.isArabic(context: context) ? "ar" : "en",
            context,
            widget.notification.createdAt) ??
        '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: AppCard(animateIn: true, 
        onTap: () {
          if (widget.notification.seen != true &&
              widget.notification.id != null) {
            Provider.of<NotificationProviderModel>(context, listen: false)
                .markAsRead(context, widget.notification.id!);
          }
          setState(() {
            widget.notification.seen = true;
          });
          context.pushNamed(
            AppRoutes.notificationDetails.name,
            pathParameters: {
              'lang': context.locale.languageCode,
              'id': widget.notification.id!.toString(),
            },
          );
        },
        child: Row(
          children: [
            AppCardLeadingAvatar(
              imageUrl: imageUrl,
              icon: Icons.notifications_outlined,
              borderColor: seen
                  ? Colors.grey.shade400
                  : Color(AppColors.buttons),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.notification.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context).copyWith(
                      fontWeight: seen ? FontWeight.w500 : FontWeight.w600,
                      color: seen
                          ? Colors.black.withOpacity(0.55)
                          : Color(AppColors.secondaryButton),
                    ),
                  ),
                  if (dateText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateText,
                      style: AppStyles.subtitleContent(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (!seen) ...[
              const SizedBox(width: 8),
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
