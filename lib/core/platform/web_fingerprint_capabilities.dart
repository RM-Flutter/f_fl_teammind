import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

import '../constants/app_constants.dart';

/// Rules for fingerprinting from the browser (Flutter web):
/// - QR scan: smartphone browsers with a camera only, in every case.
/// - GPS: every device.
/// - When the backend asks for a face image:
///   - smartphone with a camera: GPS and QR both allowed; the camera opens for a plain photo
///     that is uploaded with the fingerprint.
///   - anything else (desktop / tablet / no camera): every fingerprint method is hidden.
/// - WiFi / Bluetooth / NFC: never (a browser can't read them).
/// No liveness / face-profile challenges run in the browser.
///
/// Nothing here runs on mobile builds: every entry point returns early when not on web.
abstract class WebFingerprintCapabilities {
  static Future<bool>? _hasCameraFuture;

  /// Smartphone browser (tablets and desktops don't count).
  /// Decided by the screen's shortest side, so a phone counts in portrait and landscape,
  /// and a tablet (Android or iPad, which reports itself as macOS) does not.
  /// A desktop also needs a touch screen, so a narrow desktop window stays a desktop.
  static bool isPhone(BuildContext context) {
    if (!kIsWeb) return false;
    final double shortestSide = MediaQuery.sizeOf(context).shortestSide;
    if (shortestSide >= 600) return false;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return true;
    }
    return (html.window.navigator.maxTouchPoints ?? 0) > 0;
  }

  /// Browsers only give the location and camera to secure pages (https or localhost).
  /// On plain http they refuse without ever showing the permission prompt.
  static bool get isSecurePage {
    if (!kIsWeb) return true;
    try {
      final location = html.window.location;
      if (location.protocol == 'https:') return true;
      final host = location.hostname ?? '';
      return host == 'localhost' || host == '127.0.0.1' || host == '[::1]';
    } catch (_) {
      return true; // can't tell, let the browser decide
    }
  }

  /// Whether the browser sees at least one camera. Cached for the session.
  static Future<bool> hasCamera() {
    if (!kIsWeb) return Future.value(false);
    return _hasCameraFuture ??= _detectCamera();
  }

  static Future<bool> _detectCamera() async {
    try {
      final devices = html.window.navigator.mediaDevices;
      if (devices == null) return false;
      final list = await devices.enumerateDevices();
      return list.any((d) => d is html.MediaDeviceInfo && d.kind == 'videoinput');
    } catch (e) {
      debugPrint('⚠️ [Web] Camera detection failed: $e');
      return false;
    }
  }

  /// Backend asks for a face image with every fingerprint.
  static bool get imageEnabled => AppConstants.fingerprintUploadFaceImageToBackend;

  /// Backend refuses fingerprints without the face image.
  static bool get imageMandatory =>
      AppConstants.fingerprintUploadFaceImageToBackendLevel.isMandatory;

  /// Filters the fingerprint methods for the browser. [phone] / [camera] come from
  /// [isPhone] and [hasCamera].
  static List<String> filterMethods(
    List<String> methods, {
    required bool phone,
    required bool camera,
  }) {
    final bool canTakePhoto = phone && camera;
    // Image needed but the photo can't be taken here => no fingerprint method at all.
    if (imageEnabled && !canTakePhoto) return const [];
    return methods.where((m) {
      if (m == 'fp_navigate' || m == 'custom_fp_navigate') return true;
      if (m == 'fp_scan') return canTakePhoto; // QR: smartphones only (scanning needs the camera)
      return false; // WiFi / Bluetooth / NFC can't be read from a browser
    }).toList();
  }

  /// Opens the device camera (front camera preferred) and returns the photo ready for upload.
  /// Returns null when cancelled or when the camera can't be used.
  static Future<FilePickerResult?> takePhoto() async {
    if (!kIsWeb) return null;
    try {
      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1080,
        imageQuality: 85,
      );
      if (photo == null) return null;
      final Uint8List bytes = await photo.readAsBytes();
      if (bytes.isEmpty) return null;
      final String name = 'fingerprint_face_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return FilePickerResult([
        PlatformFile(name: name, size: bytes.length, bytes: bytes),
      ]);
    } catch (e) {
      debugPrint('⚠️ [Web] Taking fingerprint photo failed: $e');
      return null;
    }
  }
}
