
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rmemp/platform/platform_is.dart';

import '../../../general_services/alert_service/alerts.service.dart';
import '../../../general_services/app_config.service.dart';
class WebViewStackMainData extends StatefulWidget {

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
            print("onPageStarted is -> ${url}");
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
            print("onPageFinished is -> ${url}");
            if (mounted) {
              setState(() {
                loadingPercentage = 100;
              });
            }
          },
          onHttpError: (error) {
            print("onHttpError is --- > ${error.response!.statusCode}");
            print("onHttpError is --- > ${error.response!.headers}");
            print("onHttpError is --- > ${error.response!.uri}");
            print("onHttpError is --- > ${error.request!.uri}");
          },
          onWebResourceError: (error) {
            print("onWebResourceError is --- > $error");
          },
          onNavigationRequest: (navigation) {
            print("NAV is -> ${navigation.url}");
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
        SizedBox(height: 30,),
        WebViewWidget(controller: controller),
        if (loadingPercentage < 100)
          LinearProgressIndicator(value: loadingPercentage / 100.0),
      ],
    );
  }
}
