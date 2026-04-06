import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final bool hasNewNotifications;
  final VoidCallback onTap;
  final int numOfUnreadNotifications;

  const NotificationIcon(
      {super.key,
      required this.onTap,
      required this.hasNewNotifications,
      required this.numOfUnreadNotifications});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap.call(),
      child: Stack(
        children: [
          Container(
            width: AppSizes.s50.w,
            height: AppSizes.s40.h,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: Colors.white, width: 2.w)),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: AppSizes.s28.r,
            ),
          ),
          if (hasNewNotifications)
            Positioned(
              left: 0,
              top: -2.h,
              child: Container(
                padding: EdgeInsets.all(AppSizes.s2.r),
                child: CircleAvatar(
                  backgroundColor: Color(AppColors.purple),
                  radius: 8.r,
                ),
                // child: Center(
                //   child: AutoSizeText(
                //     numOfUnreadNotifications.toString(),
                //     style: const TextStyle(color: Colors.white),
                //   ),
                // ),
              ),
            ),
        ],
      ),
    );
  }
}
