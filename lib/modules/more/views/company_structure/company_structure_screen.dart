import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rmemp/platform/platform_is.dart';
class WebViewStack extends StatefulWidget {

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}
class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    if (PlatformIs.web) {
      // On web, open URL in browser instead of WebView
      _openUrlInBrowser();
      return;
    }
    
    final jsonString = CacheHelper.getString("USG");
    var gCache;
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
    }
    controller = WebViewController()
      ..loadRequest(Uri.parse(gCache['company_structure_url'] != null?
      '${gCache['company_structure_url']}' : "https://www.google.com/"))
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
    final jsonString = CacheHelper.getString("USG");
    var gCache;
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
    }
    final url = gCache['company_structure_url'] != null
        ? '${gCache['company_structure_url']}'
        : "https://www.google.com/";
    
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
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),
      body: Stack(
        children: [
          SizedBox(height: 30,),
          WebViewWidget(controller: controller),
          if (loadingPercentage < 100)
            LinearProgressIndicator(value: loadingPercentage / 100.0),
        ],
      ),
    );
  }
}
