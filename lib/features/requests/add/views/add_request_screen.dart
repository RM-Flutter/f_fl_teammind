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
import 'dart:async';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:file_picker/file_picker.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_android;
import 'package:app_test/features/home/controllers/home_controller.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({super.key});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  late WebViewController _controller;
  int _loadingPercentage = 0;
  bool _isInit = false;
  StreamSubscription<html.MessageEvent>? _webMessageSub;

  @override
  void dispose() {
    _webMessageSub?.cancel();
    super.dispose();
  }

  /// Handles actions sent by the webview page (close / go_home / request_list).
  /// Returns true if the action was recognised.
  bool _handleAction(String? action) {
    if (!mounted || action == null) return false;
    if (action == 'close') {
      if (context.canPop()) {
        context.pop(true);
      } else {
        Provider.of<HomeController>(context, listen: false)
          ..initializeHomeScreen(context, null)
          ..getHome(context);
        context.goNamed(AppRoutes.home.name,
            pathParameters: {'lang': context.locale.languageCode});
      }
      return true;
    } else if (action == 'go_home') {
      Provider.of<HomeController>(context, listen: false)
        ..initializeHomeScreen(context, null)
        ..getHome(context);
      context.goNamed(AppRoutes.home.name,
          pathParameters: {'lang': context.locale.languageCode});
      return true;
    } else if (action == 'request_list') {
      // Push replacement to ensure it completely reloads the request list
      context.pushReplacementNamed(AppRoutes.requests.name, pathParameters: {
        'lang': context.locale.languageCode,
        'type': 'mine'
      });
      return true;
    }
    return false;
  }

  /// Flutter web renders the page in an <iframe>, whose navigation can't be
  /// intercepted, so the page posts its actions to this window instead.
  void _listenToWebMessages() {
    final allowedOrigin = Uri.parse(AppConstants.base).origin;
    _webMessageSub = html.window.onMessage.listen((event) {
      if (event.origin != allowedOrigin) return;
      final data = event.data;
      if (data is Map && data['source'] == 'rm-emp-request-webview') {
        _handleAction(data['action']?.toString());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final appConfigService =
          Provider.of<AppConfigService>(context, listen: false);
      final token = appConfigService.token;

      // Construct the URL
      final url = "${AppConstants.base}/frontend/emp-requests/$token";

      _controller = WebViewController();

      if (!kIsWeb) {
        // Mobile Only Configurations
        _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
        _controller
            .setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);

        if (Platform.isAndroid) {
          final androidController =
              _controller.platform as webview_android.AndroidWebViewController;
          androidController.setOnShowFileSelector(
              (webview_android.FileSelectorParams params) async {
            final FilePickerResult? result =
                await FilePicker.platform.pickFiles(
              allowMultiple:
                  params.mode == webview_android.FileSelectorMode.openMultiple,
              type: FileType.any,
            );
            if (result != null && result.files.isNotEmpty) {
              return result.files
                  .where((file) => file.path != null)
                  .map((file) => Uri.file(file.path!).toString())
                  .toList();
            }
            return <String>[];
          });
        }

        _controller.setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              if (mounted)
                setState(() {
                  _loadingPercentage = 0;
                });
            },
            onProgress: (progress) {
              if (mounted)
                setState(() {
                  _loadingPercentage = progress;
                });
            },
            onPageFinished: (url) {
              if (mounted)
                setState(() {
                  _loadingPercentage = 100;
                });
            },
            onNavigationRequest: (NavigationRequest request) {
              final Uri uri = Uri.parse(request.url);

              // Handle custom actions
              if (_handleAction(uri.queryParameters['action'])) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        );
      } else {
        _listenToWebMessages();
      }

      debugPrint(
          "\n========== WEBVIEW URL ==========\n$url\n=================================");
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
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(AppColors.buttons)),
            ),
        ],
      )),
    );
  }
}
