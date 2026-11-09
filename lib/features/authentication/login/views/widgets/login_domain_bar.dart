import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/services/domain_selection_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small pill at the bottom of the login screen showing which company
/// domain the app is currently connected to.
class LoginDomainBar extends StatelessWidget {
  const LoginDomainBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || PlatformIs.web;
    final domain = DomainSelectionService.currentCleanDomain;

    return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 16 : 16.w,
            vertical: isWeb ? 8 : 8.h,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade800.withOpacity(0.5),
            borderRadius: BorderRadius.circular(isWeb ? 20 : 20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: isWeb ? 16 : 16.r,
                color: Colors.white70,
              ),
              SizedBox(width: isWeb ? 6 : 6.w),
              Flexible(
                child: Text(
                  domain,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 13 : 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
