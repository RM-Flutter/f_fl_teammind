import 'dart:ui' as ui;

import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/language_dropdown_button.widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/splash_and_onboarding/controller/splash_onboarding_controller.dart';

/// Colour the photo fades into at the bottom of every slide.
const Color _kOnboardingNavy = Color(0xFF0A1330);

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CacheHelper.setString(key: "watchScreen", value: "yes");
    CacheHelper.setString(
        key: "dateWatchScreen",
        value: DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now()));

    return ChangeNotifierProvider<OnboardingController>(
      create: (context) => OnboardingController(),
      child: Scaffold(
        backgroundColor: _kOnboardingNavy,
        body: Consumer<OnboardingController>(
          builder: (context, viewModel, child) {
            final items = viewModel.getAllOnboardingData(context: context) ?? [];
            return Stack(
              fit: StackFit.expand,
              children: [
                // Full-screen photos. Swiping and the next button both drive this.
                PageView.builder(
                  controller: viewModel.pageController,
                  onPageChanged: (index) => viewModel.currentIndex = index,
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _OnboardingImage(image: _imageFor(items[index], index)),
                ),
                // Fade from the photo into navy so the text stays readable.
                const _BottomGradient(),
                _OnboardingFooter(
                  viewModel: viewModel,
                  items: items,
                ),
                const LanguageDropdownButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// First image of the slide (web or mobile), or a bundled fallback.
  static String _imageFor(Map<String, dynamic> data, int index) {
    final imagesList = data[kIsWeb ? 'web_image' : 'image'];
    if (imagesList is List && imagesList.isNotEmpty) {
      final first = imagesList[0];
      if (first is Map && first['file'] != null) {
        final file = first['file'].toString();
        if (file.isNotEmpty) return file;
      }
    }
    return _fallbackFor(index);
  }

  static String _fallbackFor(int index) => index == 0
      ? AppImages.onboardingFallback1
      : index == 1
          ? AppImages.onboardingFallback2
          : AppImages.onboardingFallback3;
}

class _OnboardingImage extends StatelessWidget {
  const _OnboardingImage({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        key: ValueKey<String>(image),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const ColoredBox(color: _kOnboardingNavy),
        errorWidget: (context, url, error) => Image.asset(
          AppImages.onboardingFallback1,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      image,
      key: ValueKey<String>(image),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 0.5.sh,
      child: const IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x000A1330),
                Color(0xB30A1330),
                _kOnboardingNavy,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

/// Title and subtitle on the start side, next button / dots / skip on the end side.
class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({required this.viewModel, required this.items});

  final OnboardingController viewModel;
  final List items;

  /// Picks the current language, falling back to the other one when empty.
  String _localized(BuildContext context, dynamic map) {
    if (map is! Map) return '';
    String? read(String key) => map[key]?.toString().trim();
    final primary = LocalizationService.isArabic(context: context) ? 'ar' : 'en';
    final secondary = primary == 'ar' ? 'en' : 'ar';
    final first = read(primary);
    if (first != null && first.isNotEmpty) return first;
    return read(secondary) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final index = viewModel.currentIndex.clamp(0, items.isEmpty ? 0 : items.length - 1);
    final data = items.isEmpty ? null : items[index] as Map;
    final title = _localized(context, data?['title']);
    final info = _localized(context, data?['info']);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kIsWeb ? 600 : double.infinity),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              kIsWeb ? 24 : 24.w,
              0,
              kIsWeb ? 24 : 24.w,
              kIsWeb ? 24 : 20.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [...previous, if (current != null) current],
                    ),
                    child: Column(
                      key: ValueKey<int>(index),
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title.isNotEmpty)
                          Text(
                            title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.heading(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: kIsWeb ? 30 : 28.sp,
                              height: 1.15,
                            ),
                          ),
                        if (title.isNotEmpty && info.isNotEmpty)
                          SizedBox(height: kIsWeb ? 10 : 8.h),
                        if (info.isNotEmpty)
                          Text(
                            info,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.greyContent(context).copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: kIsWeb ? 15 : 13.sp,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: kIsWeb ? 16 : 16.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NextButton(
                      progress:
                          items.isEmpty ? 0 : (index + 1) / items.length,
                      onTap: () => viewModel.goNext(context),
                    ),
                    SizedBox(height: kIsWeb ? 14 : 14.h),
                    _PageDots(count: items.length, current: index),
                    SizedBox(height: kIsWeb ? 6 : 6.h),
                    TextButton(
                      onPressed: () => viewModel.skip(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(48, 32),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.skip.tr().toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: kIsWeb ? 12 : 11.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// White circle with a chevron. The ring around it fills as the user moves
/// through the slides (1/3, 2/3, full on the last one).
class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap, required this.progress});

  final VoidCallback onTap;

  /// 0.0 - 1.0, the share of slides reached so far.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final outer = kIsWeb ? 64.0 : 64.r;
    final inner = kIsWeb ? 52.0 : 52.r;
    return Semantics(
      button: true,
      label: AppStrings.next.tr(),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: outer,
          height: outer,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, value, _) => SizedBox(
                  width: outer,
                  height: outer,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 2.5,
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
              Container(
                width: inner,
                height: inner,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: _kOnboardingNavy,
                  size: kIsWeb ? 28 : 28.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: active ? 7 : 5,
          height: active ? 7 : 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(active ? 1 : 0.4),
          ),
        );
      }),
    );
  }
}
