import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/services/validation_service.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import 'custom_alert.dart';

enum DialogAnimationTypes { none, feedIn, open, opacity }

abstract class AlertsService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  static success({
    required String title,
    required BuildContext context,
    required String message,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        _showSnackbar(
          title: title,
          context: context,
          message: message,
          type: AlertType.success,
        );
      }
    });
  }

  static warning({
    required BuildContext context,
    required String message,
    required String title,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        _showSnackbar(
          context: context,
          title: title,
          message: message,
          type: AlertType.warning,
        );
      }
    });
  }

  static info({
    required BuildContext context,
    required String message,
    required String title,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        _showSnackbar(
          context: context,
          title: title,
          message: message,
          color: Color(AppColors.disableButton),
          type: AlertType.warning,
        );
      }
    });
  }

  static error({
    required BuildContext context,
    required String message,
    required String title,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        _showSnackbar(
          context: context,
          title: title,
          message: message,
          type: AlertType.failure,
        );
      }
    });
  }

  static void _showSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    required AlertType type,
    Color? color,
  }) {
    // Check if the context is mounted before proceeding
    if (!context.mounted) return;

    final snackBar = SnackBar(
      duration: const Duration(seconds: 5),
      elevation: 0,
      padding: const EdgeInsets.only(top: AppSizes.s15, bottom: AppSizes.s5),
      backgroundColor: Colors.transparent,
      content: CustomAlert(
        title: title,
        message: message,
        contentType: type,
        color: color,
      ),
    );

    // Use the direct context instead of the global key
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<void> showLoading(BuildContext context,
      {String title = ''}) async {
    var loadingWidget = Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      shape: null,
      child: SizedBox(
        width: AppSizes.s200,
        height: AppSizes.s150,
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(AppColors.buttons)),
              ),
              const SizedBox(width: AppSizes.s15),
              Text(title.isEmpty ? 'Loading ...' : '$title, please wait')
            ],
          ),
        ),
      ),
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => loadingWidget,
    );
  }

  static Future<bool> confirmMessage(
      BuildContext context,
      String title, {
        onTap,
        String? message,
        form3Key,
        passwordForRemoveAccountController,
        String? imageAssert,
        DialogAnimationTypes animationType = DialogAnimationTypes.feedIn,
        Widget? icon,
        bool? viewPassword = false,
        bool? isArabic,
      }) async {
    var formKey = GlobalKey<FormState>();
    var result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, a1, a2, _) => _dialogAnimated(
        animation: a1,
        type: animationType,
        body: Form(
          key: formKey,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: Color(AppColors.background),
            child: SizedBox(
              width: PlatformIs.mobile ? AppSizes.s320 : AppSizes.s600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (imageAssert != null) const SizedBox(height: AppSizes.s60),
                  if (imageAssert == null) const SizedBox(height: AppSizes.s50),
                  imageAssert != null
                      ? Image.asset(imageAssert,
                      width: AppSizes.s150, height: AppSizes.s90)
                      : icon != null
                      ? SizedBox(
                    width: AppSizes.s150,
                    height: AppSizes.s90,
                    child: icon,
                  )
                      : const SizedBox(),
                  if (imageAssert != null) const SizedBox(height: AppSizes.s25),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: AppSizes.s25, color: Color(AppColors.black)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.s20),
                  message != null
                      ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s30),
                    child: Text(
                      message,
                      style: TextStyle(
                          fontSize: AppSizes.s18, color: Color(0xff606060)),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 4,
                    ),
                  )
                      : const SizedBox(),
                  const SizedBox(height: AppSizes.s10),
                  if (viewPassword == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Form(
                        key: form3Key,
                        child: TextFormField(
                          controller: passwordForRemoveAccountController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                              hintText: AppStrings.password.tr()),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppStrings.pleaseEnterAPassword.tr();
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSizes.s10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ButtonTheme(
                          minWidth: AppSizes.s100,
                          height: AppSizes.s60,
                          child: CustomElevatedButton(
                            width: AppSizes.s100,
                            backgroundColor:
                            Color(AppColors.buttons),
                            titleSize: AppSizes.s18,
                            title: AppStrings.yes.tr().toUpperCase(),
                            onPressed: onTap ??
                                    () async {
                                  if (viewPassword == true) {
                                    if (form3Key != null &&
                                        form3Key.currentState?.validate() ==
                                            true) {
                                      Navigator.of(dialogContext)
                                          .pop(true); // بيرجع موافقة
                                    }
                                  } else {
                                    Navigator.of(dialogContext)
                                        .pop(true); // بيرجع موافقة
                                  }
                                },
                          )),
                      const SizedBox(width: 15.0),
                      ButtonTheme(
                        minWidth: AppSizes.s100,
                        height: AppSizes.s60,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0)),
                          color: Color(AppColors.background),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                            return;
                          },
                          child: Text(AppStrings.no.tr(),
                              style:
                              TextStyle(color: Color(AppColors.buttons))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s50),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return result ?? false;
  }

  static Widget _dialogAnimated({
    required Widget body,
    required DialogAnimationTypes type,
    required Animation<double> animation,
  }) {
    switch (type) {
      case DialogAnimationTypes.feedIn:
        return Column(children: <Widget>[
          Spacer(flex: (animation.value * 100).toInt() + 1),
          Opacity(
              opacity: animation.value,
              child: Transform.scale(scale: animation.value, child: body)),
          const Spacer(flex: 100),
        ]);
      case DialogAnimationTypes.opacity:
        return Column(children: <Widget>[
          const Spacer(),
          Opacity(opacity: animation.value, child: body),
          const Spacer(),
        ]);
      case DialogAnimationTypes.open:
        return Column(children: <Widget>[
          const Spacer(),
          Opacity(
            opacity: animation.value,
            child: SizeTransition(
              axisAlignment: 0.0,
              sizeFactor: animation,
              child: body,
            ),
          ),
          const Spacer(),
        ]);
      default:
        return SizedBox(child: body);
    }
  }

  static Future<bool> customConfirm({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 12,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Warning / Delete Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2), // Soft pink/rose background
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFE4E6), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFF43F5E), // Premium rose/red color
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827), // Very dark grey/black
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563), // Medium slate grey
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                          foregroundColor: const Color(0xFF374151), // Dark grey text
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(
                          'no'.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48), // Rose/red danger color
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'yes'.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }
}
