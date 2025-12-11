import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

abstract class FileAndImagePickerService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Method to pick a single image from camera or gallery
  static Future<Map<String, dynamic>?> pickImage(
      {required String type, String? cameraDevice, int? quality = 70}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: type == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: quality,
        preferredCameraDevice:
            cameraDevice == 'front' ? CameraDevice.front : CameraDevice.rear,
      );
      if (image == null) return null;

      return {
        "image": image.path,
        "fileName": image.name,
      };
    } on PlatformException catch (e) {
      debugPrint("Failed to pick image: ${e.toString()}");
      return null;
    }
  }

  static Future<FilePickerResult?> pickImageWithFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );
    return (result != null && result.files.isNotEmpty) ? result : null;
  }


  static List<FilePickerResult> convertMapListToFilePickerResults(List<Map<String, dynamic>> imageMaps) {
    return imageMaps.map((imageData) {
      final String? path = imageData["image"] as String?;
      final String fileName = (imageData["fileName"] as String?) ??
          'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final dynamic bytesValue = imageData["bytes"] ?? imageData["imageBytes"];

      Uint8List? resolvedBytes;

      if (bytesValue is Uint8List && bytesValue.isNotEmpty) {
        resolvedBytes = bytesValue;
      } else if (bytesValue is String && bytesValue.isNotEmpty) {
        try {
          resolvedBytes = base64Decode(bytesValue);
        } catch (error) {
          debugPrint('Failed to decode base64 image bytes: $error');
        }
      }

      if (resolvedBytes == null && path != null) {
        final file = File(path);
        if (file.existsSync()) {
          resolvedBytes = file.readAsBytesSync();
        }
      }

      if (resolvedBytes == null) {
        throw Exception("Unable to resolve image bytes for $fileName.");
      }

      final platformFile = PlatformFile(
        path: (path != null && File(path).existsSync()) ? path : null,
        name: fileName,
        size: resolvedBytes.length,
        bytes: resolvedBytes,
      );

      return FilePickerResult([platformFile]);
    }).toList();
  }

  /// Method to pick multiple images from gallery
  static Future<List<File>?> pickMultiImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isEmpty) return null;

      return images.map((e) => File(e.path)).toList();
    } on PlatformException catch (e) {
      debugPrint("Failed to pick images: $e");
      return null;
    }
  }

  /// Method to pick files with specific extensions
  static Future<FilePickerResult?> pickFile() async {
    const List<String> allowedExtensions = [
      'png',
      'jpg',
      'jpeg',
      'pdf',
      'doc',
      'docx'
    ];

    try {
      return await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        allowedExtensions: allowedExtensions,
        type: FileType.custom,
      );
    } on PlatformException catch (e) {
      debugPrint("Failed to pick files: ${e.toString()}");
      return null;
    }
  }
}
