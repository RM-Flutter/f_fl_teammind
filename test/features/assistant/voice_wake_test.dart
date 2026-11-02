import 'dart:math' as math;
import 'dart:typed_data';

import 'package:app_test/features/assistant/data/services/utterance_segmenter.dart';
import 'package:app_test/features/assistant/data/services/voice_features.dart';
import 'package:app_test/features/assistant/data/services/voice_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

/// كلمة اصطناعية: سلسلة مقاطع، كل مقطع مجموع نغمتين (تشبه فورمانتات الصوت).
List<double> word(List<List<double>> parts, int seed, {double speed = 1, double noise = 0.01}) {
  final rnd = math.Random(seed);
  final out = <double>[];
  for (final p in parts) {
    final n = (2400 * speed * (1 + (rnd.nextDouble() - 0.5) * 0.1)).round();
    final f1 = p[0] * (1 + (rnd.nextDouble() - 0.5) * 0.04);
    final f2 = p[1] * (1 + (rnd.nextDouble() - 0.5) * 0.04);
    for (var i = 0; i < n; i++) {
      final t = i / 16000;
      final env = math.sin(math.pi * i / n);
      out.add(0.25 * env * (math.sin(2 * math.pi * f1 * t) + 0.6 * math.sin(2 * math.pi * f2 * t)) +
          (rnd.nextDouble() - 0.5) * noise);
    }
  }
  return out;
}

const wakeWord = [[300.0, 900.0], [500.0, 1500.0], [700.0, 1200.0], [400.0, 2000.0]];
const otherWord = [[800.0, 2400.0], [250.0, 700.0], [600.0, 2200.0], [900.0, 1100.0]];

void main() {
  test('same word is closer than a different word', () {
    final a1 = VoiceFeatures.extract(word(wakeWord, 1));
    final a2 = VoiceFeatures.extract(word(wakeWord, 2, speed: 1.1));
    final b1 = VoiceFeatures.extract(word(otherWord, 3));
    final same = VoiceMatcher.distance(a1, a2);
    final diff = VoiceMatcher.distance(a1, b1);
    expect(same, lessThan(diff * 0.7), reason: 'same=$same diff=$diff');
  });

  test('enrolled voiceprint accepts the word and rejects another', () {
    final samples = [1, 2, 3]
        .map((s) => VoiceFeatures.extract(word(wakeWord, s, speed: 0.95 + s * 0.04)))
        .toList();
    final vp = VoiceMatcher.enroll(samples)!;
    final again = VoiceFeatures.extract(word(wakeWord, 10, speed: 1.05));
    final other = VoiceFeatures.extract(word(otherWord, 11));
    expect(vp.matches(again), isTrue, reason: 'd=${vp.distanceTo(again)} thr=${vp.threshold}');
    expect(vp.matches(other), isFalse, reason: 'd=${vp.distanceTo(other)} thr=${vp.threshold}');
    // serialisation round trip
    final back = VoiceprintModel.fromJson(vp.toJson());
    expect(back.matches(again), isTrue);
  });

  test('segmenter extracts one utterance from silence-speech-silence', () {
    final found = <List<double>>[];
    final seg = UtteranceSegmenter(onUtterance: found.add);
    final rnd = math.Random(5);
    List<double> silence(double sec) =>
        List.generate((sec * 16000).round(), (_) => (rnd.nextDouble() - 0.5) * 0.004);
    final signal = [...silence(1), ...word(wakeWord, 1), ...silence(1.2)];
    final pcm = Int16List.fromList(signal.map((v) => (v * 32767).round().clamp(-32768, 32767)).toList());
    // مرّره على دفعات عشوائية الحجم مثل تدفق الميكروفون
    var i = 0;
    while (i < pcm.length) {
      final n = math.min(700 + rnd.nextInt(900), pcm.length - i);
      seg.feed(Int16List.sublistView(pcm, i, i + n));
      i += n;
    }
    expect(found.length, 1);
    expect(found.first.length / 16000, inInclusiveRange(0.8, 2.2));
  });

  test('long continuous sound is ignored', () {
    final found = <List<double>>[];
    final seg = UtteranceSegmenter(onUtterance: found.add);
    final long = [for (var k = 0; k < 6; k++) ...word(wakeWord, k)]; // 3.6 ث
    final pcm = Int16List.fromList(long.map((v) => (v * 32767).round().clamp(-32768, 32767)).toList());
    seg.feed(pcm);
    seg.feed(Int16List(16000)); // ثانية صمت
    expect(found.map((f) => f.length / 16000).toList(), isEmpty);
  });
}
