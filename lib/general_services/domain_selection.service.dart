import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:app_test/common_modules_widgets/main_app_fab_widget/widgets/qrcode_Scanner_view.widget.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/general_services/app_config.service.dart';

import '../core/constants/app_colors.dart';

class DomainSelectionService {
  static const String _domainCacheKey = "custom_domain";
  static const String _domainSelectedKey = "domain_selected";
  static const String _domainsListCacheKey = "domains_list";

  /// Check if domain selection is needed and handle it
  static Future<bool> checkAndSelectDomain(BuildContext context) async {
    // Check if domain was already selected
    final domainSelected = CacheHelper.getBool(_domainSelectedKey);
    
    if (domainSelected == true) {
      // Domain already selected, continue with app
      return true;
    }

    // Show domain input dialog directly (no "Do you have a domain?" dialog)
    final domain = await _showDomainInputDialog(context);
    
    if (domain == null || domain.isEmpty) {
      // User cancelled or entered empty domain, use default
      await CacheHelper.setBool(_domainSelectedKey, true);
      return true;
    }

    // Clean and format domain
    final cleanedDomain = _cleanDomain(domain);
    final formattedDomain = _formatDomain(cleanedDomain);
    debugPrint("🌐 Domain cleaned: $cleanedDomain");
    debugPrint("🌐 Domain formatted: $formattedDomain");

    // Validate domain by calling startApp
    final isValid = await _validateDomain(context, formattedDomain);
    
    if (!isValid) {
      // Domain is invalid (404), show error and ask user what to do
      // IMPORTANT: Don't save anything to cache, so popup will show again on next app launch
      final tryAgain = await _showDomainErrorDialog(context);
      
      if (tryAgain) {
        // User wants to try again, recursively call to show input dialog again
        return await checkAndSelectDomain(context);
      } else {
        // User wants to use default domain
        await CacheHelper.setBool(_domainSelectedKey, true);
        // Don't save invalid domain to cache
        return true;
      }
    }

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

  /// Clean domain: remove http://, https://, www., empapp., empapp, all subdomains, trailing slash
  /// Returns only domain + TLD (e.g., google.com)
  static String _cleanDomain(String domain) {
    String cleaned = domain.trim();
    
    // Remove trailing slash
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    
    // Remove http:// or https://
    if (cleaned.startsWith('https://')) {
      cleaned = cleaned.substring(8);
    } else if (cleaned.startsWith('http://')) {
      cleaned = cleaned.substring(7);
    }
    
    // Remove www.
    if (cleaned.startsWith('www.')) {
      cleaned = cleaned.substring(4);
    }
    
    // Remove empapp. or empapp from the beginning (can appear multiple times)
    while (cleaned.startsWith('empapp.')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('empapp')) {
      // Check if it's exactly "empapp" followed by nothing, dot, or slash
      if (cleaned.length == 6 || (cleaned.length > 6 && (cleaned[6] == '.' || cleaned[6] == '/'))) {
        cleaned = cleaned.substring(6);
        // Remove leading dot or slash if exists
        while (cleaned.isNotEmpty && (cleaned[0] == '.' || cleaned[0] == '/')) {
          cleaned = cleaned.substring(1);
        }
      }
    }
    
    // Remove all subdomains - keep only domain + TLD (last two parts)
    // Example: amr.google.com -> google.com
    // Example: empapp.amr.google.com -> google.com
    final parts = cleaned.split('.');
    if (parts.length > 2) {
      // Take only the last two parts (domain + TLD)
      cleaned = '${parts[parts.length - 2]}.${parts[parts.length - 1]}';
    }
    
    return cleaned;
  }

  /// Format domain: add https://empapp. prefix
  static String _formatDomain(String cleanedDomain) {
    return 'https://empapp.$cleanedDomain';
  }

  /// Save domain to cache and add to domains list
  static Future<void> _saveDomain(String domain) async {
    // Save current domain
    await CacheHelper.setString(key: _domainCacheKey, value: domain);
    
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

  /// Get list of saved domains
  static List<String> getSavedDomains() {
    final domainsListJson = CacheHelper.getString(_domainsListCacheKey);
    if (domainsListJson.isEmpty) {
      return [];
    }
    
    try {
      return List<String>.from(jsonDecode(domainsListJson));
    } catch (e) {
      debugPrint('Error parsing domains list: $e');
      return [];
    }
  }

  /// Remove domain from saved list
  static Future<void> removeDomainFromList(String domain) async {
    final domainsList = getSavedDomains();
    domainsList.remove(domain);
    await CacheHelper.setString(key: _domainsListCacheKey, value: jsonEncode(domainsList));
  }

  /// Show dialog for domain input with QR scan and saved domains list
  static Future<String?> _showDomainInputDialog(BuildContext context) {
    final controller = TextEditingController();
    final savedDomains = getSavedDomains();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: Color(AppColors.white),
            title: Text(
              AppStrings.enterYourDomain.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(AppColors.dark)),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Domain input field
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: AppStrings.domainExample.tr(),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon:  const Icon(Icons.qr_code_scanner),
                          onPressed: () async {
                            // Scan QR code
                            final scannedText = await Navigator.push<String>(
                              ctx,
                              MaterialPageRoute(
                                builder: (context) => const QRScannerView(),
                              ),
                            );
                            
                            if (scannedText != null && scannedText.isNotEmpty) {
                              // Extract domain from QR code (clean it)
                              final cleaned = _cleanDomain(scannedText);
                              controller.text = cleaned;
                            }
                          },
                        ),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Saved domains list
                    if (savedDomains.isNotEmpty) ...[
                      Text(
                        AppStrings.savedDomains.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(AppColors.dark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: savedDomains.length,
                          itemBuilder: (context, index) {
                            final domain = savedDomains[index];
                            // Extract subdomain from full domain (remove https://empapp.)
                            final displayDomain = domain.replaceFirst('https://empapp.', '');
                            
                            return ListTile(
                              title: Text(
                                displayDomain,
                                style:  const TextStyle(fontSize: 14),
                              ),
                              trailing: IconButton(
                                icon:  const Icon(Icons.close, size: 20, color: Colors.red),
                                onPressed: () async {
                                  await removeDomainFromList(domain);
                                  setState(() {
                                    savedDomains.remove(domain);
                                  });
                                },
                              ),
                              onTap: () {
                                // Use selected domain
                                Navigator.of(dialogContext).pop(displayDomain);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(
                  AppStrings.cancel.tr(),
                  style: TextStyle(color: Color(AppColors.dark)),
                ),
              ),
              TextButton(
                onPressed: () {
                  final domain = controller.text.trim();
                  if (domain.isNotEmpty) {
                    debugPrint("🌐 Domain entered: $domain");
                    Navigator.of(ctx).pop(domain);
                  }
                },
                child: Text(
                  AppStrings.confirm.tr(),
                  style:  const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Validate domain by calling startApp endpoint
  static Future<bool> _validateDomain(BuildContext context, String domain) async {
    try {
      final baseUrl = "$domain/api";
      final testUrl = "$baseUrl/rm_users/v1/start_app";
      
      // Prepare minimal body for startApp
      final appConfigService = Provider.of<AppConfigService>(context, listen: false);
      Map<String, dynamic> body = {
        "needed": ["general_settings"],
        "device_id": appConfigService.deviceInformation.deviceUniqueId
      };

      // Make HTTP POST request to validate domain
      final response = await http.post(
        Uri.parse(testUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      // Check if response is 404 (domain/endpoint not found)
      // If it's 404, the domain is invalid
      // Any other status code (200, 401, 500, etc.) means the domain exists
      return response.statusCode != 404;
    } catch (e) {
      debugPrint("Error validating domain: $e");
      // For network errors or timeouts, we'll consider it invalid
      return false;
    }
  }

  /// Show error dialog when domain is invalid
  static Future<bool> _showDomainErrorDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.error.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(AppColors.dark)),
        ),
        content: Text(
          AppStrings.domainNotFound.tr(),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // User wants to use default domain
                  Navigator.of(ctx).pop(false);
                },
                child: Text(
                  AppStrings.useDefault.tr(),
                  style:  const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () {
                  // User wants to try again
                  Navigator.of(ctx).pop(true);
                },
                child: Text(
                  AppStrings.tryAgain.tr(),
                  style:  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          )
        ],
      ),
    ).then((value) => value ?? false);
  }

  /// Reset domain selection (for testing or if user wants to change domain)
  static Future<void> resetDomainSelection() async {
    await CacheHelper.deleteData(key: _domainSelectedKey);
    await CacheHelper.deleteData(key: _domainCacheKey);
    // Note: We don't delete _domainsListCacheKey here to keep the list
  }

  /// Clear domain selection on logout (but keep domains list)
  static Future<void> clearDomainSelectionOnLogout() async {
    await CacheHelper.deleteData(key: _domainSelectedKey);
    await CacheHelper.deleteData(key: _domainCacheKey);
    // Keep _domainsListCacheKey so saved domains remain available
  }
}

