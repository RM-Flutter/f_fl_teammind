import 'package:flutter/material.dart';
import 'package:rmemp/platform/platform_is.dart';
import 'package:url_launcher/url_launcher.dart';
import 'webview_wrapper_mobile.dart'
    if (dart.library.io) 'webview_wrapper_mobile.dart';

/// A platform-aware WebView widget
/// On web: opens URL in browser using url_launcher
/// On mobile: uses webview_flutter
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
      // On web, open URL in browser
      return _WebWebView(
        url: url,
        onPageStarted: onPageStarted,
        onPageFinished: onPageFinished,
      );
    } else {
      // On mobile, use actual WebView
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

/// Web implementation - opens URL in browser
class _WebWebView extends StatefulWidget {
  final String url;
  final Function(String)? onPageStarted;
  final Function(String)? onPageFinished;

  const _WebWebView({
    Key? key,
    required this.url,
    this.onPageStarted,
    this.onPageFinished,
  }) : super(key: key);

  @override
  State<_WebWebView> createState() => _WebWebViewState();
}

class _WebWebViewState extends State<_WebWebView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _openUrl();
  }

  Future<void> _openUrl() async {
    widget.onPageStarted?.call(widget.url);
    
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      widget.onPageFinished?.call(widget.url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open ${widget.url}')),
        );
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_browser, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Opening in browser...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _openUrl(),
                  child: const Text('Open again'),
                ),
              ],
            ),
    );
  }
}

