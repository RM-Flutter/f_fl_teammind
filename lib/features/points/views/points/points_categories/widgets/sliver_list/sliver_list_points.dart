import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/features/points/core/points_api/api_services_implementation.dart';
import 'package:app_test/features/points/views/conditions/condition_section.dart';
import 'package:app_test/features/points/views/history/history_item.dart';
import 'package:app_test/features/points/views/points/points_categories/widgets/sliver_list/widgets/copoun/copoun_section.dart';
import 'package:app_test/features/points/views/points/points_categories/widgets/sliver_list/widgets/referral_selection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
 
import '../../../../../controllers/condition_controller/condition_controller.dart';
import '../../../../../controllers/history_controller/history_controller.dart';
import '../../../../../controllers/points_controller/points_controller.dart';
import '../../../../../data/repositories/condition_repository/condition_repository_implementation.dart';
import '../../../../../data/repositories/history_repository/get_history_repository_implementation.dart';

class SliverListPoints extends StatelessWidget {
  const SliverListPoints({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PointsController>(
      builder: (context, provider, child) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, index) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                ),
                child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22,),
                      defaultTap2BarItem(items: [
                        AppStrings.coupon.tr(),AppStrings.referral.tr(),
                        AppStrings.conditions.tr(),AppStrings.history.tr()]),
                      const SizedBox(height: 29,),
                      provider.selectedIndex == 0 ?
                      CopounSection() :
                      provider.selectedIndex == 2?
                      ChangeNotifierProvider(
                          create: (_) => ConditionController(GetConditionRepositoryImplementation(ApiServicesImplementation(), context))..getCondition(),
                          child: const ConditionSection())
                          :provider.selectedIndex == 3?
                      ChangeNotifierProvider(
                          create: (context) => HistoryController(GetHistoryRepositoryImplementation(ApiServicesImplementation(), context))..getHistory(),
                          child: HistoryItem()): ReferralSection(

                      )
                      ,
                    ],
                  ),
                ),
              );
            },
            childCount: 1,
          ),
        );
      },
    );
  }
}

Widget defaultTap2BarItem({
  required List<String>? items,
  final Function? onTapItem,
  double? tapBarItemsWidth,
}) {
  return Consumer<PointsController>(
    builder: (context, provider, child) {
      bool isWeb = kIsWeb;

      double itemWidth = (tapBarItemsWidth ?? MediaQuery.sizeOf(context).width * 0.9) / (items?.length ?? 1);

      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
          height: isWeb ? null : 45.0,
          width: isWeb
              ? 200
              : (tapBarItemsWidth ?? MediaQuery.sizeOf(context).width * 0.9),
          decoration: BoxDecoration(
            color: Color(AppColors.secondaryButton),
            borderRadius: BorderRadius.circular(25),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            reverse: false,
            scrollDirection: isWeb ? Axis.vertical : Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items!.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                provider.changeIndex(index);
                if (onTapItem != null) {
                  onTapItem(index);
                }
              },
              child: Container(
                height: isWeb ? 45 : 32,
                width: isWeb ? double.infinity : itemWidth - 8,
                margin: isWeb
                    ? const EdgeInsets.symmetric(vertical: 5)
                    : EdgeInsets.zero,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: (provider.selectedIndex == index)
                      ? Color(AppColors.buttons)
                      : Colors.transparent,
                ),
                child: Text(
                  items[index].toUpperCase(),
                  style:  const TextStyle(
                    fontSize: 12,
                    color: Color(0xffFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
