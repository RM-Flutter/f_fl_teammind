import 'dart:convert';
import 'backend_services/api_service/dio_api_service/shared.dart';

/// Service to get dynamic app configuration from gCache['USG']
/// Uses caching to avoid repeated JSON decoding and CacheHelper reads
class DynamicAppConfigService {
  // Cache for gCache data
  static Map<String, dynamic>? _cachedGCache;
  
  // Cache for teammind profile
  static Map<String, dynamic>? _cachedTeammindProfile;
  
  // Cache for logo URL
  static String? _cachedLogoUrl;
  
  // Cache for login background URL
  static String? _cachedLoginBackgroundUrl;
  
  // Cache for colors map
  static Map<String, String>? _cachedColors;
  
  // Flag to track if we've attempted to load cache (prevents multiple attempts)
  static bool _hasAttemptedLoad = false;

  /// Clear all caches (call this when new data is fetched)
  static void clearCache() {
    _cachedGCache = null;
    _cachedTeammindProfile = null;
    _cachedLogoUrl = null;
    _cachedLoginBackgroundUrl = null;
    _cachedColors = null;
    _hasAttemptedLoad = false;
  }

  /// Get gCache data (cached)
  static Map<String, dynamic>? _getGCache() {
    // Return cached value if available
    if (_cachedGCache != null) {
      return _cachedGCache;
    }

    // If we've already attempted to load and failed, don't try again
    if (_hasAttemptedLoad) {
      return null;
    }

    // Mark that we're attempting to load
    _hasAttemptedLoad = true;

    // Load from CacheHelper
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        _cachedGCache = json.decode(jsonString) as Map<String, dynamic>;
        print('🎨 DynamicAppConfig: ✅ gCache loaded from API (keys: ${_cachedGCache!.keys.toList()})');
        return _cachedGCache;
      } catch (e) {
        print('🎨 DynamicAppConfig: ❌ Error decoding gCache: $e');
        return null;
      }
    }
    
    print('🎨 DynamicAppConfig: ⚠️ USG cache is null or empty');
    return null;
  }

  /// Get teammind coloring profile from gCache (cached)
  /// Note: USG cache stores the data directly (not wrapped in general_settings)
  static Map<String, dynamic>? _getTeammindProfile() {
    // Return cached value if available
    if (_cachedTeammindProfile != null) {
      return _cachedTeammindProfile;
    }

    final gCache = _getGCache();
    if (gCache == null) {
      return null;
    }

    try {
      // The cache stores data directly, not wrapped in general_settings
      // So we access coloring_profiles directly from gCache
      final coloringProfiles = gCache['coloring_profiles'] as List?;
      if (coloringProfiles == null) {
        return null;
      }
      
      for (var profile in coloringProfiles) {
        if (profile is Map && profile['system'] == 'teammind') {
          _cachedTeammindProfile = Map<String, dynamic>.from(profile);
          final colors = _cachedTeammindProfile!['colors'] as Map?;
          print('🎨 DynamicAppConfig: ✅ Found teammind profile! Colors from API: ${colors?.keys.toList()}');
          return _cachedTeammindProfile;
        }
      }
    } catch (e) {
      print('🎨 DynamicAppConfig: ❌ Error getting profile: $e');
    }
    return null;
  }

  /// Get colors map from teammind profile (cached)
  static Map<String, String>? _getColorsMap() {
    // Return cached value if available
    if (_cachedColors != null) {
      return _cachedColors;
    }

    final profile = _getTeammindProfile();
    if (profile == null) {
      return null;
    }

    try {
      final colors = profile['colors'] as Map?;
      if (colors != null) {
        _cachedColors = Map<String, String>.from(
          colors.map((key, value) => MapEntry(key.toString(), value.toString()))
        );
        return _cachedColors;
      }
    } catch (e) {
      // Silently handle errors
    }
    return null;
  }

  /// Get logo URL from teammind profile (cached)
  static String? getLogoUrl() {
    // Return cached value if available
    if (_cachedLogoUrl != null) {
      return _cachedLogoUrl;
    }

    try {
      final profile = _getTeammindProfile();
      if (profile == null) {
        return null;
      }

      final logo = profile['logo'] as List?;
      if (logo != null && logo.isNotEmpty) {
        final firstLogo = logo[0];
        if (firstLogo is Map && firstLogo['file'] != null) {
          _cachedLogoUrl = firstLogo['file'] as String?;
          return _cachedLogoUrl;
        }
      }
    } catch (e) {
      // Silently handle errors
    }
    return null;
  }

  /// Get login background URL from teammind profile (cached)
  static String? getLoginBackgroundUrl() {
    // Return cached value if available
    if (_cachedLoginBackgroundUrl != null) {
      return _cachedLoginBackgroundUrl;
    }

    try {
      final profile = _getTeammindProfile();
      if (profile == null) {
        return null;
      }

      final loginBackground = profile['login_background'] as List?;
      if (loginBackground != null && loginBackground.isNotEmpty) {
        final firstBg = loginBackground[0];
        if (firstBg is Map && firstBg['file'] != null) {
          _cachedLoginBackgroundUrl = firstBg['file'] as String?;
          return _cachedLoginBackgroundUrl;
        }
      }
    } catch (e) {
      // Silently handle errors
    }
    return null;
  }

  /// Get color value from teammind profile (cached)
  /// Returns hex color string without #, or null if not found
  static String? getColorValue(String colorKey) {
    final colors = _getColorsMap();
    if (colors == null) {
      return null;
    }

    return colors[colorKey];
  }

  /// Convert hex color string (without #) to int color value
  static int hexToInt(String? hexColor, int defaultValue) {
    if (hexColor == null || hexColor.isEmpty) {
      return defaultValue;
    }
    
    try {
      // Remove # if present
      String cleanHex = hexColor.replaceAll('#', '');
      // Add FF prefix for alpha if not present (assuming 6-digit hex)
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return int.parse(cleanHex, radix: 16);
    } catch (e) {
      return defaultValue;
    }
  }
}

