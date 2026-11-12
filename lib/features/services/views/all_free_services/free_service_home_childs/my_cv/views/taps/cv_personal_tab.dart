import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/widgets/app_columns_flow.widget.dart';
import 'dart:io';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/views/taps/widgets/cv_info_item_widget.dart' show CVInfoItem;
import 'package:app_test/features/services/data/models/cv_data_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/controllers/my_cv_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CVPersonalTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVPersonalTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyCVViewModel>(context, listen: true);
    final personal = viewModel.cvData?.personal ?? cvData?.personal;
    
    // Debug: Check if data is loaded
    debugPrint('CVPersonalTab - personal data: ${personal?.name}, ${personal?.countryTitle}');
    debugPrint('CVPersonalTab - cvData: ${viewModel.cvData != null}');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s16),
      child: AppColumnsFlow(fullWidthCount: 2, 
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Image Section
          _buildProfileImageSection(context, viewModel),
          const SizedBox(height: AppSizes.s24),
          
          CVInfoItem(
            label: AppStrings.name.tr(),
            value: personal?.name,
            isRequired: true,
            icon: Icons.person_outline,
          ),
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: AppStrings.birthday.tr(),
                  value: personal?.birthday != null 
                      ? personal!.birthday!.split(' ')[0] // Remove time part
                      : null,
                  isRequired: true,
                  icon: Icons.cake_outlined,
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: CVInfoItem(
                  label: AppStrings.gender.tr(),
                  value: personal?.gender,
                  isRequired: true,
                  icon: Icons.male,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: AppStrings.familyStatus.tr(),
                  value: personal?.familyStatus,
                  icon: Icons.family_restroom,
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: CVInfoItem(
                  label: AppStrings.nationality.tr(),
                  value: personal?.nationalityTitle ?? personal?.nationalityId?.toString(),
                  isRequired: true,
                  icon: Icons.flag_outlined,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: AppStrings.country.tr(),
                  value: personal?.countryTitle ?? personal?.countryId?.toString(),
                  isRequired: true,
                  icon: Icons.public,
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: CVInfoItem(
                  label: AppStrings.stateProvince.tr(),
                  value: personal?.stateTitle ?? personal?.stateId?.toString(),
                  isRequired: true,
                  icon: Icons.map_outlined,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: AppStrings.city.tr(),
                  value: personal?.cityTitle ?? personal?.cityId?.toString(),
                  icon: Icons.location_city_outlined,
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: CVInfoItem(
                  label: AppStrings.address.tr(),
                  value: personal?.address,
                  icon: Icons.home_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(BuildContext context, MyCVViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.profilePhoto.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.secondaryButton),
          ),
        ),
        const SizedBox(height: AppSizes.s12),
        
        // Image Preview
        Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: ClipOval(
                  child: _buildImageWidget(viewModel),
                ),
              ),
              if (viewModel.imageSourceType == ImageSourceType.newImage)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.s4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s16),
        
        // Image Source Options
        _buildImageSourceOptions(context, viewModel),
      ],
    );
  }

  Widget _buildImageWidget(MyCVViewModel viewModel) {
    final imageUrl = viewModel.getCurrentImageUrl();
    
    if (viewModel.imageSourceType == ImageSourceType.none) {
      // Show default image based on gender
      return Image.asset(
        viewModel.getDefaultImagePath(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }
    
    if (imageUrl == null) {
      return _buildDefaultAvatar();
    }
    
    // If it's a file path (new image)
    if (imageUrl.startsWith('/') || imageUrl.contains('file://')) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }
    
    // If it's a network URL (profile photo)
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildImageSourceOptions(BuildContext context, MyCVViewModel viewModel) {
    return Column(
      children: [
        // Use Profile Photo Option
        RadioListTile<ImageSourceType>(
          title: Text(AppStrings.useProfilePhoto.tr()),
          value: ImageSourceType.profile,
          groupValue: viewModel.imageSourceType,
          onChanged: (value) {
            if (value != null) {
              viewModel.setImageSourceType(value);
            }
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        
        // Add New Photo Option
        RadioListTile<ImageSourceType>(
          title: Text(AppStrings.addNewPhoto.tr()),
          value: ImageSourceType.newImage,
          groupValue: viewModel.imageSourceType,
          onChanged: (value) {
            if (value != null) {
              viewModel.setImageSourceType(value);
            }
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        
        // Show picker button if new image is selected
        if (viewModel.imageSourceType == ImageSourceType.newImage) ...[
          const SizedBox(height: AppSizes.s8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => viewModel.pickImageFromCamera(),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(AppStrings.camera.tr()),
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => viewModel.pickImageFromGallery(),
                  icon: const Icon(Icons.photo_library),
                  label: Text(AppStrings.gallery.tr()),
                ),
              ),
            ],
          ),
        ],
        
        // No Photo Option
        RadioListTile<ImageSourceType>(
          title: Text(AppStrings.noPhotoUseDefault.tr()),
          value: ImageSourceType.none,
          groupValue: viewModel.imageSourceType,
          onChanged: (value) {
            if (value != null) {
              viewModel.setImageSourceType(value);
            }
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }
}

