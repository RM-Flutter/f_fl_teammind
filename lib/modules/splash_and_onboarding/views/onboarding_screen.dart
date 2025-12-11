import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../common_modules_widgets/language_dropdown_button.widget.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../view_models/splash_onboarding.viewmodel.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CacheHelper.setString(key: "watchScreen", value: "yes");
    CacheHelper.setString(key: "dateWatchScreen", value: DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now().toUtc()));

    return ChangeNotifierProvider<OnboardingViewModel>(
        create: (context) => OnboardingViewModel(),
        child: Scaffold(body:
            Consumer<OnboardingViewModel>(builder: (context, viewModel, child) {
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
                    final image = data?[key][0]?['file'] ?? '';
                    if (image?.startsWith('http') == true ||
                        image?.startsWith('https') == true) {
                      // Network image
                      return CachedNetworkImage(
                        imageUrl: image!,
                        fit: BoxFit.cover,
                        key: ValueKey<String>(image),
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      );
                    } else {
                      // Asset image
                      return Stack(
                        children: [
                          Image.asset(
                            image!,
                            fit: BoxFit.cover,
                            key: ValueKey<String>(image),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF090B60).withOpacity(0.0), // #090B60 at 0%
                                  Color(0xFF090B60).withOpacity(0.30), // #090B60 at 15%
                                  Color(0xFF090B60).withOpacity(0.7), // #090B60 at 30%
                                ],
                                stops: [0.0, 0.1, 0.3], // Define stops for each color
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  }),
              // Logo
              // Positioned(
              //   top: MediaQuery.of(context).size.height * 0.3,
              //   left: AppSizes.s0,
              //   right: AppSizes.s0,
              //   child: Image.asset(
              //     AppImages.logo,
              //     width: AppSizes.s125,
              //     height: AppSizes.s125,
              //     key: const ValueKey<String>(AppImages.logo),
              //   ),
              // ),

              Positioned(
                bottom: AppSizes.s48,
                left: AppSizes.s0,
                right: AppSizes.s0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: kIsWeb?800: double.infinity,
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.s25),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.s18, vertical: AppSizes.s20),
                        height: AppSizes.s300,
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
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        LocalizationService.isArabic(context: context)? viewModel.getOnboardingDataWithIndex(index, context)!['title']!['ar']!.toUpperCase() :viewModel.getOnboardingDataWithIndex(index, context)!['title']!['en']!.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      gapH20,
                                      Text(
                                        LocalizationService.isArabic(context: context)? viewModel.getOnboardingDataWithIndex(index, context)!["info"]["ar"] :viewModel.getOnboardingDataWithIndex(index, context)!['info']!['en'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall,
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
                                      width: AppSizes.s120,
                                      isPrimaryBackground: true,
                                      isFuture: false),
                                  TextButton(
                                    onPressed: () => viewModel.skip(context),
                                    style: ElevatedButton.styleFrom(
                                      fixedSize:
                                          const Size(AppSizes.s150, AppSizes.s50),
                                    ),
                                    child: Text(AppStrings.skip.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
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
