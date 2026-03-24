import 'dart:convert';
import '../general_services/backend_services/api_service/dio_api_service/shared.dart';


class UsgPackagesService {
  static const String empEvaluation = 'emp-evaluation';
  static const String empPayroll = 'emp-payroll';
  static const String empReports = 'emp-reports';
  static const String empRequests = 'emp-requests';
  static const String fingerprintSys = 'fingerprint-sys';

  /// للتجربة فقط: لو حطيت slug وقيمة هنا هتتستخدم بدل USG.
  /// أمثلة: إخفاء الطلبات → empRequests: false ، إخفاء البصمة → fingerprintSys: false
  static final Map<String, bool> _testingOverrides = {
    //  empRequests: false,
    //  empPayroll: false,
    // empReports: false,
    //  empEvaluation: false,
    //  fingerprintSys: false,
  };

  static Map<String, bool>? _cachedPackages;

  /// Clear cache (call when USG is updated, e.g. after settings fetch or initUSG).
  static void clearCache() {
    _cachedPackages = null;
  }

  static Map<String, bool> _loadPackages() {
    if (_cachedPackages != null) return _cachedPackages!;
    _cachedPackages = {};

    final jsonString = CacheHelper.getString("USG");
    if (jsonString == null || jsonString.isEmpty) return _cachedPackages!;

    try {
      final gCache = json.decode(jsonString) as Map<String, dynamic>?;
      final packages = gCache?['packages'] as List<dynamic>?;
      if (packages != null && packages.isNotEmpty) {
        for (final p in packages) {
          if (p is Map<String, dynamic>) {
            final slug = p['slug'] as String?;
            final isActive = p['is_active'];
            if (slug != null && slug.isNotEmpty) {
              _cachedPackages![slug] = isActive == true;
            }
          }
        }
      }
    } catch (e) {
      // keep empty map → isPackageActive returns true by default
    }
    return _cachedPackages!;
  }

  /// Returns true if the package is active (visible in app), false if inactive (must be hidden).
  /// If USG has no packages or slug is missing, returns true to keep current behavior.
  /// القيمة في [_testingOverrides] لها أولوية للتجربة.
  static bool isPackageActive(String slug) {
    final override = _testingOverrides[slug];
    if (override != null) return override;
    final map = _loadPackages();
    if (map.isEmpty) return true;
    final value = map[slug];
    if (value == null) return true;
    return value;
  }

  /// Evaluation package active?
  static bool get isEvaluationActive => isPackageActive(empEvaluation);
  /// Payroll package active?
  static bool get isPayrollActive => isPackageActive(empPayroll);
  /// Reports package active?
  static bool get isReportsActive => isPackageActive(empReports);
  /// Requests package active?
  static bool get isRequestsActive => isPackageActive(empRequests);
  /// Fingerprint package active?
  static bool get isFingerprintActive => isPackageActive(fingerprintSys);
}
