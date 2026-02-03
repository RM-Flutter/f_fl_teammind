import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../utils/animated_custom_dropdown/custom_dropdown.dart';
import '../../../view_models/create_cv.viewmodel.dart';

class CreateCVPersonalTab extends StatelessWidget {
  final CreateCVViewModel viewModel;

  const CreateCVPersonalTab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image Section
          _buildProfileImageSection(context),
          const SizedBox(height: 24),
          
          _buildTextField(
            controller: viewModel.nameController,
            label: AppStrings.name.tr(),
            isRequired: true,
            hint: AppStrings.enterYourName.tr(),
          ),
          const SizedBox(height: 16),
          
          _buildFamilyStatusDropdown(),
          const SizedBox(height: 16),
          
          _buildBirthdayField(context),
          const SizedBox(height: 16),
          
          _buildGenderDropdown(),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: viewModel.phoneController,
            label: AppStrings.phone.tr(),
            isRequired: true,
            hint: AppStrings.enterYourPhoneNumber.tr(),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          
          _buildNationalityDropdown(),
          const SizedBox(height: 16),
          
          _buildCountryDropdown(context),
          const SizedBox(height: 16),
          
          if (viewModel.countryId != null) ...[
            _buildStateDropdown(context),
            const SizedBox(height: 16),
          ],
          
          if (viewModel.stateId != null) ...[
            _buildCityDropdown(context),
            const SizedBox(height: 16),
          ],
          
          _buildTextField(
            controller: viewModel.addressController,
            label: AppStrings.address.tr(),
            hint: AppStrings.enterYourAddress.tr(),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.dark),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.familyStatus.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.dark),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: viewModel.familyStatus,
          decoration: InputDecoration(
            hintText: AppStrings.selectFamilyStatus.tr(),
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(color: Color(AppColors.dark)),
          items: ['single', 'married', 'divorced', 'widowed']
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(color: Color(AppColors.dark)),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            viewModel.familyStatus = value;
            viewModel.notifyListeners();
          },
        ),
      ],
    );
  }

  Widget _buildBirthdayField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.birthday.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.dark),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: viewModel.birthday ?? DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              viewModel.birthday = date;
              viewModel.notifyListeners();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  viewModel.birthday != null
                      ? DateFormat('yyyy-MM-dd').format(viewModel.birthday!)
                      : AppStrings.selectBirthday.tr(),
                  style: TextStyle(
                    color: viewModel.birthday != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.gender.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.dark),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: viewModel.gender,
          decoration: InputDecoration(
            hintText: AppStrings.selectGender.tr(),
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(color: Color(AppColors.dark)),
          items: ['male', 'female']
              .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(
                      gender,
                      style: TextStyle(color: Color(AppColors.dark)),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            viewModel.gender = value;
            viewModel.notifyListeners();
          },
        ),
      ],
    );
  }

  Widget _buildNationalityDropdown() {
    final selectedNationality = viewModel.nationalityId != null
        ? viewModel.nationalities.firstWhere(
            (n) => n['id'] == viewModel.nationalityId,
            orElse: () => {},
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.nationality.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.dark),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomDropdown.search(
          items: viewModel.nationalities,
          selectedValue: selectedNationality,
          nameKey: 'title',
          hintText: AppStrings.selectNationality.tr(),
          hintStyle: TextStyle(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onChanged: (value) {
            if (value.isNotEmpty && value['id'] != null) {
              viewModel.nationalityId = value['id'] as int;
              viewModel.notifyListeners();
            }
          },
        ),
      ],
    );
  }

  Widget _buildCountryDropdown(BuildContext context) {
    final selectedCountry = viewModel.countryId != null
        ? viewModel.countries.firstWhere(
            (c) => c['id'] == viewModel.countryId,
            orElse: () => {},
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
        Text(
          AppStrings.country.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.dark),
          ),
        ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomDropdown.search(
          items: viewModel.countries,
          selectedValue: selectedCountry,
          nameKey: 'title',
          hintText: AppStrings.selectCountry.tr(),
          hintStyle: TextStyle(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onChanged: (value) {
            if (value.isNotEmpty && value['id'] != null) {
              viewModel.loadStates(context, value['id'] as int);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStateDropdown(BuildContext context) {
    final selectedState = viewModel.stateId != null
        ? viewModel.states.firstWhere(
            (s) => s['id'] == viewModel.stateId,
            orElse: () => {},
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
        Text(
          AppStrings.stateProvince.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.dark),
          ),
        ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomDropdown.search(
          items: viewModel.states,
          selectedValue: selectedState,
          nameKey: 'title',
          hintText: AppStrings.selectStateProvince.tr(),
          hintStyle: TextStyle(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onChanged: (value) {
            if (value.isNotEmpty && value['id'] != null) {
              viewModel.loadCities(context, value['id'] as int);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCityDropdown(BuildContext context) {
    final selectedCity = viewModel.cityId != null
        ? viewModel.cities.firstWhere(
            (c) => c['id'] == viewModel.cityId,
            orElse: () => {},
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.city.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.dark),
          ),
        ),
        const SizedBox(height: 8),
        CustomDropdown.search(
          items: viewModel.cities,
          selectedValue: selectedCity,
          nameKey: 'title',
          hintText: AppStrings.selectCity.tr(),
          hintStyle: TextStyle(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onChanged: (value) {
            if (value.isNotEmpty && value['id'] != null) {
              viewModel.cityId = value['id'] as int;
              viewModel.notifyListeners();
            }
          },
        ),
      ],
    );
  }


  Widget _buildProfileImageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.profilePhoto.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.dark),
          ),
        ),
        const SizedBox(height: 12),
        
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
                  child: _buildImageWidget(),
                ),
              ),
              if (viewModel.imageSourceType == ImageSourceType.newImage)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
        const SizedBox(height: 16),
        
        // Image Source Options
        _buildImageSourceOptions(context),
      ],
    );
  }

  Widget _buildImageWidget() {
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

  Widget _buildImageSourceOptions(BuildContext context) {
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => viewModel.pickImageFromCamera(),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(AppStrings.camera.tr()),
                ),
              ),
              const SizedBox(width: 8),
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

