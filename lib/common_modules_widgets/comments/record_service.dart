// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:record/record.dart';
//
// class RecordingResult {
//   final String? path; // للموبايل
//   final Uint8List? bytes; // للويب
//   RecordingResult({this.path, this.bytes});
// }
//
// class RecordingService {
//   AudioRecorder? _recorder;
//   Uint8List? _lastRecordingBytes; // نخزن آخر تسجيل فقط
//   String? _lastRecordingPath;
//
//   Future<void> start() async {
//     if (kIsWeb) {
//       // في الويب مفيش مسار، فبنعمل reset لأي تسجيل قديم
//       _lastRecordingBytes = null;
//     } else {
//       _recorder = AudioRecorder();
//       if (await _recorder!.hasPermission()) {
//         // كل مرة نسجل لازم نولد اسم جديد عشان ما يرسلش القديم
//         final timestamp = DateTime.now().millisecondsSinceEpoch;
//         final path = '/data/user/0/temp_audio_$timestamp.m4a';
//         await _recorder!.start(
//           RecordConfig(encoder: AudioEncoder.aacLc),
//           path: path,
//         );
//         _lastRecordingPath = path;
//       }
//     }
//   }
//
//   Future<RecordingResult?> stop() async {
//     if (kIsWeb) {
//       // لازم هنا في الويب تجيب البيانات من JavaScript أو من مكتبة الصوت اللي بتستخدمها
//       if (_lastRecordingBytes != null) {
//         return RecordingResult(bytes: _lastRecordingBytes);
//       }
//       return null;
//     } else {
//       final path = await _recorder?.stop();
//       if (path == null) return null;
//
//       // نحدث آخر تسجيل ونرجعه
//       _lastRecordingPath = path;
//       return RecordingResult(path: path);
//     }
//   }
//
//   /// تستخدمها لما يوصلك bytes جديدة من الويب
//   void updateWebRecording(Uint8List bytes) {
//     _lastRecordingBytes = bytes;
//   }
// }
