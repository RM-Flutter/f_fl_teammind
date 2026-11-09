import 'dart:convert';

import 'package:app_test/core/utils/app_styles.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'fade_slide_in.dart';
import 'package:app_test/core/constants/app_design.dart';

class VacationListWidget extends StatelessWidget {
  final bool? isInRequestsPage;
  final bool tap;
  final double? paddingBetweenVocations;
  final double? sectionPadding;
  final List<RequestModel>? requests;
  /// Slide the cards in one by one when first shown (used on the home page).
  final bool animateEntrance;

  const VacationListWidget(
      {super.key,
        this.animateEntrance = false,
        this.requests,
        required this.tap,
        this.paddingBetweenVocations = AppSizes.s12,
        this.sectionPadding = AppSizes.s32,
        this.isInRequestsPage = false});

  @override
  Widget build(BuildContext context) {
    final screenWidth = LayoutService.getWidth(context);
    final gap = paddingBetweenVocations ?? AppSizes.s12;
    const horizontalPad = AppSpacing.page * 2;
    final mobileBaseWidth = screenWidth.clamp(320.0, 430.0);
    final minItemWidth = (mobileBaseWidth - (horizontalPad + gap * 2)) / 3;

    double getResponsiveItemWidth(int itemCount) {
      final count = itemCount > 0 ? itemCount : 3;
      final distributedWidth =
          (screenWidth - horizontalPad - gap * (count - 1)) / count;
      return distributedWidth > minItemWidth ? distributedWidth : minItemWidth;
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
      vacationBalance = balance?.entries.where((entry) {
        final b = entry.value;
        final bool isTaken = b.max == -1 && b.available == -1;
        if (!isTaken) {
          final availNum = num.tryParse(b.available?.toString() ?? '');
          if (availNum != null && availNum < 0) {
            return false;
          }
        }
        return true;
      }).toList() ?? [];
    }

    final totalCount = 1 + (vacationBalance?.length ?? 0);
    final itemWidth = getResponsiveItemWidth(totalCount);

    if (vacationBalance != null) {
      vacationWidgets = [
        for (int i = 0; i < vacationBalance.length; i++)
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: i < vacationBalance.length - 1 ? gap : 0,
            ),
            child: VacationCard(
              vocation: vacationBalance[i],
              tap: tap,
              sectionPadding: sectionPadding,
              paddingBetweenVocations: paddingBetweenVocations,
              cardWidth: itemWidth,
            ),
          ),
      ];
    }
    vacationWidgets ??= [];
    vacationWidgets.insert(
      0,
      Padding(
          padding: EdgeInsetsDirectional.only(
            end: vacationWidgets.isNotEmpty ? gap : 0,
          ),
          child: InkWell(
            onTap: () async => await context.pushNamed(
                AppRoutes.requestsCalendar.name,
                pathParameters: {
                  'type': 'mine',
                  'lang': context.locale.languageCode
                },
                extra: requests),
            child: Container(
              width: itemWidth,
              height: 128,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.s10, horizontal: AppSizes.s6),
              decoration: BoxDecoration(
                // Glass tile: reads as a shortcut on the navy header, not as one more balance card.
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(AppColors.buttons),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.calendar_month_rounded,
                        color: Colors.white, size: 22),
                  ),
                  gapH8,
                  Text(
                    AppStrings.viewOnCalendar.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );

    final shimmerItemWidth = getResponsiveItemWidth(3);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.s32),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // Page padding lives on the scroll view: the first card lines up with the page edge
          // and the list still scrolls to the screen edge (layout rule 1).
          padding: AppSpacing.pagePadding,
          child: Row(
            children: gCache == null
                ? List.generate(
                3,
                    (index) => Padding(
                    padding: EdgeInsetsDirectional.only(end: index < 2 ? gap : 0),
                    child: ShimmerAnimatedLoading(
                      width: shimmerItemWidth,
                      height: 110,
                      circularRaduis: AppRadius.md,
                    )))
                : (animateEntrance
                    ? [
                        for (int i = 0; i < vacationWidgets.length; i++)
                          FadeSlideIn(
                            delay: Duration(milliseconds: 150 * i),
                            offsetX: LocalizationService.isArabic(context: context) ? -0.5 : 0.5,
                            offsetY: 0,
                            child: vacationWidgets[i],
                          ),
                      ]
                    : vacationWidgets),
          ),
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
  final double? cardWidth;
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
        this.cardWidth,
        this.userId,
        this.customBody});

  @override
  Widget build(BuildContext context) {

    bool isTaken = vocation.value.max == -1 && vocation.value.available == -1;
    double getResponsiveItemWidth(BuildContext context, {double? paddingBetweenVocations}) {
      final effectiveWidth = LayoutService.getWidth(context).clamp(320.0, 430.0);
      final totalPadding = AppSizes.s32 + ((paddingBetweenVocations ?? AppSizes.s0) * 2);
      return (effectiveWidth - totalPadding) / 3;
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
        width: cardWidth ?? getResponsiveItemWidth(context, paddingBetweenVocations: paddingBetweenVocations),
        height: 128,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Color(AppColors.secondaryButton), // Match BalanceCard color
          borderRadius: BorderRadius.circular(AppRadius.md), // Match BalanceCard radius
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
              style: AppStyles.whiteContent(context).copyWith(
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

