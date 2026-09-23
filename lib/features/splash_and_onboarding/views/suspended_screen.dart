import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum SuspendedErrorType {
  instanceSuspended,
  licenceDenied,
}

class SuspendedScreen extends StatelessWidget {
  final SuspendedErrorType errorType;
  final String? errorMessage;
  const SuspendedScreen({super.key, required this.errorType, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final bool isSuspended = errorType == SuspendedErrorType.instanceSuspended;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // الخروج من التطبيق كاملاً بدل الرجوع للخلف
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Color(AppColors.background),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.s32,
                vertical: AppSizes.s24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSuspended
                          ? Color(AppColors.failureRed).withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                    ),
                    child: Icon(
                      isSuspended
                          ? Icons.pause_circle_outline_rounded
                          : Icons.no_accounts_rounded,
                      size: 64,
                      color: isSuspended
                          ? Color(AppColors.failureRed)
                          : Colors.orange,
                    ),
                  ),
                  gapH32,
                  // Title
                  Text(
                    isSuspended
                        ? 'instance_suspended_title'.tr()
                        : 'licence_denied_title'.tr(),
                    style: AppStyles.titleTextContent(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.s22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  gapH16,
                  // Description
                  Text(
                    (errorMessage != null && errorMessage!.isNotEmpty)
                        ? errorMessage!
                        : (isSuspended
                            ? 'instance_suspended_desc'.tr()
                            : 'licence_denied_desc'.tr()),
                    style: AppStyles.bodyTextContent(context).copyWith(
                      fontSize: AppSizes.s15,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  gapH48,
                  // Divider
                  Divider(color: Colors.grey.shade200),
                  gapH24,
                  // Go to domain selection button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final appConfigService =
                            Provider.of<AppConfigService>(context, listen: false);
                        await appConfigService.logout(
                          context,
                          skipServerLogout: true,
                          skipNavigation: true,
                        );
                        if (context.mounted) {
                          context.goNamed(
                            AppRoutes.splash.name,
                            pathParameters: {'lang': context.locale.languageCode},
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: Text('go_to_domain_selection'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(AppColors.buttons),
                        side: BorderSide(color: Color(AppColors.buttons)),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.s14,
                          horizontal: AppSizes.s16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.s12),
                        ),
                        textStyle: AppStyles.bodyTextContent(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.s16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
