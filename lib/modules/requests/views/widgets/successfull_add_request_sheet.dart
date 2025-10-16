import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/modules/home/view_models/home.viewmodel.dart';
import 'package:rmemp/routing/app_router.dart';

class SuccessfullAddRequestSheet extends StatelessWidget {
var title;
var onTap;
SuccessfullAddRequestSheet({this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(builder: (context, value, child) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.sizeOf(context).width * 0.99,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 30),
            SvgPicture.asset("assets/images/svg/success_reqs.svg"),
            const SizedBox(height: 15,),
            Text(AppStrings.success.tr().toUpperCase(), style: const TextStyle(fontSize: 24,
                fontWeight: FontWeight.w700, color: Color(AppColors.dark))),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                AppStrings.yourRequestHasBeenSubmittedSuccessfully.tr().toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xff231F20),
                    fontWeight: FontWeight.w400,
                    fontSize: 14
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomElevatedButton(
                      onPressed: () async {
                       context.goNamed(AppRoutes.home.name,
                          pathParameters: {'lang': context.locale.languageCode,});
                      },
                      backgroundColor: const Color(AppColors.dark),
                      title: AppStrings.goToHome.tr().toUpperCase(),
                      isPrimaryBackground: true,
                      width: MediaQuery.sizeOf(context).width * 0.45,
                      isFuture: false),
                  const SizedBox(width: 5,),
                  CustomElevatedButton(
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
                      width: MediaQuery.sizeOf(context).width * 0.45,
                      backgroundColor: const Color(AppColors.dark),
                      title: title ?? AppStrings.goToRequest.tr().toUpperCase(),
                      isPrimaryBackground: true,
                      isFuture: false),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },);
  }
}
