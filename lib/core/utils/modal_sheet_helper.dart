import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';

import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

abstract class ModalSheetHelper {
  static Future<OperationResult<Map<String, dynamic>>?> showModalSheet(
      {required BuildContext context,
        required Widget modalContent,
        required double height,
        required bool viewProfile,
        id,
        String? title}) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? 550 : double.infinity,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.s26)),
      ),
      builder: (BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height + MediaQuery.of(context).viewInsets.bottom,
        color: Colors.white,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.s16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Modal Sheet Holder
                Container(
                  height: AppSizes.s5,
                  width: AppSizes.s80,
                  decoration: BoxDecoration(
                      color: Color(AppColors.disableButton),
                      borderRadius: BorderRadius.circular(AppSizes.s4)),
                ), gapH24,
                // Modal Sheet title
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(title!,
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: Color(AppColors.buttons),
                          )),
                    ),
                    if(viewProfile == true) 
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomElevatedButton(
                          width: 130,
                          onPressed: () async{
                            context.pushNamed(
                                AppRoutes.employeeDetails.name,
                                pathParameters: {
                                  'id': id.toString(),
                                  'lang':
                                  context.locale.languageCode
                                });
                          },
                          title: AppStrings.viewProfile.tr().toUpperCase(),
                          titleSize: 12,
                          isFuture: false,
                        ),
                      ),
                  ],
                ),
                gapH26,
                // Modal Sheet content
                Expanded(
                    child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                        child: modalContent
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
