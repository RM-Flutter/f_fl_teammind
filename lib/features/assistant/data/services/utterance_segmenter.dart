import 'dart:math' as math;
import 'dart:typed_data';

/// يقسّم تدفق الصوت إلى جمل قصيرة (من بداية الكلام حتى الصمت) بكشف الطاقة،
/// ويرمي أي مقطع أقصر من 0.45 ث أو أطول من 3 ث (ليس عبارة التنشيط).
class UtteranceSegmenter {
  static const int _frame = 160; // 10ms عند 16kHz
  static const int _startFrames = 3;
  static const int _hangoverFrames = 50; // صمت 0.5 ث ينهي الجملة
  static const int _preRollFrames = 15;
  static const int _minFrames = 45;
  static const int _maxFrames = 300;
  static const int _quietFrames = 30;
  static const int _maxWaitQuietFrames = 200; // 2 ث كحد أقصى
  static const int _floorWindow = 150; // أقل طاقة خلال 1.5 ث = مستوى الضوضاء

  final void Function(List<double> samples) onUtterance;

  UtteranceSegmenter({required this.onUtterance});

  final List<double> _pending = [];
  final List<List<double>> _preRoll = [];
  final List<double> _speech = [];
  double _floor = 0.003;
  final List<double> _recent = [];
  int _sinceFloorUpdate = 0;
  int _waitedQuiet = 0;
  int _loud = 0;
  int _silent = 0;
  int _quiet = 0;
  bool _inSpeech = false;
  bool _waitQuiet = false;

  /// آخر طاقة مقاسة (للتشخيص).
  double lastRms = 0;

  void feed(Int16List pcm) {
    for (final s in pcm) {
      _pending.add(s / 32768.0);
    }
    var offset = 0;
    while (_pending.length - offset >= _frame) {
      _processFrame(_pending.sublist(offset, offset + _frame));
      offset += _frame;
    }
    _pending.removeRange(0, offset);
  }

  void reset() {
    _pending.clear();
    _preRoll.clear();
    _speech.clear();
    _loud = _silent = _quiet = 0;
    _inSpeech = false;
    _waitQuiet = false;
    _waitedQuiet = 0;
    _recent.clear();
    _floor = 0.003;
  }

  /// مستوى الضوضاء يتبع أقل طاقة في آخر 1.5 ث، فيتكيف لو انتقل المستخدم
  /// لمكان أكثر ضوضاء (سابقاً كان يعلق ولا يسمع شيئاً).
  void _trackFloor(double rms) {
    _recent.add(rms);
    if (_recent.length > _floorWindow) _recent.removeAt(0);
    if (++_sinceFloorUpdate < 10 && _recent.length < _floorWindow) return;
    _sinceFloorUpdate = 0;
    var min = double.infinity;
    for (final v in _recent) {
      if (v < min) min = v;
    }
    _floor = min.clamp(0.0005, 0.05);
  }

  void _processFrame(List<double> frame) {
    var sum = 0.0;
    for (final v in frame) {
      sum += v * v;
    }
    final rms = math.sqrt(sum / frame.length);
    lastRms = rms;
    _trackFloor(rms);
    final startThr = math.max(_floor * 4, 0.012);
    final stayThr = math.max(_floor * 2.5, 0.008);

    if (_waitQuiet) {
      _quiet = rms < stayThr ? _quiet + 1 : 0;
      _waitedQuiet++;
      if (_quiet >= _quietFrames || _waitedQuiet >= _maxWaitQuietFrames) {
        _waitQuiet = false;
        _quiet = 0;
        _waitedQuiet = 0;
      }
      return;
    }

    if (!_inSpeech) {
      _preRoll.add(frame);
      if (_preRoll.length > _preRollFrames) _preRoll.removeAt(0);
      _loud = rms > startThr ? _loud + 1 : 0;
      if (_loud >= _startFrames) {
        _inSpeech = true;
        _silent = 0;
        for (final f in _preRoll) {
          _speech.addAll(f);
        }
        _preRoll.clear();
      }
      return;
    }

    _speech.addAll(frame);
    _silent = rms < stayThr ? _silent + 1 : 0;
    final frames = _speech.length ~/ _frame;
    if (frames > _maxFrames) {
      _discard();
      _waitQuiet = true;
      return;
    }
    if (_silent >= _hangoverFrames) {
      final keep = (_speech.length - (_hangoverFrames - 10) * _frame)
          .clamp(0, _speech.length);
      final trimmed = _speech.sublist(0, keep);
      final speechFrames = trimmed.length ~/ _frame;
      _discard();
      if (speechFrames >= _minFrames) onUtterance(trimmed);
    }
  }

  void _discard() {
    _speech.clear();
    _inSpeech = false;
    _loud = 0;
    _silent = 0;
  }
}
