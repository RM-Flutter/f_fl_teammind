import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import 'utterance_segmenter.dart';
import 'voice_features.dart';

enum WakeStartResult { started, denied, failed }

/// يفتح الميكروفون مرة واحدة كتدفق مستمر (بدون جلسات تعرف على الكلام، فلا
/// توجد أصوات فتح وإغلاق) ويرسل بصمة كل جملة قصيرة تُسمع.
class WakeWordService {
  final AudioRecorder _recorder = AudioRecorder();
  late final UtteranceSegmenter _segmenter;
  StreamSubscription<Uint8List>? _sub;
  final StreamController<List<List<double>>> _out = StreamController.broadcast();
  int? _carry;
  bool _running = false;
  DateTime _lastChunkAt = DateTime.now();

  WakeWordService() {
    _segmenter = UtteranceSegmenter(onUtterance: _onUtterance);
  }

  bool get isRunning => _running;

  /// متوقف عن استقبال الصوت (مثلاً أخذ تطبيق آخر الميكروفون) رغم أنه يعمل.
  bool get isStalled =>
      _running && DateTime.now().difference(_lastChunkAt) > const Duration(seconds: 3);

  /// بصمات (MFCC) الجمل المسموعة.
  Stream<List<List<double>>> get utterances => _out.stream;

  Future<WakeStartResult> start() async {
    if (_running) return WakeStartResult.started;
    try {
      if (!await _recorder.hasPermission()) return WakeStartResult.denied;
      _segmenter.reset();
      _carry = null;
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: VoiceFeatures.sampleRate,
        numChannels: 1,
      ));
      _sub = stream.listen(_onChunk, onError: (e) => debugPrint('WakeWord: stream error $e'));
      _running = true;
      _lastChunkAt = DateTime.now();
      return WakeStartResult.started;
    } catch (e) {
      // غالباً الميكروفون ما زال مشغولاً لحظة بعد التعرف على الكلام.
      debugPrint('WakeWord: start failed: $e');
      _running = false;
      return WakeStartResult.failed;
    }
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    try {
      await _sub?.cancel();
      _sub = null;
      if (await _recorder.isRecording()) await _recorder.stop();
    } catch (e) {
      debugPrint('WakeWord: stop failed: $e');
    }
    _segmenter.reset();
  }

  Future<void> dispose() async {
    await stop();
    await _out.close();
    await _recorder.dispose();
  }

  void _onChunk(Uint8List chunk) {
    _lastChunkAt = DateTime.now();
    var bytes = chunk;
    if (_carry != null) {
      bytes = Uint8List.fromList([_carry!, ...chunk]);
      _carry = null;
    }
    if (bytes.length.isOdd) {
      _carry = bytes.last;
      bytes = Uint8List.sublistView(bytes, 0, bytes.length - 1);
    }
    final data = ByteData.sublistView(bytes);
    final pcm = Int16List(bytes.length ~/ 2);
    for (var i = 0; i < pcm.length; i++) {
      pcm[i] = data.getInt16(i * 2, Endian.little);
    }
    _segmenter.feed(pcm);
  }

  void _onUtterance(List<double> samples) {
    final features = VoiceFeatures.extract(samples);
    if (features.isNotEmpty && !_out.isClosed) _out.add(features);
  }
}
