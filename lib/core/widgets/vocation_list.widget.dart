import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../constants/user_consts.dart';
import '../models/requests_model.dart';
import '../models/settings/user_settings_2.model.dart';
import '../routing/app_router.dart';
import '../services/backend_services/api_service/dio_api_service/shared.dart';
import '../services/layout_service.dart';
import '../services/localization_service.dart';
import '../utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class VacationListWidget extends StatelessWidget {
  final bool? isInRequestsPage;
  final bool tap;
  final double? paddingBetweenVocations;
  final double? sectionPadding;
  final List<RequestModel>? requests;

  const VacationListWidget(
      {super.key,
        this.requests,
        required this.tap,
        this.paddingBetweenVocations = AppSizes.s12,
        this.sectionPadding = AppSizes.s32,
        this.isInRequestsPage = false});

  @override
  Widget build(BuildContext context) {
    double getResponsiveItemWidth(BuildContext context, {double? paddingBetweenVocations}) {
      final screenWidth = LayoutService.getWidth(context);
      int crossAxisCount;

      if (kIsWeb) {
        if (screenWidth > 1400) {
          crossAxisCount = 6; // شاشات كبيرة جدًا
        } else if (screenWidth > 1000) {
          crossAxisCount = 5; // لابتوب
        } else {
          crossAxisCount = 4; // تابلت أو شاشة صغيرة
        }
      } else {
        if (screenWidth > 600) {
          crossAxisCount = 4; // تابلت
        } else {
          crossAxisCount = 3; // موبايل
        }
      }

      final totalPadding = AppSizes.s32 + ((paddingBetweenVocations ?? AppSizes.s0) * 2);
      return (screenWidth - totalPadding) / crossAxisCount;
    }
    var jsonString;
    var gCache;
    List<MapEntry<String, Balance>>? vacationBalance;
    List<Widget>? vacationWidgets;
    Map<String, Balance>? balance ;
    jsonString = CacheHelper.getString("US2");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings2 = UserSettings2Model.fromJson(gCache);
    }
    if(gCache != null && gCache['balance'] != null &&  (gCache['balance'] is! List || (gCache['balance'] as List).isNotEmpty)){
      balance = (gCache['balance'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Balance.fromJson(value)),
      );
      vacationBalance = balance?.entries.toList() ?? [];

      vacationWidgets = vacationBalance
          .map((entry) => Padding(
        padding: EdgeInsets.only(right: paddingBetweenVocations!),
        child: VacationCard(
          vocation: entry,
          tap: tap,
          sectionPadding: sectionPadding,
          paddingBetweenVocations: paddingBetweenVocations,
        ),
      ))
          .toList();
    }
    vacationWidgets ??= [];
    vacationWidgets.insert(
      0,
      Padding(
          padding: EdgeInsets.only(right: paddingBetweenVocations!),
          child: InkWell(
            onTap: () async => await context.pushNamed(
                AppRoutes.requestsCalendar.name,
                pathParameters: {
                  'type': 'mine',
                  'lang': context.locale.languageCode
                },
                extra: requests),
            child: Container(
              width: getResponsiveItemWidth(context, paddingBetweenVocations: paddingBetweenVocations),
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s10, horizontal: AppSizes.s6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/images/svg/calendar.svg"),
                  gapH8,
                  Text(
                    AppStrings.viewOnCalendar.tr().toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s32),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: gCache == null
              ? List.generate(
              3,
                  (index) => Padding(
                  padding: EdgeInsets.only(right: paddingBetweenVocations!),
                  child: ShimmerAnimatedLoading(
                    width: (LayoutService.getWidth(context) -
                        (AppSizes.s32 +
                            ((paddingBetweenVocations ?? AppSizes.s0) *
                                3))) /
                        3,
                    height: 110,
                  )))
              : vacationWidgets,
        ),
      ),
    );
  }
}


class VacationCard extends StatelessWidget {
  final bool? isInRequestsPage;
  final double? sectionPadding;
  final MapEntry<String, Balance> vocation;
  final double? paddingBetweenVocations;
  final Widget? customBody;
  final String? userId;
  bool tap = true;
  var type;
  VacationCard(
      {super.key,
        this.isInRequestsPage = false,
        this.sectionPadding,
        required this.tap,
        this.type,
        required this.vocation,
        this.paddingBetweenVocations,
        this.userId,
        this.customBody});

  @override
  Widget build(BuildContext context) {

    bool isTaken = vocation.value.max == -1 && vocation.value.available == -1;
    double getResponsiveItemWidth(BuildContext context, {double? paddingBetweenVocations}) {
      final screenWidth = LayoutService.getWidth(context);
      int crossAxisCount;

      if (kIsWeb) {
        if (screenWidth > 1400) {
          crossAxisCount = 6; // شاشات كبيرة جدًا
        } else if (screenWidth > 1000) {
          crossAxisCount = 5; // لابتوب
        } else {
          crossAxisCount = 4; // تابلت أو شاشة صغيرة
        }
      } else {
        if (screenWidth > 600) {
          crossAxisCount = 4; // تابلت
        } else {
          crossAxisCount = 3; // موبايل
        }
      }

      final totalPadding = AppSizes.s32 + ((paddingBetweenVocations ?? AppSizes.s0) * 2);
      return (screenWidth - totalPadding) / crossAxisCount;
    }
    return InkWell(
      onTap: tap == false ?()async {} : () async => isInRequestsPage == false
          ? await context.pushNamed(AppRoutes.requestsById.name,
          pathParameters: {
            'type': type ?? "me",
            'id': vocation.key,
            'lang': context.locale.languageCode
          },
          extra: {
            'offset': const Offset(1.0, 0.0),
            'userId': userId
          })
          : await context.pushNamed(AppRoutes.requestsById.name,
          pathParameters: {
            'id': vocation.key,
            'type': type,
            'lang': context.locale.languageCode
          },
          extra: {
            'userId': userId
          }),
      child: Container(
        width: getResponsiveItemWidth(context, paddingBetweenVocations: paddingBetweenVocations),
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary, // Match BalanceCard color
          borderRadius: BorderRadius.circular(12), // Match BalanceCard radius
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Match BalanceCard layout
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title section
            Text(
              (context.locale.languageCode == 'ar'
                  ? vocation.value.title!.ar!
                  : vocation.value.title!.en! ?? '-')
                  .replaceAll(' ', '\n'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.1,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Value section
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (isTaken ? AppStrings.taken.tr() : AppStrings.remaining.tr()),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(isTaken ? vocation.value.take : vocation.value.available)?.toString() ?? '0'} ${vocation.value.type?.toString().tr() ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Match BalanceCard size
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                // "FROM" line
                Text(
                  (!isTaken && vocation.value.max != -1)
                      ? '${AppStrings.from.tr()} ${(vocation.value.max?.toString() ?? '0')}'
                      : '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

