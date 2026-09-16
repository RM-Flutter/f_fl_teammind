import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
//
class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key});
//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.background),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                color: Color(AppColors.failureRed),
                size: AppSizes.s80,
              ),
              gapH24,
              Text(
                "no_access_title".tr(),
                style: AppStyles.titleTextContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.s24,
                ),
                textAlign: TextAlign.center,
              ),
              gapH16,
              Text(
                "no_access_desc".tr(),
                style: AppStyles.bodyTextContent(context).copyWith(
                  fontSize: AppSizes.s16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              gapH32,
              CustomElevatedButton(
                title: 'logout'.tr(),
                isPrimaryBackground: true,
                onPressed: () async {
                  AlertsService.showLoading(context);
                  final appConfigServiceProvider =
                      Provider.of<AppConfigService>(context, listen: false);
                  await appConfigServiceProvider.logout(context);
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.goNamed(
                      AppRoutes.login.name,
                      pathParameters: {'lang': context.locale.languageCode},
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
