import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:rmemp/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../constants/app_images.dart';
import '../constants/app_sizes.dart';
import '../general_services/date.service.dart';
import '../models/notification.model.dart';
import 'cached_network_image_widget.dart';

class NotificationCard extends StatefulWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    String getPlaceholderImageDependsOnNotificationPType() {
      switch (widget.notification.ptype?.key?.toLowerCase()) {
        case 'event':
          return AppImages.notificationEvent;
        case 'birthday':
          return AppImages.notificationBirthDay;
        case 'offers':
          return AppImages.notificationOffers;
        case 'rules':
          return AppImages.notificationRules;
        default:
          return AppImages.notificationGeneral;
      }
    }

    return InkWell(
      onTap: (){
        setState(() {
          widget.notification!.seen = true;
        });
        context.pushNamed(AppRoutes.notificationDetails.name,
            pathParameters: {'lang': context.locale.languageCode,
              "id" : widget.notification.id!.toString(),
            });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.s8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.s15),
        ),
        child: Row(
          children: [
            widget.notification.mainThumbnail!.isNotEmpty
                ?ClipRRect(
              borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                              height: AppSizes.s75,
                              width: AppSizes.s75,
                              fit: BoxFit.cover,
                              imageUrl: widget.notification.mainThumbnail![0].file ?? "",
                              placeholder: (context, url) =>
                              const ShimmerAnimatedLoading(),
                              errorWidget: (context, url, error) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: AppSizes.s32,
                  color: Colors.white,
                              ),
                            ),
                )
                : Container(
                    height: AppSizes.s75,
                    width: AppSizes.s75,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.s15),
                      ),
                    ),
                    child: SvgPicture.asset("assets/images/svg/image_holder.svg"),
                  ),
            const SizedBox(width: 20,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: AutoSizeText(
                      DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.notification.createdAt) ?? '',
                      style: Theme.of(context).textTheme.labelSmall!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  gapH4,
                  Text(widget.notification.title ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.notification.seen == true? FontWeight.w300 : FontWeight.w700,
                        color: widget.notification.seen == true? Colors.black.withOpacity(0.5):const Color(0xff09051C)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
