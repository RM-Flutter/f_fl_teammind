import 'dart:convert';
import 'dart:io';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/check_values.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/dynamic_image_widget.dart';
import 'package:app_test/features/personal_profile/controllers/personal_profile_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PersonalProfileHeaderWidget extends StatefulWidget {
  final PersonalProfileController viewModel;
  final String headerImage;
  final double notchedContainerHeight;
  final double backgroundHeight;
  final double notchRadius;
  final double notchPadding;
  final String notchImage;
  final String photo;
  final String title;
  final String subtitle;
  final double circleBorderWidth;

  const PersonalProfileHeaderWidget({
    super.key,
    required this.viewModel,
    required this.notchImage,
    required this.photo,
    required this.notchPadding,
    required this.headerImage,
    required this.notchedContainerHeight,
    required this.backgroundHeight,
    required this.notchRadius,
    required this.title,
    required this.subtitle,
    required this.circleBorderWidth,
  });

  @override
  State<PersonalProfileHeaderWidget> createState() =>
      _PersonalProfileHeaderWidgetState();
}

class _PersonalProfileHeaderWidgetState
    extends State<PersonalProfileHeaderWidget> {
  bool _isLoading = false;

  String _getVerificationStatus(Map<String, dynamic> us1Cache) {
    final email = us1Cache['email'];
    final phone = us1Cache['phone'];
    final emailVerified = us1Cache['email_verified_at'] != null;
    final phoneVerified = us1Cache['phone_verified_at'] != null;

    if (email == null && phone == null) return "";
    if (email != null && phone == null) {
      return emailVerified ? "" : AppStrings.email_not_verified.tr();
    }
    if (phone != null && email == null) {
      return phoneVerified ? "" : AppStrings.phone_not_verified.tr();
    }
    if (!emailVerified && !phoneVerified) {
      return AppStrings.email_phone_not_verified.tr();
    }
    if (!emailVerified && phoneVerified) {
      return AppStrings.email_not_verified.tr();
    }
    if (emailVerified && !phoneVerified) {
      return AppStrings.phone_not_verified.tr();
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> us1Cache = {};
    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      us1Cache = json.decode(jsonString) as Map<String, dynamic>;
      UserSettingConst.userSettings = UserSettingsModel.fromJson(us1Cache);
    }

    final bool showVerificationBanner = (us1Cache['phone'] != null &&
            us1Cache['phone_verified_at'] == null) ||
        (us1Cache['email'] != null && us1Cache['email_verified_at'] == null);

    return Column(
      children: [
        if (showVerificationBanner) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s10),
            decoration: BoxDecoration(
              color: AppColors.statusTones(Color(AppColors.warningYellow)).tint,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.statusTones(Color(AppColors.warningYellow)).border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(AppColors.failureRed),
                  size: 20,
                ),
                const SizedBox(width: AppSizes.s8),
                Expanded(
                  child: Text(
                    _getVerificationStatus(us1Cache),
                    style: TextStyle(
                      color: Color(AppColors.failureRed),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.s8),
                Text(
                  AppStrings.activeNow.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.successGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.s12),
        ],
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(AppColors.buttons),
                          width: 2,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          if (us1Cache['employee_profile_id'] != null) {
                            await context.pushNamed(
                              AppRoutes.employeeDetails.name,
                              pathParameters: {
                                'id':
                                    us1Cache['employee_profile_id'].toString(),
                                'lang': context.locale.languageCode,
                              },
                            );
                          }
                        },
                        child: ClipOval(
                          child: _buildProfileImage(),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: AppBorders.card,
                          boxShadow: AppShadows.card,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: Color(AppColors.secondaryButton),
                            size: 18,
                          ),
                          onPressed: () async {
                            await widget.viewModel.getImage(
                              context,
                              image1: widget.viewModel.profileImage,
                              image2: widget.viewModel.XImageFileProfile,
                              list2: widget.viewModel.listXProfileImage,
                              list: widget.viewModel.listProfileImage,
                            );
                            widget.viewModel
                                .updateProfileMainInfoImage(context: context);
                          },
                        ),
                      ),
                    ),
                    if (widget.photo.isNotEmpty &&
                        widget.photo !=
                            "https://emplive.r-m.dev/files/2024/user-profile.png")
                      Positioned(
                        bottom: -2,
                        left: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(AppColors.failureRed),
                            shape: BoxShape.circle,
                          ),
                          child: _isLoading == false
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await widget.viewModel
                                        .updateProfileMainInfoImage(
                                            context: context);
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.s12),
              if (widget.title.trim().isNotEmpty)
                AutoSizeText(
                  widget.title,
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              if (widget.subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: AppSizes.s4),
                AutoSizeText(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: AppStyles.subtitleContent(context).copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (widget.viewModel.deleteImage != false) {
      return DynamicImageWidget(
        imageUrl: AppImages.logo,
        fit: BoxFit.cover,
      );
    }
    if (widget.viewModel.listProfileImage.isNotEmpty) {
      final safeList =
          CheckValuesFromApi.safeArray(widget.viewModel.listProfileImage);
      return Image(
        image: safeList.isNotEmpty && safeList[0]['compressed'] != null
            ? FileImage(safeList[0]['compressed'] as File)
            : const AssetImage("assets/images/default_avatar.png")
                as ImageProvider,
        fit: BoxFit.cover,
      );
    }
    if (UserSettingConst.userSettings?.photo == null || widget.photo.isEmpty) {
      return DynamicImageWidget(
        imageUrl: AppImages.logo,
        fit: BoxFit.cover,
      );
    }
    if (kIsWeb) {
      return Image.network(
        widget.photo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person_outline,
          size: AppSizes.s40,
          color: Color(AppColors.secondaryButton),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: widget.photo,
      fit: BoxFit.cover,
      placeholder: (context, url) => ShimmerAnimatedLoading(
        circularRaduis: AppSizes.s50,
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.person_outline,
        size: AppSizes.s40,
        color: Color(AppColors.secondaryButton),
      ),
    );
  }
}

/// Kept for backwards compatibility if referenced elsewhere, now renders a clean white container.
class PersonalProfileHeaderBackgroundWidget extends StatelessWidget {
  final String headerImage;
  final double? backgroundHeight;

  const PersonalProfileHeaderBackgroundWidget({
    super.key,
    required this.headerImage,
    required this.backgroundHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: backgroundHeight,
      width: double.infinity,
      color: Colors.white,
    );
  }
}
