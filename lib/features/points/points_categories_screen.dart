import 'dart:convert';

import 'package:app_test/features/points/controllers/points_cubit/points_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout.service.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';

import '../../core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../../core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';

class PointsCategoriesScreen extends StatefulWidget {
  final bool viewArrow;
  const PointsCategoriesScreen(this.viewArrow, {super.key});

  @override
  _PointsCategoriesScreenState createState() => _PointsCategoriesScreenState();
}

class _PointsCategoriesScreenState extends State<PointsCategoriesScreen> {
  final ScrollController _scrollController = ScrollController();
  late PointsProvider pointsProvider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      debugPrint("Current scroll position: ${_scrollController.position.pixels}");
      debugPrint("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !pointsProvider.isLoading &&
          pointsProvider.hasMore) {
        debugPrint("BOTTOM BOTTOM");
       if(pointsProvider.hasMore == true) {
         pointsProvider.getCategoriesPrize(
             context, page: pointsProvider.currentPage);
       }else{
         debugPrint("NO DATA MORE");
       }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => PointsProvider()..getCategoriesPrize(context, page: 1),
    child: Consumer<HomeController>(
      builder: (context, value, child) {
        return Consumer<PointsProvider>(
          builder: (context, points, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (points.isLoading == false) {
                final hasFawry = points.categories.any((e) => e['title'] == AppStrings.fawry.tr());
                if (!hasFawry) {
                  final jsonString = CacheHelper.getString("USG");
                  if (jsonString != null) {
                    final gCache = json.decode(jsonString) as Map<String, dynamic>;
                    if (gCache["fawry"]['active'] == true) {
                      points.categories.add({
                        "id": 0,
                        "title": AppStrings.fawry.tr(),
                        "image": gCache["fawry"]['logo']
                      });
                      setState(() {});
                    }
                  }
                }
              }
            });
            return SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: const Color(0xffFFFFFF),
                body: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                icon:  const Icon(Icons.arrow_back, color:Color(0xff224982)),
                                onPressed: !kIsWeb?() {
                                  Navigator.pop(context);
                                } : (){},
                              ),
                              Text(
                                AppStrings.chooseTheCategory.tr().toUpperCase(),
                                style: TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon:  const Icon(Icons.arrow_back, color: Colors.transparent),
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
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: kIsWeb ? 1100 : double.infinity,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: kIsWeb ? 4 : 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: kIsWeb ? 1.0 : 1 / 1.3, // web أقصر شوية
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: (points.isLoading && points.currentPage == 1)
                                      ? 8
                                      : points.categories.length,
                                  itemBuilder: (context, index) {
                                    if (points.isLoading && points.currentPage == 1) {
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return defaultProjectCard(
                                        points.categories[index]['title'] ?? "",
                                        (points.categories[index]['image'] != null &&
                                            points.categories[index]['image'].isNotEmpty)
                                            ? points.categories[index]['image'][0]['file']
                                            : "",
                                        onTap: () {
                                          if (points.categories[index]['title'] == AppStrings.fawry.tr()) {
                                            context.pushNamed(
                                              AppRoutes.fawryProviderScreen.name,
                                              pathParameters: {'lang': context.locale.languageCode},
                                            );
                                          } else {
                                            context.pushNamed(
                                              AppRoutes.prizePointsViewScreen.name,
                                              pathParameters: {
                                                'lang': context.locale.languageCode,
                                                'id': points.categories[index]['id'].toString(),
                                              },
                                            );
                                          }
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
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
    ),
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
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                child:  CachedNetworkImage(
                  height: 135,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  imageUrl: src,
                  placeholder: (context, url) =>
                  const ShimmerAnimatedLoading(),
                  errorWidget: (context, url, error) =>  const Icon(
                    Icons.image_not_supported_outlined,
                    size: AppSizes.s32,
                    color: Colors.white,
                  ),
                ),), // Replace with project images
              const SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title1 ?? "".toUpperCase(),maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF090B60))),],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
