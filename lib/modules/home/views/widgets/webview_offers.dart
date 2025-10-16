import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStackOffers extends StatefulWidget {
  var link;
  WebViewStackOffers(this.link);
  @override
  State<WebViewStackOffers> createState() => _WebViewStackOffersState();
}
class _WebViewStackOffersState extends State<WebViewStackOffers> {
  var loadingPercentage = 0;
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(Uri.parse('${widget.link}'))
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
            // if (navigation.url.contains('status=1')) {
            //   CacheHelper.deleteData(key: "update_url");
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     final appConfigServiceProvider =
            //     Provider.of<AppConfigService>(context, listen: false);
            //     appConfigServiceProvider.setAuthenticationStatusWithToken(
            //         isLogin: true, token: appConfigServiceProvider.token);
            //   });
            //   context.goNamed(
            //     AppRoutes.splash.name,
            //     pathParameters: {'lang': context.locale.languageCode,},
            //   );
            // }
            // else if (navigation.url.contains('status=0')) {
            //   context.goNamed(
            //     AppRoutes.login.name,
            //     pathParameters: {'lang': context.locale.languageCode,},
            //   );
            //   AlertsService.error(
            //       context: context,
            //       message: AppStrings.failedLoginingPleaseTryAgain.tr(),
            //       title: AppStrings.failed.tr());
            // }
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

  @override
  Widget build(BuildContext context) {
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
