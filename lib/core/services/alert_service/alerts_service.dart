import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/routing/app_router.dart' show rootNavigatorKey;
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import '../../constants/app_colors.dart';
import 'custom_alert.dart';
import '../app_error_reporter.dart';
import 'package:app_test/core/constants/app_design.dart';

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
          title: title.tr(),
          context: context,
          message: message.tr(),
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
          title: title.tr(),
          message: message.tr(),
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
          title: title.tr(),
          message: message.tr(),
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
          title: title.tr(),
          message: message.tr(),
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

    // Never show technical text: swap it for the friendly message (and report it to Telegram)
    message = AppErrorReporter.safeMessage(message);
    if (AppErrorReporter.isTechnical(title)) {
      title = AppStrings.somethingWentWrong.tr();
    }

    final alert = CustomAlert(
      title: title,
      message: message,
      contentType: type,
      color: color,
    );

    // Shown in the app's top overlay, not through a Scaffold: a floating SnackBar is laid out by
    // every Scaffold on screen, and a screen that is closing (keyboard still open) has no room
    // for it, which threw "SnackBar presented off screen" on every frame.
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: _alertDuration,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: AppSizes.s10),
        padding: const EdgeInsets.only(top: AppSizes.s15, bottom: AppSizes.s5),
        backgroundColor: Colors.transparent,
        content: alert,
      ));
      return;
    }

    _currentAlert?.remove();
    _alertTimer?.cancel();
    late final OverlayEntry entry;
    void dismiss() {
      _alertTimer?.cancel();
      if (_currentAlert == entry) _currentAlert = null;
      if (entry.mounted) entry.remove();
    }

    entry = OverlayEntry(
      builder: (overlayContext) {
        final media = MediaQuery.of(overlayContext);
        return Positioned(
          left: 0,
          right: 0,
          bottom: media.viewInsets.bottom + media.padding.bottom + AppSizes.s10,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => dismiss(),
            child: GestureDetector(
              onTap: dismiss,
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSizes.s15, bottom: AppSizes.s5),
                  child: alert,
                ),
              ),
            ),
          ),
        );
      },
    );
    _currentAlert = entry;
    overlay.insert(entry);
    _alertTimer = Timer(_alertDuration, dismiss);
  }

  static const Duration _alertDuration = Duration(seconds: 5);
  static OverlayEntry? _currentAlert;
  static Timer? _alertTimer;

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
              Text(title.isEmpty ? 'loading'.tr() : '$title ...')
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
        bool destructive = false,
        String? confirmText,
        String? cancelText,
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
          // Clean confirmation card: icon in a tinted circle, title, message, then
          // No (outlined) and Yes (filled, red when [destructive]) side by side.
          child: Builder(builder: (dialogContext) {
            final accent = destructive
                ? Color(AppColors.failureRed)
                : Color(AppColors.buttons);
            final width = (MediaQuery.sizeOf(dialogContext).width - 32).clamp(0.0, 400.0);
            void confirm() {
              if (viewPassword == true) {
                if (form3Key != null && form3Key.currentState?.validate() == true) {
                  Navigator.of(dialogContext).pop(true);
                }
              } else {
                Navigator.of(dialogContext).pop(true);
              }
            }

            return Material(
              color: Colors.white,
              elevation: AppElevation.overlay,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (imageAssert != null)
                        Image.asset(imageAssert, width: 120, height: 80)
                      else
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: icon ??
                              Icon(
                                destructive
                                    ? Icons.warning_amber_rounded
                                    : Icons.help_outline_rounded,
                                color: accent,
                                size: 30,
                              ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(AppColors.secondaryButton),
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ],
                      if (viewPassword == true) ...[
                        const SizedBox(height: 16),
                        Form(
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
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Color(AppColors.secondaryButton),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.button),
                                ),
                                onPressed: () => Navigator.of(dialogContext).pop(false),
                                child: Text(
                                  cancelText ?? AppStrings.no.tr(),
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.button),
                                ),
                                onPressed: onTap ?? confirm,
                                child: Text(
                                  confirmText ?? AppStrings.yes.tr(),
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600),
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
            );
          }),
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
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        elevation: AppElevation.overlay,
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
                      child: SizedBox(
                        height: AppButtonSize.height,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                            foregroundColor: const Color(0xFF374151), // Dark grey text
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button,
                            ),
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: AppButtonSize.height,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48), // Rose/red danger color
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button,
                            ),
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
