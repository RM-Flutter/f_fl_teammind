import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

/// Web: reminders as timers in the open page, shown through the service worker
/// (web/firebase-messaging-sw.js), whose notificationclick handler focuses the app.
abstract class WebLocalNotifications {
  static final Map<int, Timer> _timers = {};

  /// A reminder that fires this late (the computer slept, the tab was frozen) is dropped.
  static const Duration _maxDelay = Duration(minutes: 30);

  /// Browsers keep a timer for at most ~24.8 days (2^31 ms); later ones are scheduled
  /// on a later visit.
  static const Duration _maxAhead = Duration(days: 20);

  static bool get hasScheduled => _timers.isNotEmpty;

  static void schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) {
    final wait = at.difference(DateTime.now());
    if (wait.isNegative || wait > _maxAhead) return;
    _timers.remove(id)?.cancel();
    _timers[id] = Timer(wait, () {
      _timers.remove(id);
      if (DateTime.now().difference(at) > _maxDelay) return;
      _show(id, title, body);
    });
  }

  static void cancel(int id) => _timers.remove(id)?.cancel();

  static void cancelAll() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
  }

  static Future<void> _show(int id, String title, String body) async {
    try {
      if (!html.Notification.supported || html.Notification.permission != 'granted') return;
      final options = {
        'body': body,
        'icon': 'icons/Icon-192.png',
        'tag': 'rm_local_$id', // the same reminder is never shown twice (several tabs)
      };
      final sw = html.window.navigator.serviceWorker;
      if (sw != null) {
        final reg = await sw.ready;
        await reg.showNotification(title, options);
      } else {
        // No service worker (e.g. some private windows): desktop browsers still allow this.
        html.Notification(title, body: body, icon: 'icons/Icon-192.png');
      }
    } catch (e) {
      debugPrint('⚠️ WebLocalNotifications: $e');
    }
  }
}
