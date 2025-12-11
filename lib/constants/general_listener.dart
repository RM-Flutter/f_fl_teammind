import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import '../general_services/localization.service.dart';
import '../main.dart';
import '../modules/home/views/widgets/webview_offers.dart';
import '../routing/app_router.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'app_strings.dart';

class GeneralListener {
  void startAll(
      BuildContext context, String? currentRoute, List? popups) async {
    checkAndShowPopup(context, currentRoute, popups);
    listenToNotifications(context);
  }
  void someFunction() async{
    // قبل الخطوة
    final start = DateTime.now();
    print("⏳ بدأت عند: $start");

    // الخطوة اللي عايز تقيس وقتها

    // بعد الخطوة
    final end = DateTime.now();
    print("✅ خلصت عند: $end");

    // الفرق
    final diff = end.difference(start).inMilliseconds;
  }
  Future<void> checkAndShowPopup(BuildContext context, String? currentRoute, List? popups) async {
    if (currentRoute == null || popups == null) return;

    final prefs = await SharedPreferences.getInstance();

    final relatedPopups = popups.where((popup) {
      return popup['screens'].contains(currentRoute);
    }).toList();
    for (var popup in relatedPopups) {
      String type = popup['repeat_every_type'];
      int count = popup['repeat_every_count'];

      Duration interval;
      switch (type) {
        case "mins":
          interval = Duration(minutes: count);
          break;
        case "hours":
          interval = Duration(hours: count);
          break;
        case "days":
          interval = Duration(days: count);
          break;
        default:
          interval = Duration(minutes: 5);
      }

      String key = 'last_seen_${popup['title']['en']}';
      int? lastSeenMillis = prefs.getInt(key);
      DateTime now = DateTime.now();
      if (lastSeenMillis == null ||
          now.difference(DateTime.fromMillisecondsSinceEpoch(lastSeenMillis)) >=
              interval) {
        await _showPopup(context, popup);
        prefs.setInt(key, now.millisecondsSinceEpoch);
      }
    }
  }

  Future<void> _showPopup(BuildContext context, Map popup) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) {
        final isWeb = kIsWeb;
        final screenHeight = MediaQuery.of(ctx).size.height;
        final screenWidth = MediaQuery.of(ctx).size.width;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // ✅ تحديد أقصى عرض في الويب علشان الشكل مايبقاش عريض أوي
          insetPadding: EdgeInsets.symmetric(
            horizontal: isWeb ? screenWidth * 0.25 : 20,
            vertical: isWeb ? 40 : 20,
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(16),

          content: ConstrainedBox(
            // ✅ تحديد أقصى ارتفاع للـ dialog
            constraints: BoxConstraints(
              maxHeight: isWeb ? screenHeight * 0.8 : screenHeight * 0.9,
            ),

            child: SingleChildScrollView( // ✅ علشان يمنع أي Overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ الصورة (بأقصى ارتفاع)
                  if (popup['images'] != null && popup['images'].isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        await linksAction(popup: popup['go_to'], out: false);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          popup['images'][0]['file'],
                          fit: BoxFit.contain,
                          height: isWeb ? 300 : 250, // Responsive height
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ✅ العنوان
                  if (popup['title']['ar'] != null || popup['title']['en'] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        LocalizationService.isArabic(context: context)
                            ? popup['title']['ar']
                            : popup['title']['en'] ?? "",
                        style: const TextStyle(
                          color: Color(AppColors.dark),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // ✅ المحتوى
                  if (popup['content']['ar'] != null || popup['content']['en'] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        LocalizationService.isArabic(context: context)
                            ? popup['content']['ar']
                            : popup['content']['en'] ?? "",
                        style: const TextStyle(
                          color: Color(AppColors.dark),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),

          actionsAlignment: MainAxisAlignment.center,
          actions: [
            if (popup['go_to'] != null && popup['go_to'].toString().isNotEmpty)
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await linksAction(popup: popup['go_to'], out: false);
                },
                child: Text(
                  AppStrings.go.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppStrings.cancel.tr(),
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void listenToNotifications(BuildContext context) async {
    try {
      final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
      await _analytics.logEvent(
        name: 'open_home_screen',
        parameters: {'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      // Ignore Firebase Analytics errors (e.g., HTTP request aborted)
      // These are non-critical and shouldn't affect app functionality
      debugPrint('Firebase Analytics error (ignored): $e');
    }
  }

  static linksAction({popup, bool? out = false}) async {
    while (Navigator.canPop(rootNavigatorKey.currentContext!)) {
      Navigator.pop(rootNavigatorKey.currentContext!);
    }

    if (popup.startsWith("rm_browser:")) {
      final String link = popup.replaceFirst("rm_browser:", "");
      final Uri url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw '${AppStrings.failed.tr()}: $link';
      }
    } else if (popup.startsWith("rm_webview:")) {
      final link = popup.replaceFirst("rm_webview:", "");
      final lang = CacheHelper.getString("lang");
      rootNavigatorKey.currentContext!.push('/$lang/webview', extra: link);
    } else {
      var result = await routeCompile(popup);
      if (result != null) {
        var route = result['key'];
        var params = result['values'];
        params.forEach((key, value) {
          route = route.replaceFirst('{$key}', value);
        });

        final lang = CacheHelper.getString("lang");
        rootNavigatorKey.currentContext!.goNamed(
          AppRoutes.home.name,
          pathParameters: {'lang': lang},
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          rootNavigatorKey.currentContext!.push(
            '/$lang/$route',
          );
        });
      }
    }
  }

  static routeCompile(urls) async {
    print("PLAY IS IN PROCESS");
    print(urls);
    final url = urls;
    final result = await analyzeRoute(url);
    if (result != null) {
      print("Route Key: ${result['key']}");
      print("Parameters: ${result['values']}");
      return result;
    } else {
      print("No matching route found.");
    }
  }

  static Future<List<dynamic>> loadJson() async {
    const filepath = 'assets/json/routes.json';
    final content = await rootBundle.loadString(filepath);
    return jsonDecode(content);
  }

  static Future<Map<String, dynamic>?> analyzeRoute(String url) async {
    // Decode JSON into an array
    final allRoute = await loadJson();

    // Parse URL and extract path and query parameters
    final uri = Uri.parse(url);
    final path = uri.path
        .trim()
        .replaceAll(RegExp(r'^/|/$'), ''); // Trim leading/trailing slashes
    final queryParams = uri.queryParameters;

    // Iterate through routes to find a match
    for (final route in allRoute) {
      final routePattern = route['backendRoute'];

      // Extract placeholder names (e.g., {id})
      final keys = RegExp(r'\{([^\}]+)\}')
          .allMatches(routePattern)
          .map((match) => match.group(1)!)
          .toList();

      // Convert route pattern to regex
      final pattern = '^' +
          routePattern
              .replaceAll(RegExp(r'\{[^\}]+\}'), '([^/]+)')
              .replaceAll('/', r'\/') +
          r'$';

      // Check if the path matches the pattern
      final matches = RegExp(pattern).allMatches(path);
      if (matches.isNotEmpty) {
        final match = matches.first;
        final params = <String, String>{};

        for (var i = 0; i < keys.length; i++) {
          params[keys[i]] = match.group(i + 1)!;
        }

        // Add query parameters to the values
        params.addAll(queryParams);

        // Return the matching route key and parameters
        return {
          'key': route['frontendRoute'],
          'values': params,
        };
      }
    }
    // Return null if no match is found
    return null;
  }
}
