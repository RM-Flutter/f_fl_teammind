import 'package:flutter/material.dart';
import 'package:app_test/features/offline/views/offline_screen.dart';
import 'package:app_test/core/routing/app_router.dart';

class OfflineOverlayService {
  static OverlayEntry? _offlineOverlay;
  static bool _isShowing = false;
  static bool _isTemporarilyHidden = false; // Flag to track temporary hiding


  static void hideOfflineOverlay({bool temporarily = false}) {
    if (!_isShowing && !_isTemporarilyHidden) {
      // Already hidden, reset state
      _offlineOverlay = null;
      _isTemporarilyHidden = false;
      return;
    }

    if (_offlineOverlay == null && !temporarily) {
      // Overlay entry is null, just reset state
      _isShowing = false;
      _isTemporarilyHidden = false;
      return;
    }

    try {
      final overlay = _offlineOverlay;
      if (temporarily && overlay != null) {
        _isTemporarilyHidden = true;
        // Remove overlay temporarily but keep the entry
        if (rootNavigatorKey.currentState?.overlay != null) {
          overlay.remove();
          debugPrint('Offline overlay hidden temporarily');
        }
      } else if (overlay != null) {
        _offlineOverlay = null;
        _isShowing = false;
        _isTemporarilyHidden = false;
        // Remove overlay permanently
        if (rootNavigatorKey.currentState?.overlay != null) {
          overlay.remove();
          debugPrint('Offline overlay hidden');
        }
      } else {
        debugPrint('Offline overlay state reset (navigator not available)');
      }
    } catch (e) {
      debugPrint('Error hiding offline overlay: $e');
      _isShowing = false;
      _offlineOverlay = null;
      _isTemporarilyHidden = false;
    }
  }

  static bool get isShowing => _isShowing;
  static bool get isTemporarilyHidden => _isTemporarilyHidden;

  static void showOfflineOverlay({bool restoreFromTemporary = false}) {
    if (restoreFromTemporary && _isTemporarilyHidden) {
      _isTemporarilyHidden = false;
      // Re-insert the overlay entry if it still exists
      if (_offlineOverlay != null && rootNavigatorKey.currentState?.overlay != null) {
        try {
          rootNavigatorKey.currentState!.overlay!.insert(_offlineOverlay!);
          _isShowing = true;
          debugPrint('Offline overlay restored from temporary hide');
        } catch (e) {
          debugPrint('Error restoring overlay from temporary hide: $e');
          // If restoration fails, create a new overlay
          _offlineOverlay = null;
          _isShowing = false;
          showOfflineOverlay(); // Recursively call to create new overlay
        }
      } else {
        debugPrint('Offline overlay entry not available, creating new one');
        _isTemporarilyHidden = false;
        _isShowing = false;
        showOfflineOverlay(); // Recursively call to create new overlay
      }
      return;
    }

    // Call the original showOfflineOverlay logic
    if (_isShowing) {
      debugPrint('Offline overlay already showing');
      return;
    }

    // Wait a bit to ensure navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isShowing) return; // Double check after delay

      try {
        _isShowing = true;
        _isTemporarilyHidden = false;
        _offlineOverlay = OverlayEntry(
          builder: (context) => const OfflineScreen(),
          opaque: true,
        );

        // Use rootNavigatorKey from app_router.dart (GoRouter's navigator)
        if (rootNavigatorKey.currentState?.overlay != null) {
          rootNavigatorKey.currentState!.overlay!.insert(_offlineOverlay!);
          debugPrint('Offline overlay shown successfully');
        } else {
          debugPrint('⚠️ Cannot show offline overlay: navigator overlay not available');
          _isShowing = false;
          _offlineOverlay = null;
        }
      } catch (e) {
        debugPrint('Error showing offline overlay: $e');
        _isShowing = false;
        _offlineOverlay = null;
      }
    });
  }
}
