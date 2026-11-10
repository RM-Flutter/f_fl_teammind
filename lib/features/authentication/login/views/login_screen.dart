import 'package:app_test/core/constants/app_design.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/domain_selection_service.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/overlay_gradient_widget.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/language_dropdown_button.widget.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/platform/platform_is.dart';
import '../../../../core/routing/app_router.dart';
import 'widgets/create_account_section.dart';
import 'widgets/login_animated_background.dart';
import 'widgets/login_domain_bar.dart';
import 'widgets/login_form.dart';
import 'widgets/login_logo.dart';
import 'widgets/saved_accounts_button.dart';
import 'widgets/social_login_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  late AuthenticationController viewModel;
  final ValueNotifier<bool> isLoginBySocial = ValueNotifier<bool>(false);

  AppLifecycleState _appLifecycleState = AppLifecycleState.inactive;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        log("app in resumed");
        if (_appLifecycleState == AppLifecycleState.inactive &&
            isLoginBySocial.value == true) {
          viewModel.getDeviceToken(context: context);
          isLoginBySocial.value = false;
          log('AFTER LOGIN');
        } else {
          _appLifecycleState = AppLifecycleState.resumed;
        }
        break;
      case AppLifecycleState.inactive:
        log("app in inactive");
        _appLifecycleState = AppLifecycleState.inactive;
        break;
      case AppLifecycleState.paused:
        log("app in paused");
        _appLifecycleState = AppLifecycleState.paused;
        break;
      case AppLifecycleState.detached:
        log("app in detached");
        _appLifecycleState = AppLifecycleState.detached;
        break;
      case AppLifecycleState.hidden:
        log("app in hidden");
        _appLifecycleState = AppLifecycleState.hidden;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    viewModel = AuthenticationController();
    WidgetsBinding.instance.addObserver(this);
    debugPrint("ROLE FROM CACHE IS ---> ${CacheHelper.getString('role')}");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isLoginBySocial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? gCache;
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "null") {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          gCache = decoded;
        }
      } catch (e) {
        debugPrint("Error decoding USG in login_screen.dart: $e");
      }
    }

    String accountText = AppStrings.yourAccount.tr();
    if (gCache != null) {
      try {
        final data =
            gCache['data'] ?? gCache['general_settings']?['data'] ?? gCache;
        if (data != null &&
            data['app'] != null &&
            data['app']['name'] != null) {
          final names = data['app']['name'];
          if (names is Map) {
            accountText = names[context.locale.languageCode] ?? accountText;
          }
        }
      } catch (e) {
        debugPrint("Error getting app name: $e");
      }
    }

    // Figma sizes (scaled) on phones; web and tablets keep the fixed sizes.
    final compact = LayoutService.isPhoneLayout(context);
    final isWeb = kIsWeb || PlatformIs.web;
    // Spacing of the form. Plain numbers (no .h): scaled gaps grew on tall phones and pushed
    // the form down, leaving empty space under it.
    final topSpacer = compact ? AppSizes.loginTopSpacer : AppSizes.s24;
    final logoTitleGap = AppSizes.loginLogoTitleGap;
    final titleFormGap = AppSizes.loginTitleFormGap;
    final belowButtonGap = compact
        ? AppSizes.loginBelowButtonGap.h
        : (isWeb ? AppSizes.s16 : AppSizes.s16.h);
    // Form width: the screen minus 24 on each side on phones, at most 420 on wider windows.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = compact
        ? screenWidth - AppSizes.loginSidePadding * 2
        : AppSizes.loginMaxWidth;
    final smallButtonWidth = compact ? AppSizes.buttonSmallWidth.w : null;
    final smallButtonHeight = compact ? AppSizes.buttonSmallHeight.h : null;

    return ChangeNotifierProvider<AuthenticationController>(
      create: (context) => viewModel,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Stack(
                children: [
                  const LoginAnimatedBackground(),
                  const Positioned.fill(child: OverlayGradientWidget()),
                  Positioned.fill(
                    // One scroll for the whole page: the form first, then the footer (Create New
                    // Account + the domain pill). minHeight + spaceBetween keeps the footer at the
                    // bottom of a tall screen and lets it scroll after the form on a short one, so
                    // nothing is pinned over anything. No Spacer / Expanded / IntrinsicHeight: the
                    // form holds LayoutBuilders (AutoSizeText) that cannot be measured that way.
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(
                            child: SizedBox(
                              width: contentWidth,
                              child: Form(
                                key: viewModel.formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [

                                        // Clear of the Saved accounts / language buttons.
                                        SizedBox(
                                            height: MediaQuery.paddingOf(context).top +
                                                AppSizes.loginTopBarClearance),
                                  SizedBox(height: topSpacer),
                                  const LoginLogo(),
                                  // SizedBox(height: logoTitleGap),
                                  // Login Page Headline
                                  AutoSizeText(
                                    "${AppStrings.loginTo.tr()}\n$accountText",
                                    textAlign: TextAlign.center,
                                    style: AppStyles.whiteHeading(context)
                                        .copyWith(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w400,
                                      height: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: titleFormGap),

                                  LoginForm(viewModel: viewModel),

                                  SizedBox(height: belowButtonGap),
                                  // ADD COMPANY BUTTON
                                  CustomElevatedButton(
                                    width: smallButtonWidth,
                                    height: smallButtonHeight,
                                    title: AppStrings.addCompany.tr(),
                                    onPressed: () async {
                                      await CacheHelper.deleteData(
                                          key: "last_sent_fcm_token");
                                      await DomainSelectionService
                                          .resetDomainSelection();
                                      if (context.mounted) {
                                        DioHelper.initail(context);
                                        context.goNamed(
                                          AppRoutes.splash.name,
                                          pathParameters: {
                                            'lang': context.locale.languageCode
                                          },
                                        );
                                      }
                                    },
                                    isPrimaryBackground: false,
                                  ),
                                  SizedBox(height: belowButtonGap),
                                  if (gCache != null &&
                                      gCache['can_visit'] == true)
                                    CustomElevatedButton(
                                      width: smallButtonWidth,
                                      height: smallButtonHeight,
                                      title: AppStrings.visitor.tr(),
                                      onPressed: () async {},
                                      isPrimaryBackground: false,
                                    ),
                                  if (gCache != null &&
                                      gCache['can_visit'] == true)
                                    SizedBox(height: belowButtonGap),

                                  SocialLoginSection(
                                    gCache: gCache,
                                    viewModel: viewModel,
                                    isLoginBySocial: isLoginBySocial,
                                  ),
                                  // Same VISIBLE gap as between the buttons above: the
                                  // Create Account button has no visible outline, so its
                                  // empty top padding (~(height - text) / 2) is subtracted.
                                  if (gCache != null &&
                                      gCache['can_new_register'] == true)
                                    SizedBox(
                                        height: compact
                                            ? (belowButtonGap -
                                                    (AppSizes.createAccountHeight.h -
                                                            15.sp) /
                                                        2)
                                                .clamp(0.0, belowButtonGap)
                                            : belowButtonGap),
                                  CreateAccountSection(
                                    gCache: gCache,
                                    viewModel: viewModel,
                                  ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(height: AppSpacing.section),
                                        const SizedBox(height: AppSpacing.sm),
                                        const LoginDomainBar(),
                                        SizedBox(
                                            height: MediaQuery.paddingOf(context)
                                                    .bottom +
                                                AppSpacing.md),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SavedAccountsButton(),
                  const LanguageDropdownButton()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
