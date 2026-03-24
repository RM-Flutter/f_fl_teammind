import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';

Future<String?> compressVideoToBase64({
  String? path,
  Uint8List? bytes,
}) async {
  if (path != null && path.isNotEmpty) {
    try {
      final MediaInfo? info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      if (info?.file != null) {
        final compressedBytes = await info!.file!.readAsBytes();
        if (compressedBytes.isNotEmpty) {
          return base64Encode(compressedBytes);
        }
      }
    } catch (e) {
      debugPrint('VideoCompressHelper: $e');
    }
  }

  if (bytes != null && bytes.isNotEmpty) return base64Encode(bytes);
  return null;
}
