import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/utils/helpers/media_query_values.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../common_modules_widgets/language_dropdown_button.widget.dart';
import '../../../constants/app_icons.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/app_config.service.dart';
import '../../../general_services/settings.service.dart';
import '../../../general_services/validation_service.dart';
import '../../../models/settings/general_settings.model.dart';
import '../../../routing/app_router.dart';
import '../../../utils/overlay_gradient_widget.dart';
import '../../../utils/widgets/text_form_widget.dart';
import '../view_models/login.viewmodel.dart';
import 'widgets/phone_number_field.dart';
import 'widgets/switch_row_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin,WidgetsBindingObserver {
  late AuthenticationViewModel viewModel;
  bool hidePassword = true;
  final ValueNotifier<bool> isLoginBySocial = ValueNotifier<bool>(false);

  late final AppConfigService appConfigServiceProvider;
  AppLifecycleState _appLifecycleState = AppLifecycleState.inactive;
  GeneralSettingsModel? generalSettings;
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
    viewModel = AuthenticationViewModel();
    viewModel.initializeAnimation(this);
    WidgetsBinding.instance.addObserver(this);
    print("ROLE FROM CACHE IS ---> ${CacheHelper.getString('role')}");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isLoginBySocial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var gCache;
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
    }
    print("Can Register is --> ${gCache['can_new_register']}");
    return ChangeNotifierProvider<AuthenticationViewModel>(
      create: (context) => viewModel,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
          child: SafeArea(
            child: Stack(
              children: [
                //const OverlayBackgroundGradientWidget(),
                AnimatedBackgroundWidget(),
                //const OverlayGradientWidget(),
                Positioned.fill(child: const OverlayGradientWidget()),

                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s24),
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60,),
                        Image.asset(
                          AppImages.logo,
                          height: AppSizes.s75,
                          width: AppSizes.s75,
                          fit: BoxFit.contain,
                        ),
                        gapH32,
                        // Login Page Headline
                        AutoSizeText(
                          AppStrings.loginTo.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        AutoSizeText(
                          AppStrings.yourAccount.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        gapH32,
                        // TOGGLE BUTTON TO TOGGLE BETWEEN (PHONE || EMAIL)
                        Consumer<AuthenticationViewModel>(
                          builder: (context, viewModel, child) {
                            return SwitchRow(
                              viewPhone: true,
                              isLoginPageStyle: true,
                              value: viewModel.isPhoneLogin,
                              onChanged: (newValue) =>
                                  viewModel.toggleLoginMethod(),
                            );
                          },
                        ),
                        gapH20,
                        // EMAIL OR PHONE FIELD
                        Consumer<AuthenticationViewModel>(
                          builder: (context, viewModel, child) {
                            return viewModel.isPhoneLogin
                                ? PhoneNumberField(
                                    controller: viewModel.phoneController,
                                    countryCodeController: viewModel.countryCodeController,
                                  )
                                : TextFormField(
                              controller:
                              viewModel.emailController,
                              decoration: InputDecoration(
                                hintText:
                                AppStrings.yourEmail.tr().toUpperCase(),
                              ),
                              validator: (value) =>
                                  ValidationService.validateEmail(
                                      value),
                            );
                          },
                        ),
                        gapH12,
                        // PASSWORD FIELD
                        TextFormField(
                          controller: viewModel.passwordController,
                          decoration: InputDecoration(
                            hintText: AppStrings.password.tr().toUpperCase(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) =>
                              ValidationService.validatePassword(value, login: true),
                          obscureText: hidePassword,
                        ),
                        gapH12,
                        // FORGET PASSSORD BUTTON
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                await viewModel.showForgotPasswordModal(
                                  context: context,
                                );
                              },
                              child: Text(AppStrings.forgetPassword.tr(),
                                  style:
                                      Theme.of(context).textTheme.headlineMedium),
                            ),
                          ],
                        ),
                        gapH16,
                        // LOGIN BUTTON
                        CustomElevatedButton(
                          title: AppStrings.login.tr(),
                          onPressed: () async {
                            if(viewModel.formKey.currentState!.validate()){
                              if(viewModel.isPhoneLogin && viewModel.phoneController.text.isEmpty){
                                Fluttertoast.showToast(
                                    msg: AppStrings.phoneNumberIsRequired.tr(),
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                                return;
                              }else{
                              await viewModel.login(context: context);
                              }
                            }
                          },
                          isPrimaryBackground: false,
                        ),
                        gapH16,
                        if(gCache != null && gCache['can_visit'] == true) CustomElevatedButton(
                          title: AppStrings.visitor.tr(),
                          onPressed: () async {
                            final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
                            await appConfigServiceProvider.setAuthenticationStatusWithToken(isLogin: true,  token:  "nulls");
                            context.goNamed(
                              AppRoutes.splash.name,
                              pathParameters: {'lang': context.locale.languageCode,},
                            );
                          },
                          isPrimaryBackground: false,
                        ),
                        const SizedBox(height: 25),
                        if(gCache != null && gCache != "") Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if ((gCache['login_types'] ?? [])
                                .contains('social_google'))
                              defaultCircularSocial(
                                context: context,
                                src: AppIcons.google,
                                onTap: () async {
                                  isLoginBySocial.value = true;
                                  final deviceUniqueId =
                                      Provider.of<AppConfigService>(context, listen: false).deviceInformation.deviceUniqueId;
                                  final url = '${AppConstants.socialLoginGoogle}$deviceUniqueId';
                                  await viewModel.loginWithSocial(context, url);
                                },
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            if ((gCache['login_types'] ?? [])
                                .contains('social_facebook'))
                              defaultCircularSocial(
                                context: context,
                                src: AppIcons.facebookColored,
                                onTap: () async {
                                  isLoginBySocial.value = true;
                                  final deviceUniqueId =
                                      Provider.of<AppConfigService>(context, listen: false).deviceInformation.deviceUniqueId;
                                  final url = '${AppConstants.socialLoginFacebook}$deviceUniqueId';
                                  await viewModel.loginWithSocial(context, url);
                                },
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            if ((gCache['login_types'] ?? [])
                                .contains('social_linkedin-openid'))
                              defaultCircularSocial(
                                context: context,
                                src: AppIcons.linkedInColored,
                                onTap: () async {
                                  isLoginBySocial.value = true;
                                  final deviceUniqueId =
                                      Provider.of<AppConfigService>(context, listen: false).deviceInformation.deviceUniqueId;
                                  final url = '${AppConstants.socialLoginLinkedIn}$deviceUniqueId';
                                  await viewModel.loginWithSocial(context, url);
                                },
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            if ((gCache['login_types'] ?? [])
                                .contains('social_apple'))
                              defaultCircularSocial(
                                context: context,
                                src: AppIcons.apple,
                                onTap: () async {
                                  isLoginBySocial.value = true;
                                  final deviceUniqueId =
                                      Provider.of<AppConfigService>(context, listen: false).deviceInformation.deviceUniqueId;
                                  final url = '${AppConstants.socialLoginAppleStore}$deviceUniqueId';
                                  await viewModel.loginWithSocial(context, url);
                                },
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                          ],
                        ),
                        const SizedBox(height: 25),
                         if(gCache != null && gCache['can_new_register'] == true) Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomElevatedButton(
                              width: AppSizes.s290,
                              title: AppStrings.createNewAccount.tr(),
                              isFuture: false,
                              onPressed: () => viewModel.showCreateAccountModal(
                                  context: context),
                              buttonStyle: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white, // Text color
                                disabledForegroundColor: Colors.transparent,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(AppSizes.s28),
                                  side: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              titleWidget: Text(
                                AppStrings.createNewAccount.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary,
                                ),
                              ),
                            )
                          ],
                                                  )
                      ],
                    ),
                  ),
                ),
                const LanguageDropdownButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget defaultCircularSocial({context, onTap, src, color}) => GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(5),
        height: 30,
        width: 30,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: SvgPicture.asset(src),
      ),
    );
Future<void> loginWithSocial(BuildContext context, String url) async {
  try {
    return await launchUrl(
      Uri.parse(url),
      customTabsOptions: CustomTabsOptions(
        colorSchemes: CustomTabsColorSchemes.defaults(
          toolbarColor: Theme.of(context).colorScheme.surface,
        ),
        shareState: CustomTabsShareState.on,
        urlBarHidingEnabled: true,
        showTitle: true,
        closeButton: CustomTabsCloseButton(
          icon: CustomTabsCloseButtonIcons.back,
        ),
      ),
      safariVCOptions: SafariViewControllerOptions(
        preferredBarTintColor: Theme.of(context).colorScheme.surface,
        preferredControlTintColor: Theme.of(context).colorScheme.onSurface,
        barCollapsingEnabled: true,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      ),
    );
  } catch (e) {
    debugPrint(e.toString());
  }
}

class AnimatedBackgroundWidget extends StatefulWidget {
  const AnimatedBackgroundWidget({super.key});

  @override
  State<AnimatedBackgroundWidget> createState() =>
      _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: AppSizes.s4,
          alignment: Alignment((animation.value * 2) - 1, 0),
          child: Image.asset(
            AppImages.loginBackground,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
