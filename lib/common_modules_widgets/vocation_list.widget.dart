import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/services/requests.services.dart';
import '../constants/app_sizes.dart';
import '../general_services/layout.service.dart';
import '../models/request.model.dart';
import '../models/settings/user_settings_2.model.dart';
import '../routing/app_router.dart';
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
              width: (LayoutService.getWidth(context) -
                  (AppSizes.s32 +
                      ((paddingBetweenVocations ?? AppSizes.s0) * 2))) /
                  3,
              height: AppSizes.s120,
              padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.s14, horizontal: AppSizes.s6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppSizes.s8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/images/svg/calendar.svg"),
                  gapH18,
                  Expanded(
                    child: Text(AppStrings.viewOnCalendar.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge),
                  )
                ],
              ),
            ),
          )),
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
                        height: AppSizes.s120,
                      )))
              : vacationWidgets! ,
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
          // if the old page is request page , so i dont need to pass type as path parameter becouse the current location is already contain type parameter
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
        width: (LayoutService.getWidth(context) -
                (AppSizes.s32 +
                    ((paddingBetweenVocations ?? AppSizes.s0) * 2))) /
            3,
        height: AppSizes.s120,
        padding: const EdgeInsets.symmetric(
            vertical: AppSizes.s14, horizontal: AppSizes.s6),
        decoration: BoxDecoration(
          color: const Color(AppColors.dark),
          borderRadius: BorderRadius.circular(AppSizes.s8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoSizeText(
              LocalizationService.isArabic(context: context)? vocation.value.title!.ar! : vocation.value.title!.en! ?? '-',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if(vocation.value.max != -1) gapH18,
             Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                 if(vocation.value.max != -1) AutoSizeText(
                     AppStrings.remaining.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                 if(isTaken) AutoSizeText(
                   AppStrings.taken.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  gapH4,
                  if(isTaken) AutoSizeText(
                      '${(vocation.value.take?.toString() ?? '0')} ${(vocation.value.type?.toString().tr() ?? '')}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.s20,
                          )),
                  if(!isTaken && vocation.value.max != -1)AutoSizeText(
                      '${(vocation.value.available?.toString() ?? '0') } ${(vocation.value.type?.toString().tr() ?? '')}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.s20,
                          )),
                  gapH4,
                  if (vocation.value.max != -1 &&
                      vocation.value.available != -1)
                    AutoSizeText(
                      '${AppStrings.from.tr()} ${(vocation.value.max?.toString() ?? '0')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
