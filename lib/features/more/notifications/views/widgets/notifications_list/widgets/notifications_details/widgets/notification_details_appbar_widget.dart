import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/bookmark_widgets/bookmark_button.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/more/notifications/data/models/get_one_notification_model.dart';
import 'package:share_plus/share_plus.dart';


class NotificationDetailsAppbarWidget extends StatelessWidget {
  NotificationSingleModel? notificationSingleModel;
  NotificationDetailsAppbarWidget({this.notificationSingleModel});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s32.r),
            bottomRight: Radius.circular(AppSizes.s32.r)),
      ),
      child: Stack(
        children: [
          // Background image using the Home screen asset
          ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.s32.r),
                bottomRight: Radius.circular(AppSizes.s32.r)),
            child: Image.asset(
              "assets/images/png/tasks-app-bar.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300.h,
            ),
          ),
          // Content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                            ),
                            BookmarkButton(
                              routeName: AppRoutes.notificationDetails.name,
                              defaultTitle: "Notification Info",
                              iconColor: Colors.white,
                            ),
                          ],
                        ),
                        Text(
                          AppStrings.notificationInfo.tr(),
                          style: AppStyles.whiteHeading(context).copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        (notificationSingleModel?.title?.toString() ?? "").toUpperCase(),
                        style: AppStyles.whiteHeading(context).copyWith(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMetadataItem(
                          context,
                          icon: Icons.calendar_today_outlined,
                          text: notificationSingleModel?.createdAt != null
                              ? DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context) ? "ar" : "en")
                                  .format(DateTime.parse(notificationSingleModel!.createdAt.toString()))
                              : "",
                        ),
                        SizedBox(width: 15.w),
                        _buildMetadataItem(
                          context,
                          icon: Icons.folder_open_outlined,
                          text: (notificationSingleModel?.ptype?.key ?? "").toUpperCase(),
                        ),
                        SizedBox(width: 15.w),
                        GestureDetector(
                          onTap: () {
                             if (notificationSingleModel != null) {
                              Share.share(
                                "${notificationSingleModel!.title}\n\n"
                                "${notificationSingleModel!.content?.replaceAll(RegExp(r'<[^>]*>'), '') ?? ''}",
                              );
                            }
                          },
                          child: _buildMetadataItem(
                            context,
                            icon: Icons.share_outlined,
                            text: "SHARE",
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(BuildContext context, {required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: (Color(AppColors.buttons)), size: 16.r),
        SizedBox(width: 6.w),
        Text(
          text,
          style: AppStyles.whiteContent(context).copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}