import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/routing/app_router.dart';

import '../constants/app_sizes.dart';
import '../models/operation_result.model.dart';
import 'package:flutter/material.dart';

abstract class ModalSheetHelper {
  static Future<OperationResult<Map<String, dynamic>>?> showModalSheet(
      {required BuildContext context,
      required Widget modalContent,
      required double height,
      required bool viewProfile,
        id,
       String? title}) async {
    if (kIsWeb) {
      // Use showDialog for web to ensure it's fully visible
      return await showDialog<OperationResult<Map<String, dynamic>>>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          final screenHeight = MediaQuery.of(dialogContext).size.height;
          final screenWidth = MediaQuery.of(dialogContext).size.width;
          return Dialog(
            alignment: Alignment.center,
            insetPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.2,
              vertical: screenHeight * 0.1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.s26),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.5,
                maxWidth: 550,
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.white,
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20, vertical: AppSizes.s16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Modal Sheet title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(title!,
                                style: Theme.of(dialogContext).textTheme.headlineLarge!),
                          ),
                          if(viewProfile == true) CustomElevatedButton(
                            width: 130,
                            onPressed: () async{
                              Navigator.of(dialogContext).pop();
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
                        ],
                      ),
                      const SizedBox(height: AppSizes.s20),
                      // Modal Sheet content
                      Flexible(
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
        },
      );
    } else {
      // Use showModalBottomSheet for mobile
      return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
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
                        color: const Color(0xffB9C0C9),
                        borderRadius: BorderRadius.circular(AppSizes.s4)),
                  ), gapH24,
                  // Modal Sheet title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(title!,
                            style: Theme.of(context).textTheme.headlineLarge!),
                      ),
                      if(viewProfile == true)  Spacer(),
                      if(viewProfile == true)   CustomElevatedButton(
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
}
