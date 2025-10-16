import 'dart:io';
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
      final path = imageData["image"] as String?;
      final name = imageData["fileName"] as String?;

      if (path != null && name != null) {
        final file = File(path);

        final platformFile = PlatformFile(
          path: path,
          name: name,
          size: file.lengthSync(),
          bytes: file.readAsBytesSync(),
        );

        return FilePickerResult([platformFile]);
      } else {
        throw Exception("Invalid image data format.");
      }
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
