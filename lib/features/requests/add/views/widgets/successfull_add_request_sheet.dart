import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SuccessfullAddRequestSheet extends StatelessWidget {
  var title;
  var onTap;
  SuccessfullAddRequestSheet({this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    const isWeb = kIsWeb;
    return Consumer<HomeController>(builder: (context, value, child) {
      return Container(
        height: isWeb ? 0.4.sh : 0.5.sh,
        width: isWeb ? null : 0.99.sw,
        constraints: isWeb
            ? BoxConstraints(
          maxHeight: 0.6.sh,
          maxWidth: 500.w,
        )
            : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isWeb
              ? BorderRadius.circular(30.r)
              : BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 30.h),
            SvgPicture.asset("assets/images/svg/success_reqs.svg", width: 100.r, height: 100.r),
            SizedBox(height: 15.h,),
            Text(AppStrings.success.tr().toUpperCase(), style: AppStyles.heading(context).copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
            )),
            Padding(
              padding: EdgeInsets.all(15.r),
              child: Text(
                AppStrings.yourRequestHasBeenSubmittedSuccessfully.tr().toUpperCase(),
                textAlign: TextAlign.center,
                style: AppStyles.blackWithObacityContent(context).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomElevatedButton(
                          onPressed: () async {
                            context.goNamed(AppRoutes.home.name,
                                pathParameters: {'lang': context.locale.languageCode,});
                          },
                          backgroundColor: Color(AppColors.secondaryButton),
                          title: AppStrings.goToHome.tr().toUpperCase(),
                          titleWidget: Text(
                            AppStrings.goToHome.tr().toUpperCase(),
                            style: AppStyles.whiteContent(context).copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          isPrimaryBackground: true,
                          width:!kIsWeb? 0.45.sw : null,
                          isFuture: false),
                    ),
                  ),
                  SizedBox(width: kIsWeb ? 10.w : 5.w,),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomElevatedButton(
                          onPressed: onTap ?? () async {
                            // context.goNamed(AppRoutes.requests2.name, pathParameters: {
                            //   'type': 'mine',
                            //   'lang': context.locale.languageCode
                            // });
                            // Navigator.pop(context);
                            // Navigator.pop(context);
                            await context.pushNamed(AppRoutes.requests2.name,
                                pathParameters: {
                                  'type': 'mine',
                                  'lang': context.locale.languageCode
                                });
                          },
                          width: !kIsWeb? 0.45.sw : null,
                          backgroundColor: Color(AppColors.secondaryButton),
                          title: title ?? AppStrings.goToRequest.tr().toUpperCase(),
                          titleWidget: Text(
                            (title ?? AppStrings.goToRequest.tr()).toUpperCase(),
                            style: AppStyles.whiteContent(context).copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          isPrimaryBackground: true,
                          isFuture: false),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      );
    },);
  }
}
