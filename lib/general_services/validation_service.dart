import 'package:easy_localization/easy_localization.dart';
import 'package:rmemp/constants/app_strings.dart';

abstract class ValidationService {
  // Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseEnterAnEmailAddress.tr();
    }
    // Regex pattern for email validation
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return AppStrings.pleaseEnterAValidEmailAddress.tr();
    }
    return null;
  }

  // Validate phone number format
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.phoneNumberIsRequired.tr();
    }
    // Regex pattern for phone number validation
    String pattern = r'^[0-9]{10}$'; // Change pattern as per your requirement
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return  AppStrings.pleaseEnterValidPhoneNumber.tr();
    }
    return null;
  }

  // Validate password format
  static String? validatePassword(String? value, {bool login = false}) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseEnterAPassword.tr();
    }
    if (!login) {
      String upperCasePattern = r'(?=.*?[A-Z])'; // At least one uppercase letter
      String lowerCasePattern = r'(?=.*?[a-z])'; // At least one lowercase letter
      String numberPattern = r'(?=.*?[0-9])';    // At least one number
      String specialCharPattern = r'(?=.*?[!@#\$&*~])'; // At least one special character
      String minLengthPattern = r'.{8,}';        // At least 8 characters
      // Check each requirement
      if (!RegExp(upperCasePattern).hasMatch(value)) {
        return "${AppStrings.mustInclude.tr()}: ${AppStrings.atLeastOneUppercaseLetter.tr()}. \n";
      }
      if (!RegExp(lowerCasePattern).hasMatch(value)) {
        return "${AppStrings.mustInclude.tr()}: ${AppStrings.atLeastOneLowercaseLetter.tr()}. \n";
      }
      if (!RegExp(numberPattern).hasMatch(value)) {
        return "${AppStrings.mustInclude.tr()}: ${AppStrings.atLeastOneNumber.tr()}. \n";
      }
      if (!RegExp(specialCharPattern).hasMatch(value)) {
        return "${AppStrings.mustInclude.tr()}: ${AppStrings.atLeastOneSpecialCharacter.tr()}. \n";
      }
      if (!RegExp(minLengthPattern).hasMatch(value)) {
        return "${AppStrings.mustInclude.tr()}: ${AppStrings.aMinimumOfEightCharacters.tr()}. \n";
      }
    }else{
      String minLengthPattern = r'.{6,}';
      if (!RegExp(minLengthPattern).hasMatch(value)) {
        return "${AppStrings.mustInclude.tr()}: ${AppStrings.aMinimumOfSixCharacters.tr()}. \n";
      }
    }
    return null;
  }

  // Validate required field
  static String? validateRequired(String? value,field) {
    if (value == null || value.isEmpty) {
      return '$field ${AppStrings.isRequired.tr()}';
    }
    if (value.length < 6) {
      return '$field ${AppStrings.mustBeAtLeastSixCharactersLong.tr()}';
    }
    return null;
  }

  // Validate numeric input
  static String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional validation if empty value is allowed
    }
    String pattern = r'^[0-9]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return AppStrings.pleaseEnterOnlyNumericCharacters.tr();
    }
    return null;
  }

  // Validate URL format
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional validation if empty value is allowed
    }
    String pattern =
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // Validate date format
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional validation if empty value is allowed
    }
    // Customize date format pattern as per your requirement
    String pattern = r'^\d{4}-\d{2}-\d{2}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
    // Additional validation logic can be added to check if the date is valid
    return null;
  }
}
