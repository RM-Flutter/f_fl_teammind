import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../services/backend_services/api_service/dio_api_service/shared.dart';
import '../services/localization_service.dart';

class GeneralScreenMessageWidget extends StatelessWidget {
  /// current Screen route
  final String screenId;
  String? id = "1";
  final int? maxTextLines;
  GeneralScreenMessageWidget(
      {super.key, this.maxTextLines = 3, required this.screenId, this.id});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? gCache;
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "null") {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          gCache = decoded;
        }
      } catch (e) {
        debugPrint("Error decoding USG in general_screen_message_widget.dart: $e");
      }
    }
    if (gCache == null) return const SizedBox.shrink();
    final messages = (gCache["general_message_by_screen"] as List?)?.cast<Map<String, dynamic>>();
    if (messages == null || messages.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSizes.s12, right: AppSizes.s12, bottom: AppSizes.s16),
      child: ListView.separated(
          reverse: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) => AutoSizeText(
            LocalizationService.isArabic(context: context)
                ? messages[index]["screen_message"]["ar"]
                : messages[index]["screen_message"]["en"] ?? "",
            maxLines: maxTextLines,
            style: const TextStyle(
                color: Color(AppColors.grey40),
                fontSize: AppSizes.s12,
                fontWeight: FontWeight.w400),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemCount: messages.length),
    );
  }
}
