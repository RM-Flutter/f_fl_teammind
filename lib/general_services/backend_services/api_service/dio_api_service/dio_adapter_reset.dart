import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Closes the current HTTP adapter and replaces it with a new one so the next
/// request uses fresh TCP connections. Fixes "no API response until WiFi toggle".
void resetDioAdapter(Dio dio) {
  try {
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.close(force: true);
      dio.httpClientAdapter = IOHttpClientAdapter();
    }
  } catch (_) {}
}
