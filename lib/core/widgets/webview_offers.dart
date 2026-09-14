import 'package:flutter/material.dart';
import 'webview_wrapper.dart'; // Make sure this is imported

class WebViewStackOffers extends StatelessWidget {
  final String link;
  const WebViewStackOffers(this.link, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PlatformWebView(url: link),
    );
  }
}
