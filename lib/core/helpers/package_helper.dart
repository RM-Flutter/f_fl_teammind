import 'package:app_test/core/constants/user_consts.dart';

class PackageHelper {
  static bool hasPackage(String packageSlug) {
    final license = UserSettingConst.generalSettingsModel?.license;
    
    // For testing: returning false if license is null helps us know if the cache is stale.
    // In production, you might want to return true to avoid hiding everything on old caches.
    if (license == null || license.allowedPackages == null) {
      return false; 
    }
    
    return license.allowedPackages!.contains(packageSlug);
  }

  static bool hasFeature(String featureSlug) {
    final license = UserSettingConst.generalSettingsModel?.license;
    if (license == null || license.allowedFeatures == null) {
      return true;
    }
    return license.allowedFeatures!.contains(featureSlug);
  }
}
