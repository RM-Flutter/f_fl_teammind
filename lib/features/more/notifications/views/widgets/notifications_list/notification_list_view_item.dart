import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';


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
    final double iconSize = (MediaQuery.sizeOf(context).width * 0.22).clamp(60.0, 84.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s12),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(AppSizes.s15),
        child: Container(
          // no padding — icon fills full card height
          decoration: BoxDecoration(
            color: Color(AppColors.white),
            borderRadius: BorderRadius.circular(AppSizes.s15),
            border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.03),
                spreadRadius: 0,
                offset: Offset(0, 2),
                blurRadius: 6,
              )
            ],
          ),
          child: Row(
            children: [
              // Blue icon — fills card height, all corners rounded
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.s15 - 1),
                child: Container(
                  width: iconSize,
                  height: iconSize,
                  color: Color(AppColors.primary),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: iconSize,
                          height: iconSize,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => ShimmerAnimatedLoading(
                            width: iconSize,
                            height: iconSize,
                            circularRaduis: 0,
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: iconSize * 0.45,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: iconSize * 0.45,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy', context.locale.languageCode)
                            .format(DateTime.parse(notification['created_at'])),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFB0B7C3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (notification['title'] ?? '').toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: seen ? FontWeight.w400 : FontWeight.w700,
                          color: seen
                              ? Colors.black.withOpacity(0.5)
                              : Color(AppColors.dark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.s12),
            ],
          ),
        ),
      ),
    );
  }
}
