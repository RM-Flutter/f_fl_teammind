import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/domain_selection_service.dart';
import 'package:app_test/core/utils/helpers/media_query_values.dart';
import 'package:app_test/core/utils/overlay_gradient_widget.dart';
import 'package:app_test/core/widgets/language_dropdown_button.widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_icons.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/validation_service.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../../../../core/platform/platform_is.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/webview_offers.dart';
import '../../shared/widgets/phone_number_field.dart';
import '../../shared/widgets/switch_row_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin,WidgetsBindingObserver {
  late AuthenticationController viewModel;
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
    viewModel = AuthenticationController();
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

  Widget _buildLogoImage() {
    final logoUrl = AppImages.logo;
    final isNetworkImage = logoUrl.startsWith('http://') || logoUrl.startsWith('https://');

    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        height: AppSizes.s100,
        width: AppSizes.s100,
        fit: BoxFit.contain,
        placeholder: (context, url) => Image.asset(
          'assets/images/general_images/logo.png',
          height: AppSizes.s100,
          width: AppSizes.s100,
          fit: BoxFit.contain,
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/general_images/logo.png',
          height: AppSizes.s100,
          width: AppSizes.s100,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Image.asset(
        logoUrl,
        height: AppSizes.s100,
        width: AppSizes.s100,
        fit: BoxFit.contain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var gCache;
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
    }
    print("Can Register is --> ${gCache['can_new_register']}");
    return ChangeNotifierProvider<AuthenticationController>(
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
                        horizontal: AppSizes.s24,
                        vertical: (kIsWeb || PlatformIs.web) ? AppSizes.s32 : 0,
                      ),
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: (kIsWeb || PlatformIs.web) ? 40 : 60),
                            _buildLogoImage(),
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
                            Consumer<AuthenticationController>(
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
                            Consumer<AuthenticationController>(
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
                                // التحقق من صحة النموذج أولاً
                                if(!viewModel.formKey.currentState!.validate()){
                                  return;
                                }

                                // إذا كان مختار BY PHONE، التحقق من أن رقم الهاتف غير فارغ وصحيح
                                if(viewModel.isPhoneLogin){
                                  final phoneText = viewModel.phoneController.text.trim();
                                  if(phoneText.isEmpty){
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
                                  }
                                  // التحقق من أن الرقم يحتوي على أرقام فقط
                                  if(!RegExp(r'^[0-9]+$').hasMatch(phoneText)){
                                    Fluttertoast.showToast(
                                        msg: AppStrings.pleaseEnterValidPhoneNumber.tr(),
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 5,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );
                                    return;
                                  }
                                }

                                // إذا تم التحقق بنجاح، إرسال الطلب
                                await viewModel.login(context: context);
                              },
                              isPrimaryBackground: false,
                            ),
                            gapH16,
                            // LOGIN BUTTON
                            CustomElevatedButton(
                              title: AppStrings.addCompany.tr(),
                              onPressed: () async {
                                // لا تحذف fcm_token حتى start_app بعد اختيار الدومين يبعته. احذف last_sent فقط.
                                await CacheHelper.deleteData(key: "last_sent_fcm_token");
                                await DomainSelectionService.resetDomainSelection();
                                if (context.mounted) {
                                  DioHelper.initail(context);
                                  context.goNamed(
                                    AppRoutes.splash.name,
                                    pathParameters: {'lang': context.locale.languageCode},
                                  );
                                }
                              },
                              isPrimaryBackground: false,
                            ),
                            gapH16,
                            if(gCache != null && gCache['can_visit'] == true)
                              CustomElevatedButton(
                                title: AppStrings.visitor.tr(),
                                onPressed: () async {
                                  // context.pushNamed(
                                  //   AppRoutes.freeServicesHome.name,
                                  //   pathParameters: {'lang': context.locale.languageCode,},
                                  // );
                                },
                                isPrimaryBackground: false,
                              ),
                            SizedBox(height: (kIsWeb || PlatformIs.web) ? 30 : 25),
                            if(gCache != null && gCache != "") Container(
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
                            ),
                            if(gCache != null && gCache['can_new_register'] == true)...[
                              SizedBox(height: (kIsWeb || PlatformIs.web) ? 30 : 25),
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: (kIsWeb || PlatformIs.web) ? AppSizes.s48 : AppSizes.s16,
                                ),
                                child: Row(
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
                                ),
                              ),
                            ],
                            //  Container(
                            //   padding: EdgeInsets.only(
                            //     bottom: (kIsWeb || PlatformIs.web) ? AppSizes.s48 : AppSizes.s16,
                            //   ),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       CustomElevatedButton(
                            //         width: AppSizes.s290,
                            //         title: AppStrings.addCompany.tr(),
                            //         isFuture: false,
                            //         onPressed: () async {
                            //           const url = 'https://lab.r-m.dev/frontend/emp-app-request/create';
                            //
                            //           // On web, open in browser. On mobile, use WebView
                            //           if (PlatformIs.web) {
                            //             final uri = Uri.parse(url);
                            //             if (await url_launcher.canLaunchUrl(uri)) {
                            //               await url_launcher.launchUrl(
                            //                 uri,
                            //                 mode: url_launcher.LaunchMode.externalApplication
                            //               );
                            //             } else {
                            //               if (mounted) {
                            //                 ScaffoldMessenger.of(context).showSnackBar(
                            //                   SnackBar(content: Text('Could not open $url')),
                            //                 );
                            //               }
                            //             }
                            //           } else {
                            //             // On mobile, navigate to WebView screen
                            //             await Navigator.push(
                            //               context,
                            //               MaterialPageRoute(
                            //                 builder: (context) => Scaffold(
                            //                   appBar: AppBar(
                            //                     toolbarHeight: 0.0,
                            //                   ),
                            //                   body: WebViewStackOffers(url),
                            //                 ),
                            //               ),
                            //             );
                            //           }
                            //         },
                            //         titleWidget: Text(
                            //           AppStrings.addCompany.tr(),
                            //           style: Theme.of(context)
                            //               .textTheme
                            //               .titleMedium
                            //               ?.copyWith(
                            //             color: Theme.of(context)
                            //                 .colorScheme
                            //                 .onPrimary,
                            //           ),
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
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
    await custom_tabs.launchUrl(
      Uri.parse(url),
      customTabsOptions: custom_tabs.CustomTabsOptions(
        colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(
          toolbarColor: Theme.of(context).colorScheme.surface,
        ),
        shareState: custom_tabs.CustomTabsShareState.on,
        urlBarHidingEnabled: true,
        showTitle: true,
        closeButton: custom_tabs.CustomTabsCloseButton(
          icon: custom_tabs.CustomTabsCloseButtonIcons.back,
        ),
      ),
      safariVCOptions: custom_tabs.SafariViewControllerOptions(
        preferredBarTintColor: Theme.of(context).colorScheme.surface,
        preferredControlTintColor: Theme.of(context).colorScheme.onSurface,
        barCollapsingEnabled: true,
        dismissButtonStyle: custom_tabs.SafariViewControllerDismissButtonStyle.close,
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
        final bgUrl = !kIsWeb ? AppImages.loginBackground : AppImages.loginBackgroundWeb;
        final isNetworkImage = bgUrl.startsWith('http://') || bgUrl.startsWith('https://');

        return FractionallySizedBox(
          widthFactor: AppSizes.s4,
          alignment: Alignment((animation.value * 2) - 1, 0),
          child: isNetworkImage
              ? CachedNetworkImage(
            imageUrl: bgUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              !kIsWeb
                  ? 'assets/images/login_images/login_background.png'
                  : 'assets/images/login_images/login-bg.jpg',
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => Image.asset(
              !kIsWeb
                  ? 'assets/images/login_images/login_background.png'
                  : 'assets/images/login_images/login-bg.jpg',
              fit: BoxFit.cover,
            ),
          )
              : Image.asset(
            bgUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
