import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_test/modules/points/widgets/bottom_sheet_external_success.dart';
import 'package:app_test/modules/points/widgets/raya_add_data_bottomsheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/layout.service.dart';
import 'package:app_test/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import 'package:app_test/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/modules/home/view_models/home.viewmodel.dart';
import 'logic/points_cubit/points_provider.dart';

class PrizeScreen extends StatefulWidget {
  final bool viewArrow;
  var id;
  PrizeScreen(this.viewArrow,this.id, {super.key});

  @override
  _PrizeScreenState createState() => _PrizeScreenState();
}

class _PrizeScreenState extends State<PrizeScreen> {
  final ScrollController _scrollController = ScrollController();
  late PointsProvider pointsProvider;
  FocusNode fieldFocusNode = FocusNode();
  FocusNode fieldFocusNode2 = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pointsProvider = Provider.of<PointsProvider>(context, listen: false);
      pointsProvider.getPrize(context,widget.id, page: 1);
    });
    _scrollController.addListener(() {
      print("Current scroll position: ${_scrollController.position.pixels}");
      print("Max scroll extent: ${_scrollController.position.maxScrollExtent}");

      if ((_scrollController.position.maxScrollExtent - _scrollController.position.pixels).abs() < 10 &&
          !pointsProvider.isLoading &&
          pointsProvider.hasMorePrizes) {
        print("BOTTOM BOTTOM");
        if(pointsProvider.hasMorePrizes == true){
          pointsProvider.getPrize(context,widget.id, page: pointsProvider.currentPage);
        }else{
          print("NO PRIZE GET");
        }
      }
    });
  }
  void copyToClipboard(BuildContext context, {text}) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
        msg: AppStrings.textCopiedToClipboard.tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, value, child) {
        return Consumer<PointsProvider>(
          builder: (context, points, child) {
            if(points.isRedeemSuccess == true){
              print("points.type --> ${points.type}");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                points.getPrize(context,widget.id, page: 1);
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                value.initializeHomeScreen(context, null);
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {

                if(points.type == "external" || points.type == "internal"){
                  if(points.redeemCode != null) {
                    PointsSuccessSheet.externalSuccess(fieldFocusNode, context: context,
                        redeemCode: points.redeemCode.toString());
                  }else{
                    PointsSuccessSheet.manualSuccess(fieldFocusNode2,context: context);
                  }
                }else{
                  PointsSuccessSheet.manualSuccess(fieldFocusNode2,context: context);
                }
              });
              points.isRedeemSuccess = false;
            }
            return SafeArea(
              child: Scaffold( resizeToAvoidBottomInset: true,
                backgroundColor: const Color(0xffFFFFFF),
                body: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

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
                                AppStrings.chooseThePrize.tr().toUpperCase(),
                                style:  const TextStyle(color: Color(0xff224982), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon:  const Icon(Icons.arrow_back, color: Colors.transparent),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.s20),
                        if(points.prizes.isEmpty)Container(
                          height: MediaQuery.sizeOf(context).height * 0.8,
                          alignment: Alignment.center,
                          child: NoExistingPlaceholderScreen(
                              height: LayoutService.getHeight(context) * 0.4,
                              title: AppStrings.noPrizesAvailable.tr()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            reverse: false,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const SizedBox(height: 10,),
                            itemCount: points.isLoading && points.currentPage == 1
                                ? 12 // Show 5 loading items initially
                                : points.prizes.length,
                            itemBuilder: (context, index) {
                              if (points.isLoading && points.currentPage == 1) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                                    padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSizes.s15, vertical: AppSizes.s12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AppSizes.s15),
                                    ),
                                    height: 100,
                                  ),
                                );
                              } else {
                                return InkWell(
                                  onTap: points.isRedeemLoading == false? () {
                                    setState(() {
                                      points.selectIndex = index;
                                      points.type = points.prizes[index]['type']['key'];
                                    });
                                   if((points.prizes[index]['type']['key'] == "external" || points.prizes[index]['type']['key'] == "internal") &&
                                       (points.prizes[index]['needed_data'].isNotEmpty && points.prizes[index]['needed_data'] != [] && points.prizes[index]['needed_data'] != null)){
                                     showModalBottomSheet(
                                         context: context,
                                         isScrollControlled: true, // Allow full screen interaction
                                         builder: (BuildContext context) {
                                           return RayaAddDataBottomsheet(points.prizes[index]['id'],
                                               points.prizes[index]['needed_data']
                                           );
                                         }
                                     );
                                   }
                                   else if((points.prizes[index]['type']['key'] != "external" && points.prizes[index]['type']['key'] != "internal") &&
                                       (points.prizes[index]['needed_data'].isEmpty ||points.prizes[index]['needed_data'] == [] || points.prizes[index]['needed_data'] == null)){
                                     PointsSuccessSheet.showConfirmationSheet(context, onTap: ()async{
                                       Navigator.pop(context);
                                       await points.postRedeemPrize(context, id: points.prizes[index]['id'].toString());
                                     });
                                   }
                                   else if((points.prizes[index]['type']['key'] == "external" || points.prizes[index]['type']['key'] == "internal") &&
                                       (points.prizes[index]['needed_data'].isEmpty || points.prizes[index]['needed_data'] == [] || points.prizes[index]['needed_data'] == null)){
                                     PointsSuccessSheet.showConfirmationSheet(context, onTap: ()async{
                                       Navigator.pop(context);
                                       await points.postRedeemPrize(context, id: points.prizes[index]['id'].toString());
                                     });
                                   }
                                   else if(points.prizes[index]['type']['key'] == null){
                                     PointsSuccessSheet.showConfirmationSheet(context, onTap: ()async{
                                       Navigator.pop(context);
                                       await points.postRedeemPrize(context, id: points.prizes[index]['id'].toString());
                                     });
                                   }else{
                                     print("DATA --> ${points.prizes[index]['needed_data']}");
                                   }
                                  } : (){},
                                  child: Container(
                                    padding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: AppSizes.s15, vertical: AppSizes.s12),
                                    decoration: BoxDecoration(
                                      color: Color(AppColors.textC5),
                                      borderRadius: BorderRadius.circular(AppSizes.s15),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color.fromRGBO(0, 0, 0, 0.05),
                                            spreadRadius: 0,
                                            offset: Offset(0, 1),
                                            blurRadius: 10)
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                              imageUrl: (points.prizes[index]['image'].isNotEmpty)?
                                              points.prizes[index]['image'][0]['file'] : "",
                                              fit: BoxFit.contain,
                                              height: 110,
                                              width: double.infinity,
                                              placeholder: (context, url) => const ShimmerAnimatedLoading(
                                                width: 63.0,
                                                height: 63,
                                                circularRaduis: 63,
                                              ),
                                              errorWidget: (context, url, error) =>  const Icon(
                                                Icons.image_not_supported_outlined,
                                              )),
                                        ),
                                        gapH14,
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if(!points.isRedeemLoading) const Icon(Icons.arrow_back_ios, size: 16,),
                                            if(!points.isRedeemLoading)  gapH4,
                                            if(!points.isRedeemLoading)  Text("${points.prizes[index]['points']} ${AppStrings.points.tr()}".toString(),
                                              style:  const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:  FontWeight.w700,
                                                  color: Color(0xff0D3B6F)),
                                            ),
                                            if(points.isRedeemLoading && points.selectIndex == index)const CircularProgressIndicator()
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
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
    );
  }
}
