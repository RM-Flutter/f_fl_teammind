
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionService extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  ConnectionService() {
    // في الويب، لا نستخدم connectivity listener لأنه يسبب refresh مستمر
    if (kIsWeb) {
      _isConnected = true; // افتراض أن الويب متصل دائماً
      return;
    }
    
    // Consider user requirement: show offline screen only when connection is completely cut off.
    // Use connectivity_plus to detect 'none' status only (ignore weak/unstable internet).
    final connectivity = Connectivity();

    // Set initial state
    connectivity.checkConnectivity().then((results) {
      final hasNetwork = !(results.contains(ConnectivityResult.none));
      if (_isConnected != hasNetwork) {
        _isConnected = hasNetwork;
        notifyListeners();
      } else {
        _isConnected = hasNetwork;
      }
    });

    // Listen for changes
    connectivity.onConnectivityChanged.listen((results) {
      final hasNetwork = !(results.contains(ConnectivityResult.none));
      if (_isConnected != hasNetwork) {
        _isConnected = hasNetwork;
        notifyListeners();
      }
    });
  }
}
