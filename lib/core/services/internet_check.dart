
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'offline_overlay_service.dart';
import 'package:app_test/core/routing/app_router.dart';

class ConnectionService extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicCheckTimer;
  Timer? _offlineDebounceTimer; // Timer قبل ما تظهر شاشة الأوفلاين
  Timer? _onlineDebounceTimer;  // Timer قبل ما تتخبي شاشة الأوفلاين

  final Connectivity _connectivity = Connectivity();

  // مدة الانتظار قبل تغيير حالة الاتصال (عشان ما تظهرش الشاشة على كل انقطاع مؤقت)
  static const Duration _changeDelay = Duration(seconds: 5);

  // Callback to resume initialization when connection is restored
  VoidCallback? onConnectionRestored;

  ConnectionService() {
    _initializeConnectionCheck();
  }

  Future<void> _initializeConnectionCheck() async {
    // الفحص الأولي عند بدء التطبيق — بدون delay
    await _checkConnectionStatus(debounce: false);
    await Future.delayed(const Duration(milliseconds: 300));
    await _checkConnectionStatus(debounce: false);

    // لو أوفلاين عند البداية → اعرض شاشة الأوفلاين فوراً
    if (!_isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        OfflineOverlayService.showOfflineOverlay();
      });
    }

    // استمع لتغييرات الشبكة (WiFi/Mobile/Ethernet/etc) — مع delay
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });

    // فحص دوري كل 5 ثواني — مع delay
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnectionStatus(debounce: true);
    });
  }

  /// Performs a real DNS lookup to verify actual internet access (mobile/desktop only).
  static Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkConnectionStatus({bool debounce = true}) async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasNetworkCard = !results.contains(ConnectivityResult.none);

      if (kIsWeb) {
        // على الويب: نعتمد على connectivity_plus (يستخدم navigator.onLine داخلياً)
        _applyConnectionChange(hasNetworkCard, debounce: debounce);
        return;
      }

      // على الموبايل: إذا مفيش شبكة خالص → أوفلاين مباشرة
      if (!hasNetworkCard) {
        _applyConnectionChange(false, debounce: debounce);
        return;
      }

      // إذا في شبكة → نتأكد بـ DNS ping فعلي
      final realInternet = await _hasRealInternet();
      _applyConnectionChange(realInternet, debounce: debounce);
    } catch (e) {
      debugPrint('Error checking connection status: $e');
    }
  }

  /// يطبّق تغيير حالة الاتصال.
  /// [debounce]: إذا true، ينتظر 10 ثواني قبل التطبيق (يتجاهل الانقطاعات المؤقتة).
  /// إذا false، يطبّق فوراً (للاستخدام عند بدء التطبيق أو الضغط على Retry).
  void _applyConnectionChange(bool hasConnection, {bool debounce = true}) {
    // لو الحالة مش هتتغير — ألغِ أي pending debounce عكسي
    if (_isConnected == hasConnection) {
      if (hasConnection) {
        // كنا عم نستنى offline debounce → ألغيه
        _offlineDebounceTimer?.cancel();
        _offlineDebounceTimer = null;
      } else {
        // كنا عم نستنى online debounce → ألغيه
        _onlineDebounceTimer?.cancel();
        _onlineDebounceTimer = null;
      }
      return;
    }

    if (!debounce) {
      // تطبيق فوري — يُستخدم عند الـ startup أو Retry
      _cancelAllDebounces();
      _isConnected = hasConnection;
      notifyListeners();

      if (!_isConnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OfflineOverlayService.showOfflineOverlay();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _handleConnectionRestored();
        });
      }
      debugPrint('Connection changed immediately: ${_isConnected ? "Online" : "Offline"}');
      return;
    }

    // تطبيق مع delay — يتجاهل الانقطاعات المؤقتة
    if (!hasConnection) {
      // الاتصال انقطع → ابدأ عدّ 10 ثواني قبل ما تُعلن أوفلاين
      _onlineDebounceTimer?.cancel(); // ألغِ أي online timer معلق
      _onlineDebounceTimer = null;
      if (_offlineDebounceTimer != null) return; // already counting

      debugPrint('📶 Connection seems lost — waiting ${_changeDelay.inSeconds}s before showing offline screen...');
      _offlineDebounceTimer = Timer(_changeDelay, () {
        _offlineDebounceTimer = null;
        _isConnected = false;
        notifyListeners();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OfflineOverlayService.showOfflineOverlay();
        });
        debugPrint('🔴 Offline confirmed after delay');
      });
    } else {
      // الاتصال عاد → ابدأ عدّ 10 ثواني قبل ما تُخبّي الشاشة
      _offlineDebounceTimer?.cancel(); // ألغِ أي offline timer معلق
      _offlineDebounceTimer = null;
      if (_onlineDebounceTimer != null) return; // already counting

      debugPrint('📶 Connection seems restored — waiting ${_changeDelay.inSeconds}s before hiding offline screen...');
      _onlineDebounceTimer = Timer(_changeDelay, () {
        _onlineDebounceTimer = null;
        _isConnected = true;
        notifyListeners();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _handleConnectionRestored();
        });
        debugPrint('🟢 Online confirmed after delay');
      });
    }
  }

  void _cancelAllDebounces() {
    _offlineDebounceTimer?.cancel();
    _offlineDebounceTimer = null;
    _onlineDebounceTimer?.cancel();
    _onlineDebounceTimer = null;
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasNetworkConnection = !results.contains(ConnectivityResult.none);

    if (kIsWeb) {
      // على الويب: نعتمد على نتيجة connectivity_plus مباشرة
      _applyConnectionChange(hasNetworkConnection, debounce: true);
      return;
    }

    if (!hasNetworkConnection) {
      // مفيش شبكة خالص — أوفلاين بعد delay
      _applyConnectionChange(false, debounce: true);
    } else {
      // في شبكة — نتأكد بـ DNS ping ثم نطبّق مع delay
      _hasRealInternet().then((realInternet) {
        _applyConnectionChange(realInternet, debounce: true);
      });
    }
  }

  Future<void> _handleConnectionRestored() async {
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
  }

  /// فحص يدوي يُستدعى من زرار Retry — يلغي أي delay معلق ويطبّق النتيجة فوراً
  Future<void> checkConnection() async {
    _cancelAllDebounces();
    await _checkConnectionStatus(debounce: false);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicCheckTimer?.cancel();
    _cancelAllDebounces();
    super.dispose();
  }
}
