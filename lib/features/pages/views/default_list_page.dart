
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/more/blog/controllers/blog_controller.dart';
import 'package:shimmer/shimmer.dart';

import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/utils/gradient_bg_image.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';

class DefaultListPage extends StatefulWidget {
  var type;
  DefaultListPage({super.key, this.type});

  @override
  _DefaultListPageState createState() => _DefaultListPageState();
}

class _DefaultListPageState extends State<DefaultListPage> {
  final ScrollController _scrollController = ScrollController();
  late BlogProviderModel PointsController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PointsController = Provider.of<BlogProviderModel>(context, listen: false);
      PointsController.getBlog(context,"${widget.type}" ,page: 1);
    });
    _scrollController.addListener(() {
      debugPrint("Current scroll position: ${_scrollController.position.pixels}");
      debugPrint("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !PointsController.isGetBlogLoading &&
          PointsController.hasMore) {
        debugPrint("BOTTOM BOTTOM");
        if(PointsController.hasMore == true) {
          PointsController.getBlog(
              context, "${widget.type}",page: PointsController.currentPage);
        }else{
          debugPrint("NO DATA MORE");
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
                      height: 90.h,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color:  const Color(0xff224982), size: 24.r,),
                            onPressed: () =>  Navigator.pop(context),
                          ),
                          Text(
                            widget.type == "rmnotifications" ? AppStrings.notifications.tr().toUpperCase() : widget.type.toString().tr().toUpperCase(),
                            style: AppStyles.heading(context).copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                          IconButton(
                            icon:  Icon(Icons.arrow_back, color: Colors.transparent, size: 24.r,),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.s20.h),
                    if(points.blogs.isEmpty)Container(
                      height: 0.8.sh,
                      alignment: Alignment.center,
                      child: NoExistingPlaceholderScreen(
                          height: 0.4.sh,
                          title: AppStrings.noDataFounded.tr()),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            childAspectRatio: 1/1.3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate((points.isGetBlogLoading && points.currentPage == 1)?8 :
                            points.blogs.length, (index){
                              return (points.isGetBlogLoading && points.currentPage == 1)?
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.infinity,
                                  height: 100.h, // Adjust height based on your UI
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r), // Adjust as needed
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
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.r,
                spreadRadius: 1.r,
              )
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r)),
                child:  CachedNetworkImage(
                  height: 135.h,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  imageUrl: src,
                  placeholder: (context, url) =>
                  const ShimmerAnimatedLoading(),
                  errorWidget: (context, url, error) =>  Icon(
                    Icons.image_not_supported_outlined,
                    size: AppSizes.s32.r,
                    color: Colors.white,
                  ),
                ),), // Replace with project images
              SizedBox(height: 5.h,),
              Padding(
                padding: EdgeInsets.all(8.0.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title1 ?? "".toUpperCase(),maxLines: 1, style: AppStyles.primaryContent(context).copyWith(fontWeight: FontWeight.w500, fontSize: 10.sp, color: const Color(0xFF090B60))),],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
