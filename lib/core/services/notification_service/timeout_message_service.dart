import 'package:app_test/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

import 'package:app_test/main.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/routing/app_router.dart' show rootNavigatorKey;

import '../../constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';

class TimeoutMessage {
  static int currentMessageId = 0;
  static OverlayEntry? _activeOverlay;
  static Future<dynamic> Function()? beforeClose;

  static Future hide() async {
    if (_activeOverlay == null) {
      return;
    }

    if (beforeClose != null) {
      await beforeClose?.call();
      _activeOverlay?.remove();
      _activeOverlay = null;
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    try {
      _activeOverlay?.remove();
    } catch (err) {
      debugPrint('cannot remove old overlay ${err.toString}');
    }
    _activeOverlay = null;
  }

  static Future show(
      {required String title,
        required String logoWithWihteText,
        String? soundFilePath,
        String? message,
        double top = 30,
        double left = 20,
        double width = 200,
        bool showSilent = false,
        int timeoutMiniseconds = 5000,
        onClick}) async {
    // if (showSilent == true && soundFilePath != null) {
    //   SoundService.init(soundFilePath: soundFilePath);
    //   SoundService.play();
    // }
    await hide();
    int local = ++currentMessageId; // track the messages

    _activeOverlay = OverlayEntry(
        builder: (BuildContext context) => TimeoutMessageDialog(
            title: title,
            logoWithWihteText: logoWithWihteText,
            message: message,
            top: top,
            width: width,
            left: left,
            duration: Duration(milliseconds: timeoutMiniseconds),
            onCLick: onClick));
    if (PlatformIs.web) {
      // Web: the router's navigator owns the overlay (main.dart's navigatorKey
      // is not attached to it). Skip if it is not mounted yet, so hide()
      // never removes an entry that was never inserted.
      final overlay = rootNavigatorKey.currentState?.overlay;
      if (overlay == null) {
        _activeOverlay = null;
        return;
      }
      overlay.insert(_activeOverlay!);
    } else {
      navigatorKey?.currentState?.overlay?.insert(_activeOverlay!);
    }
    Future.delayed(Duration(milliseconds: timeoutMiniseconds)).then((_) {
      // make sure that you're removing the current message
      if (local == currentMessageId) {
        hide();
      }
    });
  }
}

/// In-app notification banner: a white card at the top end of the screen with the app logo,
/// the title and message, a close button and a thin bar that counts down until it hides.
class TimeoutMessageDialog extends StatefulWidget {
  final String title;
  final String? message;
  final BuildContext? parentContext;
  final double? left;
  final double? top;
  final double? width;
  final Duration duration;
  final Function()? onCLick;
  final String logoWithWihteText;
  const TimeoutMessageDialog(
      {required this.title,
        super.key,
        this.message,
        required this.logoWithWihteText,
        this.parentContext,
        this.top,
        this.width,
        this.left,
        this.duration = const Duration(seconds: 5),
        this.onCLick});
  @override
  TimeoutMessageDialogState createState() => TimeoutMessageDialogState();
}

class TimeoutMessageDialogState extends State<TimeoutMessageDialog>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final AnimationController _countdown;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    _countdown = AnimationController(vsync: this, duration: widget.duration)
      ..forward();

    TimeoutMessage.beforeClose = () async {
      if (mounted) await controller.reverse();
    };
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    _countdown.dispose();
    super.dispose();
  }

  void _open() {
    TimeoutMessage.hide();
    widget.onCLick?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    // Phones: almost full width. Wider screens: a 380 card at the top end.
    final cardWidth = screen.width < 600
        ? screen.width - 2 * AppSpacing.page
        : (widget.width ?? 380).clamp(320.0, 420.0);
    final accent = Color(AppColors.buttons);
    final navy = Color(AppColors.secondaryButton);
    final hasMessage = widget.message != null && widget.message!.trim().isNotEmpty;

    return PositionedDirectional(
      top: safeTop + AppSpacing.page,
      end: AppSpacing.page,
      width: cardWidth,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: accent.withOpacity(0.12)),
                  boxShadow: AppShadows.overlay,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _open,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(AppSizes.s14, AppSizes.s14, AppSizes.s6, AppSizes.s14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App logo in a soft tinted tile.
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(AppSizes.s8),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Image.asset(widget.logoWithWihteText,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                      Icons.notifications_active_rounded,
                                      color: accent)),
                            ),
                            const SizedBox(width: AppSizes.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.3,
                                      fontWeight: FontWeight.w700,
                                      color: navy,
                                    ),
                                  ),
                                  if (hasMessage) ...[
                                    const SizedBox(height: AppSizes.s4),
                                    Text(
                                      widget.message!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        height: 1.45,
                                        color: Color(0xFF475467),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Close without opening.
                            IconButton(
                              onPressed: TimeoutMessage.hide,
                              visualDensity: VisualDensity.compact,
                              splashRadius: 18,
                              icon: Icon(Icons.close_rounded,
                                  size: 18, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      // Time left before it hides.
                      AnimatedBuilder(
                        animation: _countdown,
                        builder: (_, __) => LinearProgressIndicator(
                          value: 1 - _countdown.value,
                          minHeight: 3,
                          backgroundColor: accent.withOpacity(0.08),
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
