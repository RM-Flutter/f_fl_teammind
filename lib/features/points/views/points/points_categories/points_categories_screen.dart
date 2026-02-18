import 'dart:convert';

import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/points/views/fawry/widgets/withdraw_money_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';

import '../../../../../core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../../../../../core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../../../controllers/points_controller/points_controller.dart';

class PointsCategoriesScreen extends StatefulWidget {
  final bool viewArrow;
  const PointsCategoriesScreen(this.viewArrow, {super.key});

  @override
  _PointsCategoriesScreenState createState() => _PointsCategoriesScreenState();
}

class _PointsCategoriesScreenState extends State<PointsCategoriesScreen> {
  final ScrollController _scrollController = ScrollController();
  late PointsController pointsProvider;
  var payoutName;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pointsProvider = Provider.of<PointsController>(context, listen: false);
      pointsProvider.getCategoriesPrize(context, page: 1);
    });
    _scrollController.addListener(() {
      print("Current scroll position: ${_scrollController.position.pixels}");
      print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !pointsProvider.isLoading &&
          pointsProvider.hasMore) {
        print("BOTTOM BOTTOM");
        if(pointsProvider.hasMore == true) {
          pointsProvider.getCategoriesPrize(
              context, page: pointsProvider.currentPage);
        }else{
          print("NO DATA MORE");
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, value, child) {
        return Consumer<PointsController>(
          builder: (context, points, child) {
            final jsonString = CacheHelper.getString("USG");
            Map<String, dynamic>? gCache;
            if (jsonString != null && jsonString.isNotEmpty) {
              gCache = json.decode(jsonString) as Map<String, dynamic>;
            }
            final fawryPayout = gCache?["fawry_payout"];
            if (fawryPayout is Map && fawryPayout['active'] == true) {
              final titleMap = fawryPayout['title'];
              if (titleMap is Map) {
                payoutName = LocalizationService.isArabic(context: context)
                    ? (titleMap['ar']?.toString() ?? '')
                    : (titleMap['en']?.toString() ?? '');
              }
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (points.isLoading == false && points.status == true) {
                final hasPayout = payoutName != null
                    ? points.categories.any((e) => e['title'] == payoutName)
                    : true;
                final hasFawry = points.categories.any((e) => e['title'] == AppStrings.fawry.tr());
                if (!hasFawry) {
                  final fawry = gCache?["fawry"];
                  if (fawry is Map && fawry['active'] == true) {
                    points.categories.add({
                      "id": 0,
                      "title": AppStrings.fawry.tr(),
                      "image": fawry['logo']
                    });
                  }
                }
                if (!hasPayout) {
                  if (fawryPayout is Map && fawryPayout['active'] == true) {
                    points.categories.add({
                      "id": 0,
                      "title": payoutName,
                      "image": fawryPayout['logo']
                    });
                  }
                }
                setState(() {});
              }
            });

            return SafeArea(
              child: Scaffold( resizeToAvoidBottomInset: false,
                backgroundColor: const Color(0xffFFFFFF),
                body: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,

                  controller: _scrollController,
                  child: GradientBgImage(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.transparent,
                          height: 90,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: widget.viewArrow ? const Color(0xff224982) : Colors.transparent),
                                onPressed: () => widget.viewArrow ? Navigator.pop(context) : null,
                              ),
                              Text(
                                AppStrings.chooseTheCategory.tr().toUpperCase(),
                                style: const TextStyle(color: Color(0xff224982), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.transparent),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.s20),
                        if(points.categories.isEmpty)Container(
                          height: MediaQuery.sizeOf(context).height * 0.8,
                          alignment: Alignment.center,
                          child: NoExistingPlaceholderScreen(
                              height: LayoutService.getHeight(context) * 0.4,
                              title: AppStrings.noCategoriesAvailable.tr()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1/1.3,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: List.generate((points.isLoading && points.currentPage == 1)?8 :
                                points.categories.length, (index){
                                  return (points.isLoading && points.currentPage == 1)?
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 100, // Adjust height based on your UI
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8), // Adjust as needed
                                      ),
                                    ),
                                  ):
                                  defaultProjectCard(
                                    points.categories[index]['title'] ??"",
                                    (points.categories[index]['image'] != null && points.categories[index]['image'].isNotEmpty)?
                                    points.categories[index]['image'][0]['file'] : "",
                                    onTap: (){
                                      if(points.categories[index]['title'] == payoutName && gCache != null){
                                        final ppu = gCache?['fawry_payout'] is Map
                                            ? (gCache?['fawry_payout']?['points_per_unit'])?.toString()
                                            : null;
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawMoneyScreen(ppu ?? "0"),));
                                      }
                                      if(points.categories[index]['title'] == AppStrings.fawry.tr()){
                                        context.pushNamed(
                                            AppRoutes.fawryProviderScreen
                                                .name,
                                            pathParameters: {
                                              'lang': context.locale
                                                  .languageCode,
                                            });
                                      }if(points.categories[index]['title'] != payoutName && points.categories[index]['title'] != AppStrings.fawry.tr()) {
                                        context.pushNamed(
                                            AppRoutes.prizePointsViewScreen
                                                .name,
                                            pathParameters: {
                                              'lang': context.locale
                                                  .languageCode,
                                              'id': points
                                                  .categories[index]['id']
                                                  .toString(),
                                            });
                                      }
                                    },
                                  );
                                })
                            ),
                          ),
                        ),
                        SizedBox(height: 15,),
                        if (points.isLoading && points.currentPage != 1)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget defaultProjectCard(String? title1, src, {onTap}) {
    return GestureDetector(
      onTap: onTap ?? (){},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                child:  CachedNetworkImage(
                  height: 135,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  imageUrl: src,
                  placeholder: (context, url) =>
                  const ShimmerAnimatedLoading(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: AppSizes.s32,
                    color: Colors.white,
                  ),
                ),), // Replace with project images
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title1 ?? "".toUpperCase(),maxLines: 1, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF090B60))),],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
