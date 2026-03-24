import 'dart:convert';
import 'dart:typed_data';

/// على الويب: لا ضغط، نُرجع base64 للفيديو الأصلي فقط.
Future<String?> compressVideoToBase64({
  String? path,
  Uint8List? bytes,
}) async {
  if (bytes != null && bytes.isNotEmpty) return base64Encode(bytes);
  return null;
}
