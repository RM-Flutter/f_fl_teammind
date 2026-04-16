import 'package:app_test/core/platform/platform_is.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_icons.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';

class SocialLoginSection extends StatelessWidget {
  final Map<String, dynamic>? gCache;
  final AuthenticationController viewModel;
  final ValueNotifier<bool> isLoginBySocial;

  const SocialLoginSection({
    super.key,
    required this.gCache,
    required this.viewModel,
    required this.isLoginBySocial,
  });

  @override
  Widget build(BuildContext context) {
    if (gCache == null || gCache == "") return const SizedBox.shrink();

    final loginTypes = gCache?['login_types'] ?? [];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (kIsWeb || PlatformIs.web) ? AppSizes.s16 : 0,
        vertical: (kIsWeb || PlatformIs.web) ? AppSizes.s8 : 0,
      ),
      constraints: BoxConstraints(
        maxWidth: (kIsWeb || PlatformIs.web)
            ? MediaQuery.of(context).size.width < 600
                ? double.infinity
                : 400
            : double.infinity,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: (kIsWeb || PlatformIs.web) ? AppSizes.s12 : AppSizes.s8,
        children: [
          if (loginTypes.contains('social_google'))
            _CircularSocialButton(
              src: AppIcons.google,
              onTap: () async {
                isLoginBySocial.value = true;
                final deviceUniqueId = Provider.of<AppConfigService>(context, listen: false)
                    .deviceInformation
                    .deviceUniqueId;
                final url = '${AppConstants.socialLoginGoogle}$deviceUniqueId';
                await viewModel.loginWithSocial(context, url);
              },
            ),
          if (loginTypes.contains('social_facebook'))
            _CircularSocialButton(
              src: AppIcons.facebookColored,
              onTap: () async {
                isLoginBySocial.value = true;
                final deviceUniqueId = Provider.of<AppConfigService>(context, listen: false)
                    .deviceInformation
                    .deviceUniqueId;
                final url = '${AppConstants.socialLoginFacebook}$deviceUniqueId';
                await viewModel.loginWithSocial(context, url);
              },
            ),
          if (loginTypes.contains('social_linkedin-openid'))
            _CircularSocialButton(
              src: AppIcons.linkedInColored,
              onTap: () async {
                isLoginBySocial.value = true;
                final deviceUniqueId = Provider.of<AppConfigService>(context, listen: false)
                    .deviceInformation
                    .deviceUniqueId;
                final url = '${AppConstants.socialLoginLinkedIn}$deviceUniqueId';
                await viewModel.loginWithSocial(context, url);
              },
            ),
          if (loginTypes.contains('social_apple'))
            _CircularSocialButton(
              src: AppIcons.apple,
              onTap: () async {
                isLoginBySocial.value = true;
                final deviceUniqueId = Provider.of<AppConfigService>(context, listen: false)
                    .deviceInformation
                    .deviceUniqueId;
                final url = '${AppConstants.socialLoginAppleStore}$deviceUniqueId';
                await viewModel.loginWithSocial(context, url);
              },
            ),
        ],
      ),
    );
  }
}

class _CircularSocialButton extends StatelessWidget {
  final String src;
  final VoidCallback onTap;

  const _CircularSocialButton({
    required this.src,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(5),
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(AppColors.background),
        ),
        child: SvgPicture.asset(src),
      ),
    );
  }
}
