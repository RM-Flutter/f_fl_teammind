import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Mobile implementation using webview_flutter
class MobileWebView extends StatefulWidget {
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

  const MobileWebView({
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
  State<MobileWebView> createState() => _MobileWebViewState();
}

class _MobileWebViewState extends State<MobileWebView> {
  late WebViewController _controller;
  int _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.url),
        headers: widget.headers!,
      )
      ..setJavaScriptMode(
        widget.javascriptMode
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            widget.onPageStarted?.call(url);
            if (mounted) {
              setState(() {
                _loadingPercentage = 0;
              });
            }
          },
          onProgress: (progress) {
            widget.onProgress?.call(progress);
            if (mounted) {
              setState(() {
                _loadingPercentage = progress;
              });
            }
          },
          onPageFinished: (url) {
            widget.onPageFinished?.call(url);
            if (mounted) {
              setState(() {
                _loadingPercentage = 100;
              });
            }
          },
          onHttpError: widget.onHttpError,
          onWebResourceError: widget.onWebResourceError,
          onNavigationRequest: (navigation) {
            if (widget.onNavigationRequest != null) {
              final decision = widget.onNavigationRequest!(navigation);
              return decision ?? NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Add JavaScript channels
    if (widget.javascriptChannels != null) {
      widget.javascriptChannels!.forEach((name, callback) {
        _controller.addJavaScriptChannel(
          name,
          onMessageReceived: (message) {
            callback(message);
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loadingPercentage < 100)
          LinearProgressIndicator(
            value: _loadingPercentage / 100.0,
          ),
      ],
    );
  }
}

