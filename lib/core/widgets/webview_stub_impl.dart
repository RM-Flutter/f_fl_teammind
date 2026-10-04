import 'package:flutter/material.dart';

/// Stub implementation for mobile — never actually used at runtime
/// because PlatformIs.web is false on mobile, but needed for compilation.
class WebWebView extends StatelessWidget {
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
  Widget build(BuildContext context) => const SizedBox.shrink();
}
