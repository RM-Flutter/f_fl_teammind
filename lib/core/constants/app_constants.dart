import 'dart:convert';

import 'package:app_test/core/models/settings/fingerprint_security_checks.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';


abstract class AppConstants {
  static  List<Map<String, dynamic>>? requestsTypess;
  static  List? fingerPrints = [];

  // ═══════════════════════════════════════════════════════════════════════════
  // مفاتيح أمان البصمة (13) — تدعم 3 مستويات: mandatory / optional / disabled
  // الأولوية لـ fingerprint_security_checks (object).
  // الـ fallback هو fingerprintChecks (array القديم) إن لم يوجد الـ object.
  // ═══════════════════════════════════════════════════════════════════════════

  /// أسماء المفاتيح الـ 13 (بنفس أسماء الباك اند).
  static const List<String> fingerprintSecurityKeyNames = [
    'block_fingerprint_on_developer_mode',
    'fingerprint_block_on_root_or_jailbreak',
    'fingerprint_block_on_fake_gps',
    'fingerprint_block_on_vpn',
    'fingerprint_verify_time_drift',
    'fingerprint_verify_gps_network_comparison',
    'fingerprint_verify_gps_timestamp_offline',
    'fingerprint_liveness_challenges_enabled',
    'fingerprint_face_challenge_enabled',
    'fingerprint_face_profile_verification_enabled',
    'fingerprint_upload_face_image_to_backend',
    'fingerprint_send_note_report_to_api',
    'fp_scan_steps',
  ];

  /// مستويات الأمان (Levels)
  static FingerprintCheckLevel blockFingerprintOnDeveloperModeLevel = FingerprintCheckLevel.mandatory;
  static FingerprintCheckLevel fingerprintBlockOnRootOrJailbreakLevel = FingerprintCheckLevel.mandatory;
  static FingerprintCheckLevel fingerprintBlockOnFakeGpsLevel = FingerprintCheckLevel.mandatory;
  static FingerprintCheckLevel fingerprintBlockOnVpnLevel = FingerprintCheckLevel.optional;
  static FingerprintCheckLevel fingerprintVerifyTimeDriftLevel = FingerprintCheckLevel.optional;
  static FingerprintCheckLevel fingerprintVerifyGpsNetworkComparisonLevel = FingerprintCheckLevel.disabled;
  static FingerprintCheckLevel fingerprintVerifyGpsTimestampOfflineLevel = FingerprintCheckLevel.disabled;
  static FingerprintCheckLevel fingerprintLivenessChallengesEnabledLevel = FingerprintCheckLevel.optional;
  static FingerprintCheckLevel fingerprintFaceChallengeEnabledLevel = FingerprintCheckLevel.disabled;
  static FingerprintCheckLevel fingerprintFaceProfileVerificationEnabledLevel = FingerprintCheckLevel.optional;
  static FingerprintCheckLevel fingerprintUploadFaceImageToBackendLevel = FingerprintCheckLevel.optional;
  static FingerprintCheckLevel fingerprintSendNoteReportToApiLevel = FingerprintCheckLevel.optional;
  static FingerprintCheckLevel fpScanStepsLevel = FingerprintCheckLevel.optional;

  /// Getters متوافقة مع الكود السابق (ترجع true إذا كان المفتاح مفعلاً: mandatory أو optional)
  static bool get blockFingerprintOnDeveloperMode => blockFingerprintOnDeveloperModeLevel.isEnabled;
  static bool get fingerprintBlockOnRootOrJailbreak => fingerprintBlockOnRootOrJailbreakLevel.isEnabled;
  static bool get fingerprintBlockOnFakeGps => fingerprintBlockOnFakeGpsLevel.isEnabled;
  static bool get fingerprintBlockOnVpn => fingerprintBlockOnVpnLevel.isEnabled;
  static bool get fingerprintVerifyTimeDrift => fingerprintVerifyTimeDriftLevel.isEnabled;
  static bool get fingerprintVerifyGpsNetworkComparison => fingerprintVerifyGpsNetworkComparisonLevel.isEnabled;
  static bool get fingerprintVerifyGpsTimestampOffline => fingerprintVerifyGpsTimestampOfflineLevel.isEnabled;
  static bool get fingerprintLivenessChallengesEnabled => fingerprintLivenessChallengesEnabledLevel.isEnabled;
  static bool get fingerprintFaceChallengeEnabled => fingerprintFaceChallengeEnabledLevel.isEnabled;
  static bool get fingerprintFaceProfileVerificationEnabled => fingerprintFaceProfileVerificationEnabledLevel.isEnabled;
  static bool get fingerprintUploadFaceImageToBackend => fingerprintUploadFaceImageToBackendLevel.isEnabled;
  static bool get fingerprintSendNoteReportToApi => fingerprintSendNoteReportToApiLevel.isEnabled;
  static bool get fpScanSteps => fpScanStepsLevel.isEnabled;

  /// تحديث مستويات أمان البصمة من موديل الـ object الجديد (الأولوية الأولى).
  static void updateFingerprintSecurityFromChecksObject(FingerprintSecurityChecksModel checks) {
    blockFingerprintOnDeveloperModeLevel = checks.blockFingerprintOnDeveloperMode;
    fingerprintBlockOnRootOrJailbreakLevel = checks.fingerprintBlockOnRootOrJailbreak;
    fingerprintBlockOnFakeGpsLevel = checks.fingerprintBlockOnFakeGps;
    fingerprintBlockOnVpnLevel = checks.fingerprintBlockOnVpn;
    fingerprintVerifyTimeDriftLevel = checks.fingerprintVerifyTimeDrift;
    fingerprintVerifyGpsNetworkComparisonLevel = checks.fingerprintVerifyGpsNetworkComparison;
    fingerprintVerifyGpsTimestampOfflineLevel = checks.fingerprintVerifyGpsTimestampOffline;
    fingerprintLivenessChallengesEnabledLevel = checks.fingerprintLivenessChallengesEnabled;
    fingerprintFaceChallengeEnabledLevel = checks.fingerprintFaceChallengeEnabled;
    fingerprintFaceProfileVerificationEnabledLevel = checks.fingerprintFaceProfileVerificationEnabled;
    fingerprintUploadFaceImageToBackendLevel = checks.fingerprintUploadFaceImageToBackend;
    fingerprintSendNoteReportToApiLevel = checks.fingerprintSendNoteReportToApi;
    fpScanStepsLevel = checks.fpScanSteps;
  }

  /// تحديث مفاتيح أمان البصمة من كاش USG:
  /// 1) يفحص أولاً وجود object جديد: "fingerprint_security_checks"
  /// 2) إذا لم يوجد، يتراجع للـ array القديم: "fingerprintChecks" (fallback)
  static void updateFingerprintSecurityFromUsgFingerprintChecks() {
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final gCache = json.decode(jsonString) as Map<String, dynamic>?;
        if (gCache != null) {
          if (gCache['fingerprint_security_checks'] is Map) {
            final checks = FingerprintSecurityChecksModel.fromJson(
              gCache['fingerprint_security_checks'] as Map<String, dynamic>,
            );
            updateFingerprintSecurityFromChecksObject(checks);
            return;
          } else if (gCache['fingerprintChecks'] is List) {
            final checks = FingerprintSecurityChecksModel.fromLegacyArray(
              gCache['fingerprintChecks'] as List<dynamic>,
            );
            updateFingerprintSecurityFromChecksObject(checks);
            return;
          }
        }
      } catch (_) {}
    }
  }

  /// الكاميرا تفتح لو أي key من الـ keys دي موجود — كل key مستقل تماماً.
  /// - fingerprintFaceChallengeEnabled    : تصوير وجه أساسي
  /// - fingerprintUploadFaceImageToBackend: محتاج صورة يرفعها للباك إند
  /// - fingerprintLivenessChallengesEnabled: محتاج كاميرا للتحديات الحية
  /// - fingerprintFaceProfileVerificationEnabled: محتاج صورة يقارنها بالبروفايل
  /// - fingerprintSendNoteReportToApi    : يجمع تقرير الوجه والـ GPS ويرسله في الـ note
  static bool get showFaceVerifyForFingerprint =>
      fingerprintFaceChallengeEnabled ||
      fingerprintUploadFaceImageToBackend ||
      fingerprintLivenessChallengesEnabled ||
      fingerprintFaceProfileVerificationEnabled ||
      fingerprintSendNoteReportToApi;

  static const String _defaultBase = "https://emplive.r-m.dev";

  /// Get base URL from cache or use default
  static String get base {
    final cachedBase = CacheHelper.getString("custom_domain");
    if (cachedBase != null && cachedBase.isNotEmpty) {
      return cachedBase;
    }
    return _defaultBase;
  }

  static String get baseUrl => "$base/api";
  static const String refreshTokenBaseUrl = "http://refresh_token_test-api/";
  static const String appPackageName = "com.rightminddev.rmemp";
  static const String fontFamilyPoppins = 'Poppins';
  static const String fontFamilyIbrand = 'Ibrand';
  static const String country = 'EG';
  static const String countryCode = '+20';
  static const String fontFamilyMontserratArabic = 'Montserrat-Arabic';
  static String get socialLoginGoogle => '$base/auth/socialite/google/login?redirect_url=$base/front-end/social_login&device_unique_id=';
  static String get socialLoginFacebook => '$base/auth/socialite/facebook/login?redirect_url=$base/front-end/social_login&device_unique_id=';
  static String get socialLoginLinkedIn => '$base/auth/socialite/linkedin-openid/login?redirect_url=$base/front-end/social_login&device_unique_id=';
  static String get socialLoginAppleStore => '$base/auth/socialite/apple/login?redirect_url=$base/front-end/social_login&device_unique_id=';
  static const Map<String, String> countryDialCodes = {
    'AF': '+93', // أفغانستان
    'AL': '+355', // ألبانيا
    'DZ': '+213', // الجزائر
    'AS': '+1-684', // ساموا الأمريكية
    'AD': '+376', // أندورا
    'AO': '+244', // أنغولا
    'AI': '+1-264', // أنغويلا
    'AG': '+1-268', // أنتيغوا وبربودا
    'AR': '+54', // الأرجنتين
    'AM': '+374', // أرمينيا
    'AW': '+297', // أروبا
    'AU': '+61', // أستراليا
    'AT': '+43', // النمسا
    'AZ': '+994', // أذربيجان
    'BS': '+1-242', // جزر البهاما
    'BH': '+973', // البحرين
    'BD': '+880', // بنغلاديش
    'BB': '+1-246', // بربادوس
    'BY': '+375', // بيلاروسيا
    'BE': '+32', // بلجيكا
    'BZ': '+501', // بليز
    'BJ': '+229', // بنين
    'BM': '+1-441', // برمودا
    'BT': '+975', // بوتان
    'BO': '+591', // بوليفيا
    'BA': '+387', // البوسنة والهرسك
    'BW': '+267', // بوتسوانا
    'BR': '+55', // البرازيل
    'BN': '+673', // بروناي
    'BG': '+359', // بلغاريا
    'BF': '+226', // بوركينا فاسو
    'BI': '+257', // بوروندي
    'KH': '+855', // كمبوديا
    'CM': '+237', // الكاميرون
    'CA': '+1', // كندا
    'CV': '+238', // الرأس الأخضر
    'KY': '+1-345', // جزر كايمان
    'CF': '+236', // جمهورية أفريقيا الوسطى
    'TD': '+235', // تشاد
    'CL': '+56', // تشيلي
    'CN': '+86', // الصين
    'CO': '+57', // كولومبيا
    'KM': '+269', // جزر القمر
    'CG': '+242', // جمهورية الكونغو
    'CD': '+243', // جمهورية الكونغو الديمقراطية
    'CK': '+682', // جزر كوك
    'CR': '+506', // كوستاريكا
    'HR': '+385', // كرواتيا
    'CU': '+53', // كوبا
    'CY': '+357', // قبرص
    'CZ': '+420', // جمهورية التشيك
    'DK': '+45', // الدنمارك
    'DJ': '+253', // جيبوتي
    'DM': '+1-767', // دومينيكا
    'DO': '+1-809, 1-829, 1-849', // جمهورية الدومينيكان
    'EC': '+593', // الإكوادور
    'EG': '+20', // مصر
    'SV': '+503', // السلفادور
    'GQ': '+240', // غينيا الاستوائية
    'ER': '+291', // إريتريا
    'EE': '+372', // إستونيا
    'ET': '+251', // إثيوبيا
    'FK': '+500', // جزر فوكلاند
    'FO': '+298', // جزر فارو
    'FJ': '+679', // فيجي
    'FI': '+358', // فنلندا
    'FR': '+33', // فرنسا
    'GF': '+594', // غيانا الفرنسية
    'PF': '+689', // بولينيزيا الفرنسية
    'GA': '+241', // الغابون
    'GM': '+220', // غامبيا
    'GE': '+995', // جورجيا
    'DE': '+49', // ألمانيا
    'GH': '+233', // غانا
    'GI': '+350', // جبل طارق
    'GR': '+30', // اليونان
    'GL': '+299', // غرينلاند
    'GD': '+1-473', // غرينادا
    'GU': '+1-671', // غوام
    'GT': '+502', // غواتيمالا
    'GN': '+224', // غينيا
    'GW': '+245', // غينيا بيساو
    'GY': '+592', // غيانا
    'HT': '+509', // هايتي
    'HN': '+504', // هندوراس
    'HK': '+852', // هونغ كونغ
    'HU': '+36', // المجر
    'IS': '+354', // آيسلندا
    'IN': '+91', // الهند
    'ID': '+62', // إندونيسيا
    'IR': '+98', // إيران
    'IQ': '+964', // العراق
    'IE': '+353', // أيرلندا
    'IL': '+972', // إسرائيل
    'IT': '+39', // إيطاليا
    'JM': '+1-876', // جامايكا
    'JP': '+81', // اليابان
    'JO': '+962', // الأردن
    'KZ': '+7', // كازاخستان
    'KE': '+254', // كينيا
    'KI': '+686', // كيريباتي
    'KR': '+82', // كوريا الجنوبية
    'KW': '+965', // الكويت
    'KG': '+996', // قيرغيزستان
    'LA': '+856', // لاوس
    'LV': '+371', // لاتفيا
    'LB': '+961', // لبنان
    'LS': '+266', // ليسوتو
    'LR': '+231', // ليبيريا
    'LY': '+218', // ليبيا
    'LI': '+423', // ليختنشتاين
    'LT': '+370', // ليتوانيا
    'LU': '+352', // لوكسمبورغ
    'MO': '+853', // ماكاو
    'MK': '+389', // مقدونيا
    'MG': '+261', // مدغشقر
    'MW': '+265', // مالاوي
    'MY': '+60', // ماليزيا
    'MV': '+960', // جزر المالديف
    'ML': '+223', // مالي
    'MT': '+356', // مالطا
    'MH': '+692', // جزر مارشال
    'MQ': '+596', // مارتينيك
    'MR': '+222', // موريتانيا
    'MU': '+230', // موريشيوس
    'YT': '+262', // مايوت
    'MX': '+52', // المكسيك
    'FM': '+691', // ميكرونيزيا
    'MD': '+373', // مولدوفا
    'MC': '+377', // موناكو
    'MN': '+976', // منغوليا
    'ME': '+382', // الجبل الأسود
    'MA': '+212', // المغرب
    'MZ': '+258', // موزمبيق
    'MM': '+95', // ميانمار
    'NA': '+264', // ناميبيا
    'NR': '+674', // ناورو
    'NP': '+977', // نيبال
    'NL': '+31', // هولندا
    'NC': '+687', // كاليدونيا الجديدة
    'NZ': '+64', // نيوزيلندا
    'NI': '+505', // نيكاراغوا
    'NE': '+227', // النيجر
    'NG': '+234', // نيجيريا
    'NU': '+683', // نيوي
    'NF': '+672', // جزيرة نورفولك
    'MP': '+1-670', // جزر ماريانا الشمالية
    'NO': '+47', // النرويج
    'OM': '+968', // عمان
    'PK': '+92', // باكستان
    'PW': '+680', // بالاو
    'PA': '+507', // بنما
    'PG': '+675', // بابوا غينيا الجديدة
    'PY': '+595', // باراغواي
    'PE': '+51', // بيرو
    'PH': '+63', // الفلبين
    'PL': '+48', // بولندا
    'PT': '+351', // البرتغال
    'PR': '+1-787, 1-939', // بورتو ريكو
    'QA': '+974', // قطر
    'RO': '+40', // رومانيا
    'RU': '+7', // روسيا
    'RW': '+250', // رواندا
    'RE': '+262', // ريونيون
    'BL': '+590', // سانت بارتيليمي
    'SH': '+290', // سانت هيلينا
    'KN': '+1-869', // سانت كيتس ونيفيس
    'LC': '+1-758', // سانت لوسيا
    'MF': '+590', // سانت مارتين
    'PM': '+508', // سانت بيير وميكلون
    'VC': '+1-784', // سانت فنسنت والغرينادين
    'WS': '+685', // ساموا
    'SM': '+378', // سان مارينو
    'ST': '+239', // ساو تومي وبرينسيب
    'SA': '+966', // المملكة العربية السعودية
    'SN': '+221', // السنغال
    'RS': '+381', // صربيا
    'SC': '+248'
  };
}
