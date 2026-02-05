import 'package:app_test/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    CacheHelper.setString(key: "dateWatchScreen", value: DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now().toUtc()));

    return ChangeNotifierProvider<OnboardingController>(
        create: (context) => OnboardingController(),
        child: Scaffold(body:
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
                                  Color(AppColors.dark).withOpacity(0.0), // #090B60 at 0%
                                  Color(AppColors.dark).withOpacity(0.30), // #090B60 at 15%
                                  Color(AppColors.dark).withOpacity(0.7), // #090B60 at 30%
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
                bottom: AppSizes.s32,
                left: AppSizes.s0,
                right: AppSizes.s0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: kIsWeb ? 800 : double.infinity,
                  ),
                  child: Container(
                    // تحديد ارتفاع ثابت للكونتينر الأساسي عشان الـ PageView ميعملش شاشة بيضا
                    height: AppSizes.s300,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s18),
                    child: PageView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: viewModel.pageController2,
                      itemCount: viewModel.getAllOnboardingData(context: context)?.length,
                      itemBuilder: (context, index) {

                        // حساب نسبة التحميل للدائرة
                        int totalPages = viewModel.getAllOnboardingData(context: context)?.length ?? 1;
                        double progress = (index + 1) / totalPages;

                        return Row(
                          children: [
                            // 1. الجزء الأيسر: النصوص (العنوان والوصف)
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    LocalizationService.isArabic(context: context)
                                        ? viewModel.getOnboardingDataWithIndex(index, context)!['title']!['ar']!.toUpperCase()
                                        : viewModel.getOnboardingDataWithIndex(index, context)!['title']!['en']!.toUpperCase(),
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 38, // حجم الخط مناسب للعرض
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    LocalizationService.isArabic(context: context)
                                        ? viewModel.getOnboardingDataWithIndex(index, context)!["info"]["ar"]
                                        : viewModel.getOnboardingDataWithIndex(index, context)!['info']!['en'],
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),

                            // 2. الجزء الأيمن: الزر الدائري والمؤشرات و Skip
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // الزر الدائري مع اللودينج
                                  GestureDetector(
                                    onTap: () => viewModel.goNext(context),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 65,
                                          height: 65,
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 4,
                                            backgroundColor: Colors.white24,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.chevron_right, color: Colors.black, size: 30),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  // النقاط (Indicators)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(totalPages, (i) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        width: i == index ? 12 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: i == index ? Colors.white : Colors.white38,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 20),

                                  // زر SKIP
                                  InkWell(
                                    onTap: () => viewModel.skip(context),
                                    child: const Text(
                                      "SKIP",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        })));
  }
}
