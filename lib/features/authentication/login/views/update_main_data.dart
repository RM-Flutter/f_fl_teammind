import 'package:app_test/core/platform/platform_is.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/app_config_service.dart';

class WebViewStackMainData extends StatefulWidget {
  const WebViewStackMainData({super.key});

  @override
  State<WebViewStackMainData> createState() => _WebViewStackMainDataState();
}
class _WebViewStackMainDataState extends State<WebViewStackMainData> {
  var loadingPercentage = 0;
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    if (PlatformIs.web) {
      // On web, open URL in browser
      _openUrlInBrowser();
      return;
    }
    controller = WebViewController()
      ..loadRequest(Uri.parse('${CacheHelper.getString("update_url")}'))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                loadingPercentage = 0;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                loadingPercentage = progress;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                loadingPercentage = 100;
              });
            }
          },
          onHttpError: (error) {
          },
          onWebResourceError: (error) {
          },
          onNavigationRequest: (navigation) {
            final host = Uri.parse(navigation.url).host;
            if (navigation.url.contains('status=1')) {
              CacheHelper.deleteData(key: "update_url");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final appConfigServiceProvider =
                Provider.of<AppConfigService>(context, listen: false);
                appConfigServiceProvider.setAuthenticationStatusWithToken(
                    isLogin: true, token: appConfigServiceProvider.token);
              });
              context.goNamed(
                AppRoutes.splash.name,
                pathParameters: {'lang': context.locale.languageCode,},
              );
            }
            else if (navigation.url.contains('status=0')) {
              context.goNamed(
                AppRoutes.login.name,
                pathParameters: {'lang': context.locale.languageCode,},
              );
              AlertsService.error(
                  context: context,
                  message: AppStrings.failedLoginingPleaseTryAgain.tr(),
                  title: AppStrings.failed.tr());
            }
            if (host.contains('youtube.com')) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Blocking navigation to $host')),
                );
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.message)));
          }
        },
      );
  }

  Future<void> _openUrlInBrowser() async {
    final url = CacheHelper.getString("update_url");
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No URL to open')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Close the screen after opening browser
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformIs.web) {
      // On web, show loading while opening browser
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      children: [
        const SizedBox(height: 30,),
        WebViewWidget(controller: controller),
        if (loadingPercentage < 100)
          LinearProgressIndicator(value: loadingPercentage / 100.0),
      ],
    );
  }
}
