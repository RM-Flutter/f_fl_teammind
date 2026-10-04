// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Web implementation - embeds URL in an iframe inside the Flutter web page
class WebWebView extends StatefulWidget {
  final String url;
  final Function(String)? onPageStarted;
  final Function(String)? onPageFinished;

  const WebWebView({
    Key? key,
    required this.url,
    this.onPageStarted,
    this.onPageFinished,
  }) : super(key: key);

  @override
  State<WebWebView> createState() => _WebWebViewState();
}

class _WebWebViewState extends State<WebWebView> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'webview-iframe-${widget.url.hashCode}';
    widget.onPageStarted?.call(widget.url);
    _registerIframe();
    widget.onPageFinished?.call(widget.url);
  }

  void _registerIframe() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
