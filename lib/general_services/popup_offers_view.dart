import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/popup_model.dart';
import '../modules/home/views/widgets/webview_offers.dart';
import '../routing/app_router.dart';
import 'localization.service.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

void checkAndShowPopup(BuildContext context, String? currentRoute, List? popups) async {
  if (currentRoute == null || popups == null) return;

  final prefs = await SharedPreferences.getInstance();

  for (var popup in popups) {
    if (popup['screens'].contains(currentRoute)) {
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

      String key = 'last_seen_${popup['id']}';
      int? lastSeenMillis = prefs.getInt(key);
      DateTime now = DateTime.now();
      _showPopup(context, popup);

      // if (lastSeenMillis == null || now.difference(DateTime.fromMillisecondsSinceEpoch(lastSeenMillis)) >= interval) {
      //   _showPopup(context, popup);
      //   prefs.setInt(key, now.millisecondsSinceEpoch);
      // }
      Timer.periodic(interval, (timer) async {
        if (!context.mounted) {
          timer.cancel();
          return;
        }
        int? lastSeen = prefs.getInt(key);
        DateTime now = DateTime.now();
        if (lastSeen == null || now.difference(DateTime.fromMillisecondsSinceEpoch(lastSeen)) >= interval) {
          _showPopup(context, popup);
          prefs.setInt(key, now.millisecondsSinceEpoch);
        }
      });

      break;
    }
  }
}


void _showPopup(BuildContext context, Map popup) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // غيّر القيمة زي ما تحب
      ),
      titlePadding: EdgeInsets.zero,   // يشيل المساحة حوالين الـ title
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (popup['images'] != null && popup['images'].isNotEmpty)
            GestureDetector(
              onTap: ()async{
                if(popup['go_to'].startsWith("rm_browser:")){
                  final String link = popup['go_to'].replaceFirst("rm_browser:", "");
                  final Uri url = Uri.parse(link);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw '${AppStrings.failed.tr()}: $link';
                  }
                }else if(popup['go_to'].startsWith("rm_webview:")) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewStackOffers(popup['go_to'].replaceFirst("rm_webview:", "").toString()),));
                }else{
                  context.pushNamed(
                      AppRoutes.taskScreen.name,
                      pathParameters: {
                        'lang': context.locale.languageCode
                      });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  popup['images'][0]['file'],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          if(popup['title']['ar'] != null || popup['title']['en'] != null)Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              LocalizationService.isArabic(context: context)? popup['title']['ar']:popup['title']['en'] ??"",
              style: const TextStyle(
                color: Color(AppColors.dark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: popup['content']['ar'] != null || popup['content']['en'] != null ? Text(
        LocalizationService.isArabic(context: context)?popup['content']['ar']:popup['content']['en'] ??"",
        style: const TextStyle(color: Color(AppColors.dark)),
      ): null,
      actions:  [
        if((popup['content']['ar'] != null || popup['content']['en'] != null ||
            popup['title']['ar'] != null || popup['title']['en'] != null))TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(AppStrings.go.tr()),
                    ),
        if((popup['content']['ar'] != null || popup['content']['en'] != null ||
            popup['title']['ar'] != null || popup['title']['en'] != null))TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(AppStrings.cancel.tr()),
                    )
      ],
    ),
  );

}
