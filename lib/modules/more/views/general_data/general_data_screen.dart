import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import '../../../../utils/styles.dart';
import '../../view_models/general_controller.dart';

class GeneralDataScreen extends StatelessWidget {
  GeneralDataScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => GeneralController()..getGeneralData(context),
      child: Consumer<GeneralController>(
        builder: (context, value, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color(0xffFFFFFF),
            body: (!value.isLoading)?Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 1,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s15),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.transparent,
                        height: 90,
                        width: double.infinity,
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(AppColors.dark)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Text(
                              value.dataTitle.toUpperCase(),
                              style: const TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.transparent),
                                onPressed: (){}
                            ),
                          ],
                        ),
                      ),
                      gapH16,
                      if(value.dataimage != null) ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.225,
                          fit: BoxFit.fill,
                          imageUrl: value.dataimage,
                          placeholder: (context, url) =>
                          const ShimmerAnimatedLoading(),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: AppSizes.s32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if(value.dataimage != null)  gapH24,
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(25),
                      //   child: CachedNetworkImage(
                      //     width: MediaQuery.of(context).size.width,
                      //     height: MediaQuery.of(context).size.height * 0.225,
                      //     fit: BoxFit.fill,
                      //     imageUrl: image,
                      //     placeholder: (context, url) =>
                      //     const ShimmerAnimatedLoading(),
                      //     errorWidget: (context, url, error) => const Icon(
                      //       Icons.image_not_supported_outlined,
                      //       size: AppSizes.s32,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                      // gapH14,
                      // Text(
                      //   "title",
                      //   style: const TextStyle(
                      //       fontSize: AppSizes.s16,
                      //       fontWeight: FontWeight.bold,
                      //       color: Color(AppColors.oC1Color)),
                      // ),
                      // gapH14,
                      Html(
                          data: value.dataContent,
                          style: TextsStyles.htmlStyle),
                    ],
                  ),
                )):
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 200,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
