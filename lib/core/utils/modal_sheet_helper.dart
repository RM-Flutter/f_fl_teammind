import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/widgets/app_filter_actions.widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';

import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';

abstract class ModalSheetHelper {
  static Future<OperationResult<Map<String, dynamic>>?> showModalSheet(
      {required BuildContext context,
        required Widget modalContent,
        required double height,
        required bool viewProfile,
        bool fitContent = false,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (BuildContext context) => fitContent
          ? _FitContentSheet(
              maxHeight: height,
              title: title,
              viewProfile: viewProfile,
              id: id,
              child: modalContent,
            )
          : AnimatedContainer(
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
                      borderRadius: BorderRadius.circular(AppRadius.xs)),
                ), gapH24,
                // Modal Sheet title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: viewProfile == true
                          ? Text(title!,
                              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                    color: Color(AppColors.buttons),
                                  ))
                          : AppFilterTitle(title!),
                    ),
                    if(viewProfile == true) ...[
                      const SizedBox(width: AppSizes.s8),
                      CustomElevatedButton(
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
                        title: AppStrings.viewProfile.tr(),
                        titleSize: 12,
                        isFuture: false,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
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

/// Sheet whose height follows its content (up to [maxHeight]); long content scrolls. Same handle,
/// title and padding as the fixed-height sheet.
class _FitContentSheet extends StatelessWidget {
  final double maxHeight;
  final String? title;
  final bool viewProfile;
  final dynamic id;
  final Widget child;

  const _FitContentSheet({
    required this.maxHeight,
    required this.title,
    required this.viewProfile,
    required this.id,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight + MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: AppSizes.s5,
                width: AppSizes.s80,
                decoration: BoxDecoration(
                    color: Color(AppColors.disableButton), borderRadius: BorderRadius.circular(AppRadius.xs)),
              ),
              gapH24,
              if (title != null) AppFilterTitle(title!),
              const SizedBox(height: AppSpacing.lg),
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
