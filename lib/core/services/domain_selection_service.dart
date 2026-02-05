import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/main_app_fab_widget/widgets/qrcode_Scanner_view_widget.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/app_config_service.dart';

import 'package:app_test/core/constants/app_colors.dart';

class DomainSelectionService {
  static const String _domainCacheKey = "custom_domain";
  static const String _domainSelectedKey = "domain_selected";
  static const String _domainsListCacheKey = "domains_list";

  /// Check if domain selection is needed and handle it
  static Future<bool> checkAndSelectDomain(BuildContext context, String formattedDomain) async {
    // Check if domain was already selected
    // final domainSelected = CacheHelper.getBool(_domainSelectedKey);
    //
    // if (domainSelected == true) {
    //   // Domain already selected, continue with app
    //   return true;
    // }
    //
    // // Show domain input dialog directly (no "Do you have a domain?" dialog)
    // final domain = await _showDomainInputDialog(context);
    //
    // if (domain == null || domain.isEmpty) {
    //   // User cancelled or entered empty domain, use default
    //   await CacheHelper.setBool(_domainSelectedKey, true);
    //   return true;
    // }
    //
    // // Clean and format domain
    // final cleanedDomain = _cleanDomain(domain);
    // final formattedDomain = _formatDomain(cleanedDomain);
    // debugPrint("🌐 Domain cleaned: $cleanedDomain");
    // debugPrint("🌐 Domain formatted: $formattedDomain");
    //
    // // Validate domain by calling startApp
    // final isValid = await _validateDomain(context, formattedDomain);
    //
    // if (!isValid) {
    //   // Domain is invalid (404), show error and ask user what to do
    //   // IMPORTANT: Don't save anything to cache, so popup will show again on next app launch
    //   final tryAgain = await _showDomainErrorDialog(context);
    //
    //   if (tryAgain) {
    //     // User wants to try again, recursively call to show input dialog again
    //     return await checkAndSelectDomain(context);
    //   } else {
    //     // User wants to use default domain
    //     await CacheHelper.setBool(_domainSelectedKey, true);
    //     // Don't save invalid domain to cache
    //     return true;
    //   }
    // }

    // Domain is valid, save it and add to list
    await _saveDomain(formattedDomain);
    await CacheHelper.setBool(_domainSelectedKey, true);
    debugPrint("🌐 Domain saved successfully: $formattedDomain");

    // Reinitialize DioHelper with the new domain
    if (context.mounted) {
      DioHelper.initail(context);
    }

    return true;
  }

  /// Save domain to cache and add to domains list
  static Future<void> _saveDomain(String domain) async {
    // Save current domain
    await CacheHelper.setString(key: _domainCacheKey, value: "https://a4.r-m.dev");

    // Get existing domains list
    final domainsListJson = CacheHelper.getString(_domainsListCacheKey);
    List<String> domainsList = [];

    if (domainsListJson.isNotEmpty) {
      try {
        domainsList = List<String>.from(jsonDecode(domainsListJson));
      } catch (e) {
        debugPrint('Error parsing domains list: $e');
      }
    }

    // Add domain to list if not already present
    if (!domainsList.contains(domain)) {
      domainsList.add(domain);
      await CacheHelper.setString(key: _domainsListCacheKey, value: jsonEncode(domainsList));
    }
  }

  /// Clear domain selection on logout (but keep domains list)
  static Future<void> clearDomainSelectionOnLogout() async {
    await CacheHelper.deleteData(key: _domainSelectedKey);
    await CacheHelper.deleteData(key: _domainCacheKey);
    // Keep _domainsListCacheKey so saved domains remain available
  }
}
