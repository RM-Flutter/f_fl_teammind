import 'package:app_test/features/assistant/data/services/voice_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('split', () {
    test('english text with an arabic name', () {
      final s = VoicePicker.split('Name: ابانوب Magdy (verified)', 'en');
      expect(s.map((e) => e.lang).toList(), ['en', 'ar', 'en']);
      expect(s.map((e) => e.text).toList(), ['Name:', 'ابانوب', 'Magdy (verified)']);
    });

    test('arabic text with english words and numbers', () {
      final s = VoicePicker.split('رصيدك 15 يوم، افتح PDF دلوقتي', 'ar');
      expect(s.map((e) => '${e.lang}:${e.text}').toList(),
          ['ar:رصيدك 15 يوم، افتح', 'en:PDF', 'ar:دلوقتي']);
    });

    test('single language stays one segment', () {
      expect(VoicePicker.split('Hi there, it is 3:05 PM.', 'en').length, 1);
      expect(VoicePicker.split('', 'en'), isEmpty);
    });
  });

  group('pick', () {
    // أسماء أصوات Google TTS على أندرويد كما يرجعها getVoices
    final android = [
      {'name': 'en-us-x-sfg-local', 'locale': 'en-US'},
      {'name': 'en-us-x-iom-network', 'locale': 'en-US'},
      {'name': 'en-us-x-iom-local', 'locale': 'en-US'},
      {'name': 'en-gb-x-gbb-local', 'locale': 'en-GB'},
      {'name': 'ar-xa-x-arc-local', 'locale': 'ar'},
      {'name': 'ar-xa-x-ard-local', 'locale': 'ar'},
    ];

    test('android: local male english voice', () {
      final c = VoicePicker.pick(android, 'en');
      expect(c.voice!['name'], 'en-us-x-iom-local');
      expect(c.isMale, isTrue);
      expect(c.pitch, 1);
    });

    test('android: male arabic voice', () {
      final c = VoicePicker.pick(android, 'ar', region: 'EG');
      expect(c.voice!['name'], 'ar-xa-x-ard-local');
      expect(c.isMale, isTrue);
    });

    test('ios: uses the gender field and prefers the region', () {
      final ios = [
        {'name': 'Samantha', 'locale': 'en-US', 'gender': 'female'},
        {'name': 'Aaron', 'locale': 'en-US', 'gender': 'male'},
        {'name': 'Maged', 'locale': 'ar-SA', 'gender': 'male'},
        {'name': 'Laila', 'locale': 'ar-EG', 'gender': 'female'},
      ];
      expect(VoicePicker.pick(ios, 'en').voice!['name'], 'Aaron');
      // male beats region
      expect(VoicePicker.pick(ios, 'ar', region: 'EG').voice!['name'], 'Maged');
    });

    test('no male voice: deeper pitch on the best voice', () {
      final c = VoicePicker.pick([
        {'name': 'en-us-x-sfg-local', 'locale': 'en-US'}
      ], 'en');
      expect(c.isMale, isFalse);
      expect(c.pitch, VoicePicker.fallbackMalePitch);
    });

    test('no voices at all: language default with deeper pitch', () {
      final c = VoicePicker.pick(const [], 'ar');
      expect(c.voice, isNull);
      expect(c.language, 'ar');
      expect(c.pitch, VoicePicker.fallbackMalePitch);
    });
  });
}
