
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'offline_overlay.service.dart';
import '../routing/app_router.dart';

class ConnectionService extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicCheckTimer;
  final Connectivity _connectivity = Connectivity();
  
  // Callback to resume initialization when connection is restored
  VoidCallback? onConnectionRestored;

  ConnectionService() {
    // في الويب، لا نستخدم connectivity listener لأنه يسبب refresh مستمر
    if (kIsWeb) {
      _isConnected = true; // افتراض أن الويب متصل دائماً
      return;
    }
    
    _initializeConnectionCheck();
  }

  Future<void> _initializeConnectionCheck() async {
    // Check initial connection status multiple times to ensure accuracy
    await _checkConnectionStatus();
    await Future.delayed(const Duration(milliseconds: 300));
    await _checkConnectionStatus();
    
    // Show overlay if offline on startup
    if (!_isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        OfflineOverlayService.showOfflineOverlay();
      });
    }
    
    // Listen to connectivity changes (WiFi/Mobile/Ethernet/etc)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });

    // Periodic check every 5 seconds to ensure we catch connection changes
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkConnectionStatus();
    });
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Error checking connection status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Consider connected if there's any network connection (WiFi, Mobile, Ethernet, VPN, etc.)
    // Only show offline if there's NO network connection at all (ConnectivityResult.none)
    final hasNetworkConnection = !results.contains(ConnectivityResult.none);
    
    if (_isConnected != hasNetworkConnection) {
      _isConnected = hasNetworkConnection;
      
      // Show/hide offline overlay based on connection status
      if (!_isConnected) {
        // Connection lost - show overlay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OfflineOverlayService.showOfflineOverlay();
        });
      } else {
        // Connection restored - hide overlay and trigger callback if registered
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Check if we're on offline screen BEFORE hiding overlay
          final navigatorContext = rootNavigatorKey.currentContext;
          bool isOnOfflineScreen = false;
          
          if (navigatorContext != null) {
            try {
              final router = GoRouter.of(navigatorContext);
              final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
              isOnOfflineScreen = currentLocation.contains('offline-screen') || 
                                 currentLocation.contains('offline') ||
                                 currentLocation.contains('fingerPrintOffline');
            } catch (e) {
              debugPrint("⚠️ Error checking route: $e");
            }
          }
          
          // Only hide overlay if we're NOT on offline screen
          if (!isOnOfflineScreen) {
            OfflineOverlayService.hideOfflineOverlay();
          }
          
          // NEVER call onConnectionRestored if we're on offline screen or overlay is temporarily hidden
          if (isOnOfflineScreen || OfflineOverlayService.isTemporarilyHidden) {
            debugPrint("🔄 Connection restored, but user is on offline screen or overlay is temporarily hidden - NOT calling onConnectionRestored");
            return;
          }
          
          // Wait a bit to ensure the screen is stable before checking route
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Call callback to resume initialization if registered (e.g., from SplashScreen)
          if (onConnectionRestored != null) {
            // Double check we're still not on offline screen
            final checkContext = rootNavigatorKey.currentContext;
            if (checkContext != null) {
              try {
                final router = GoRouter.of(checkContext);
                final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
                final stillOnOfflineScreen = currentLocation.contains('offline-screen') || 
                                           currentLocation.contains('offline') ||
                                           currentLocation.contains('fingerPrintOffline');
                
                if (!stillOnOfflineScreen) {
                  debugPrint("🔄 Connection restored, triggering initialization callback... (current location: $currentLocation)");
                  onConnectionRestored!();
                } else {
                  debugPrint("🔄 Connection restored, but user is still on offline screen ($currentLocation) - NOT calling onConnectionRestored");
                }
              } catch (e) {
                debugPrint("⚠️ Error checking route: $e - NOT calling onConnectionRestored to be safe");
              }
            } else {
              debugPrint("🔄 Connection restored, but no context available - NOT calling onConnectionRestored");
            }
          }
        });
      }
      
      notifyListeners();
      debugPrint('Connection status changed: ${_isConnected ? "Connected" : "Offline"}');
    }
  }

  // Manual check method that can be called from UI
  Future<void> checkConnection() async {
    await _checkConnectionStatus();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicCheckTimer?.cancel();
    super.dispose();
  }
}
