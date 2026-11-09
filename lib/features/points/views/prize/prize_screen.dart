import 'package:app_test/core/services/app_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_test/features/points/views/prize/widgets/raya/widgets/bottom_sheet_external_success.dart';
import 'package:app_test/features/points/views/prize/widgets/raya/raya_add_data_bottomsheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
import '../../../../core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../../../../core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../../controllers/points_controller/points_controller.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';

class PrizeScreen extends StatefulWidget {
  final bool viewArrow;
  var id;
  PrizeScreen(this.viewArrow, this.id, {super.key});

  @override
  _PrizeScreenState createState() => _PrizeScreenState();
}

class _PrizeScreenState extends State<PrizeScreen> {
  final ScrollController _scrollController = ScrollController();
  late PointsController pointsProvider;
  FocusNode fieldFocusNode = FocusNode();
  FocusNode fieldFocusNode2 = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pointsProvider = Provider.of<PointsController>(context, listen: false);
      pointsProvider.getPrize(context, widget.id, page: 1);
    });
    _scrollController.addListener(() {
      print("Current scroll position: ${_scrollController.position.pixels}");
      print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent -
                      _scrollController.position.pixels)
                  .abs() <
              10 &&
          !pointsProvider.isLoading &&
          pointsProvider.hasMorePrizes) {
        print("BOTTOM BOTTOM");
        if (pointsProvider.hasMorePrizes == true) {
          pointsProvider.getPrize(context, widget.id,
              page: pointsProvider.currentPage);
        } else {
          print("NO PRIZE GET");
        }
      }
    });
  }

  void copyToClipboard(BuildContext context, {text}) {
    Clipboard.setData(ClipboardData(text: text));
    AppToast.showToast(
        msg: AppStrings.textCopiedToClipboard.tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, value, child) {
        return Consumer<PointsController>(
          builder: (context, points, child) {
            if (points.isRedeemSuccess == true) {
              print("points.type --> ${points.type}");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                points.getPrize(context, widget.id, page: 1);
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                value.initializeHomeScreen(context, null);
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (points.type == "external" || points.type == "internal") {
                  if (points.redeemCode != null) {
                    PointsSuccessSheet.externalSuccess(fieldFocusNode,
                        context: context,
                        redeemCode: points.redeemCode.toString());
                  } else {
                    PointsSuccessSheet.manualSuccess(fieldFocusNode2,
                        context: context);
                  }
                } else {
                  PointsSuccessSheet.manualSuccess(fieldFocusNode2,
                      context: context);
                }
              });
              points.isRedeemSuccess = false;
            }
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Color(AppColors.background),
              appBar: AppBarWithBookmark(
                title: AppStrings.chooseThePrize.tr().toUpperCase(),
                centerTitle: true,
                leading: widget.viewArrow ? null : const SizedBox.shrink(),
              ),
              body: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                controller: _scrollController,
                child: GradientBgImage(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.s20),
                      if (points.prizes.isEmpty && !points.isLoading)
                        Container(
                          height: MediaQuery.sizeOf(context).height * 0.8,
                          alignment: Alignment.center,
                          child: NoExistingPlaceholderScreen(
                              height: LayoutService.getHeight(context) * 0.4,
                              title: AppStrings.noPrizesAvailable.tr()),
                        ),
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        clipBehavior: Clip.none,
                        shrinkWrap: true,
                        reverse: false,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.cardGap),
                        itemCount: points.isLoading && points.currentPage == 1
                            ? 12 // Show 5 loading items initially
                            : points.prizes.length,
                        itemBuilder: (context, index) {
                          if (points.isLoading && points.currentPage == 1) {
                            return const AppShimmerCard();
                          } else {
                            return InkWell(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              onTap: points.isRedeemLoading == false
                                  ? () {
                                      setState(() {
                                        points.selectIndex = index;
                                        points.type =
                                            points.prizes[index]['type']['key'];
                                      });
                                      if ((points.prizes[index]['type']['key'] == "external" || points.prizes[index]['type']['key'] == "internal") &&
                                          (points.prizes[index]['needed_data'].isNotEmpty &&
                                              points.prizes[index]['needed_data'] !=
                                                  [] &&
                                              points.prizes[index]['needed_data'] !=
                                                  null)) {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled:
                                                true, // Allow full screen interaction
                                            builder: (BuildContext context) {
                                              return RayaAddDataBottomsheet(
                                                  points.prizes[index]['id'],
                                                  points.prizes[index]
                                                      ['needed_data']);
                                            });
                                      } else if ((points.prizes[index]['type']['key'] != "external" &&
                                              points.prizes[index]['type']['key'] !=
                                                  "internal") &&
                                          (points.prizes[index]['needed_data'].isEmpty ||
                                              points.prizes[index]['needed_data'] ==
                                                  [] ||
                                              points.prizes[index]['needed_data'] ==
                                                  null)) {
                                        PointsSuccessSheet
                                            .showConfirmationSheet(context,
                                                onTap: () async {
                                          Navigator.pop(context);
                                          await points.postRedeemPrize(context,
                                              id: points.prizes[index]['id']
                                                  .toString());
                                        });
                                      } else if ((points.prizes[index]['type']['key'] == "external" ||
                                              points.prizes[index]['type']['key'] ==
                                                  "internal") &&
                                          (points.prizes[index]['needed_data'].isEmpty ||
                                              points.prizes[index]['needed_data'] == [] ||
                                              points.prizes[index]['needed_data'] == null)) {
                                        PointsSuccessSheet
                                            .showConfirmationSheet(context,
                                                onTap: () async {
                                          Navigator.pop(context);
                                          await points.postRedeemPrize(context,
                                              id: points.prizes[index]['id']
                                                  .toString());
                                        });
                                      } else if (points.prizes[index]['type']['key'] == null) {
                                        PointsSuccessSheet
                                            .showConfirmationSheet(context,
                                                onTap: () async {
                                          Navigator.pop(context);
                                          await points.postRedeemPrize(context,
                                              id: points.prizes[index]['id']
                                                  .toString());
                                        });
                                      } else {
                                        print(
                                            "DATA --> ${points.prizes[index]['needed_data']}");
                                      }
                                    }
                                  : () {},
                              child: Container(
                                padding: AppSpacing.cardPadding,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border: AppBorders.card,
                                  boxShadow: AppShadows.card,
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                      child: CachedNetworkImage(
                                          imageUrl: (points
                                                  .prizes[index]['image']
                                                  .isNotEmpty)
                                              ? points.prizes[index]['image'][0]
                                                  ['file']
                                              : "",
                                          fit: BoxFit.contain,
                                          height: 110,
                                          width: double.infinity,
                                          placeholder: (context, url) =>
                                              const ShimmerAnimatedLoading(
                                                width: 63.0,
                                                height: 63,
                                                circularRaduis: 63,
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                              )),
                                    ),
                                    gapH14,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!points.isRedeemLoading)
                                          Icon(
                                            Icons.arrow_back_ios,
                                            size: 16,
                                          ),
                                        if (!points.isRedeemLoading) gapH4,
                                        if (!points.isRedeemLoading)
                                          Text(
                                            "${points.prizes[index]['points']} ${AppStrings.points.tr()}"
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xff0D3B6F)),
                                          ),
                                        if (points.isRedeemLoading &&
                                            points.selectIndex == index)
                                          const CircularProgressIndicator()
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      if (points.isLoading && points.currentPage != 1)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
