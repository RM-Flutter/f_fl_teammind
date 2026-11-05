import 'package:app_test/core/services/app_error_reporter.dart';
import 'package:app_test/core/services/app_toast.dart';
import 'dart:async';
import 'package:app_test/core/widgets/main_app_fab_widget/widgets/face_capture_screen.dart';
import 'package:app_test/core/widgets/fingerprint_rejection_dialog.dart';
import 'package:app_test/core/services/fingerprint_security_runner.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_settings/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../models/settings/fingerprint_security_checks.model.dart';
import '../../services/connections_service.dart';
import '../../services/vpn_detection_service.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';
import '../../platform/platform_is.dart';
import '../../services/alert_service/alerts_service.dart';
import '../../services/app_config_service.dart';
import '../../services/backend_services/api_service/dio_api_service/shared.dart';
import '../../services/image_file_picker_service.dart';
import '../../services/offline_overlay_service.dart';
import '../../services/settings_service.dart';
import '../custom_alert_dialog_with_two_buttons.dart';
import 'tflite_wrapper.dart';
import '../../constants/app_colors.dart';
import '../../models/settings/general_settings.model.dart';
import '../../routing/app_router.dart';
import '../../services/fingerprint_service.dart';
import 'widgets/qrcode_Scanner_view_widget.dart';
import '../../platform/web_fingerprint_capabilities.dart';
import 'widgets/liveness_challenge_camera_widget.dart';
import 'package:app_test/core/constants/app_design.dart';

class _FaceAnalysisResult {
  const _FaceAnalysisResult({
    required this.hasFace,
    required this.embedding,
    required this.leftEyeOpenProbability,
    required this.rightEyeOpenProbability,
    required this.yaw,
    required this.roll,
    required this.boundingBox,
    required this.boundingBoxCoverage,
    required this.sharpness,
    required this.smilingProbability,
    this.error,
    this.imageWidth,
    this.imageHeight,
  });

  final bool hasFace;
  final List<double>? embedding;
  final double leftEyeOpenProbability;
  final double rightEyeOpenProbability;
  final double yaw;
  final double roll;
  final Rect boundingBox;
  final double boundingBoxCoverage;
  final double sharpness;
  final double smilingProbability;
  final int? imageWidth;
  final int? imageHeight;
  final String? error;

  bool get hasEmbedding => embedding != null && embedding!.isNotEmpty;
  bool get hasEyeProbabilities =>
      leftEyeOpenProbability >= 0 && rightEyeOpenProbability >= 0;
  bool get isFrontal => yaw.abs() <= 20 && roll.abs() <= 15;
  bool get eyesOpen =>
      !hasEyeProbabilities ||
          (leftEyeOpenProbability >= 0.6 && rightEyeOpenProbability >= 0.6);
  bool get eyesClosed =>
      hasEyeProbabilities &&
          leftEyeOpenProbability <= 0.35 &&
          rightEyeOpenProbability <= 0.35;
  bool get hasSmileProbability => smilingProbability >= 0;
  bool get isSmiling => hasSmileProbability && smilingProbability >= 0.75;
}

class _CapturedFaceData {
  _CapturedFaceData({
    required this.imageMap,
    required this.file,
    required this.embedding,
    required this.bytes,
    this.noteReport,
    this.livenessReports,
  });

  final Map<String, dynamic> imageMap;
  final File file;
  final List<double> embedding;
  final Uint8List bytes;
  final Map<String, dynamic>? noteReport;
  final List<LivenessChallengeReport>? livenessReports;

  List<FilePickerResult> get asFilePickerResults =>
      FileAndImagePickerService.convertMapListToFilePickerResults([imageMap]);
}

class _CapturedFrame {
  _CapturedFrame({
    required this.file,
    required this.analysis,
    required this.bytes,
  }) : imageMap = {
    'image': file.path,
    'fileName': p.basename(file.path),
    'bytes': bytes,
  };

  final Map<String, dynamic> imageMap;
  final File file;
  final _FaceAnalysisResult analysis;
  final Uint8List bytes;
}

class _FaceVerificationProgressDialog extends StatelessWidget {
  const _FaceVerificationProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {

    // لو مفيش لا liveness ولا profile verification (صورة فقط) نعرض نفس الـ dialog بدون نص "Verifying"
    final bool livenessEnabled =
        AppConstants.fingerprintLivenessChallengesEnabled;
    final bool profileVerifyEnabled =
        AppConstants.fingerprintFaceProfileVerificationEnabled;
    final bool captureOnly = !livenessEnabled && !profileVerifyEnabled;

    final String? message = captureOnly
        ? null
        : ('verifying'.tr());

    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Color(AppColors.buttons),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              decoration: TextDecoration.none,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: Colors.white,
                  ),
                ),
                if (message != null)  const SizedBox(height: 16),
                if (message != null)
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

abstract class MainFabServices {
  static const double _minFaceCoverage = 0.08;
  static const double _minSharpness = 7.0;
  static const double _minProfileSimilarity = 0.4;
  static const double _smileProbabilityThreshold = 0.7;
  static const int _maxCaptureAttempts = 1;
  static const int _cameraQuality = 85;
  static const MethodChannel _secureChannel =
  MethodChannel('com.rightminddev.rmemp/secure');

  /// Compress image bytes if they look like an image and size >= 1KB.
  static Future<Uint8List> _compressImageIfNeeded(
      Uint8List bytes,
      String mimeType,
      String fileName,
      ) async {
    final isImage = mimeType.startsWith('image/') ||
        RegExp(r'\.(jpg|jpeg|png|gif|webp|bmp)$', caseSensitive: false).hasMatch(fileName);
    if (!isImage || bytes.lengthInBytes < 1024) return bytes;
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 1200,
        minWidth: 1200,
        quality: 72,
      );
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('⚠️ Image compression failed: $e');
      return bytes;
    }
  }

  static Future<bool> _isDeveloperModeEnabled() async {
    if (PlatformIs.web) return false;
    try {
      final bool? value =
      await _secureChannel.invokeMethod<bool>('isDeveloperModeEnabled');
      return value ?? false;
    } catch (e) {
      debugPrint('Error checking developer mode: $e');
      return false;
    }
  }

  static Future<bool> _isDeviceRootedOrJailbroken() async {
    if (PlatformIs.web) return false;
    try {
      final bool? value =
      await _secureChannel.invokeMethod<bool>('isDeviceRooted');
      return value ?? false;
    } catch (e) {
      debugPrint('Error checking root/jailbreak: $e');
      return false;
    }
  }

  static Future<bool> _ensureDeviceSecurityForFingerprint(
      BuildContext context) async {
    debugPrint("🔒 Checking device security for fingerprint...");

    // 1) فحص Developer Mode إذا كان mandatory
    final bool blockOnDevMode =
        AppConstants.blockFingerprintOnDeveloperModeLevel == FingerprintCheckLevel.mandatory;
    debugPrint("   Block on Dev Mode (mandatory): $blockOnDevMode");

    if (blockOnDevMode) {
      final bool devModeOnDevice = await _isDeveloperModeEnabled();
      debugPrint("   Developer mode on device: $devModeOnDevice");
      if (devModeOnDevice) {
        final msg = _localized(
          context,
          en:
          'Fingerprint is blocked because Developer Mode is enabled on this device.',
          ar:
          'تم إيقاف البصمة لأن وضع المطوّر مفعّل على هذا الجهاز.',
        );
        final dialogContext = rootNavigatorKey.currentContext ?? context;
        if (dialogContext.mounted) {
          AlertsService.error(
            context: dialogContext,
            title: AppStrings.failed.tr(),
            message: msg,
          );
        }
        return false;
      }
    }

    // 2) فحص Root / Jailbreak إذا كان mandatory
    if (AppConstants.fingerprintBlockOnRootOrJailbreakLevel == FingerprintCheckLevel.mandatory) {
      final bool isRooted = await _isDeviceRootedOrJailbroken();
      debugPrint("   Root/Jailbreak: $isRooted");
      if (isRooted) {
        final msg = _localized(
          context,
          en: 'Fingerprint is blocked on rooted or jailbroken devices.',
          ar: 'البصمة غير متاحة على أجهزة الـ Root أو الـ Jailbreak.',
        );
        final dialogContext = rootNavigatorKey.currentContext ?? context;
        if (dialogContext.mounted) {
          AlertsService.error(
            context: dialogContext,
            title: AppStrings.failed.tr(),
            message: msg,
          );
        }
        return false;
      }
    }

    // 3) فحص VPN إذا كان mandatory
    if (AppConstants.fingerprintBlockOnVpnLevel == FingerprintCheckLevel.mandatory) {
      final vpnCheck = await VpnDetectionService.checkVpn();
      debugPrint("   VPN active: ${vpnCheck['isVpnActive']}");
      if (vpnCheck['isVpnActive'] == true) {
        final msg = _localized(
          context,
          en: 'Fingerprint is blocked because VPN is active on this device.',
          ar: 'تم إيقاف البصمة بسبب تفعيل اتصال VPN على هذا الجهاز.',
        );
        final dialogContext = rootNavigatorKey.currentContext ?? context;
        if (dialogContext.mounted) {
          AlertsService.error(
            context: dialogContext,
            title: AppStrings.failed.tr(),
            message: msg,
          );
        }
        return false;
      }
    }

    debugPrint("✅ Device security OK, fingerprint allowed");
    return true;
  }
  static IconData getFingerprintMethodIcon(
      {required String fingerprintMethod}) {
    switch (fingerprintMethod.toLowerCase().trim()) {
      case 'fp_scan':
        return Icons.qr_code;
      case 'fp_navigate' || 'custom_fp_navigate':
        return Icons.gps_fixed_rounded;
      case 'fp_wifi':
        return Icons.wifi;
      case 'fp_bluetooth':
        return Icons.bluetooth_connected;
      case 'fp_machine':
        return Icons.fingerprint;
      default:
        return Icons.fingerprint;
    }
  }

  static Future<void> getFingerprintActionMethodDependsOnFingerprintMethod(
      {required BuildContext context,
        required String fingerprintMethod}) async {
    // تحديث مفاتيح الأمان من الكاش للتأكد من استخدام أحدث إعدادات
    AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks();
    final safeContext = rootNavigatorKey.currentContext ?? context;

    // تحقق أولاً من أمان الجهاز قبل تنفيذ أي طريقة بصمة
    final allowed = await _ensureDeviceSecurityForFingerprint(safeContext);
    if (!allowed) return;

    if (kIsWeb || PlatformIs.web) {
      if (fingerprintMethod.toLowerCase().trim() == 'fp_scan') {
        debugPrint("✅ Opening QR Code fingerprint for WEB");
        await addFingerprintUsingQrCode(context: safeContext);
      } else {
        debugPrint("✅ Opening GPS fingerprint for WEB");
        await addFingerprintUsingGPS(context: safeContext);
      }
      return;
    }

    final method = fingerprintMethod.toLowerCase().trim();
    debugPrint("🔍 Fingerprint Method: $method");
    switch (method) {
      case 'fp_scan':
        debugPrint("✅ Opening QR Code fingerprint");
        await addFingerprintUsingQrCode(context: safeContext);
        return;
      case 'fp_navigate':
      case 'custom_fp_navigate':
        debugPrint("✅ Opening GPS fingerprint");
        await addFingerprintUsingGPS(context: safeContext);
        return;
      case 'fp_wifi':
        debugPrint("✅ Opening WiFi fingerprint");
        await addFingerprintUsingWiFi(context: safeContext);
        return;
      case 'fp_bluetooth':
        debugPrint("✅ Opening Bluetooth fingerprint");
        await addFingerprintUsingBluetooth(context: safeContext);
        return;
      case 'fp_nfc':
        debugPrint("✅ Opening NFC fingerprint");
        await addFingerprintUsingNFC(context: safeContext);
        return;
      case 'fp_machine':
        debugPrint("⚠️ Machine fingerprint not implemented");
        break;
      default:
        debugPrint("❌ Unknown fingerprint method: $method");
        AlertsService.error(
            context: safeContext,
            message: AppStrings.failed.tr(),
            title: AppStrings.failed.tr());
    }
  }
  static Future<File?> downloadImage(String imageUrl, {bool useCache = true}) async {
    try {
      // Try to get cached image first
      if (useCache) {
        final documentDirectory = await getTemporaryDirectory();
        final cachedFile = File('${documentDirectory.path}/profile_image_${Uri.parse(imageUrl).pathSegments.last}');
        if (await cachedFile.exists()) {
          debugPrint('✅ Using cached profile image');
          return cachedFile;
        }
      }

      // Try to download from server
      final response = await http.get(Uri.parse(imageUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Image download timeout');
        },
      );

      if (response.statusCode == 200) {
        final documentDirectory = await getTemporaryDirectory();
        final fileName = Uri.parse(imageUrl).pathSegments.last;
        final file = File('${documentDirectory.path}/profile_image_$fileName');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Profile image downloaded and cached');
        return file;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Error downloading image: $e');
      // Try to use cached image as fallback
      if (useCache) {
        try {
          final documentDirectory = await getTemporaryDirectory();
          final cachedFile = File('${documentDirectory.path}/profile_image_${Uri.parse(imageUrl).pathSegments.last}');
          if (await cachedFile.exists()) {
            debugPrint('✅ Using cached profile image as fallback');
            return cachedFile;
          }
        } catch (cacheError) {
          debugPrint('⚠️ Error accessing cached image: $cacheError');
        }
      }
      return null;
    }
  }
  /////////////////////////////////////////////////////////////////

  static Interpreter? _interpreter;
  static bool _modelLoaded = false;

  static Future<void> _loadModel() async {
    if (PlatformIs.web) {
      throw UnsupportedError('Face recognition is not supported on web platform');
    }
    if (_modelLoaded && _interpreter != null) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/facenet.tflite');
      _modelLoaded = true;
      print("✅ FaceNet model loaded successfully");
    } catch (e) {
      print("❌ Error loading model: $e");
      rethrow;
    }
  }

  static List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final input = List.generate(1, (_) =>
        List.generate(160, (_) =>
            List.generate(160, (_) => List.filled(3, 0.0))));

    for (int y = 0; y < 160; y++) {
      for (int x = 0; x < 160; x++) {
        final pixel = image.getPixel(x, y); // Pixel object
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        input[0][y][x][0] = (r - 128) / 128.0;
        input[0][y][x][1] = (g - 128) / 128.0;
        input[0][y][x][2] = (b - 128) / 128.0;
      }
    }

    return input;
  }

  static Future<_FaceAnalysisResult?> _processFace({
    required File imageFile,
    required bool withEmbedding,
  }) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true,
        enableContours: false,
        enableLandmarks: false,
      ),
    );

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return const _FaceAnalysisResult(
          hasFace: false,
          embedding: null,
          leftEyeOpenProbability: -1,
          rightEyeOpenProbability: -1,
          yaw: 0,
          roll: 0,
          boundingBox: Rect.zero,
          boundingBoxCoverage: 0,
          sharpness: 0,
          smilingProbability: -1,
          error: 'no_face',
        );
      }

      // Several faces (a poster, someone in the background, a false detection): use the largest one, the
      // person holding the phone. Only refuse when another face is almost as big (two people in front of the camera).
      faces.sort((a, b) => (b.boundingBox.width * b.boundingBox.height)
          .compareTo(a.boundingBox.width * a.boundingBox.height));
      final double largestArea = faces.first.boundingBox.width * faces.first.boundingBox.height;
      final double secondArea = faces.length > 1
          ? faces[1].boundingBox.width * faces[1].boundingBox.height
          : 0;
      if (faces.length > 1 && secondArea >= largestArea * 0.6) {
        return const _FaceAnalysisResult(
          hasFace: false,
          embedding: null,
          leftEyeOpenProbability: -1,
          rightEyeOpenProbability: -1,
          yaw: 0,
          roll: 0,
          boundingBox: Rect.zero,
          boundingBoxCoverage: 0,
          sharpness: 0,
          smilingProbability: -1,
          error: 'multiple_faces',
        );
      }

      final bytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        return const _FaceAnalysisResult(
          hasFace: false,
          embedding: null,
          leftEyeOpenProbability: -1,
          rightEyeOpenProbability: -1,
          yaw: 0,
          roll: 0,
          boundingBox: Rect.zero,
          boundingBoxCoverage: 0,
          sharpness: 0,
          smilingProbability: -1,
          error: 'invalid_image',
        );
      }

      final face = faces.first;
      final Rect rect = face.boundingBox;
      final double coverage = max(
        0,
        (rect.width * rect.height) /
            (originalImage.width * originalImage.height),
      );

      final int left = max(0, rect.left.floor());
      final int top = max(0, rect.top.floor());
      final int width = max(
        1,
        min(rect.width.ceil(), originalImage.width - left),
      );
      final int height = max(
        1,
        min(rect.height.ceil(), originalImage.height - top),
      );

      if (left >= originalImage.width ||
          top >= originalImage.height ||
          width <= 0 ||
          height <= 0) {
        return const _FaceAnalysisResult(
          hasFace: false,
          embedding: null,
          leftEyeOpenProbability: -1,
          rightEyeOpenProbability: -1,
          yaw: 0,
          roll: 0,
          boundingBox: Rect.zero,
          boundingBoxCoverage: 0,
          sharpness: 0,
          smilingProbability: -1,
          error: 'invalid_bounds',
        );
      }

      final cropped = img.copyCrop(
        originalImage,
        x: left,
        y: top,
        width: width,
        height: height,
      );
      final resized = img.copyResizeCropSquare(cropped, size: 160);
      final double sharpness = _computeSharpness(resized);

      List<double>? embedding;
      if (withEmbedding) {
        if (PlatformIs.web) {
          throw UnsupportedError('Face embedding is not supported on web platform');
        }
        if (_interpreter == null) {
          await _loadModel();
        }
        final input = _preprocessImage(resized);
        final output = List.generate(1, (_) => List.filled(512, 0.0));
        _interpreter!.run(input, output);
        embedding =
        List<double>.from(output[0].map((e) => (e as num).toDouble()));
      }

      return _FaceAnalysisResult(
        hasFace: true,
        embedding: embedding,
        leftEyeOpenProbability: face.leftEyeOpenProbability ?? -1,
        rightEyeOpenProbability: face.rightEyeOpenProbability ?? -1,
        yaw: face.headEulerAngleY ?? 0,
        roll: face.headEulerAngleZ ?? 0,
        boundingBox: face.boundingBox,
        boundingBoxCoverage: coverage,
        sharpness: sharpness,
        smilingProbability: face.smilingProbability ?? -1,
        imageWidth: originalImage.width,
        imageHeight: originalImage.height,
      );
    } catch (error) {
      debugPrint('Face processing error: $error');
      return const _FaceAnalysisResult(
        hasFace: false,
        embedding: null,
        leftEyeOpenProbability: -1,
        rightEyeOpenProbability: -1,
        yaw: 0,
        roll: 0,
        boundingBox: Rect.zero,
        boundingBoxCoverage: 0,
        sharpness: 0,
        smilingProbability: -1,
        error: 'processing_error',
      );
    } finally {
      await faceDetector.close();
    }
  }

  static double _cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0.0;
    return dot / (sqrt(normA) * sqrt(normB));
  }

  static double _computeSharpness(img.Image image) {
    if (image.width < 3 || image.height < 3) {
      return 0;
    }
    double sum = 0;
    int count = 0;

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final center = image.getPixel(x, y).luminance;
        final left = image.getPixel(x - 1, y).luminance;
        final right = image.getPixel(x + 1, y).luminance;
        final up = image.getPixel(x, y - 1).luminance;
        final down = image.getPixel(x, y + 1).luminance;

        final double laplacian =
        (-4 * center + left + right + up + down).toDouble();
        sum += laplacian * laplacian;
        count++;
      }
    }

    return count == 0 ? 0 : sum / count;
  }

  static double _scoreFrame(_FaceAnalysisResult analysis) {
    double score = analysis.boundingBoxCoverage * 100;
    score += analysis.sharpness;
    if (analysis.isSmiling) {
      score += 20;
    }
    return score;
  }

  static Future<bool> _ensureCameraPermission() async {
    final permission = permission_handler.Permission.camera;
    var status = await permission.status;
    if (status.isGranted) return true;

    // Request the permission
    final wasNotDetermined = status.isDenied; // "not determined" on iOS
    status = await permission.request();
    // Denied before (iOS asks only once / Android "don't ask again") => send the user to app settings
    if (status.isPermanentlyDenied) await permission_handler.openAppSettings();

    // On iOS, after the user grants the camera permission for the very first
    // time, the system needs a brief moment to register the grant with
    // AVCaptureSession. Without this delay the subsequent camera call can
    // fail silently or throw, which surfaces as a generic "Network Error".
    if (PlatformIs.iOS && wasNotDetermined && status.isGranted) {
      await Future.delayed(const Duration(milliseconds: 600));
    }

    return status.isGranted;
  }

  static Future<String?> _recordVerificationVideo(
      BuildContext context) async {
    final hasPermission = await _ensureCameraPermission();
    if (!hasPermission) {
      _showWarning(
        context,
        en: 'Camera permission is required to record the verification video.',
        ar: 'يجب منح إذن الكاميرا لتسجيل فيديو التحقق.',
      );
      return null;
    }
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxDuration: const Duration(seconds: 3),
      );
      return video?.path;
    } catch (error) {
      _showWarning(
        context,
        en: 'Failed to record verification video. Please try again.',
        ar: 'تعذر تسجيل فيديو التحقق. حاول مرة أخرى.',
        details: {
          'error': error.toString(),
        },
      );
      return null;
    }
  }

  static Future<List<_CapturedFrame>> _extractFramesFromVideo(
      String videoPath) async {
    final tempDir = await getTemporaryDirectory();
    final sampleTimes = <int>[500, 1100, 1700];
    final List<_CapturedFrame> frames = [];

    for (final time in sampleTimes) {
      final String? framePath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        quality: 85,
        thumbnailPath: tempDir.path,
        timeMs: time,
      );
      if (framePath == null) continue;

      final file = File(framePath);
      final analysis =
      await _processFace(imageFile: file, withEmbedding: true);

      if (analysis == null ||
          !analysis.hasFace ||
          !analysis.hasEmbedding) {
        await _deleteFileIfExists(file);
        continue;
      }

      final bytes = await file.readAsBytes();

      frames.add(_CapturedFrame(
        file: file,
        analysis: analysis,
        bytes: bytes,
      ));
    }

    return frames;
  }

  static String _localized(BuildContext context,
      {required String en, required String ar}) {
    final String languageCode =
    context.locale.languageCode.toLowerCase().trim();
    return languageCode.startsWith('ar') ? ar : en;
  }

  /// حوار موحّد لرسائل أمان البصمة (يستخدم الـ rootNavigator عشان نضمن ظهوره)
  static Future<void> _showSecurityErrorDialog(
      BuildContext context, {
        required String message,
      }) async {
    final dialogContext = rootNavigatorKey.currentContext ?? context;
    if (!dialogContext.mounted) {
      debugPrint("⚠️ Cannot show security dialog: context not mounted");
      return;
    }

    await showDialog<void>(
      context: dialogContext,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.failed.tr(),
          style: TextStyle(
            color: Color(AppColors.failureRed),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: Color(AppColors.black)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Color(AppColors.secondaryButton)),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> _showInstructionSheet(
      BuildContext context, {
        required String title,
        required String message,
        required String actionLabel,
        String? cancelLabel,
      }) async {
    debugPrint("📋 Showing instruction sheet: $title");
    final dialogContext = rootNavigatorKey.currentContext ?? context;
    if (!dialogContext.mounted) {
      debugPrint("⚠️ Dialog context not mounted, proceeding directly to camera");
      return true;
    }
    try {
      final bool? result = await showModalBottomSheet<bool>(
        context: dialogContext,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        builder: (sheetContext) {
          debugPrint("📋 Building instruction sheet UI");
          ThemeData theme;
          try {
            theme = Theme.of(sheetContext);
          } catch (e) {
            theme = ThemeData.light();
          }

          double bottomInset = 0;
          try {
            bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
          } catch (_) {}

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: bottomInset + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700, color: Color(AppColors.secondaryButton), fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith( color: Color(AppColors.black)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(AppColors.secondaryButton)),
                    ),
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    child: Text(
                      actionLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white) ?? const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (cancelLabel != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: Text(
                        cancelLabel,
                        style: theme.textTheme.headlineSmall?.copyWith(color: Color(AppColors.secondaryButton)) ?? TextStyle(color: Color(AppColors.secondaryButton)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
      debugPrint("📋 Instruction sheet result: $result");

      return result ?? true;
    } catch (e, stackTrace) {
      debugPrint("⚠️ Error showing instruction sheet: $e, proceeding directly to camera");
      return true;
    }
  }

  static void _showWarning(
      BuildContext context, {
        required String en,
        required String ar,
        Map<String, String>? details,
      }) {
    final buffer = StringBuffer(_localized(context, en: en, ar: ar));
    details?.forEach((label, value) {
      buffer.writeln('\n• $label: $value');
    });
    AlertsService.warning(
      context: context,
      title: AppStrings.warning.tr(),
      message: buffer.toString(),
    );
  }

  static Future<bool> verifyFace(File newImageFile, File profileImageFile,
      {double threshold = 0.8}) async {
    if (PlatformIs.web) {
      throw UnsupportedError('Face verification is not supported on web platform');
    }
    await _loadModel();

    final candidate =
    await _processFace(imageFile: newImageFile, withEmbedding: true);
    final reference =
    await _processFace(imageFile: profileImageFile, withEmbedding: true);

    if (candidate == null ||
        reference == null ||
        !candidate.hasFace ||
        !reference.hasFace ||
        !candidate.hasEmbedding ||
        !reference.hasEmbedding) {
      debugPrint('❌ Face not detected or embedding missing for comparison');
      return false;
    }

    final similarity = _cosineSimilarity(
      candidate.embedding!,
      reference.embedding!,
    );
    debugPrint('🧠 Similarity: ${(similarity * 100).toStringAsFixed(2)}%');
    return similarity >= threshold;
  }

  static Future<void> _deleteFileIfExists(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      debugPrint('⚠️ Failed to delete temp file ${file.path}: $error');
    }
  }

  static Future<double?> _calculateSimilarityWithProfile(
      BuildContext context, List<double> candidateEmbedding) async {
    final safeContext = rootNavigatorKey.currentContext ?? context;
    final bool isMandatory = AppConstants.fingerprintFaceProfileVerificationEnabledLevel ==
        FingerprintCheckLevel.mandatory;

    final jsonString = CacheHelper.getString("US1");
    if (jsonString == null || jsonString.isEmpty) {
      debugPrint("⚠️ [ProfileFace] US1 cache is empty, cannot compare face");
      if (isMandatory && safeContext.mounted) {
        AlertsService.error(
          context: safeContext,
          title: AppStrings.failed.tr(),
          message: AppStrings.faceVerificationFailure.tr(),
        );
      }
      return null;
    }

    final Map<String, dynamic> cache =
    json.decode(jsonString) as Map<String, dynamic>;
    final String? photoUrl = cache['photo'] as String?;

    if (photoUrl == null || photoUrl.isEmpty) {
      debugPrint("⚠️ [ProfileFace] No profile photo URL in US1 cache");
      if (isMandatory && safeContext.mounted) {
        AlertsService.error(
          context: safeContext,
          title: AppStrings.failed.tr(),
          message: AppStrings.faceVerificationFailure.tr(),
        );
      }
      return null;
    }

    if (!safeContext.mounted) return null;

    showDialog(
      context: safeContext,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Try to download image (will use cache if available)
      final profileImage = await downloadImage(photoUrl, useCache: true);

      if (profileImage == null) {
        // If download failed and no cache available, skip verification in offline mode
        final isConnected = await ConnectionsService.isOnline();
        if (!isConnected) {
          debugPrint('⚠️ Offline mode: Skipping face verification');
          return 1.0;
        } else {
          debugPrint('⚠️ [ProfileFace] Failed to download profile photo');
          if (isMandatory && safeContext.mounted) {
            AlertsService.error(
              context: safeContext,
              title: AppStrings.failed.tr(),
              message: AppStrings.faceVerificationFailure.tr(),
            );
          }
          return null;
        }
      }

      final reference =
      await _processFace(imageFile: profileImage, withEmbedding: true);

      if (reference == null ||
          !reference.hasFace ||
          !reference.hasEmbedding ||
          !reference.isFrontal) {
        debugPrint('⚠️ [ProfileFace] Profile photo has no valid frontal face');
        if (isMandatory && safeContext.mounted) {
          AlertsService.error(
            context: safeContext,
            title: AppStrings.failed.tr(),
            message: AppStrings.faceVerificationFailure.tr(),
          );
        }
        return null;
      }

      return _cosineSimilarity(candidateEmbedding, reference.embedding!);
    } catch (error) {
      debugPrint('⚠️ Error while verifying profile face: $error');

      final isConnected = await ConnectionsService.isOnline();
      if (!isConnected) {
        debugPrint('⚠️ Offline mode: Skipping face verification due to error');
        return 1.0;
      }

      if (isMandatory && safeContext.mounted) {
        AlertsService.error(
          context: safeContext,
          title: AppStrings.failed.tr(),
          message: AppStrings.faceVerificationFailure.tr(),
        );
      }
      return null;
    } finally {
      // Always close dialog in finally block
      try {
        final popContext = rootNavigatorKey.currentContext ?? safeContext;
        if (popContext.mounted &&
            Navigator.of(popContext, rootNavigator: true).canPop()) {
          Navigator.of(popContext, rootNavigator: true).pop();
        }
      } catch (e) {
        debugPrint('⚠️ Error closing dialog: $e');
      }
    }
  }

  static LivenessChallenge _getRandomChallenge() {
    final challenges = LivenessChallenge.values;
    return challenges[Random().nextInt(challenges.length)];
  }

  static Map<String, dynamic> _createNoteReport(List<LivenessChallengeReport> reports) {
    final totalTime = reports.fold<Duration>(
      Duration.zero,
          (sum, report) => sum + report.duration,
    );
    final successfulChallenges = reports.where((r) => r.success).length;
    final failedChallenges = reports.where((r) => !r.success).toList();
    final timeoutFailures = failedChallenges.where((r) => r.failureReason?.contains('Time limit exceeded') ?? false).length;

    // Get failed challenges with their reasons
    final failedChallengesDetails = failedChallenges.map((report) => {
      'challengeId': report.challengeId,
      'challenge': report.challengeName,
      'challengeAr': report.challengeNameAr,
      'failureReason': report.failureReason,
      'durationSeconds': report.duration.inSeconds,
    }).toList();

    return {
      'reports': reports.map((report) => {
        'challengeId': report.challengeId,
        'challenge': report.challengeName,
        'challengeAr': report.challengeNameAr,
        'startTime': report.startTime.toIso8601String(),
        'endTime': report.endTime?.toIso8601String(),
        'durationSeconds': report.duration.inSeconds,
        'success': report.success,
        'failureReason': report.failureReason,
        'wasRetried': report.wasRetried,
      }).toList(),
      'totalTimeSeconds': totalTime.inSeconds,
      'successfulChallenges': successfulChallenges,
      'totalChallenges': reports.length,
      'failedChallengesCount': failedChallenges.length,
      'timeoutFailuresCount': timeoutFailures,
      'failedChallengesDetails': failedChallengesDetails,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> _showLivenessReport(BuildContext context, List<LivenessChallengeReport> reports,) async {
    final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');
    final buffer = StringBuffer();
    buffer.writeln('liveness_verification_report'.tr());
    buffer.writeln('');

    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      final challengeName = isArabic ? report.challengeNameAr : report.challengeName;
      final duration = report.duration.inSeconds;
      final status = report.success
          ? ('success_2'.tr())
          : ('failed_2'.tr());
      final retry = report.wasRetried ? ('retried'.tr()) : '';

      buffer.writeln('${i + 1}. $challengeName: $status (${duration}s)$retry');
      if (report.failureReason != null) {
        buffer.writeln('   ${'reason_2'.tr()} ${report.failureReason}');
      }
    }

    final totalTime = reports.fold<Duration>(
      Duration.zero,
          (sum, report) => sum + report.duration,
    );
    buffer.writeln('');
    buffer.writeln('total_time_seconds'.tr(namedArgs: {'in_seconds': '${totalTime.inSeconds}'}));

    final successfulChallenges = reports.where((r) => r.success).length;
    buffer.writeln('successful_challenges_of'.tr(namedArgs: {'successful_challenges': '$successfulChallenges', 'length': '${reports.length}'}));

    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: Text('verification_report'.tr(), style: TextStyle(color: Color(AppColors.secondaryButton), fontWeight: FontWeight.w700),),
        content: SingleChildScrollView(
          child: Text(buffer.toString(), style: TextStyle(color: Color(AppColors.black), fontWeight: FontWeight.w500),),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  static Future<void> _showScanStepsSuccessDialog(
    BuildContext context, {
    _CapturedFaceData? capturedFace,
    String? fingerprintType,
  }) async {

    final List<Map<String, dynamic>> steps = [];
    // Real results: failed optional device/GPS checks of this punch + failed face checks.
    // (A failed mandatory check blocks the punch, so it never reaches this report.)
    final Map<String, dynamic> deviceFailed = FingerprintSecurityRunner.lastFailedOptionals;
    final faceFailedRaw = capturedFace?.noteReport?['security_checks_failed'];
    final Map faceFailed = faceFailedRaw is Map ? faceFailedRaw : const {};
    bool anyFailed(Iterable<String> keys) => keys.any(deviceFailed.containsKey);

    // 1. أمان الجهاز
    final bool deviceOk = !anyFailed(const [
      'block_fingerprint_on_developer_mode',
      'fingerprint_block_on_root_or_jailbreak',
      'fingerprint_block_on_vpn',
      'fingerprint_verify_time_drift',
    ]);
    steps.add({
      'title': 'device_system_security'.tr(),
      'detail': deviceOk
          ? 'developer_mode_safe_no_root_jailbreak_detected'.tr()
          : 'scan_step_device_failed'.tr(),
      'icon': Icons.security,
      'passed': deviceOk,
    });

    // 2. فحص الموقع
    final bool locationOk = !anyFailed(const [
      'fingerprint_block_on_fake_gps',
      'fingerprint_verify_gps_network_comparison',
      'fingerprint_verify_gps_timestamp_offline',
    ]);
    steps.add({
      'title': 'location_verification'.tr(),
      'detail': locationOk
          ? 'location_verified_no_fake_gps_detected'.tr()
          : 'scan_step_location_failed'.tr(),
      'icon': Icons.location_on,
      'passed': locationOk,
    });

    // 3. فحص الوجه (إذا تم)
    if (capturedFace != null) {
      final bool livenessOk = !faceFailed.containsKey('fingerprint_liveness_challenges_enabled');
      if (capturedFace.livenessReports != null &&
          capturedFace.livenessReports!.isNotEmpty) {
        final totalChallenges = capturedFace.livenessReports!.length;
        final successful =
            capturedFace.livenessReports!.where((r) => r.success).length;
        final bool ok = livenessOk && successful == totalChallenges;
        steps.add({
          'title': 'face_liveness_check'.tr(),
          'detail': 'of_challenges_passed_successfully'.tr(namedArgs: {'successful': '$successful', 'total_challenges': '$totalChallenges'}),
          'icon': Icons.face_retouching_natural,
          'passed': ok,
        });
      } else if (!livenessOk) {
        steps.add({
          'title': 'face_liveness_check'.tr(),
          'detail': 'scan_step_liveness_failed'.tr(),
          'icon': Icons.face_retouching_natural,
          'passed': false,
        });
      } else {
        steps.add({
          'title': 'face_capture'.tr(),
          'detail': 'face_photo_captured_successfully'.tr(),
          'icon': Icons.camera_alt,
          'passed': true,
        });
      }

      if (AppConstants.fingerprintFaceProfileVerificationEnabled) {
        final bool identityOk = !faceFailed.containsKey('fingerprint_face_profile_verification_enabled');
        steps.add({
          'title': 'identity_verification'.tr(),
          'detail': identityOk
              ? 'face_matched_with_employee_profile'.tr()
              : 'scan_step_identity_failed'.tr(),
          'icon': Icons.verified_user,
          'passed': identityOk,
        });
      }
    }

    // 4. تسجيل البصمة
    steps.add({
      'title': 'fingerprint_registration'.tr(),
      'detail': 'fingerprint_verified_recorded'.tr(namedArgs: {'fingerprint_type_null': '${fingerprintType != null ? "($fingerprintType)" : ""}'}),
      'icon': Icons.fingerprint,
      'passed': true,
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('scan_steps_report'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(AppColors.black),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: steps.map((step) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(step['icon'] as IconData, size: 20, color: const Color(0xFF007AFF)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['detail'] as String,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    step['passed'] == false
                        ? const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18)
                        : const Icon(Icons.check, color: Colors.green, size: 18),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(45),
              backgroundColor: Color(AppColors.secondaryButton),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('ok'.tr(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static Future<_CapturedFaceData?> captureEmployeeFaceAndVerify(
      BuildContext context) async {
    debugPrint("📸 Starting face capture and verification...");
    final safeContext = rootNavigatorKey.currentContext ?? (context.mounted ? context : null);
    if (safeContext == null || !safeContext.mounted) {
      debugPrint("❌ No valid mounted context available for face capture");
      return null;
    }

    if (PlatformIs.web) {
      debugPrint("❌ Web platform not supported");
      AlertsService.error(
        context: safeContext,
        title: AppStrings.failed.tr(),
        message: 'Face recognition is not supported on web platform',
      );
      return null;
    }
    if (AppConstants.fingerprintFaceProfileVerificationEnabled) {
      debugPrint("📸 Loading FaceNet model...");
      try {
        await _loadModel();
        debugPrint("📸 FaceNet model loaded");
      } catch (e) {
        debugPrint("⚠️ FaceNet model failed to load: $e");
        if (AppConstants.fingerprintFaceProfileVerificationEnabledLevel ==
            FingerprintCheckLevel.mandatory) {
          rethrow;
        }
      }
    }

    // البوب أب "Start verification" تظهر فقط لو fingerprint_liveness_challenges_enabled مفعّل
    // لو fingerprint_face_profile_verification_enabled لوحده من غير liveness → لا تظهر
    final bool requiresAdvancedVerification =
        AppConstants.fingerprintLivenessChallengesEnabled;

    if (requiresAdvancedVerification) {
      debugPrint("📸 Showing instruction sheet (liveness challenges enabled)...");
      final bool introAccepted = await _showInstructionSheet(
        safeContext,
        title: _localized(
          safeContext,
          en: 'Face verification',
          ar: 'التحقق من الوجه',
        ),
        message: _localized(
          safeContext,
          en:
          'You will be asked to perform a random challenge. Please follow the on-screen instructions.',
          ar:
          'سيُطلب منك تنفيذ تحدّي عشوائي. يرجى اتباع التعليمات المعروضة على الشاشة.',
        ),
        actionLabel: _localized(
          safeContext,
          en: 'Start verification',
          ar: 'بدء التحقق',
        ),
        cancelLabel: _localized(
          safeContext,
          en: 'Cancel',
          ar: 'إلغاء',
        ),
      );

      debugPrint("📸 Instruction sheet result: $introAccepted");
      if (!introAccepted) {
        debugPrint("❌ User cancelled or instruction sheet failed");
        return null;
      }
    } else {
      debugPrint(
          "📸 Skipping instruction sheet (fingerprint_liveness_challenges_enabled is off; profile verification alone does not show it).");
    }

    // Ensure camera permission before opening camera screen
    debugPrint("📸 Checking camera permission...");
    final hasPermission = await _ensureCameraPermission();
    debugPrint("📸 Camera permission: $hasPermission");
    if (!hasPermission) {
      // Use rootNavigatorKey.currentContext if context is not mounted
      final warningContext = rootNavigatorKey.currentContext ?? safeContext;
      if (warningContext.mounted) {
        _showWarning(
          warningContext,
          en: 'Camera permission is required for face verification.',
          ar: 'إذن الكاميرا مطلوب للتحقق من الوجه.',
        );
      }
      return null;
    }

    final List<LivenessChallengeReport> reports = [];
    Uint8List? capturedImageBytes;
    File? capturedImageFile;
    bool challengeCompleted = false;
    bool isRetry = false;
    // Set when liveness is optional and we fell back to a plain selfie (sent to backend as a failed check).
    Map<String, dynamic>? livenessCheckFailed;

    List<LivenessChallengeReport>? allReportsFromScreen;

    if (!AppConstants.fingerprintLivenessChallengesEnabled) {
      // التقاط صورة واحدة بدون تحديات (لا يظهر للعميل أي تحدي حي)
      // in-app camera with the face frame and its reason (system camera if it cannot start)
      final XFile? photo = await FaceCaptureScreen.capture(rootNavigatorKey.currentContext ?? safeContext);
      if (photo == null) return null;
      try {
        capturedImageFile = File(photo.path);
        capturedImageBytes = await capturedImageFile!.readAsBytes();
        challengeCompleted = true;
      } catch (e) {
        debugPrint('Error reading captured photo: $e');
        return null;
      }
    }

    while (!challengeCompleted) {
      final challenge = _getRandomChallenge();
      LivenessChallengeReport? report;
      try {
        // Use rootNavigatorKey.currentContext instead of context to avoid mounted issues
        final cameraContext = rootNavigatorKey.currentContext ?? safeContext;
        debugPrint("📸 Opening camera screen for challenge: ${challenge.name}");
        report = await Navigator.of(cameraContext, rootNavigator: true).push<LivenessChallengeReport>(
          MaterialPageRoute(
            builder: (ctx) => LivenessChallengeCameraScreen(
              challenge: challenge,
              onComplete: (report, imageBytes) {
                if (report.success && imageBytes != null) {
                  capturedImageBytes = imageBytes;
                }
              },
              onAllReports: (allReports) {
                // Store all reports including failed ones (timeouts)
                allReportsFromScreen = allReports;
              },
            ),
          ),
        );
        debugPrint("📸 Camera screen returned: ${report != null ? 'report received' : 'null'}");
      } catch (e) {
        debugPrint('Error opening camera screen: $e');
        if (AppConstants.fingerprintLivenessChallengesEnabledLevel == FingerprintCheckLevel.optional) {
          debugPrint('📸 Liveness challenge error, falling back to standard front camera...');
          try {
            // in-app camera with the face frame and its reason (system camera if it cannot start)
            final XFile? photo = await FaceCaptureScreen.capture(rootNavigatorKey.currentContext ?? safeContext);
            if (photo != null) {
              capturedImageFile = File(photo.path);
              capturedImageBytes = await capturedImageFile!.readAsBytes();
              challengeCompleted = true;
              livenessCheckFailed = {
                'status': 'failed',
                'message': 'Liveness challenge could not run, plain selfie used',
                'detected_at': DateTime.now().toIso8601String(),
              };
              break;
            }
          } catch (pickerErr) {
            debugPrint('Error in fallback camera picker: $pickerErr');
          }
        }
        if (!challengeCompleted) {
          final warningContext = rootNavigatorKey.currentContext ?? safeContext;
          if (warningContext.mounted) {
            _showWarning(
              warningContext,
              en: 'Failed to open camera. Please try again.',
              ar: 'فشل فتح الكاميرا. يرجى المحاولة مرة أخرى.',
            );
          }
          return null;
        }
      }

      if (report == null && !challengeCompleted) {
        if (AppConstants.fingerprintLivenessChallengesEnabledLevel == FingerprintCheckLevel.optional &&
            (AppConstants.fingerprintFaceProfileVerificationEnabled ||
             AppConstants.fingerprintUploadFaceImageToBackend)) {
          debugPrint('📸 Liveness returned null, falling back to standard front camera...');
          try {
            // in-app camera with the face frame and its reason (system camera if it cannot start)
            final XFile? photo = await FaceCaptureScreen.capture(rootNavigatorKey.currentContext ?? safeContext);
            if (photo != null) {
              capturedImageFile = File(photo.path);
              capturedImageBytes = await capturedImageFile!.readAsBytes();
              challengeCompleted = true;
              livenessCheckFailed = {
                'status': 'failed',
                'message': 'Liveness challenge was not completed, plain selfie used',
                'detected_at': DateTime.now().toIso8601String(),
              };
              break;
            }
          } catch (pickerErr) {
            debugPrint('Error in fallback camera picker: $pickerErr');
          }
        }
        if (!challengeCompleted) {
          return null;
        }
      }

      if (challengeCompleted) {
        break;
      }

      if (report == null) {
        return null;
      }

      // Mark as retry if this is not the first attempt
      if (reports.isNotEmpty) {
        isRetry = true;
      }

      // If we have all reports from the screen (including timeouts), use them
      if (allReportsFromScreen != null && allReportsFromScreen!.isNotEmpty) {
        // Add all reports from screen, marking them as retried if needed
        for (var screenReport in allReportsFromScreen!) {
          final reportWithRetry = LivenessChallengeReport(
            challenge: screenReport.challenge,
            startTime: screenReport.startTime,
            endTime: screenReport.endTime,
            success: screenReport.success,
            failureReason: screenReport.failureReason,
            wasRetried: isRetry || screenReport.wasRetried,
          );
          reports.add(reportWithRetry);
        }
        // Clear to avoid duplicates
        allReportsFromScreen = null;
      } else {
        // Fallback: add only the returned report
        final reportWithRetry = LivenessChallengeReport(
          challenge: report.challenge,
          startTime: report.startTime,
          endTime: report.endTime,
          success: report.success,
          failureReason: report.failureReason,
          wasRetried: isRetry,
        );
        reports.add(reportWithRetry);
      }

      if (report.success && capturedImageBytes != null) {
        challengeCompleted = true;
        try {
          capturedImageBytes = await _compressImageIfNeeded(
            capturedImageBytes!,
            'image/jpeg',
            'captured_face.jpg',
          );
          final tempDir = await getTemporaryDirectory();
          final fileName = 'captured_face_${DateTime.now().millisecondsSinceEpoch}.jpg';
          capturedImageFile = File(p.join(tempDir.path, fileName));
          await capturedImageFile!.writeAsBytes(capturedImageBytes!);
        } catch (e) {
          debugPrint('Error saving captured image: $e');
          _showWarning(
            context,
            en: 'Failed to save captured image. Please try again.',
            ar: 'فشل حفظ الصورة الملتقطة. يرجى المحاولة مرة أخرى.',
          );
          continue;
        }
      } else {
        final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');
        final challengeName = isArabic ? report.challengeNameAr : report.challengeName;
        final retry = await showDialog<bool>(
          context: context,
          useRootNavigator: true,
          builder: (dialogContext) => AlertDialog(
            title: Text('challenge_failed'.tr(), style: TextStyle(color: Color(AppColors.secondaryButton)),),
            content: Text('challenge_failed_would_you_like_to_try'.tr(namedArgs: {'challenge_name': '$challengeName'})
                , style: TextStyle(color: Color(AppColors.black))
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text('assistantEnrollCancel'.tr(), style: Theme.of(context).textTheme.headlineSmall!.copyWith(color:Color(AppColors.secondaryButton))),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text('retry'.tr(), style: Theme.of(context).textTheme.headlineSmall!.copyWith(color:Color(AppColors.secondaryButton))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (retry != true) {
          if (AppConstants.fpScanSteps) await _showLivenessReport(context, reports);
          return null;
        }
      }
    }

    if (capturedImageFile == null || !await capturedImageFile!.exists()) {
      _showWarning(
        context,
        en: 'Failed to capture image. Please try again.',
        ar: 'فشل التقاط الصورة. يرجى المحاولة مرة أخرى.',
      );
      if (AppConstants.fpScanSteps) await _showLivenessReport(context, reports);
      return null;
    }

    bool processingDialogVisible = false;

    void showProcessingDialog() {
      if (!context.mounted || processingDialogVisible) return;
      processingDialogVisible = true;
      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (_) => const _FaceVerificationProgressDialog(),
        ).then((_) {
          processingDialogVisible = false;
        }),
      );
    }

    void hideProcessingDialog() {
      if (!context.mounted) return;
      try {
        if (processingDialogVisible && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
          processingDialogVisible = false;
        }
      } catch (e) {
        debugPrint('⚠️ Error hiding processing dialog: $e');
        processingDialogVisible = false;
      }
    }

    showProcessingDialog();
    double? similarity;
    List<double>? embedding;
    Map<String, dynamic>? faceProfileCheckFailed;

    try {
      final analysis = await _processFace(
        imageFile: capturedImageFile!,
        withEmbedding: true,
      );

      if (analysis == null || !analysis.hasFace || !analysis.hasEmbedding) {
        hideProcessingDialog();
        if (AppConstants.fingerprintFaceProfileVerificationEnabled) {
          if (AppConstants.fingerprintFaceProfileVerificationEnabledLevel ==
              FingerprintCheckLevel.mandatory) {
            _showWarning(
              context,
              en: 'Face not detected in captured image. Please try again.',
              ar: 'لم يتم اكتشاف الوجه في الصورة الملتقطة. يرجى المحاولة مرة أخرى.',
            );
            if (AppConstants.fpScanSteps) await _showLivenessReport(context, reports);
            await _deleteFileIfExists(capturedImageFile!);
            return null;
          } else {
            // the real reason; comparing an empty embedding would always report "similarity 0.000"
            faceProfileCheckFailed = {
              'status': 'failed',
              'message': switch (analysis?.error) {
                'multiple_faces' => 'More than one face was found in the selfie',
                'processing_error' || 'invalid_image' || 'invalid_bounds' =>
                  'The selfie could not be processed on the phone',
                _ => 'No face was found in the selfie',
              },
              'detected_at': DateTime.now().toIso8601String(),
            };
          }
        }
        embedding = List.filled(512, 0.0);
      } else {
        embedding = analysis.embedding!;
      }
      if (faceProfileCheckFailed != null) {
        similarity = null; // no usable face in the selfie: nothing to compare
      } else if (AppConstants.fingerprintFaceProfileVerificationEnabled) {
        similarity = await _calculateSimilarityWithProfile(safeContext, embedding);
      } else {
        similarity = 1.0;
      }
    } finally {
      hideProcessingDialog();
    }

    if (AppConstants.fingerprintFaceProfileVerificationEnabled) {
      if (faceProfileCheckFailed != null) {
        // optional check already failed on the selfie itself; keep that reason
      } else if (similarity == null) {
        debugPrint('Similarity calculation returned null');
        if (AppConstants.fingerprintFaceProfileVerificationEnabledLevel ==
            FingerprintCheckLevel.mandatory) {
          await _deleteFileIfExists(capturedImageFile!);
          _showWarning(
            safeContext,
            en: 'Face verification failed. Please try again.',
            ar: 'فشل التحقق من الوجه. يرجى المحاولة مرة أخرى.',
          );
          if (AppConstants.fpScanSteps) await _showLivenessReport(safeContext, reports);
          return null;
        } else {
          faceProfileCheckFailed = {
            'status': 'failed',
            'message': 'The profile photo could not be used for comparison (no profile photo, it could not be downloaded, or it has no clear front face)',
            'detected_at': DateTime.now().toIso8601String(),
          };
        }
      } else {
        debugPrint('Face verification similarity score: ' + similarity.toString());
        if (similarity < _minProfileSimilarity) {
          if (AppConstants.fingerprintFaceProfileVerificationEnabledLevel ==
              FingerprintCheckLevel.mandatory) {
            await _deleteFileIfExists(capturedImageFile!);
            _showWarning(
              safeContext,
              en:
              'Face verification failed. Please make sure the employee you are registering is standing in front of the camera.',
              ar: 'لم يتم قبول التحقق من الوجه. تأكد أن الموظف صاحب البصمة واقف أمام الكاميرا.',
              details: {
                _localized(safeContext, en: 'Similarity', ar: 'التشابه'):
                similarity.toStringAsFixed(3),
                _localized(safeContext, en: 'Required', ar: 'المطلوب'):
                _minProfileSimilarity.toStringAsFixed(2),
              },
            );
            if (AppConstants.fpScanSteps) await _showLivenessReport(safeContext, reports);
            return null;
          } else {
            faceProfileCheckFailed = {
              'status': 'failed',
              'message':
                  'Face similarity score ${similarity.toStringAsFixed(3)} is below minimum ${_minProfileSimilarity.toStringAsFixed(2)}',
              'similarity': similarity,
              'min_similarity': _minProfileSimilarity,
              'detected_at': DateTime.now().toIso8601String(),
            };
          }
        }
      }
    }

    // نظهر رسالة "identity / face verification successful" فقط
    // لو اللّيفنس والتطابق مع صورة البروفايل مفعّلين معاً ونجح الفحص
    if (AppConstants.fingerprintLivenessChallengesEnabled &&
        AppConstants.fingerprintFaceProfileVerificationEnabled &&
        faceProfileCheckFailed == null) {
      AlertsService.success(
        context: context,
        title: AppStrings.success.tr(),
        message: AppStrings.faceVerificationSuccess.tr(),
      );
    }

    final imageMap = {
      'image': capturedImageFile!.path,
      'fileName': p.basename(capturedImageFile!.path),
      'bytes': capturedImageBytes!,
    };

    // Create noteReport from reports
    final noteReport = _createNoteReport(reports);
    if (faceProfileCheckFailed != null || livenessCheckFailed != null) {
      final existingFailed = (noteReport['security_checks_failed'] as Map<String, dynamic>?) ?? {};
      noteReport['security_checks_failed'] = {
        ...existingFailed,
        if (faceProfileCheckFailed != null)
          'fingerprint_face_profile_verification_enabled': faceProfileCheckFailed,
        if (livenessCheckFailed != null)
          'fingerprint_liveness_challenges_enabled': livenessCheckFailed,
      };
    }

    // Print noteReport for debugging
    debugPrint('noteReport is ---> ${jsonEncode(noteReport)}');

    return _CapturedFaceData(
      imageMap: imageMap,
      file: capturedImageFile!,
      embedding: embedding!,
      bytes: capturedImageBytes!,
      noteReport: noteReport,
      livenessReports: reports,
    );
  }

  static Future<List<Map<String, dynamic>>> convertFilesAndProcess(List<FilePickerResult> files) async {
    List<Map<String, dynamic>> processedFiles = [];

    // Check if the files list is not empty
    if (files.isNotEmpty) {
      for (var file in files) {
        // Loop over the files in each FilePickerResult
        for (var fileItem in file.files) {
          // Ensure the file has valid bytes
          if (fileItem.bytes != null) {
            // Lookup the MIME type based on the file's name
            String mimeType = lookupMimeType(fileItem.name) ?? 'application/octet-stream';

            // Compress image bytes to reduce cache size
            Uint8List bytesToStore = await _compressImageIfNeeded(
              fileItem.bytes!,
              mimeType,
              fileItem.name,
            );

            // Create a MultipartFile from the file's bytes
            var multipartFile = MultipartFile.fromBytes(
              bytesToStore,
              filename: fileItem.name,
              contentType: MediaType.parse(mimeType.startsWith('image/') ? 'image/jpeg' : mimeType),
            );

            // Add the file metadata to the processedFiles list
            processedFiles.add({
              'fileName': fileItem.name,
              'path': fileItem.path,
              'bytes': base64Encode(bytesToStore),
            });

            print("Processed file: ${fileItem.name}, MIME Type: $mimeType");
          }
        }
      }
    } else {
      print("No files selected or files are empty.");
    }

    // Return the list of processed files for caching
    return processedFiles;
  }

  // Cache the fingerprint locally if no internet connection
  static Future<void> _cacheFingerprint({
    required String data,
    required String type,
    List<FilePickerResult>? file,
    Map<String, dynamic>? noteReport,
  }) async {
    // Initialize the list if it is null
    if (AppConstants.fingerPrints == null) {
      AppConstants.fingerPrints = [];
    }
    final fingerprintEntry = {
      'type': type,
      'data': data,
      'finger_day': DateFormat('yyyy-MM-dd HH:mm:ss' , "en").format(DateTime.now()),
    };

    // Add noteReport if provided
    if (noteReport != null) {
      fingerprintEntry['note'] = jsonEncode(noteReport);
    }

    // Handle file serialization
    if (file != null && file.isNotEmpty) {
      final List<Map<String, dynamic>> serializedFiless = [];

      for (var fileResult in file) {
        for (var platformFile in fileResult.files) {
          Uint8List? bytes = platformFile.bytes;
          if (bytes != null) {
            final mime = lookupMimeType(platformFile.name) ?? 'application/octet-stream';
            bytes = await _compressImageIfNeeded(bytes, mime, platformFile.name);
          }
          serializedFiless.add({
            'fileName': platformFile.name,
            'path': platformFile.path,
            'bytes': bytes != null ? base64Encode(bytes) : null,
          });
        }
      }

      // Add the serialized files under the 'types' key
      fingerprintEntry['files'] = jsonEncode(serializedFiless);
    }

    // Now save all fingerprint entries under the "types" key
    AppConstants.fingerPrints!.add(fingerprintEntry);

    // Store the list under a single key 'types'
    final Map<String, dynamic> dataToSave = {'fingerprints': AppConstants.fingerPrints};

    // Assuming you have a method to save data in shared preferences
    await _saveFingerprintsToPreferences();

    AppToast.showToast(
        msg: AppStrings.saveSucessFull.tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
    print("Cached fingerprints under 'types': ${AppConstants.fingerPrints}");
  }

  static Future<Map<String, dynamic>> filePickerResultToCacheableMap(FilePickerResult result) async {
    final file = result.files.first;
    Uint8List? bytes = file.bytes;
    if (bytes != null) {
      final mime = lookupMimeType(file.name) ?? 'application/octet-stream';
      bytes = await _compressImageIfNeeded(bytes, mime, file.name);
    }
    return {
      'fileName': file.name,
      'path': file.path,
      'bytes': bytes != null ? base64Encode(bytes) : null,
    };
  }
  // Save the list of fingerprints to shared preferences
  /// Failed optional face checks (liveness fallback / profile verification) from the captured face.
  /// Passed as failedSecurityChecks so they reach the backend suspicion_flags
  /// even when fingerprint_send_note_report_to_api is off.
  /// Web only: takes the plain face photo when the backend asks for one (no challenges in the browser).
  /// Only smartphone browsers with a camera can take it.
  /// Returns the files to upload ([] when no photo is needed / optional photo skipped),
  /// or null when the fingerprint must stop because the mandatory photo wasn't taken.
  static Future<List<FilePickerResult>?> _captureWebFingerprintPhoto(BuildContext context) async {
    if (!WebFingerprintCapabilities.imageEnabled) return const [];
    final bool canTakePhoto = WebFingerprintCapabilities.isPhone(context) &&
        await WebFingerprintCapabilities.hasCamera();
    if (canTakePhoto) {
      final FilePickerResult? photo = await WebFingerprintCapabilities.takePhoto();
      if (photo != null) return [photo];
    }
    if (WebFingerprintCapabilities.imageMandatory) {
      final warningContext = rootNavigatorKey.currentContext ?? context;
      if (warningContext.mounted) {
        _showWarning(
          warningContext,
          en: 'A photo of your face is required to add this fingerprint.',
          ar: 'صورة وجهك مطلوبة لإضافة هذه البصمة.',
        );
      }
      return null;
    }
    return const [];
  }

  /// Web only: face checks the browser can't run are reported to the backend as failed,
  /// and the face image only when the photo wasn't taken.
  static Map<String, dynamic>? _webFailedChecks({required bool photoTaken}) {
    final now = DateTime.now().toIso8601String();
    final notRunOnWeb = {
      'status': 'failed',
      'message': 'Not run on web (browser)',
      'detected_at': now,
    };
    final failed = <String, dynamic>{
      if (AppConstants.fingerprintLivenessChallengesEnabled)
        'fingerprint_liveness_challenges_enabled': notRunOnWeb,
      if (AppConstants.fingerprintFaceProfileVerificationEnabled)
        'fingerprint_face_profile_verification_enabled': notRunOnWeb,
      if (AppConstants.fingerprintUploadFaceImageToBackend && !photoTaken)
        'fingerprint_upload_face_image_to_backend': {
          'status': 'failed',
          'message': 'Face photo was not taken on web',
          'detected_at': now,
        },
    };
    return failed.isEmpty ? null : failed;
  }

  static Map<String, dynamic>? _faceFailedChecks(_CapturedFaceData? capturedFace) {
    // Face step was on but nothing captured (camera permission denied / cancelled) => flag each enabled face key
    if (capturedFace == null && AppConstants.showFaceVerifyForFingerprint) {
      final notCaptured = {
        'status': 'failed',
        'message': 'Face was not captured (camera permission denied or cancelled)',
        'detected_at': DateTime.now().toIso8601String(),
      };
      return {
        if (AppConstants.fingerprintLivenessChallengesEnabled) 'fingerprint_liveness_challenges_enabled': notCaptured,
        if (AppConstants.fingerprintFaceProfileVerificationEnabled) 'fingerprint_face_profile_verification_enabled': notCaptured,
        if (AppConstants.fingerprintUploadFaceImageToBackend) 'fingerprint_upload_face_image_to_backend': notCaptured,
      };
    }
    final failed = capturedFace?.noteReport?['security_checks_failed'];
    return failed is Map ? Map<String, dynamic>.from(failed) : null;
  }

  static Future<void> _saveFingerprintsToPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Ensure AppConstants.fingerPrints is not null
      if (AppConstants.fingerPrints == null) {
        AppConstants.fingerPrints = [];
      }

      // Convert the list of fingerprints to a JSON string
      final String jsonString = jsonEncode(AppConstants.fingerPrints);

      // Save the JSON string in shared preferences
      await prefs.setString('fingerPrints', jsonString);
      print("Fingerprints saved to preferences!");
    } catch (e) {
      debugPrint('⚠️ Error saving fingerprints to preferences: $e');
    }
  }
  // Adding Fingerprint using NFC
  static Future<void> addFingerprintUsingNFC(
      {required BuildContext context}) async {
    try {
      AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks();
      final safeContext = rootNavigatorKey.currentContext ?? context;
      final bool showFaceVerify = AppConstants.showFaceVerifyForFingerprint;
      final bool uploadFaceImage = AppConstants.fingerprintUploadFaceImageToBackend;

      _CapturedFaceData? capturedFace;
      if (showFaceVerify) {
        try {
          capturedFace = await captureEmployeeFaceAndVerify(safeContext);
        } catch (e) {
          debugPrint('⚠️ Face capture failed in NFC: $e');
          if (AppConstants.faceCaptureMandatory) {
            if (safeContext.mounted) {
              AlertsService.error(
                context: safeContext,
                title: AppStrings.failed.tr(),
                message: AppErrorReporter.safeMessage(e),
              );
            }
            return;
          }
          capturedFace = null;
        }
        if (capturedFace == null &&
            AppConstants.faceCaptureMandatory) {
          return;
        }
      }

      final List<FilePickerResult> faceFiles =
      uploadFaceImage && capturedFace != null
          ? capturedFace.asFilePickerResults
          : <FilePickerResult>[];
      // Check if the device supports NFC
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        AlertsService.error(
            context: context,
            message: 'NFC is not supported or enabled on this device!',
            title: AppStrings.failed.tr());
        return;
      }
      AlertsService.info(
          context: context,
          message: 'Please attach the device to the NFC chip',
          title: 'NFC');
      // Start NFC session
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          // Extract the UID, card content, and tag type
          final Map<dynamic, dynamic> tagData = tag.data as Map<dynamic, dynamic>;
          String uid = tagData['id']?.toString() ?? '0';
          String cardContent =
              '0'; // Placeholder, customize as per your card type
          String tagType = tagData['type']?.toString() ?? '0';

          // Combine the UID, card content, and tag type
          String nfcData = '$uid-$cardContent-$tagType';

          // Stop the session
          NfcManager.instance.stopSession();

          try {
            // Send the combined data to the server
            final result = await FingerprintService.addNFCFingerprint(
                context: context,
                data: nfcData,
                files: faceFiles,
                                noteReport: AppConstants.fingerprintSendNoteReportToApi ? (capturedFace?.noteReport ?? {}) : null,
                                failedSecurityChecks: _faceFailedChecks(capturedFace));

            // Handle the server response
            if (result.success) {
              if (AppConstants.fpScanSteps && context.mounted) {
                await _showScanStepsSuccessDialog(context,
                    capturedFace: capturedFace, fingerprintType: 'NFC');
              }
              AlertsService.success(
                  context: context,
                  message: result.message ?? AppStrings.saveSucessFull.tr(),
                  title: AppStrings.success.tr());
              return;
            } else {
              if (await showFingerprintRejection(result)) return;
              AlertsService.error(
                  context: context,
                  message: result.message ?? AppStrings.noInternetConnection.tr(),
                  title: AppStrings.failed.tr());
              return;
            }
          } catch (e) {
            AlertsService.error(
              context: context,
              message: AppErrorReporter.safeMessage(e),
              title: AppStrings.failed.tr(),
            );
          } finally {
            if (capturedFace != null) {
              await _deleteFileIfExists(capturedFace.file);
            }
          }
        },
      );
    } catch (e) {
      debugPrint('Error Adding NFC Fingerprint: $e');
      AlertsService.error(
          context: context,
          message: 'Error Happened! Please try later!',
          title: AppStrings.failed.tr());
      return;
    }
  }

  static Future<void> addFingerprintUsingBluetooth({required BuildContext context,}) async {
    debugPrint("📱 Starting Bluetooth fingerprint process...");
    try {
      AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks();
      final safeContext = rootNavigatorKey.currentContext ?? context;
      if (!safeContext.mounted) {
        debugPrint("❌ Context not mounted in addFingerprintUsingBluetooth");
        return;
      }
      final bool uploadFaceImage = AppConstants.fingerprintUploadFaceImageToBackend;

      _CapturedFaceData? capturedFace;
      DateTime? qrScanSuccessTime;
      final bool showFaceVerify = AppConstants.showFaceVerifyForFingerprint;

      if (showFaceVerify) {
        debugPrint("📱 Starting face verification for Bluetooth fingerprint...");
        try {
          capturedFace = await captureEmployeeFaceAndVerify(safeContext);
        } catch (e) {
          debugPrint('⚠️ Face capture failed in Bluetooth: $e');
          if (AppConstants.faceCaptureMandatory) {
            if (safeContext.mounted) {
              AlertsService.error(
                context: safeContext,
                title: AppStrings.failed.tr(),
                message: AppErrorReporter.safeMessage(e),
              );
            }
            return;
          }
          capturedFace = null;
        }
        if (capturedFace == null &&
            AppConstants.faceCaptureMandatory) {
          return;
        }
      }
      final List<FilePickerResult> uploadFaceFiles =
      uploadFaceImage && capturedFace != null
          ? capturedFace.asFilePickerResults
          : <FilePickerResult>[];

      // Uncomment this if photo upload is mandatory
      // if (fingerprintMustUploadImage == true) {
      //   empPhoto = await FileAndImagePickerService.pickImageWithFilePicker();
      //   if (empPhoto == null || empPhoto.files.first.bytes == null) {
      //     AlertsService.error(
      //       context: context,
      //       message: 'Please Take Photo Before Adding Fingerprint',
      //       title: 'Photo Required!',
      //     );
      //     return;
      //   }
      // }

      // Request necessary permissions (Android only)
      if (Platform.isAndroid) {
        var scanStatus = await Permission.bluetoothScan.status;
        var connectStatus = await Permission.bluetoothConnect.status;
        var locationStatus = await Permission.locationWhenInUse.status;

        if (!scanStatus.isGranted) scanStatus = await Permission.bluetoothScan.request();
        if (!connectStatus.isGranted) connectStatus = await Permission.bluetoothConnect.request();
        if (!locationStatus.isGranted) locationStatus = await Permission.locationWhenInUse.request();

        // without these the scan silently returns nothing (Android 12+: Nearby devices; Android 11 and older: location)
        if (!scanStatus.isGranted || !connectStatus.isGranted || !locationStatus.isGranted) {
          AlertsService.error(
            context: context,
            message: 'bluetooth_permission_required'.tr(),
            title: AppStrings.cannotProceed.tr(),
          );
          if (scanStatus.isPermanentlyDenied || connectStatus.isPermanentlyDenied || locationStatus.isPermanentlyDenied) {
            await openAppSettings();
          }
          return;
        }
        // Android 11 and older return no Bluetooth results while the location service is off
        if (!await Geolocator.isLocationServiceEnabled()) {
          AlertsService.warning(
            context: context,
            message: 'bluetooth_location_service_off'.tr(),
            title: AppStrings.warning.tr(),
          );
        }
      }
      // Check Bluetooth adapter state
      BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        AlertsService.info(
          context: context,
          message: AppStrings.bluetoothIsOffPleaseEnableItToContinue.tr(),
          title: AppStrings.bluetoothRequired.tr(),
        );

        // Optionally: open Bluetooth settings
        // await AppSettings.openBluetoothSettings();

        // Wait for user to enable Bluetooth (max 15 seconds)
        BluetoothAdapterState newState;
        try {
          newState = await FlutterBluePlus.adapterState
              .where((state) => state == BluetoothAdapterState.on)
              .first
              .timeout(const Duration(seconds: 15));
        } catch (_) {
          newState = BluetoothAdapterState.off;
        }

        if (newState != BluetoothAdapterState.on) {
          AlertsService.error(
            context: context,
            message: AppStrings.bluetoothWasNotEnabledInTime.tr(),
            title: AppStrings.cannotProceed.tr(),
          );
          return;
        }
      }

      // ✅ Two scans feed one list:
      //  - BLE (all platforms): beacons and devices that advertise a name / maker
      //  - classic discovery (Android only, iOS does not allow it): the devices the phone's Bluetooth settings list
      final devices = ValueNotifier<Map<String, _BtDevice>>({});
      final bleScanning = ValueNotifier<bool>(true);
      final classicScanning = ValueNotifier<bool>(Platform.isAndroid);

      void addDevice(_BtDevice d) {
        final current = devices.value[d.id];
        // the same device can come from both scans: keep the named entry and the stronger signal
        final merged = current == null
            ? d
            : _BtDevice(
                id: d.id,
                name: current.name.isNotEmpty && !current.isGeneric ? current.name : d.name,
                isGeneric: current.isGeneric && d.isGeneric,
                rssi: (d.rssi ?? -999) > (current.rssi ?? -999) ? d.rssi : current.rssi,
                isBeacon: current.isBeacon || d.isBeacon,
                majorClass: d.majorClass ?? current.majorClass,
              );
        devices.value = {...devices.value, d.id: merged};
      }

      String getDeviceName(ScanResult r) {
        try {
          if (r.advertisementData.advName.isNotEmpty) return r.advertisementData.advName;
        } catch (_) {}
        try {
          if (r.device.platformName.isNotEmpty) return r.device.platformName;
        } catch (_) {}
        return '';
      }

      // Most devices advertise no name: recognise beacons (what branches use) and the maker from the advertisement
      bool isBeacon(ScanResult r) {
        final apple = r.advertisementData.manufacturerData[0x004C];
        final iBeacon = apple != null && apple.length >= 2 && apple[0] == 0x02 && apple[1] == 0x15;
        final eddystone = r.advertisementData.serviceUuids.any((u) => u.str.toLowerCase().contains('feaa'));
        return iBeacon || eddystone;
      }

      String describeDevice(ScanResult r) {
        final name = getDeviceName(r);
        if (name.isNotEmpty) return name;
        final apple = r.advertisementData.manufacturerData[0x004C];
        if (apple != null && apple.length >= 2 && apple[0] == 0x02 && apple[1] == 0x15) return 'iBeacon';
        if (r.advertisementData.serviceUuids.any((u) => u.str.toLowerCase().contains('feaa'))) return 'Eddystone beacon';
        const makers = {
          0x004C: 'Apple', 0x0075: 'Samsung', 0x0006: 'Microsoft', 0x00E0: 'Google', 0x038F: 'Xiaomi',
          0x027D: 'Huawei', 0x0157: 'Huami', 0x0059: 'Nordic', 0x000D: 'Texas Instruments', 0x0171: 'Amazon',
          0x0087: 'Garmin', 0x00D2: 'Dialog', 0x0499: 'Ruuvi', 0x015D: 'Estimote', 0x0118: 'Radius Networks',
        };
        for (final id in r.advertisementData.manufacturerData.keys) {
          final maker = makers[id];
          if (maker != null) return '${'bluetooth_device_by'.tr()} $maker';
        }
        return '';
      }


      StreamSubscription<List<ScanResult>>? bleSub;
      StreamSubscription<bool>? bleStateSub;
      StreamSubscription? classicSub;

      Future<void> startScans() async {
        bleScanning.value = true;
        bleSub ??= FlutterBluePlus.scanResults.listen((results) {
          for (final r in results) {
            final label = describeDevice(r);
            if (label.isEmpty) continue; // unnamed and unidentified (phones, watches, earbuds broadcasting BLE)
            addDevice(_BtDevice(
              id: r.device.remoteId.toString().toUpperCase(),
              name: label,
              isGeneric: getDeviceName(r).isEmpty, // "Device by Apple", "iBeacon"
              rssi: r.rssi,
              isBeacon: isBeacon(r),
            ));
          }
        });
        bleStateSub ??= FlutterBluePlus.isScanning.listen((v) => bleScanning.value = v);
        try {
          await FlutterBluePlus.startScan(timeout: const Duration(seconds: 25));
        } catch (e) {
          debugPrint('⚠️ Bluetooth scan failed: $e');
          bleScanning.value = false;
        }

        if (Platform.isAndroid) {
          classicScanning.value = true;
          await classicSub?.cancel();
          classicSub = const EventChannel('com.rightminddev.rmemp/bt_classic').receiveBroadcastStream().listen((event) {
            if (event is! Map) return;
            if (event['finished'] == true) {
              classicScanning.value = false;
              return;
            }
            final name = (event['name'] ?? '').toString().trim();
            final address = (event['address'] ?? '').toString().toUpperCase();
            if (name.isEmpty || address.isEmpty) return;
            addDevice(_BtDevice(
              id: address,
              name: name,
              rssi: event['rssi'] is int ? event['rssi'] as int : null,
              majorClass: event['majorClass'] is int && event['majorClass'] != -1 ? event['majorClass'] as int : null,
            ));
          }, onError: (e) {
            debugPrint('⚠️ Classic Bluetooth discovery failed: $e');
            classicScanning.value = false;
          });
        }
      }

      unawaited(startScans());

      IconData iconFor(_BtDevice d) {
        if (d.isBeacon) return Icons.cell_tower;
        switch (d.majorClass) {
          case 0x0400: return Icons.headphones; // audio / video
          case 0x0200: return Icons.smartphone; // phone
          case 0x0100: return Icons.computer; // computer
          case 0x0700: return Icons.watch; // wearable
          case 0x0500: return Icons.keyboard; // peripheral
        }
        return Icons.bluetooth;
      }

      // Show scanned devices
      final selectedDevice = await showModalBottomSheet<_BtDevice>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('bluetooth_scan_hint'.tr(),
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5)),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: Listenable.merge([bleScanning, classicScanning]),
                  builder: (context, _) => bleScanning.value || classicScanning.value
                      ? const LinearProgressIndicator(minHeight: 2)
                      : const SizedBox(height: 2),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([devices, bleScanning, classicScanning]),
                    builder: (context, _) {
                      final scanning = bleScanning.value || classicScanning.value;
                      int rank(_BtDevice d) => d.isBeacon ? 2 : (d.isGeneric ? 0 : 1);
                      final list = devices.value.values.toList()
                        ..sort((a, b) {
                          final byRank = rank(b) - rank(a);
                          return byRank != 0 ? byRank : (b.rssi ?? -999).compareTo(a.rssi ?? -999);
                        });

                      if (list.isEmpty) {
                        if (scanning) return Center(child: Text(AppStrings.scanningForDevices.tr()));
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bluetooth_disabled, size: 40, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text('bluetooth_no_devices_found'.tr(), textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: startScans,
                                  icon: const Icon(Icons.refresh),
                                  label: Text('bluetooth_scan_again'.tr()),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final device = list[index];
                          final rssi = device.rssi;
                          final sameName = list.where((d) => d.name == device.name).length > 1;
                          return ListTile(
                            leading: Icon(
                              iconFor(device),
                              color: device.isBeacon
                                  ? Colors.green
                                  : ((rssi ?? -999) >= -80 ? Colors.blue : Colors.grey),
                            ),
                            title: Text(device.name, style: const TextStyle(color: Colors.black)),
                            // the device ID is what the branch registers, so it is always shown
                            subtitle: Text(
                              [
                                if (rssi != null)
                                  '${'wifi_signal'.tr()}: ${rssi >= -60 ? 'wifi_signal_strong'.tr() : (rssi >= -80 ? 'wifi_signal_medium'.tr() : 'wifi_signal_weak'.tr())}',
                                if (sameName) 'bluetooth_same_name'.tr(),
                                device.id,
                              ].join(' • '),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            onTap: () => Navigator.pop(context, device),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
      // stop both scans whether a device was chosen or the sheet was closed
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}
      await bleSub?.cancel();
      await bleStateSub?.cancel();
      await classicSub?.cancel(); // cancelling the stream stops the classic discovery

      if (selectedDevice == null) return;
      var result;
      await customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            // customAlertDialogWithTwoButtons handles popping the dialog automatically.
          },
          onRightActionPressed: ()async{
            try {
              result = await FingerprintService.addBluetoothFingerprint(
                context: context,
                data: selectedDevice.id,
                files: uploadFaceFiles,
                                noteReport: AppConstants.fingerprintSendNoteReportToApi ? (capturedFace?.noteReport ?? {}) : null,
                failedSecurityChecks: _faceFailedChecks(capturedFace),
              );

              // ✅ Show result
              if (result != null && result.success) {
                if (AppConstants.fpScanSteps && context.mounted) {
                  await _showScanStepsSuccessDialog(context,
                      capturedFace: capturedFace, fingerprintType: 'Bluetooth');
                }
                AlertsService.success(
                  context: context,
                  message: result.message ?? AppStrings.saveSucessFull.tr(),
                  title: AppStrings.success.tr(),
                );
              } else {
                if (await showFingerprintRejection(result)) return;
                AlertsService.error(
                  context: context,
                  message: result?.message ?? AppStrings.noInternetConnection.tr(),
                  title: AppStrings.failed.tr(),
                );
              }
            } catch (e) {
              AlertsService.error(
                context: context,
                message: AppErrorReporter.safeMessage(e),
                title: AppStrings.failed.tr(),
              );
            } finally {
              if (capturedFace != null) {
                await _deleteFileIfExists(capturedFace.file);
              }
            }
          }
      );
    } catch (e) {
      debugPrint('Error Adding Bluetooth Fingerprint: $e');
      AlertsService.error(
        context: context,
        message: AppErrorReporter.safeMessage(e),
        title: AppStrings.failed.tr(),
      );
    }
  }

  static Future<bool> isWiFiEnabled() async {
    var connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.wifi);
  }
  // Adding Fingerprint Using Wifi
  static Future<void> addFingerprintUsingWiFi({required BuildContext context,}) async {
    try {
      AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks();
      final safeContext = rootNavigatorKey.currentContext ?? context;
      final bool uploadFaceImage = AppConstants.fingerprintUploadFaceImageToBackend;
      _CapturedFaceData? capturedFace;
      final bool showFaceVerify = AppConstants.showFaceVerifyForFingerprint;
      if (showFaceVerify) {
        debugPrint("📱 Starting face verification for WiFi fingerprint...");
        try {
          capturedFace = await captureEmployeeFaceAndVerify(safeContext);
        } catch (e) {
          debugPrint('⚠️ Face capture failed in WiFi: $e');
          if (AppConstants.faceCaptureMandatory) {
            if (safeContext.mounted) {
              AlertsService.error(
                context: safeContext,
                title: AppStrings.failed.tr(),
                message: AppErrorReporter.safeMessage(e),
              );
            }
            return;
          }
          capturedFace = null;
        }
        if (capturedFace == null &&
            AppConstants.faceCaptureMandatory) {
          return;
        }
      }
      final List<FilePickerResult> uploadFaceFiles =
      uploadFaceImage && capturedFace != null
          ? capturedFace.asFilePickerResults
          : <FilePickerResult>[];

      List<Map<String, String>> availableNetworks = [];

      try {
        final status = await WiFiScan.instance.canStartScan();
        if (status == CanStartScan.yes) {
          await WiFiScan.instance.startScan();
        } else {
          debugPrint('⚠️ WiFi scan not started. Status: $status. Proceeding with cached/current results...');
        }
        final scanned = await WiFiScan.instance.getScannedResults();
        for (var net in scanned) {
          if (net.ssid.isNotEmpty) {
            final bssid = net.bssid.toLowerCase();
            // the same access point can be reported more than once in a scan
            if (availableNetworks.any((n) => n['bssid'] == bssid)) continue;
            availableNetworks.add({
              'ssid': net.ssid,
              'bssid': bssid,
              'band': net.frequency >= 5925 ? '6 GHz' : (net.frequency >= 4900 ? '5 GHz' : '2.4 GHz'),
              'level': '${net.level}',
            });
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error scanning WiFi: $e');
      }

      // Always try to add the currently connected network as a fallback (especially for iOS or throttled Android)
      try {
        final networkInfo = NetworkInfo();
        final String? wifiName = await networkInfo.getWifiName(); // SSID
        final String? wifiBSSID = await networkInfo.getWifiBSSID(); // MAC Address
        
        if (wifiBSSID != null && wifiBSSID.isNotEmpty && wifiBSSID != "02:00:00:00:00:00") {
          final formattedName = (wifiName != null && wifiName.isNotEmpty) ? wifiName.replaceAll('"', '') : 'Connected Network';
          // BSSIDs compared case-insensitively: the scan and the connection info can differ in letter case,
          // which used to list the connected network twice
          final connectedBssid = wifiBSSID.toLowerCase();
          final index = availableNetworks.indexWhere((net) => net['bssid'] == connectedBssid);
          if (index == -1) {
            availableNetworks.insert(0, {'ssid': formattedName, 'bssid': connectedBssid, 'connected': '1'});
          } else {
            availableNetworks[index]['connected'] = '1';
          }
        }
        // connected network first, then the strongest signal
        availableNetworks.sort((a, b) {
          final byConnected = (b['connected'] == '1' ? 1 : 0) - (a['connected'] == '1' ? 1 : 0);
          if (byConnected != 0) return byConnected;
          return (int.tryParse(b['level'] ?? '') ?? -200).compareTo(int.tryParse(a['level'] ?? '') ?? -200);
        });
      } catch (e) {
        debugPrint('⚠️ Error getting connected WiFi: $e');
      }

      if (availableNetworks.isEmpty) {
        AlertsService.warning(
          context: context,
          message: AppStrings.pleaseEnableWifiFirst.tr(),
          title: AppStrings.warning.tr(),
        );
        AppSettings.openAppSettings(type: AppSettingsType.wifi);
        return;
      }

      // Show available Wi-Fi networks in a popup or sheet
      final selectedNetwork = await showModalBottomSheet<Map<String, String>>(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: availableNetworks.length,
            itemBuilder: (context, index) {
              final network = availableNetworks[index];
              // same name on several access points (2.4 / 5 GHz bands, extenders): show what tells them apart
              final sameName = availableNetworks.where((n) => n['ssid'] == network['ssid']).length > 1;
              final level = int.tryParse(network['level'] ?? '');
              final details = [
                if (network['connected'] == '1') 'wifi_connected'.tr(),
                if (network['band'] != null) network['band']!,
                if (level != null) '${'wifi_signal'.tr()}: ${level >= -60 ? 'wifi_signal_strong'.tr() : (level >= -75 ? 'wifi_signal_medium'.tr() : 'wifi_signal_weak'.tr())}',
                if (sameName) network['bssid']!.toUpperCase(),
              ];
              return ListTile(
                leading: Icon(
                  level == null || level >= -60 ? Icons.wifi : (level >= -75 ? Icons.wifi_2_bar : Icons.wifi_1_bar),
                  color: network['connected'] == '1' ? Colors.green : null,
                ),
                title: Text(network['ssid'] ?? AppStrings.unknownDevice.tr()),
                subtitle: details.isEmpty ? null : Text(details.join(' • ')),
                onTap: () => Navigator.pop(context, network),
              );
            },
          );
        },
      );

      if (selectedNetwork == null) return;

      // Prepare the data to send to the server
      final wifiData = {'mac_address': selectedNetwork['bssid']};
      print( "mac_address -> ${selectedNetwork['bssid']}");
      var result;
      await customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            // customAlertDialogWithTwoButtons handles popping the dialog automatically.
          },
          onRightActionPressed: ()async{
            try {
              result = await FingerprintService.addWifiFingerprint(
                  context: context,
                  data: selectedNetwork['bssid'].toString(),
                  files:  uploadFaceFiles,
                                  noteReport: AppConstants.fingerprintSendNoteReportToApi ? (capturedFace?.noteReport ?? {}) : null,
                                  failedSecurityChecks: _faceFailedChecks(capturedFace));

              // Handle the server response
              if (result != null && result.success) {
                if (AppConstants.fpScanSteps && context.mounted) {
                  await _showScanStepsSuccessDialog(context,
                      capturedFace: capturedFace, fingerprintType: 'Wi-Fi');
                }
                AlertsService.success(
                  context: context,
                  message: result.message ?? (result.data != null && result.data is Map ? result.data['message'] : null) ?? AppStrings.saveSucessFull.tr(),
                  title: AppStrings.success.tr(),
                );
                return;
              }
              else {
                if (await showFingerprintRejection(result)) return;
                AlertsService.error(
                  context: context,
                  message: result?.message ?? (result?.data != null && result?.data is Map ? result.data['message'] : null) ?? AppStrings.noInternetConnection.tr(),
                  title: AppStrings.failed.tr(),
                );
                return;
              }
            } catch (e) {
              AlertsService.error(
                context: context,
                message: AppErrorReporter.safeMessage(e),
                title: AppStrings.failed.tr(),
              );
            } finally {
              if (capturedFace != null) {
                await _deleteFileIfExists(capturedFace.file);
              }
            }
          }
      );

    } catch (e) {
      debugPrint('Error Adding Wi-Fi Fingerprint: $e');
      AlertsService.error(
        context: context,
        message: AppErrorReporter.safeMessage(e),
        title: AppStrings.failed.tr(),
      );
      return;
    }
  }
  static double? lat;
  static double? long;

  /// Why the last [getCurrentLocation] call failed (null when it succeeded).
  static _LocationFailure? _lastLocationFailure;

  /// Reads the current position into the "lat" / "long" cache.
  /// Returns false when it couldn't (reason in [_lastLocationFailure]).
  static Future<bool> getCurrentLocation(context) async {
    bool serviceEnabled;
    LocationPermission permission;
    _lastLocationFailure = null;

    // Web: the browser refuses the location on plain http without showing the prompt
    if ((kIsWeb || PlatformIs.web) && !WebFingerprintCapabilities.isSecurePage) {
      print('❌ [Web] Location needs https — page is not a secure context');
      _lastLocationFailure = _LocationFailure.insecurePage;
      return false;
    }

    try {
      // تأكد إن خدمة الموقع مفعلة
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ خدمة الموقع غير مفعلة');
        _lastLocationFailure = _LocationFailure.serviceDisabled;
        return false;
      }

      // تحقق من الصلاحيات (on web requestPermission shows the browser prompt)
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ صلاحيات الموقع مرفوضة');
          _lastLocationFailure = _LocationFailure.denied;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ الصلاحيات مرفوضة دائمًا');
        _lastLocationFailure = _LocationFailure.deniedForever;
        return false;
      }
    } catch (e) {
      // Web: geolocator throws when the user blocks the prompt
      print('❌ Location permission check failed: $e');
      _lastLocationFailure = _LocationFailure.denied;
      return false;
    }

    try {
      // الحصول على الإحداثيات (مع حد أقصى ٢٥ ثانية عشان ما يعلقش لو الإشارة ضعيفة)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 25),
      );

      double lat = position.latitude;
      double long = position.longitude;
      print('📍 Latitude: $lat, Longitude: $long');
      CacheHelper.setString(key: "lat", value: lat.toString());
      CacheHelper.setString(key: "long", value: long.toString());
      return true;
    } catch (e) {
      print('❌ حصل خطأ أثناء تحديد الموقع: $e');
      _lastLocationFailure = _LocationFailure.unavailable;
      return false;
    }
  }

  /// Web only: tells the user why the location couldn't be read (the punch is stopped).
  static void _showWebLocationError(BuildContext context, _LocationFailure? failure) {
    switch (failure) {
      case _LocationFailure.insecurePage:
        _showWarning(context,
            en: 'The browser only allows location on a secure (https) page. Open the app using its https link and try again.',
            ar: 'المتصفح لا يسمح بتحديد الموقع إلا على رابط آمن (https). افتح التطبيق من رابط https وحاول مرة أخرى.');
        break;
      case _LocationFailure.serviceDisabled:
        _showWarning(context,
            en: 'Location is turned off on this device. Turn it on and try again.',
            ar: 'خدمة الموقع مغلقة على هذا الجهاز. فعّلها وحاول مرة أخرى.');
        break;
      case _LocationFailure.denied:
      case _LocationFailure.deniedForever:
        _showWarning(context,
            en: 'Location permission is blocked for this site. Allow location from the browser\'s site settings (the icon next to the address), then try again.',
            ar: 'صلاحية الموقع محظورة لهذا الموقع. اسمح بالموقع من إعدادات الموقع في المتصفح (الأيقونة بجانب العنوان) ثم حاول مرة أخرى.');
        break;
      case _LocationFailure.unavailable:
      case null:
        _showWarning(context,
            en: 'Couldn\'t get your current location. Check that location is on and try again.',
            ar: 'تعذر تحديد موقعك الحالي. تأكد من تفعيل الموقع وحاول مرة أخرى.');
        break;
    }
  }
  // Add Fingerprint Using GPS
  static Future<void> addFingerprintUsingGPS({required BuildContext context,}) async {
    debugPrint("📍 Starting GPS fingerprint process...");
    AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks();
    final safeContext = rootNavigatorKey.currentContext ?? context;
    OverlayEntry? loadingOverlay;
    try {
      if (!safeContext.mounted) {
        debugPrint("❌ Context not mounted in addFingerprintUsingGPS");
        return;
      }
      // لودينج في نص الشاشة عبر overlay الـ Navigator (Overlay.of قد يفشل مع go_router)
      final overlayContext = rootNavigatorKey.currentContext ?? safeContext;
      if (overlayContext.mounted) {
        loadingOverlay = OverlayEntry(
          builder: (ctx) => Material(
            color: Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.gettingCurrentLocationPleaseWait.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(ctx).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        final overlay = Navigator.of(overlayContext).overlay;
        if (overlay != null) {
          overlay.insert(loadingOverlay!);
        } else {
          loadingOverlay = null;
        }
      }
      debugPrint("📍 Getting current location...");
      final bool locationOk = await getCurrentLocation(safeContext);
      debugPrint(locationOk ? "📍 Location obtained" : "❌ Location not obtained: $_lastLocationFailure");
      // إخفاء اللودينج
      if (loadingOverlay != null) {
        try {
          loadingOverlay!.remove();
        } catch (_) {}
        loadingOverlay = null;
      }
      // Web: never send a GPS punch without a real location (it would go out as 0,0 / a stale one)
      if (!locationOk && (kIsWeb || PlatformIs.web)) {
        final warningContext = rootNavigatorKey.currentContext ?? safeContext;
        if (warningContext.mounted) _showWebLocationError(warningContext, _lastLocationFailure);
        return;
      }
      final bool uploadFaceImage = AppConstants.fingerprintUploadFaceImageToBackend;
      _CapturedFaceData? capturedFace;
      
      // Face verification is not supported on web, so we force it to false
      final bool showFaceVerify = (kIsWeb || PlatformIs.web) 
          ? false 
          : AppConstants.showFaceVerifyForFingerprint;

      Map<String, dynamic>? webSkipNote;
      List<FilePickerResult>? webPhotoFiles;
      if (kIsWeb || PlatformIs.web) {
        // Web: no liveness / profile challenges; only the plain photo when the backend asks for it.
        webPhotoFiles = await _captureWebFingerprintPhoto(safeContext);
        if (webPhotoFiles == null) return; // mandatory photo not taken
        if (AppConstants.showFaceVerifyForFingerprint) {
          webSkipNote = {
            'face_verification_skipped': {
              'reason': 'Web: face challenges are not run in the browser',
              'photo_taken': webPhotoFiles.isNotEmpty,
              'skipped_at': DateTime.now().toIso8601String(),
            }
          };
        }
      }
          
      if (showFaceVerify) {
        debugPrint("📍 Starting face verification for GPS fingerprint...");
        try {
          capturedFace = await captureEmployeeFaceAndVerify(safeContext);
        } catch (e) {
          debugPrint('⚠️ Face capture failed in GPS: $e');
          if (AppConstants.faceCaptureMandatory) {
            if (safeContext.mounted) {
              AlertsService.error(
                context: safeContext,
                title: AppStrings.failed.tr(),
                message: AppErrorReporter.safeMessage(e),
              );
            }
            return;
          }
          capturedFace = null;
        }
        if (capturedFace == null &&
            AppConstants.faceCaptureMandatory) {
          return;
        }
      }
      final List<FilePickerResult> uploadFaceFiles = webPhotoFiles ??
          (uploadFaceImage && capturedFace != null
              ? capturedFace.asFilePickerResults
              : <FilePickerResult>[]);
      var result;
      await customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            // customAlertDialogWithTwoButtons handles popping the dialog automatically.
          },
          onRightActionPressed: ()async{
            try {
              final effectiveNoteReport = <String, dynamic>{
                if (capturedFace?.noteReport != null) ...capturedFace!.noteReport!,
                if (webSkipNote != null) ...webSkipNote,
              };
              result = await FingerprintService.addGPSFingerprint(
                  context: context,
                  type: 'fp_navigate',
                  lat: double.tryParse(CacheHelper.getString('lat') ?? '0') ?? 0.0,
                  long: double.tryParse(CacheHelper.getString('long') ?? '0') ?? 0.0,
                  files: uploadFaceFiles,
                  noteReport: (AppConstants.fingerprintSendNoteReportToApi || webSkipNote != null)
                      ? effectiveNoteReport
                      : null,
                  failedSecurityChecks: webPhotoFiles != null
                      ? _webFailedChecks(photoTaken: webPhotoFiles.isNotEmpty)
                      : _faceFailedChecks(capturedFace));

              print("GPS DONE TWO");

              // Handle the server response
              if (result != null && result.success) {
                if (AppConstants.fpScanSteps && context.mounted) {
                  await _showScanStepsSuccessDialog(context,
                      capturedFace: capturedFace, fingerprintType: 'GPS');
                }
                AlertsService.success(
                    context: context,
                    message: result.message ?? (result.data != null && result.data is Map && result.data['message'] != null ? result.data['message'] : null) ?? AppStrings.saveSucessFull.tr(),
                    title: AppStrings.success.tr());
                return;
              }
              else {
                if (await showFingerprintRejection(result)) return;
                AlertsService.error(
                    context: context,
                    message: result?.message ?? (result?.data != null && result?.data is Map && result.data['message'] != null ? result.data['message'] : null) ?? AppStrings.noInternetConnection.tr(),
                    title: AppStrings.failed.tr());
                return;
              }
            } catch (e) {
              AlertsService.error(
                context: context,
                message: AppErrorReporter.safeMessage(e),
                title: AppStrings.failed.tr(),
              );
            } finally {
              if (capturedFace != null) {
                await _deleteFileIfExists(capturedFace.file);
              }
            }
          }
      );

    } catch (e) {
      debugPrint('Error Adding GPS Fingerprint: $e');
      if (loadingOverlay != null) {
        try {
          loadingOverlay!.remove();
        } catch (_) {}
      }
      if (context.mounted) {
        AlertsService.error(
            context: context,
            message: AppErrorReporter.safeMessage(e),
            title: AppStrings.failed.tr());
      }
      return;
    }
  }

  // Add Fingerprint Using QrCode
  static Future<void> addFingerprintUsingQrCode(
      {required BuildContext context}) async {
    debugPrint("📱 Starting QR Code fingerprint process...");
    try {
      AppConstants.updateFingerprintSecurityFromUsgFingerprintChecks();
      final safeContext = rootNavigatorKey.currentContext ?? context;
      if (!safeContext.mounted) {
        debugPrint("❌ Context not mounted in addFingerprintUsingQrCode");
        return;
      }
      final jsonString = CacheHelper.getString("US1");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        json.decode(jsonString) as Map<String, dynamic>;
      }
      final bool uploadFaceImage = AppConstants.fingerprintUploadFaceImageToBackend;

      _CapturedFaceData? capturedFace;
      DateTime? qrScanSuccessTime;
      final bool isOnline = await ConnectionsService.isOnline();
      // في كل أنواع البصمات الأخرى الكاميرا تفتح لو مفتاح الكاميرا مفعّل حتى في وضع الأوفلاين.
      // هنا كانت مربوطة بوجود إنترنت، فتم فصلها عن isOnline عشان QR يتصرف نفس التصرف.
      // Face verification is not supported on web (same as the GPS flow).
      final bool showFaceVerify = (kIsWeb || PlatformIs.web)
          ? false
          : AppConstants.showFaceVerifyForFingerprint;
      if (showFaceVerify) {
        debugPrint("📱 Starting face verification for QR Code fingerprint...");
        final faceContext = rootNavigatorKey.currentContext ?? context;
        try {
          capturedFace = await captureEmployeeFaceAndVerify(faceContext);
        } catch (e) {
          debugPrint('⚠️ Face capture failed in QR: $e');
          if (AppConstants.faceCaptureMandatory) {
            if (faceContext.mounted) {
              AlertsService.error(
                context: faceContext,
                title: AppStrings.failed.tr(),
                message: AppErrorReporter.safeMessage(e),
              );
            }
            return;
          }
          capturedFace = null;
        }
        if (capturedFace == null &&
            AppConstants.faceCaptureMandatory) {
          return;
        }
      }

      // Web: no face challenges; only the plain photo when the backend asks for it.
      List<FilePickerResult>? webPhotoFiles;
      if (kIsWeb || PlatformIs.web) {
        webPhotoFiles = await _captureWebFingerprintPhoto(safeContext);
        if (webPhotoFiles == null) return; // mandatory photo not taken
      }

      final qrContext = rootNavigatorKey.currentContext ?? context;
      final String? scanedQrCode =
      await _scanQrcodeToGetSecretKeyString(context: qrContext);
      if (scanedQrCode == null || scanedQrCode.isEmpty) {
        if (capturedFace != null) {
          await _deleteFileIfExists(capturedFace.file);
        }
        return;
      }
      // Save the exact time when QR scan succeeded
      qrScanSuccessTime = DateTime.now();

      final List<FilePickerResult> uploadFaceFiles = webPhotoFiles ??
          (uploadFaceImage && capturedFace != null
              ? capturedFace.asFilePickerResults
              : <FilePickerResult>[]);

      // if (uploadFaceImage &&
      //     (empPhoto == null || empPhoto.files.first.bytes == null)) {
      // uploadFaceFiles is already [] when capturedFace == null, no need to block here

      print("DONE FROM ONE");
      // Call Your Fingerprint Scanner API
      print("DONE FROM ONE");
      print("DONE FROM ONE");
      var result;
      await customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            // customAlertDialogWithTwoButtons handles popping the dialog automatically.
          },
          onRightActionPressed: ()async{
            // The "Yes" button shows its own spinner while this runs (like the GPS / WiFi / Bluetooth flows).
            try {
              result = await FingerprintService.addQRCodeFingerprint(
                  context: context,
                  data: scanedQrCode,
                  fingerDay: qrScanSuccessTime,
                  files: uploadFaceFiles,
                  noteReport: AppConstants.fingerprintSendNoteReportToApi ? (capturedFace?.noteReport ?? {}) : null,
                  failedSecurityChecks: webPhotoFiles != null
                      ? _webFailedChecks(photoTaken: webPhotoFiles.isNotEmpty)
                      : _faceFailedChecks(capturedFace));

              print("result status --> ${result?.data != null && result.data is Map ? result.data['status'] : result?.success}");
              if (result != null && result.success) {
                if (AppConstants.fpScanSteps && context.mounted) {
                  await _showScanStepsSuccessDialog(context,
                      capturedFace: capturedFace, fingerprintType: 'QR Code');
                }
                AlertsService.success(
                    context: context,
                    message: result.message ?? (result.data != null && result.data is Map && result.data['message'] != null ? result.data['message'] : null) ?? AppStrings.saveSucessFull.tr(),
                    title: AppStrings.success.tr());
                return;
              }
              else {
                if (await showFingerprintRejection(result)) return;
                AlertsService.error(
                    context: context,
                    message: result?.message ?? (result?.data != null && result?.data is Map && result.data['message'] != null ? result.data['message'] : null) ?? AppStrings.noInternetConnection.tr(),
                    title: AppStrings.failed.tr());
                return;
              }
            } catch (e) {
              AlertsService.error(
                context: context,
                message: AppErrorReporter.safeMessage(e),
                title: AppStrings.failed.tr(),
              );
            } finally {
              if (capturedFace != null) {
                await _deleteFileIfExists(capturedFace.file);
              }
            }
          }
      );

    } catch (e) {
      debugPrint(
          'Error Happeded While Adding Fingerprint Using Qrcode! Error :-> $e');
      AlertsService.error(
          context: context,
          message: AppErrorReporter.safeMessage(e),
          title: AppStrings.failed.tr());
    }
  }

  static Future<String?> _scanQrcodeToGetSecretKeyString(
      {required BuildContext context}) async {
    try {
      // Request camera permission (on web the browser asks when the scanner opens the camera)
      final bool cameraGranted = (kIsWeb || PlatformIs.web) ||
          (await permission_handler.Permission.camera.request()).isGranted;
      if (!cameraGranted) {
        // Use rootNavigatorKey.currentContext if context is not mounted
        final alertContext = rootNavigatorKey.currentContext ?? context;
        if (alertContext.mounted) {
          AlertsService.warning(
              context: alertContext,
              message: 'Camera permission is required to scan QR codes',
              title: AppStrings.warning.tr());
        }
        return null;
      }

      // Initialize a GlobalKey for the QRView widget
      final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
      // Use rootNavigatorKey.currentContext if context is not mounted
      final qrScannerContext = rootNavigatorKey.currentContext ?? context;
      if (!qrScannerContext.mounted) {
        debugPrint("❌ QR scanner context not mounted");
        return null;
      }
      debugPrint("📱 Opening QR scanner screen...");
      // Use a Navigator to push a full-screen scanner widget
      final result = await Navigator.of(qrScannerContext, rootNavigator: true).push<String?>(
        MaterialPageRoute(
          builder: (context) => const QRScannerView(),
        ),
      );
      debugPrint("📱 QR scanner returned: ${result != null ? 'result received' : 'null'}");
      // If scanning was successful, return the scanned text
      return result;
    } catch (e) {
      // Handle any errors, return null in case of an error
      debugPrint('Error scanning QR code: $e');
      // Use rootNavigatorKey.currentContext if context is not mounted
      final errorContext = rootNavigatorKey.currentContext ?? context;
      if (errorContext.mounted) {
        AlertsService.error(
            context: errorContext,
            message: 'Error Happeded! Please try later!',
            title: AppStrings.failed.tr());
      }
    }
  }
}

/// A device in the Bluetooth fingerprint list (from the BLE scan or the Android classic discovery)
class _BtDevice {
  const _BtDevice({
    required this.id,
    required this.name,
    this.isGeneric = false,
    this.rssi,
    this.isBeacon = false,
    this.majorClass,
  });

  /// MAC address (or iOS identifier) the branch registers
  final String id;
  final String name;

  /// name built from the advertisement ("iBeacon", "Device by Apple"), not broadcast by the device
  final bool isGeneric;
  final int? rssi;
  final bool isBeacon;

  /// classic Bluetooth major device class (phone, audio, computer...)
  final int? majorClass;
}

/// Why [MainFabServices.getCurrentLocation] couldn't read the position.
enum _LocationFailure { insecurePage, serviceDisabled, denied, deniedForever, unavailable }
