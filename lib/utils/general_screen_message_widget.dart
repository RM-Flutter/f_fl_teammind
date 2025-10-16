import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';

import '../constants/app_sizes.dart';
import '../general_services/settings.service.dart';

class GeneralScreenMessageWidget extends StatelessWidget {
  /// current Screen route
  final String screenId;
  String? id = "1";
  final int? maxTextLines;
  GeneralScreenMessageWidget(
      {super.key, this.maxTextLines = 3, required this.screenId, this.id});

  @override
  Widget build(BuildContext context) {
    var gCache;
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;// Convert String back to JSON
    }return  gCache["general_message_by_screen"] != null && gCache["general_message_by_screen"].isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(
                left: AppSizes.s12, right: AppSizes.s12, bottom: AppSizes.s16),
            child: ListView.separated(
                reverse: false,
                shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => AutoSizeText(
                  LocalizationService.isArabic(context: context)? gCache["general_message_by_screen"][index]["screen_message"]["ar"]:gCache["general_message_by_screen"][index]["screen_message"]["en"] ?? "",
                  maxLines: maxTextLines,
                  style: const TextStyle(
                      color: Color(0xff404040),
                      fontSize: AppSizes.s12,
                      fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ), separatorBuilder: (context, index) => const SizedBox(height: 15,), itemCount: gCache["general_message_by_screen"].length)
          )
        : const SizedBox.shrink();
  }
}
