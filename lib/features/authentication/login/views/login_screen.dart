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
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/overlay_gradient_widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/language_dropdown_button.widget.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/platform/platform_is.dart';
import '../../../../core/routing/app_router.dart';
import 'widgets/create_account_section.dart';
import 'widgets/login_animated_background.dart';
import 'widgets/login_form.dart';
import 'widgets/login_logo.dart';
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
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
    }

    return ChangeNotifierProvider<AuthenticationController>(
      create: (context) => viewModel,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Stack(
            children: [
              const LoginAnimatedBackground(),
              const Positioned.fill(child: OverlayGradientWidget()),

              Container(
                width: double.infinity,
                height: (kIsWeb || PlatformIs.web) ? double.infinity : null,
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width < 600
                      ? double.infinity
                      : 400,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.s24.w,
                      vertical: (kIsWeb || PlatformIs.web) ? AppSizes.s32 : 0,
                    ),
                    child: Form(
                      key: viewModel.formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: (kIsWeb || PlatformIs.web) ? 40 : 60),
                          const LoginLogo(),
                          SizedBox(height: AppSizes.s32.h),
                          // Login Page Headline
                          AutoSizeText(
                            "${AppStrings.loginTo.tr()}\n${AppStrings.yourAccount.tr()}",
                            textAlign: TextAlign.center,
                            style: AppStyles.whiteHeading(context).copyWith(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: AppSizes.s32.h),

                          LoginForm(viewModel: viewModel),

                          SizedBox(height: AppSizes.s16.h),
                          // ADD COMPANY BUTTON
                          CustomElevatedButton(
                            title: AppStrings.addCompany.tr(),
                            onPressed: () async {
                              await CacheHelper.deleteData(key: "last_sent_fcm_token");
                              await DomainSelectionService.resetDomainSelection();
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
                          SizedBox(height: AppSizes.s16.h),
                          if (gCache != null && gCache['can_visit'] == true)
                            CustomElevatedButton(
                              title: AppStrings.visitor.tr(),
                              onPressed: () async {},
                              isPrimaryBackground: false,
                            ),

                          SocialLoginSection(
                            gCache: gCache,
                            viewModel: viewModel,
                            isLoginBySocial: isLoginBySocial,
                          ),

                          CreateAccountSection(
                            gCache: gCache,
                            viewModel: viewModel,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const LanguageDropdownButton()
            ],
          ),
        ),
      ),
    );
  }
}