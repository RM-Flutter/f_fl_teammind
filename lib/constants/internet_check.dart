
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionService extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  ConnectionService() {
    InternetConnectionChecker.createInstance().onStatusChange.listen((status) {
      final newStatus = status == InternetConnectionStatus.connected;
      if (_isConnected != newStatus) {
        _isConnected = newStatus;
        notifyListeners();
      }
    });
  }
}
