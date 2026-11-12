import 'package:app_test/core/constants/app_sizes.dart';
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
import 'package:app_test/core/constants/app_design.dart';

class SuccessfullAddRequestSheet extends StatelessWidget {
  var title;
  var onTap;
  SuccessfullAddRequestSheet({this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(builder: (context, value, child) {
      return Container(
        height: 0.5.sh,
        width: 0.99.sw,
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          children: [
            SizedBox(height: AppSizes.s30),
            SvgPicture.asset("assets/images/svg/success_reqs.svg", width: 100, height: 100),
            SizedBox(height: 15,),
            Text(AppStrings.success.tr(), style: AppStyles.heading(context).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
            )),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                AppStrings.yourRequestHasBeenSubmittedSuccessfully.tr(),
                textAlign: TextAlign.center,
                style: AppStyles.blackWithObacityContent(context).copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.s10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomElevatedButton(
                          onPressed: () async {
                            await Future.delayed(const Duration(milliseconds: 1000));
                            value.getHome(context);
                            context.goNamed(AppRoutes.home.name,
                                pathParameters: {'lang': context.locale.languageCode,});
                          },
                          backgroundColor: Color(AppColors.secondaryButton),
                          title: AppStrings.goToHome.tr(),
                          titleWidget: Text(
                            AppStrings.goToHome.tr(),
                            style: AppStyles.whiteContent(context).copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          isPrimaryBackground: true,
                          width:!kIsWeb? 0.45.sw : null,
                          isFuture: false),
                    ),
                  ),
                  SizedBox(width: kIsWeb ? 10 : 5,),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomElevatedButton(
                          onPressed: onTap ?? () async {
                            await Future.delayed(const Duration(milliseconds: 1200)); // Wait for backend to sync
                            Navigator.pop(context); // close the success sheet
                            // Replace the AddRequestScreen with Requests2Screen
                            context.pushReplacementNamed(AppRoutes.requests2.name,
                                pathParameters: {
                                  'type': 'mine',
                                  'lang': context.locale.languageCode
                                });
                          },
                          width: !kIsWeb? 0.45.sw : null,
                          backgroundColor: Color(AppColors.secondaryButton),
                          title: title ?? AppStrings.goToRequest.tr(),
                          titleWidget: Text(
                            (title ?? AppStrings.goToRequest.tr()),
                            style: AppStyles.whiteContent(context).copyWith(
                              fontSize: 12,
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
            SizedBox(height: AppSizes.s20),
          ],
        ),
      );
    },);
  }
}
