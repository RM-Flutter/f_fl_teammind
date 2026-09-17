import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  late WebViewController _controller;
  int _loadingPercentage = 0;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final appConfigService = Provider.of<AppConfigService>(context, listen: false);
      final token = appConfigService.token;
      
      // Construct the URL
      final url = "${AppConstants.base}/frontend/emp-requests/$token";
      
      _controller = WebViewController();
      
      if (!kIsWeb) {
        // Mobile Only Configurations
        _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
        _controller.setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);
        _controller.setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              if (mounted) setState(() { _loadingPercentage = 0; });
            },
            onProgress: (progress) {
              if (mounted) setState(() { _loadingPercentage = progress; });
            },
            onPageFinished: (url) {
              if (mounted) setState(() { _loadingPercentage = 100; });
            },
            onNavigationRequest: (NavigationRequest request) {
              final Uri uri = Uri.parse(request.url);
              
              // Handle custom actions
              final action = uri.queryParameters['action'];
              if (action != null) {
                if (action == 'close') {
                  if (context.canPop()) {
                    context.pop(true);
                  } else {
                    context.goNamed(AppRoutes.home.name, pathParameters: {'lang': context.locale.languageCode});
                  }
                  return NavigationDecision.prevent;
                } else if (action == 'go_home') {
                  context.goNamed(AppRoutes.home.name, pathParameters: {'lang': context.locale.languageCode});
                  return NavigationDecision.prevent;
                } else if (action == 'request_list') {
                  // Push replacement to ensure it completely reloads the request list
                  context.pushReplacementNamed(
                    AppRoutes.requests.name, 
                    pathParameters: {'lang': context.locale.languageCode, 'type': 'mine'}
                  );
                  return NavigationDecision.prevent;
                }
              }
              return NavigationDecision.navigate;
            },
          ),
        );
      }
      
      debugPrint("\n========== WEBVIEW URL ==========\n$url\n=================================");
      _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loadingPercentage < 100 && !kIsWeb)
            LinearProgressIndicator(
              value: _loadingPercentage / 100.0,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.buttons)),
            ),
        ],
      )),
    );
  }
}
