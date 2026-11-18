/// Non-web: nothing to do.
abstract class WebLocalNotifications {
  static bool get hasScheduled => false;
  static void schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) {}
  static void cancel(int id) {}
  static void cancelAll() {}
}
