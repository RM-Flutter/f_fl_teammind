import 'package:flutter/material.dart';
import 'package:app_test/features/offline/views/offline_screen.dart';
import 'package:app_test/core/routing/app_router.dart';

class OfflineOverlayService {
  static Route? _offlineRoute;
  static bool _isShowing = false;
  static bool _isTemporarilyHidden = false; // Flag to track temporary hiding

  static bool get isShowing => _isShowing;
  static bool get isTemporarilyHidden => _isTemporarilyHidden;

  static void hideOfflineOverlay({bool temporarily = false}) {
    if (!_isShowing && !_isTemporarilyHidden) {
      // Already hidden, reset state
      _offlineRoute = null;
      _isTemporarilyHidden = false;
      return;
    }

    try {
      final route = _offlineRoute;
      if (temporarily && route != null) {
        _isTemporarilyHidden = true;
        if (rootNavigatorKey.currentState != null) {
          if (route.isCurrent || route.isActive) {
            rootNavigatorKey.currentState!.removeRoute(route);
          }
          debugPrint('Offline route hidden temporarily');
        }
      } else if (route != null) {
        _offlineRoute = null;
        _isShowing = false;
        _isTemporarilyHidden = false;
        if (rootNavigatorKey.currentState != null) {
          if (route.isCurrent || route.isActive) {
            rootNavigatorKey.currentState!.removeRoute(route);
          }
          debugPrint('Offline route hidden');
        }
      } else {
        debugPrint('Offline route state reset (navigator not available)');
      }
    } catch (e) {
      debugPrint('Error hiding offline route: $e');
      _isShowing = false;
      _offlineRoute = null;
      _isTemporarilyHidden = false;
    }
  }

  static void showOfflineOverlay({bool restoreFromTemporary = false}) {
    if (restoreFromTemporary && _isTemporarilyHidden) {
      _isTemporarilyHidden = false;
      if (_offlineRoute != null && rootNavigatorKey.currentState != null) {
        try {
          rootNavigatorKey.currentState!.push(_offlineRoute!);
          _isShowing = true;
          debugPrint('Offline route restored from temporary hide');
        } catch (e) {
          debugPrint('Error restoring route from temporary hide: $e');
          _offlineRoute = null;
          _isShowing = false;
          showOfflineOverlay();
        }
      } else {
        debugPrint('Offline route not available, creating new one');
        _isTemporarilyHidden = false;
        _isShowing = false;
        showOfflineOverlay();
      }
      return;
    }

    if (_isShowing) {
      debugPrint('Offline route already showing');
      return;
    }

    // Wait a bit to ensure navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isShowing) return; // Double check after delay

      try {
        _isShowing = true;
        _isTemporarilyHidden = false;
        _offlineRoute = PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OfflineScreen(),
          settings: const RouteSettings(name: '/offline-screen'),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );

        if (rootNavigatorKey.currentState != null) {
          rootNavigatorKey.currentState!.push(_offlineRoute!);
          debugPrint('Offline route shown successfully');
        } else {
          debugPrint('⚠️ Cannot show offline route: navigator not available');
          _isShowing = false;
          _offlineRoute = null;
        }
      } catch (e) {
        debugPrint('Error showing offline route: $e');
        _isShowing = false;
        _offlineRoute = null;
      }
    });
  }
}
