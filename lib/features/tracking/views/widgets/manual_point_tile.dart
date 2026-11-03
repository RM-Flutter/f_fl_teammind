import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../data/models/tracking_point.model.dart';

class ManualPointTile extends StatelessWidget {
  final TrackingPointModel point;
  final bool isLast;
  final bool? isArabic;

  const ManualPointTile({
    super.key,
    required this.point,
    this.isLast = false,
    this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAr = isArabic ?? LocalizationService.isArabic(context: context);

    Color pointColor;
    IconData pointIcon;

    if (point.isStartPoint) {
      pointColor = const Color(0xff2D6A4F); // Green
      pointIcon = Icons.play_arrow_rounded;
    } else if (point.isEndPoint) {
      pointColor = const Color(0xffc72c41); // Red
      pointIcon = Icons.stop_rounded;
    } else if (point.isManual) {
      pointColor = Color(AppColors.buttons); // Blue
      pointIcon = Icons.location_on_rounded;
    } else {
      pointColor = const Color(0xff606060);
      pointIcon = Icons.circle;
    }

    final formattedTime = DateFormat('hh:mm a', isAr ? 'ar' : 'en').format(point.recordedAt);
    final displayLabel = point.getDisplayLabel(isArabic: isAr);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with vertical line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: pointColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: pointColor.withOpacity(0.5), width: 1.5),
                ),
                child: Icon(pointIcon, size: 15, color: pointColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: Color(AppColors.divider),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayLabel,
                          style: AppStyles.content(context).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff231F20),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: AppStyles.subtitleContent(context).copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff606060),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        size: 11,
                        color: Color(AppColors.hintText),
                      ),
                      const SizedBox(width: 4),
                      Text('acc_m'.tr(namedArgs: {'to_string_as_fixed': '${point.accuracy.toStringAsFixed(0)}', 'to_string_as_fixed2': '${point.latitude.toStringAsFixed(4)}', 'to_string_as_fixed3': '${point.longitude.toStringAsFixed(4)}'}),
                        style: AppStyles.hintContent(context).copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
