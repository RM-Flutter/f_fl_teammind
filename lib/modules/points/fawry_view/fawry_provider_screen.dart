import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_test/modules/points/fawry_view/charge_phone_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization.service.dart';
import 'package:app_test/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_test/utils/gradient_bg_image.dart';
import '../logic/fawry_cubit/fawry_provider.dart';

class FawryProviderScreen extends StatelessWidget {
  const FawryProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FawryProviderModel()..getFawryCategory(context),
      child: Consumer<FawryProviderModel>(
          builder: (context, value, child) {
            return Scaffold( resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: const Color(0xffFFFFFF),
                leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:  Icon(
                      Icons.arrow_back,
                      color: Color(AppColors.primary),
                    )),
                title: Text(
                  AppStrings.chooseFromFawryServices.tr().toUpperCase(),
                  style:  TextStyle(
                      fontSize: AppSizes.s16,
                      fontWeight: FontWeight.w700,
                      color: Color(AppColors.primary)),
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFFFF007A).withOpacity(0.03),
                        const Color(0xFF00A1FF).withOpacity(0.03)
                      ],
                    ),
                  ),
                ),
              ),
              body: SizedBox(
                height: MediaQuery.sizeOf(context).height * 1,
                child: GradientBgImage(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1/0.9,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: List.generate((value.isGetFawryCategoryLoading)?8 :
                      value.fawryCategory.length, (index){
                        return (value.isGetFawryCategoryLoading)?
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
                        gridItem(
                            context,value.fawryCategory[index]['title'],
                            value.fawryCategory[index]['icon'].isNotEmpty ?
                            value.fawryCategory[index]['icon'][0]['file']:"",
                            value.fawryCategory[index]
                           );
                      })
                  )

                ),
              ),
            );
          },
      ),
    );
  }
  Widget gridItem(context,String title, src, service) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChargePhoneScreen(service, ),));
      },
      child: SizedBox(
        height: 150,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: LocalizationService.isArabic(context: context) ?20 : 30,top: 50, left: 5, right: 5),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      fontSize: 16,
                      color: Color(AppColors.primary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  height: 80,
                  fit: BoxFit.contain,
                  width: 80,
                  imageUrl: src,
                  placeholder: (context, url) =>
                  const ShimmerAnimatedLoading(),
                  errorWidget: (context, url, error) =>  const Icon(
                    Icons.image_not_supported_outlined,
                    size: AppSizes.s32,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
