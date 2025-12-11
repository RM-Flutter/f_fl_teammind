import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show Rect;
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
import 'package:nfc_manager/nfc_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'
as permission_handler;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rmemp/common_modules_widgets/custom_alert_dialog_with_two_buttons.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/internet_check.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../platform/platform_is.dart';
import 'tflite_wrapper.dart';
import '../../constants/app_colors.dart';
import '../../general_services/alert_service/alerts.service.dart';
import '../../general_services/image_file_picker.service.dart';
import '../../general_services/settings.service.dart';
import '../../models/settings/general_settings.model.dart';
import '../../services/fingerprint_service.dart';
import 'widgets/qrcode_Scanner_view.widget.dart';
import 'widgets/liveness_challenge_camera.widget.dart';
import 'package:location/location.dart' as location_package;

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
  });

  final Map<String, dynamic> imageMap;
  final File file;
  final List<double> embedding;
  final Uint8List bytes;
  final Map<String, dynamic>? noteReport;

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
    final bool isArabic =
    context.locale.languageCode.toLowerCase().startsWith('ar');
    final String message =
    isArabic ? 'جارٍ التأكد من الفيديو...' : 'Verifying video...';

    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Color(AppColors.primary),
            borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
    print("FINGER IS ---> ${fingerprintMethod.toLowerCase().trim()}");
    switch (fingerprintMethod.toLowerCase().trim()) {
      case 'fp_scan':
        await addFingerprintUsingQrCode(context: context);
        return;
      case 'fp_navigate' || 'custom_fp_navigate':
        await addFingerprintUsingGPS(context: context);
      case 'fp_wifi':
        await addFingerprintUsingWiFi(context: context);
      case 'fp_bluetooth':
        await addFingerprintUsingBluetooth(context: context);
      case 'fp_nfc':
        await addFingerprintUsingNFC(context: context);
      case 'fp_machine':
      default:
        AlertsService.error(
            context: context,
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

      if (faces.length > 1) {
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
    status = await permission.request();
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

  static Future<bool> _showInstructionSheet(
      BuildContext context, {
        required String title,
        required String message,
        required String actionLabel,
        String? cancelLabel,
      }) async {
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final double bottomInset =
            MediaQuery.of(sheetContext).viewInsets.bottom;
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
                    ?.copyWith(fontWeight: FontWeight.w700, color: Color(AppColors.dark), fontSize: 18),
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
                    backgroundColor: MaterialStateProperty.all(Color(AppColors.dark)),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(actionLabel, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color:Colors.white),),
                ),
              ),
              if (cancelLabel != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: Text(cancelLabel, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color:Color(AppColors.dark)),),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
    return result ?? false;
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
    final jsonString = CacheHelper.getString("US1");
    if (jsonString == null || jsonString.isEmpty) {
      AlertsService.error(
        context: context,
        title: AppStrings.failed.tr(),
        message: AppStrings.faceVerificationFailure.tr(),
      );
      return null;
    }

    final Map<String, dynamic> cache =
    json.decode(jsonString) as Map<String, dynamic>;
    final String? photoUrl = cache['photo'] as String?;

    if (photoUrl == null || photoUrl.isEmpty) {
      AlertsService.error(
        context: context,
        title: AppStrings.failed.tr(),
        message: AppStrings.faceVerificationFailure.tr(),
      );
      return null;
    }

    if (!context.mounted) return null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Try to download image (will use cache if available)
      final profileImage = await downloadImage(photoUrl, useCache: true);
      
      if (profileImage == null) {
        // If download failed and no cache available, skip verification in offline mode
        final isConnected = await InternetConnectionChecker.createInstance().hasConnection.timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
        if (!isConnected) {
          debugPrint('⚠️ Offline mode: Skipping face verification');
          // Return a high similarity to allow proceeding in offline mode
          // Don't close dialog here, let finally block handle it
          return 1.0;
        } else {
          AlertsService.error(
            context: context,
            title: AppStrings.failed.tr(),
            message: AppStrings.faceVerificationFailure.tr(),
          );
          return null;
        }
      }

      final reference =
      await _processFace(imageFile: profileImage, withEmbedding: true);

      if (reference == null ||
          !reference.hasFace ||
          !reference.hasEmbedding ||
          !reference.isFrontal) {
        AlertsService.error(
          context: context,
          title: AppStrings.failed.tr(),
          message: AppStrings.faceVerificationFailure.tr(),
        );
        return null;
      }

      return _cosineSimilarity(candidateEmbedding, reference.embedding!);
    } catch (error) {
      debugPrint('⚠️ Error while verifying profile face: $error');
      
      // Check if offline and allow proceeding
      try {
        final isConnected = await InternetConnectionChecker.createInstance().hasConnection.timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
        if (!isConnected) {
          debugPrint('⚠️ Offline mode: Skipping face verification due to error');
          // Return a high similarity to allow proceeding in offline mode
          // Don't close dialog here, let finally block handle it
          return 1.0;
        }
      } catch (e) {
        debugPrint('⚠️ Error checking connection: $e');
      }
      
      AlertsService.error(
        context: context,
        title: AppStrings.failed.tr(),
        message: AppStrings.faceVerificationFailure.tr(),
      );
      return null;
    } finally {
      // Always close dialog in finally block
      try {
        if (context.mounted &&
            Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
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
    buffer.writeln(isArabic ? 'تقرير التحقق من الحياة:' : 'Liveness Verification Report:');
    buffer.writeln('');

    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      final challengeName = isArabic ? report.challengeNameAr : report.challengeName;
      final duration = report.duration.inSeconds;
      final status = report.success
          ? (isArabic ? 'نجح' : 'Success')
          : (isArabic ? 'فشل' : 'Failed');
      final retry = report.wasRetried ? (isArabic ? ' (تمت إعادة المحاولة)' : ' (Retried)') : '';

      buffer.writeln('${i + 1}. $challengeName: $status (${duration}s)$retry');
      if (report.failureReason != null) {
        buffer.writeln('   ${isArabic ? 'السبب:' : 'Reason:'} ${report.failureReason}');
      }
    }

    final totalTime = reports.fold<Duration>(
      Duration.zero,
      (sum, report) => sum + report.duration,
    );
    buffer.writeln('');
    buffer.writeln(isArabic
        ? 'الوقت الإجمالي: ${totalTime.inSeconds} ثانية'
        : 'Total Time: ${totalTime.inSeconds} seconds');

    final successfulChallenges = reports.where((r) => r.success).length;
    buffer.writeln(isArabic
        ? 'التحديات الناجحة: $successfulChallenges من ${reports.length}'
        : 'Successful Challenges: $successfulChallenges of ${reports.length}');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isArabic ? 'تقرير التحقق' : 'Verification Report', style: TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.w700),),
        content: SingleChildScrollView(
          child: Text(buffer.toString(), style: TextStyle(color: Color(AppColors.black), fontWeight: FontWeight.w500),),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(isArabic ? 'موافق' : 'OK'),
          ),
        ],
      ),
    );
  }

  static Future<_CapturedFaceData?> captureEmployeeFaceAndVerify(
      BuildContext context) async {
    if (PlatformIs.web) {
      AlertsService.error(
        context: context,
        title: AppStrings.failed.tr(),
        message: 'Face recognition is not supported on web platform',
      );
      return null;
    }
    await _loadModel();

    if (!context.mounted) return null;

    final bool introAccepted = await _showInstructionSheet(
      context,
      title: _localized(
        context,
        en: 'Face verification',
        ar: 'التحقق من الوجه',
      ),
      message: _localized(
        context,
        en:
        'You will be asked to perform a random challenge. Please follow the on-screen instructions.',
        ar:
        'سيُطلب منك تنفيذ تحدّي عشوائي. يرجى اتباع التعليمات المعروضة على الشاشة.',
      ),
      actionLabel: _localized(
        context,
        en: 'Start verification',
        ar: 'بدء التحقق',
      ),
      cancelLabel: _localized(
        context,
        en: 'Cancel',
        ar: 'إلغاء',
      ),
    );

    if (!introAccepted) {
      return null;
    }

    // Ensure camera permission before opening camera screen
    final hasPermission = await _ensureCameraPermission();
    if (!hasPermission) {
      _showWarning(
        context,
        en: 'Camera permission is required for face verification.',
        ar: 'إذن الكاميرا مطلوب للتحقق من الوجه.',
      );
      return null;
    }

    final List<LivenessChallengeReport> reports = [];
    Uint8List? capturedImageBytes;
    File? capturedImageFile;
    bool challengeCompleted = false;
    bool isRetry = false;

    List<LivenessChallengeReport>? allReportsFromScreen;
    
    while (!challengeCompleted) {
      final challenge = _getRandomChallenge();
      LivenessChallengeReport? report;
      try {
        report = await Navigator.of(context).push<LivenessChallengeReport>(
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
      } catch (e) {
        debugPrint('Error opening camera screen: $e');
        _showWarning(
          context,
          en: 'Failed to open camera. Please try again.',
          ar: 'فشل فتح الكاميرا. يرجى المحاولة مرة أخرى.',
        );
        return null;
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
          builder: (dialogContext) => AlertDialog(
            title: Text(isArabic ? 'فشل التحدي' : 'Challenge Failed', style: TextStyle(color: Color(AppColors.dark)),),
            content: Text(
              isArabic
                  ? 'فشل التحدي: $challengeName\n\nهل تريد المحاولة مرة أخرى؟'
                  : 'Challenge failed: $challengeName\n\nWould you like to try again?'
                , style: TextStyle(color: Color(AppColors.black))
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(isArabic ? 'إلغاء' : 'Cancel', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color:Color(AppColors.dark))),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(isArabic ? 'إعادة المحاولة' : 'Retry', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color:Color(AppColors.dark))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (retry != true) {
          // await _showLivenessReport(context, reports);
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
      await _showLivenessReport(context, reports);
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

    try {
      final analysis = await _processFace(
        imageFile: capturedImageFile!,
        withEmbedding: true,
      );

      if (analysis == null || !analysis.hasFace || !analysis.hasEmbedding) {
        hideProcessingDialog();
        _showWarning(
          context,
          en: 'Face not detected in captured image. Please try again.',
          ar: 'لم يتم اكتشاف الوجه في الصورة الملتقطة. يرجى المحاولة مرة أخرى.',
        );
        await _showLivenessReport(context, reports);
        await _deleteFileIfExists(capturedImageFile!);
        return null;
      }

      embedding = analysis.embedding!;
      similarity = await _calculateSimilarityWithProfile(context, embedding);
    } finally {
      hideProcessingDialog();
    }

    if (similarity == null) {
      debugPrint('Similarity calculation returned null');
      await _deleteFileIfExists(capturedImageFile!);
      _showWarning(
        context,
        en: 'Face verification failed. Please try again.',
        ar: 'فشل التحقق من الوجه. يرجى المحاولة مرة أخرى.',
      );
      await _showLivenessReport(context, reports);
      return null;
    }

    debugPrint('Face verification similarity score: ' + similarity.toString());

    if (similarity < _minProfileSimilarity) {
      await _deleteFileIfExists(capturedImageFile!);
      _showWarning(
        context,
        en:
        'Face verification failed. Please make sure the employee you are registering is standing in front of the camera.',
        ar: 'لم يتم قبول التحقق من الوجه. تأكد أن الموظف صاحب البصمة واقف أمام الكاميرا.',
        details: {
          _localized(context, en: 'Similarity', ar: 'التشابه'):
          similarity.toStringAsFixed(3),
          _localized(context, en: 'Required', ar: 'المطلوب'):
          _minProfileSimilarity.toStringAsFixed(2),
        },
      );
      await _showLivenessReport(context, reports);
      return null;
    }

    AlertsService.success(
      context: context,
      title: AppStrings.success.tr(),
      message: AppStrings.faceVerificationSuccess.tr(),
    );

    // await _showLivenessReport(context, reports);

    final imageMap = {
      'image': capturedImageFile!.path,
      'fileName': p.basename(capturedImageFile!.path),
      'bytes': capturedImageBytes!,
    };

    // Create noteReport from reports
    final noteReport = _createNoteReport(reports);
    
    // Print noteReport for debugging
    debugPrint('noteReport is ---> ${jsonEncode(noteReport)}');

    return _CapturedFaceData(
      imageMap: imageMap,
      file: capturedImageFile!,
      embedding: embedding!,
      bytes: capturedImageBytes!,
      noteReport: noteReport,
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

            // Create a MultipartFile from the file's bytes
            var multipartFile = MultipartFile.fromBytes(
              fileItem.bytes!, // File bytes
              filename: fileItem.name, // File name
              contentType: MediaType.parse(mimeType), // Mime type
            );

            // Add the file metadata to the processedFiles list
            processedFiles.add({
              'fileName': fileItem.name,
              'path': fileItem.path,
              'bytes': base64Encode(fileItem.bytes!), // Convert bytes to base64 for storage
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
          serializedFiless.add({
            'fileName': platformFile.name,
            'path': platformFile.path,
            'bytes': platformFile.bytes != null ? base64Encode(platformFile.bytes!) : null,
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

    Fluttertoast.showToast(
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

  static Map<String, dynamic> filePickerResultToCacheableMap(FilePickerResult result) {
    final file = result.files.first;
    return {
      'fileName': file.name,
      'path': file.path,
      'bytes': file.bytes != null ? base64Encode(file.bytes!) : null,
    };
  }
  // Save the list of fingerprints to shared preferences
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
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;

      final _CapturedFaceData? capturedFace =
      await captureEmployeeFaceAndVerify(context);
      if (capturedFace == null) {
        return;
      }

      final List<FilePickerResult> faceFiles =
      fingerprintMustUploadImage == true
          ? capturedFace.asFilePickerResults
          : <FilePickerResult>[];
      await _deleteFileIfExists(capturedFace.file);
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
        onDiscovered: (NfcTag tag) async {
          // Extract the UID, card content, and tag type
          String uid = tag.data['id']?.toString() ?? '0';
          String cardContent =
              '0'; // Placeholder, customize as per your card type
          String tagType = tag.data['type']?.toString() ?? '0';

          // Combine the UID, card content, and tag type
          String nfcData = '$uid-$cardContent-$tagType';

          // Stop the session
          NfcManager.instance.stopSession();

          // Show loading indicator immediately before sending
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              useRootNavigator: true,
              builder: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          }

          try {
            // Send the combined data to the server
            final result = await FingerprintService.addNFCFingerprint(
                context: context,
                data: nfcData,
                files: faceFiles,
                noteReport: capturedFace.noteReport);

            // Close loading indicator
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            // Handle the server response
            if (result.success) {
              AlertsService.success(
                  context: context,
                  message: result.message ?? AppStrings.saveSucessFull.tr(),
                  title: AppStrings.success.tr());
              return;
            } else {
              AlertsService.error(
                  context: context,
                  message: result.message ?? AppStrings.noInternetConnection.tr(),
                  title: AppStrings.failed.tr());
              return;
            }
          } catch (e) {
            // Close loading indicator on error
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            AlertsService.error(
              context: context,
              message: e.toString(),
              title: AppStrings.failed.tr(),
            );
          }
        },
        onError: (NfcError error) {
          AlertsService.error(
              context: context,
              message: 'Error during NFC session: ${error.message}',
              title: AppStrings.failed.tr());
          return NfcManager.instance.stopSession();
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
    try {
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;

      final _CapturedFaceData? capturedFace =
      await captureEmployeeFaceAndVerify(context);
      if (capturedFace == null) {
        return;
      }
      final List<FilePickerResult> uploadFaceFiles =
      fingerprintMustUploadImage == true
          ? capturedFace.asFilePickerResults
          : <FilePickerResult>[];
      await _deleteFileIfExists(capturedFace.file);

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

      if (!scanStatus.isGranted) await Permission.bluetoothScan.request();
      if (!connectStatus.isGranted) await Permission.bluetoothConnect.request();
      if (!locationStatus.isGranted) await Permission.locationWhenInUse.request();
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

      // ✅ Start scanning for Bluetooth devices
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 25));

      // Show scanned devices

      final selectedDevice = await showModalBottomSheet<ScanResult>(
        context: context,
        builder: (context) {
          return StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            builder: (context, snapshot) {
              final results = snapshot.data?.where((r) => r.device.name.isNotEmpty).toList() ?? [];

              if (results.isEmpty) {
                return  Center(child: Text('${AppStrings.scanningForDevices.tr()}'));
              }
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return ListTile(
                    title: Text(
                      result.device.name.isEmpty ? AppStrings.unknownDevice.tr() : result.device.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: ()async{
                      await FlutterBluePlus.stopScan();
                      Navigator.pop(context, result);
                    },
                  );
                },
              );
            },
          );
        },
      );

      if (selectedDevice == null) return;
      var result;
      customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            Navigator.pop(context);
          },
          onRightActionPressed: ()async{
            // Close confirmation dialog first
            try {
              if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            } catch (e) {
              debugPrint('Error closing confirmation dialog: $e');
            }
            
            // Show loading indicator immediately using post frame callback
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    useRootNavigator: true,
                    builder: (context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                }
              } catch (e) {
                debugPrint('Error showing loading dialog: $e');
              }
            });
            
            try {
              result = await FingerprintService.addBluetoothFingerprint(
                context: context,
                data: selectedDevice.device.remoteId.toString(),
                files: uploadFaceFiles,
                noteReport: capturedFace.noteReport,
              );

              // Close loading indicator
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } catch (e) {
                  debugPrint('Error closing loading dialog: $e');
                }
              });

              // ✅ Show result
              if (result != null && result.success) {
                AlertsService.success(
                  context: context,
                  message: result.message ?? AppStrings.saveSucessFull.tr(),
                  title: AppStrings.success.tr(),
                );
              } else {
                AlertsService.error(
                  context: context,
                  message: result?.message ?? AppStrings.noInternetConnection.tr(),
                  title: AppStrings.failed.tr(),
                );
              }
            } catch (e) {
              // Close loading indicator on error
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              AlertsService.error(
                context: context,
                message: e.toString(),
                title: AppStrings.failed.tr(),
              );
            }
          }
      );
    } catch (e) {
      debugPrint('Error Adding Bluetooth Fingerprint: $e');
      AlertsService.error(
        context: context,
        message:  AppStrings.noInternetConnection.tr(),
        title: AppStrings.failed.tr(),
      );
    }
  }

  static Future<bool> isWiFiEnabled() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi;
  }
  // Adding Fingerprint Using Wifi
  static Future<void> addFingerprintUsingWiFi({required BuildContext context,}) async {
    try {
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;
      final status = await WiFiScan.instance.canStartScan();
      if (status != CanStartScan.yes) {
        AlertsService.warning(
          context: context,
          message: AppStrings.pleaseEnableWifiFirst.tr(),
          title: AppStrings.warning.tr(),
        );
        AppSettings.openAppSettings(type: AppSettingsType.wifi);
        return;
      }
      final _CapturedFaceData? capturedFace =
      await captureEmployeeFaceAndVerify(context);
      if (capturedFace == null) {
        return;
      }
      final List<FilePickerResult> uploadFaceFiles =
      fingerprintMustUploadImage == true
          ? capturedFace.asFilePickerResults
          : <FilePickerResult>[];
      await _deleteFileIfExists(capturedFace.file);
      // Check for Wi-Fi scan permissions

      // Start scanning for Wi-Fi networks
      await WiFiScan.instance.startScan();

      // Get the list of Wi-Fi networks
      final List<WiFiAccessPoint> wifiNetworks =
      await WiFiScan.instance.getScannedResults();

      if (wifiNetworks.isEmpty) {
        AlertsService.warning(
          context: context,
          message: AppStrings.noWiFiNetworksFound.tr(),
          title: AppStrings.warning.tr(),
        );
        return;
      }

      // Show available Wi-Fi networks in a popup or sheet
      final List<WiFiAccessPoint> filteredNetworks = wifiNetworks
          .where((net) => net.ssid != null && net.ssid.trim().isNotEmpty)
          .toList();
      final selectedNetwork = await showModalBottomSheet<WiFiAccessPoint>(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: filteredNetworks.length,
            itemBuilder: (context, index) {
              final network = filteredNetworks[index];
              return ListTile(
                title: Text(network.ssid != null && network.ssid.toString().isNotEmpty ? network.ssid : AppStrings.unknownDevice.tr()),
                onTap: () => Navigator.pop(context, network),
              );
            },
          );
        },
      );

      if (selectedNetwork == null) return;

      // Prepare the data to send to the server
      final wifiData = {'mac_address': selectedNetwork.bssid};
      var result;
      customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            Navigator.pop(context);
          },
          onRightActionPressed: ()async{
            // Close confirmation dialog first
            try {
              if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            } catch (e) {
              debugPrint('Error closing confirmation dialog: $e');
            }
            
            // Show loading indicator immediately using post frame callback
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    useRootNavigator: true,
                    builder: (context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                }
              } catch (e) {
                debugPrint('Error showing loading dialog: $e');
              }
            });
            
            try {
              result = await FingerprintService.addWifiFingerprint(
                  context: context,
                  data: selectedNetwork.bssid.toString(),
                  files:  uploadFaceFiles,
                  noteReport: capturedFace.noteReport);

              // Close loading indicator
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } catch (e) {
                  debugPrint('Error closing loading dialog: $e');
                }
              });

              // Handle the server response
              if (result != null && result.success) {
                AlertsService.success(
                  context: context,
                  message: result.message ?? (result.data != null && result.data is Map ? result.data['message'] : null) ?? AppStrings.saveSucessFull.tr(),
                  title: AppStrings.success.tr(),
                );
                return;
              }
              else {
                AlertsService.error(
                  context: context,
                  message: result?.message ?? (result?.data != null && result?.data is Map ? result.data['message'] : null) ?? AppStrings.noInternetConnection.tr(),
                  title: AppStrings.failed.tr(),
                );
                return;
              }
            } catch (e) {
              // Close loading indicator on error
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              AlertsService.error(
                context: context,
                message: e.toString(),
                title: AppStrings.failed.tr(),
              );
            }
          }
      );

    } catch (e) {
      debugPrint('Error Adding Wi-Fi Fingerprint: $e');
      AlertsService.error(
        context: context,
        message: AppStrings.noInternetConnection.tr(),
        title: AppStrings.failed.tr(),
      );
      return;
    }
  }
  static double? lat;
  static double? long;

  static Future<void> getCurrentLocation(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // تأكد إن خدمة الموقع مفعلة
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ خدمة الموقع غير مفعلة');
      return;
    }

    // تحقق من الصلاحيات
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ صلاحيات الموقع مرفوضة');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ الصلاحيات مرفوضة دائمًا');
      return;
    }

    try {
      // الحصول على الإحداثيات بدون إنترنت
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // استخدم low علشان النت مش شغال
      );

      double lat = position.latitude;
      double long = position.longitude;
      print('📍 Latitude: $lat, Longitude: $long');
      CacheHelper.setString(key: "lat", value: lat.toString());
      CacheHelper.setString(key: "long", value: long.toString());
    } catch (e) {
      print('❌ حصل خطأ أثناء تحديد الموقع: $e');
    }
  }
  // Add Fingerprint Using GPS
  static Future<void> addFingerprintUsingGPS({required BuildContext context,}) async {
    try {
      print("HEY1");
      await getCurrentLocation(context);
      print("HEY2");
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;
      final _CapturedFaceData? capturedFace =
      await captureEmployeeFaceAndVerify(context);
      if (capturedFace == null) {
        return;
      }
      final List<FilePickerResult> uploadFaceFiles =
      fingerprintMustUploadImage == true
          ? capturedFace.asFilePickerResults
          : <FilePickerResult>[];
      await _deleteFileIfExists(capturedFace.file);
      var result;
      customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            Navigator.pop(context);
          },
          onRightActionPressed: ()async{
            // Close confirmation dialog first
            try {
              if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            } catch (e) {
              debugPrint('Error closing confirmation dialog: $e');
            }
            
            // Show loading indicator immediately using post frame callback
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    useRootNavigator: true,
                    builder: (context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                }
              } catch (e) {
                debugPrint('Error showing loading dialog: $e');
              }
            });
            
            try {
              result = await FingerprintService.addGPSFingerprint(
                  context: context,
                  type: 'fp_navigate',
                  lat: double.parse(CacheHelper.getString('lat') ?? '0'),
                  long: double.parse(CacheHelper.getString('long') ?? '0'),
                  files: uploadFaceFiles,
                  noteReport: capturedFace.noteReport);

              // Close loading indicator
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } catch (e) {
                  debugPrint('Error closing loading dialog: $e');
                }
              });

              print("GPS DONE TWO");
              // Handle the server response
              if (result != null && result.success) {
                AlertsService.success(
                    context: context,
                    message: result.message ?? (result.data != null && result.data is Map && result.data['message'] != null ? result.data['message'] : null) ?? AppStrings.saveSucessFull.tr(),
                    title: AppStrings.success.tr());
                return;
              }
              else {
                AlertsService.error(
                    context: context,
                    message: result?.message ?? (result?.data != null && result?.data is Map && result.data['message'] != null ? result.data['message'] : null) ?? AppStrings.noInternetConnection.tr(),
                    title: AppStrings.failed.tr());
                return;
              }
            } catch (e) {
              // Close loading indicator on error
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              AlertsService.error(
                context: context,
                message: e.toString(),
                title: AppStrings.failed.tr(),
              );
            }
          }
      );

    } catch (e) {
      debugPrint('Error Adding GPS Fingerprint: $e');
      AlertsService.error(
          context: context,
          message: AppStrings.noInternetConnection.tr(),
          title: AppStrings.failed.tr());
      return;
    }
  }

  // Add Fingerprint Using QrCode
  static Future<void> addFingerprintUsingQrCode(
      {required BuildContext context}) async {
    try {
      var jsonString;
      var gCache;
      jsonString = CacheHelper.getString("US1");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      }
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;
      
      // Verify face first
      final _CapturedFaceData? capturedFace =
      await captureEmployeeFaceAndVerify(context);
      if (capturedFace == null) {
        return;
      }
      
      // Then scan QR code
      final String? scanedQrCode =
      await _scanQrcodeToGetSecretKeyString(context: context);
      if (scanedQrCode == null || scanedQrCode.isEmpty) {
        // Delete the captured face file if QR scan was cancelled
        await _deleteFileIfExists(capturedFace.file);
        return;
      }
      
      final List<FilePickerResult> uploadFaceFiles =
      fingerprintMustUploadImage == true
          ? capturedFace.asFilePickerResults
          : <FilePickerResult>[];

      // if (fingerprintMustUploadImage == true &&
      //     (empPhoto == null || empPhoto.files.first.bytes == null)) {
      if (false) {
        AlertsService.error(
            context: context,
            message: 'Please Take Photo Before Adding Fingerprint',
            title: 'Photo Required!');
        return;
      }

      print("DONE FROM ONE");
      // Call Your Fingerprint Scanner API
      print("DONE FROM ONE");
      print("DONE FROM ONE");
      var result;

      customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            Navigator.pop(context);
          },
          onRightActionPressed: ()async{
            // Close confirmation dialog first
            try {
              if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            } catch (e) {
              debugPrint('Error closing confirmation dialog: $e');
            }
            
            // Show loading indicator immediately using post frame callback
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    useRootNavigator: true,
                    builder: (context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                }
              } catch (e) {
                debugPrint('Error showing loading dialog: $e');
              }
            });
            
            try {
              result = await FingerprintService.addQRCodeFingerprint(
                  context: context,
                  data: scanedQrCode,
                  files: uploadFaceFiles,
                  noteReport: capturedFace.noteReport);

              // Close loading indicator
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } catch (e) {
                  debugPrint('Error closing loading dialog: $e');
                }
              });

              print("result status --> ${result?.data != null && result.data is Map ? result.data['status'] : result?.success}");
              if (result != null && result.success) {
                AlertsService.success(
                    context: context,
                    message: result.message ?? (result.data != null && result.data is Map && result.data['message'] != null ? result.data['message'] : null) ?? AppStrings.saveSucessFull.tr(),
                    title: AppStrings.success.tr());
                return;
              }
              else {
                AlertsService.error(
                    context: context,
                    message: result?.message ?? (result?.data != null && result?.data is Map && result.data['message'] != null ? result.data['message'] : null) ?? AppStrings.noInternetConnection.tr(),
                    title: AppStrings.failed.tr());
                return;
              }
            } catch (e) {
              // Close loading indicator on error
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                } catch (e) {
                  debugPrint('Error closing loading dialog: $e');
                }
              });
              AlertsService.error(
                context: context,
                message: e.toString(),
                title: AppStrings.failed.tr(),
              );
            }
          }
      );

    } catch (e) {
      debugPrint(
          'Error Happeded While Adding Fingerprint Using Qrcode! Error :-> $e');
      AlertsService.error(
          context: context,
          message: AppStrings.noInternetConnection.tr(),
          title: AppStrings.failed.tr());
    }
  }

  static Future<String?> _scanQrcodeToGetSecretKeyString(
      {required BuildContext context}) async {
    try {
      // Request camera permission
      var cameraStatus = await permission_handler.Permission.camera.request();
      if (!cameraStatus.isGranted) {
        AlertsService.warning(
            context: context,
            message: 'Camera permission is required to scan QR codes',
            title: AppStrings.warning.tr());
        return null;
      }

      // Initialize a GlobalKey for the QRView widget
      final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
      // Use a Navigator to push a full-screen scanner widget
      final result = await Navigator.push<String?>(
        context,
        MaterialPageRoute(
          builder: (context) => const QRScannerView(),
        ),
      );
      // If scanning was successful, return the scanned text
      return result;
    } catch (e) {
      // Handle any errors, return null in case of an error
      debugPrint('Error scanning QR code: $e');
      AlertsService.error(
          context: context,
          message: 'Error Happeded! Please try later!',
          title: AppStrings.failed.tr());
      return null;
    }
  }
}
