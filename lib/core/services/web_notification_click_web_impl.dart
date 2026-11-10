import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import 'backend_services/api_service/dio_api_service/shared.dart';
import 'general_listener.dart';

/// Web: handles notification clicks sent by web/firebase-messaging-sw.js.
abstract class WebNotificationClick {
  // Must match CLICK_MESSAGE_TYPE / CLICK_QUERY_PARAM in firebase-messaging-sw.js.
  static const String _messageType = 'rm_notification_click';
  static const String _queryParam = 'notification_endpoint';

  static bool _listening = false;

  /// Call once in main(), after CacheHelper.init().
  static void init() {
    _readEndpointFromUrl();
    _listenToServiceWorker();
  }

  /// App opened by a click while it was closed: hand the endpoint to the splash,
  /// which opens it after start-up (same key as a mobile initial message).
  static void _readEndpointFromUrl() {
    final endpoint = Uri.base.queryParameters[_queryParam];
    if (endpoint == null || endpoint.isEmpty) return;
    CacheHelper.setString(key: 'initialNotification', value: endpoint);
    // Drop the query so a reload does not open the same page again.
    final location = html.window.location;
    html.window.history
        .replaceState(null, '', '${location.pathname}${location.hash}');
  }

  /// App already open: the service worker focuses it and posts the endpoint.
  static void _listenToServiceWorker() {
    final container = html.window.navigator.serviceWorker;
    if (container == null || _listening) return;
    _listening = true;
    container.onMessage.listen((html.MessageEvent event) {
      try {
        final data = event.data;
        if (data is! Map || data['type'] != _messageType) return;
        final endpoint = data['endpoint'];
        if (endpoint is String && endpoint.isNotEmpty) {
          GeneralListener.linksAction(popup: endpoint);
        }
      } catch (e) {
        debugPrint('⚠️ WebNotificationClick: $e');
      }
    });
  }
}
