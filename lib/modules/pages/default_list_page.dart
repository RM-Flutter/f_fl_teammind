import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/modules/more/views/blog/controller/blog_controller.dart';
import 'package:rmemp/modules/more/views/blog/controller/blog_controller.dart';
import 'package:rmemp/modules/more/views/blog/controller/blog_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../general_services/layout.service.dart';
import '../../routing/app_router.dart';
import '../../utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../../utils/gradient_bg_image.dart';
import '../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';

class DefaultListPage extends StatefulWidget {
  var type;
  DefaultListPage({this.type});

  @override
  _DefaultListPageState createState() => _DefaultListPageState();
}

class _DefaultListPageState extends State<DefaultListPage> {
  final ScrollController _scrollController = ScrollController();
  late BlogProviderModel pointsProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pointsProvider = Provider.of<BlogProviderModel>(context, listen: false);
      pointsProvider.getBlog(context,"${widget.type}" ,page: 1);
    });
    _scrollController.addListener(() {
      print("Current scroll position: ${_scrollController.position.pixels}");
      print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !pointsProvider.isGetBlogLoading &&
          pointsProvider.hasMore) {
        print("BOTTOM BOTTOM");
        if(pointsProvider.hasMore == true) {
          pointsProvider.getBlog(
              context, "${widget.type}",page: pointsProvider.currentPage);
        }else{
          print("NO DATA MORE");
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlogProviderModel>(
      builder: (context, points, child) {
        return SafeArea(
          child: Scaffold( resizeToAvoidBottomInset: true,
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
                            icon: Icon(Icons.arrow_back, color:  const Color(0xff224982)),
                            onPressed: () =>  Navigator.pop(context),
                          ),
                          Text(
                            widget.type == "rmnotifications" ? AppStrings.notifications.tr().toUpperCase() : widget.type.toString().tr().toUpperCase(),                            style: const TextStyle(color: Color(0xff224982), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.transparent),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.s20),
                    if(points.blogs.isEmpty)Container(
                      height: MediaQuery.sizeOf(context).height * 0.8,
                      alignment: Alignment.center,
                      child: NoExistingPlaceholderScreen(
                          height: LayoutService.getHeight(context) * 0.4,
                          title: AppStrings.noDataFounded.tr()),
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
                            children: List.generate((points.isGetBlogLoading && points.currentPage == 1)?8 :
                            points.blogs.length, (index){
                              return (points.isGetBlogLoading && points.currentPage == 1)?
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
                                points.blogs[index]['title'] ??"",
                                id: points.blogs[index]['id'] ??"",
                                type: widget.type,
                                (points.blogs[index]['main_thumbnail'] != null && points.blogs[index]['main_thumbnail'].isNotEmpty)?
                                points.blogs[index]['main_thumbnail'][0]['file'] : "",
                                onTap: (){
                                  // if(points.blogs[index]['title'] == AppStrings.fawry.tr()){
                                  //   context.pushNamed(
                                  //       AppRoutes.fawryProviderScreen
                                  //           .name,
                                  //       pathParameters: {
                                  //         'lang': context.locale
                                  //             .languageCode,
                                  //       });
                                  // }else {
                                  //   context.pushNamed(
                                  //       AppRoutes.prizePointsViewScreen
                                  //           .name,
                                  //       pathParameters: {
                                  //         'lang': context.locale
                                  //             .languageCode,
                                  //         'id': points
                                  //             .blogs[index]['id']
                                  //             .toString(),
                                  //       });
                                  // }
                                },
                              );
                            })
                        ),
                      ),
                    ),
                    if (points.isGetBlogLoading && points.currentPage != 1)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget defaultProjectCard(String? title1, src, {onTap, type, id}) {
    return GestureDetector(
      onTap: (){
        context.pushNamed(AppRoutes.defaultSinglePage.name,
            pathParameters: {'lang': context.locale.languageCode,
              "id" : id.toString(),
              "type" : type,
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
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
                  fit: BoxFit.cover,
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
