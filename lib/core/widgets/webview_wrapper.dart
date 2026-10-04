import 'package:flutter/material.dart';
import '../platform/platform_is.dart';
import 'webview_wrapper_mobile.dart'
    if (dart.library.io) 'webview_wrapper_mobile.dart';
import 'webview_web_impl.dart'
    if (dart.library.io) 'webview_stub_impl.dart';

/// A platform-aware WebView widget.
/// - On web:    embeds the URL in an <iframe> inside the Flutter web page.
/// - On mobile: uses webview_flutter to show the URL natively.
class PlatformWebView extends StatelessWidget {
  final String url;
  final Map<String, String>? headers;
  final Function(String)? onPageStarted;
  final Function(int)? onProgress;
  final Function(String)? onPageFinished;
  final Function(dynamic)? onHttpError;
  final Function(dynamic)? onWebResourceError;
  final Function(dynamic)? onNavigationRequest;
  final bool javascriptMode;
  final Map<String, Function(dynamic)>? javascriptChannels;

  const PlatformWebView({
    Key? key,
    required this.url,
    this.headers,
    this.onPageStarted,
    this.onProgress,
    this.onPageFinished,
    this.onHttpError,
    this.onWebResourceError,
    this.onNavigationRequest,
    this.javascriptMode = true,
    this.javascriptChannels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformIs.web) {
      return WebWebView(
        url: url,
        onPageStarted: onPageStarted,
        onPageFinished: onPageFinished,
      );
    } else {
      return MobileWebView(
        url: url,
        headers: headers,
        onPageStarted: onPageStarted,
        onProgress: onProgress,
        onPageFinished: onPageFinished,
        onHttpError: onHttpError,
        onWebResourceError: onWebResourceError,
        onNavigationRequest: onNavigationRequest,
        javascriptMode: javascriptMode,
        javascriptChannels: javascriptChannels,
      );
    }
  }
}
