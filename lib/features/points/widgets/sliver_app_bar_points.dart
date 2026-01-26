import 'dart:convert';
import 'package:app_test/features/points/widgets/redeem_now_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import '../controllers/points_cubit/points_provider.dart';

class SliverAppBarPoints extends StatelessWidget {
  bool arrow = true;
  SliverAppBarPoints({super.key, required this.arrow});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PointsProvider(),
      child: Consumer<PointsProvider>(
        builder: (context, pointsProvider, child) {
          return Consumer<HomeController>(
            builder: (context, value, child) {
              final json2String = CacheHelper.getString("US2");
              Map<String, dynamic> us2Cache = {};
              if (json2String != null && json2String != "") {
                us2Cache = json.decode(json2String)
                    as Map<String, dynamic>; // Convert String back to JSON
                print("S111111 IS --> ${us2Cache['points']['available']}");
              }
              // value.userSettings2!.balance!.forEach((key, balance) {
              //   balancePoints = balance.max;
              //   availablePoints = balance.available;
              // });
              return SliverAppBar(
                elevation: 0,
                pinned: true,
                title: Text(
                  AppStrings.myPoints.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: (arrow == true) ? Colors.white : Colors.transparent,
                    size: 18,
                  ),
                  onPressed: () {
                    if (arrow == true) {
                      Navigator.of(context).pop();
                    } else {
                      null;
                    }
                  },
                ),
                expandedHeight: 275,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        defaultFillImageAppbar(containerHeight: 400),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(
                              flex: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.myPointsEarned.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            gapH16,
                            Text.rich(TextSpan(children: [
                              TextSpan(
                                text: us2Cache['points']['available'].toString(),
                                style:  const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: "\t ${AppStrings.points.tr()}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ])),
                            Text(
                              "${AppStrings.from.tr().toUpperCase()} ${us2Cache['points']['total'].toString()} ${AppStrings.myPoints.tr()}",
                              style:  const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(AppRoutes.CategoriesprizePointsViewScreen.name,
                                    pathParameters: {'lang': context.locale.languageCode,});

                                // showModalBottomSheet(
                                //   backgroundColor: Colors.white,
                                //   context: context,
                                //   shape: const RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.only(
                                //       topLeft: Radius.circular(50),
                                //       topRight: Radius.circular(50),
                                //     ),
                                //   ),
                                //   clipBehavior: Clip.antiAlias,
                                //   builder: (context) {
                                //     return MultiProvider(
                                //       providers: [
                                //         ChangeNotifierProvider(
                                //           create: (context) => PrizeProvider(
                                //               GetPrizeRepositoryImplementation(
                                //                   ApiServicesImplementation(),
                                //                   context),
                                //               RedeemPrizeRepositoryImplementation(
                                //                   ApiServicesImplementation(),
                                //                   context))
                                //             ..getPrize(),
                                //         ),
                                //       ],
                                //       child: StatefulBuilder(
                                //         builder: (context, setState) {
                                //           return SizedBox(
                                //             width: double.infinity,
                                //             child: Padding(
                                //               padding: EdgeInsets.all(12.0),
                                //               child: Column(
                                //                 mainAxisSize: MainAxisSize.min,
                                //                 crossAxisAlignment:
                                //                     CrossAxisAlignment.center,
                                //                 children: [
                                //                   const SizedBox(
                                //                     height: 5,
                                //                   ),
                                //                   const BottomSheetEdge(),
                                //                   const SizedBox(
                                //                     height: 15,
                                //                   ),
                                //                   Text(
                                //                       AppStrings.redeemNow
                                //                           .tr()
                                //                           .toUpperCase(),
                                //                       style:  TextStyle(
                                //                         fontSize: 16,
                                //                         fontWeight:
                                //                             FontWeight.bold,
                                //                         color:
                                //                             Color(0xFFE6007E),
                                //                       )),
                                //                   const SizedBox(
                                //                     height: 25,
                                //                   ),
                                //                   const DropDownAndButtonBottomSheet()
                                //                 ],
                                //               ),
                                //             ),
                                //           );
                                //         },
                                //       ),
                                //     );
                                //   },
                                // );
                              },
                              child: const RedeemNowButton(
                                friends: false,
                              ),
                            ),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            // GestureDetector(
                            //   onTap: () async {
                            //     await showModalBottomSheet(
                            //         context: context,
                            //         isScrollControlled: true, // Allow full screen interaction
                            //         builder: (BuildContext context) {
                            //           return SendPointFriendBottomSheet();
                            //         });
                            //   },
                            //   child: const RedeemNowButton(
                            //     friends: true,
                            //   ),
                            // ),
                            const Spacer(
                              flex: 1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
Widget defaultFillImageAppbar({
  double? containerHeight
}){
  return Container(
    height: containerHeight ?? 212,
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30))),
    width: double.infinity,
    child: ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30)),
        child: Image.asset(
          "assets/images/png/points_back.png",
          fit: BoxFit.cover,
        )),
  );
}