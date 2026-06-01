import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/language_dropdown_button.widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/features/splash_and_onboarding/controller/splash_onboarding_controller.dart';


class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CacheHelper.setString(key: "watchScreen", value: "yes");
    CacheHelper.setString(key: "dateWatchScreen", value: DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now()));

    return ChangeNotifierProvider<OnboardingController>(
        create: (context) => OnboardingController(),
        child: Scaffold(
            backgroundColor: Colors.black,
            body:
        Consumer<OnboardingController>(builder: (context, viewModel, child) {
          return Stack(
            children: [
              PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: viewModel.pageController,
                  onPageChanged: (index) => viewModel.currentIndex = index,
                  itemCount:
                  viewModel.getAllOnboardingData(context: context)?.length,
                  itemBuilder: (context, index) {
                    final data = viewModel.getOnboardingDataWithIndex(index, context);
                    var key = kIsWeb ? 'web_image' : 'image';
                    // Safe access: data[key] may be an empty list, so avoid [0] when length is 0
                    final imagesList = data?[key];
                    var image = '';
                    if (imagesList is List && imagesList.isNotEmpty) {
                      final first = imagesList[0];
                      if (first is Map && first['file'] != null) {
                        image = first['file'].toString();
                      }
                    }
                    // When API returns no image or empty list, use default assets (onboard1, onboard2, onboard3)
                    if (image.isEmpty) {
                      image = index == 0
                          ? AppImages.onboardingFallback1
                          : index == 1
                          ? AppImages.onboardingFallback2
                          : AppImages.onboardingFallback3;
                    }
                    if (image.startsWith('http') || image.startsWith('https')) {
                      // Network image
                      return Opacity(
                        opacity: 0.5,
                        child: CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          key: ValueKey<String>(image),
                          placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Stack(
                              children: [
                                Opacity(
                                  opacity: 0.5,
                                  child: Image.asset(
                                    index == 0
                                        ? AppImages.onboardingFallback1
                                        : index == 1
                                        ? AppImages.onboardingFallback2
                                        : AppImages.onboardingFallback3,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.35),
                                ),
                              ],
                            ),
                          ),
                        );
                    } else {
                      // Asset image
                      return Stack(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              image,
                              fit: BoxFit.cover,
                              key: ValueKey<String>(image),
                            ),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.35),
                          )
                        ],
                      );
                    }
                  }),
              // Centered Logo
              Positioned(
                top: 0.25.sh,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    AppImages.logo,
                    width: 140.r,
                    height: 140.r,
                  ),
                ),
              ),

              Positioned(
                bottom: 48.h,
                left: 0,
                right: 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: kIsWeb? 800.w : 1.sw,
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 20.h),
                        height: 340.h,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 5,
                              child: PageView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                controller: viewModel.pageController2,
                                itemCount: viewModel
                                    .getAllOnboardingData(context: context)
                                    ?.length,
                                itemBuilder: (context, index) {
                                  final data = viewModel.getOnboardingDataWithIndex(index, context);
                                  final titleMap = data?['title'];
                                  final infoMap = data?['info'];
                                  String? _str(dynamic v) => v?.toString().trim();
                                  bool _empty(String? s) => s == null || s.isEmpty;
                                  // لو انجليزي/عربي رجع null أو فاضي تجاهله واعرض التاني (أي داتا راجعة نعرضها)
                                  final title = titleMap is Map
                                      ? (_empty(_str(LocalizationService.isArabic(context: context) ? titleMap['ar'] : titleMap['en']))
                                      ? _str(LocalizationService.isArabic(context: context) ? titleMap['en'] : titleMap['ar'])
                                      : _str(LocalizationService.isArabic(context: context) ? titleMap['ar'] : titleMap['en']))
                                      : null;
                                  final info = infoMap is Map
                                      ? (_empty(_str(LocalizationService.isArabic(context: context) ? infoMap['ar'] : infoMap['en']))
                                      ? _str(LocalizationService.isArabic(context: context) ? infoMap['en'] : infoMap['ar'])
                                      : _str(LocalizationService.isArabic(context: context) ? infoMap['ar'] : infoMap['en']))
                                      : null;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        Text(
                                          (title ?? '').split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join(' '),
                                          style: AppStyles.heading(context).copyWith(
                                                color:  Color(AppColors.buttons),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24.sp,
                                              ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      gapH20,
                                        Text(
                                          info ?? '',
                                          style: AppStyles.greyContent(context).copyWith(
                                                color: Colors.grey.shade500,
                                                height: 1.65,
                                                fontSize: 14.sp,
                                              ),
                                          textAlign: TextAlign.center,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomElevatedButton(
                                      onPressed: () async =>
                                          viewModel.goNext(context),
                                      title: AppStrings.next.tr(),
                                      width: 120.w,
                                      titleSize: 14.sp,
                                      isPrimaryBackground: true,
                                      isFuture: false),
                                  TextButton(
                                    onPressed: () => viewModel.skip(context),
                                    style: ElevatedButton.styleFrom(
                                      fixedSize:
                                      Size(170.w, 50.h),
                                    ),
                                    child: Text(AppStrings.skip.tr(),
                                        style: AppStyles.blackContent(context).copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const LanguageDropdownButton()
            ],
          );
        })));
  }
}
