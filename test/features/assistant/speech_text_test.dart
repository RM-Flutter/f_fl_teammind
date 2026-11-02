import 'dart:convert';
import 'dart:io';

import 'package:app_test/features/assistant/data/repos/user_data_repo.dart';
import 'package:app_test/features/assistant/data/services/speech_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpeechText.prepare (ar)', () {
    String ar(String s) => SpeechText.prepare(s, 'ar');

    test('numbers in Egyptian words', () {
      expect(SpeechText.number(3), 'تلاتة');
      expect(SpeechText.number(12), 'اتناشر');
      expect(SpeechText.number(21), 'واحد وعشرين');
      expect(SpeechText.number(250), 'ميتين وخمسين');
      expect(SpeechText.number(2026), 'ألفين وستة وعشرين');
      expect(SpeechText.number(15000), 'خمستاشر ألف');
    });

    test('dates and times', () {
      expect(ar('النهارده 2026-11-02.'), 'النهارده اتنين نوفمبر ألفين وستة وعشرين.');
      expect(ar('الساعة دلوقتي 9:30 الصبح.'), 'الساعة دلوقتي تسعة ونص الصبح.');
      expect(ar('من 09:00 لـ 17:45'), 'من تسعة لـ ستة إلا ربع');
      expect(ar('2026-01-05 14:07'), 'خمسة يناير ألفين وستة وعشرين الساعة اتنين وسبعة دقايق');
    });

    test('long numbers are read digit by digit, Arabic-Indic digits too', () {
      expect(ar('رقمك ٠١٠٢'), 'رقمك صفر واحد صفر اتنين');
      expect(ar('1155667788'), 'واحد واحد خمسة خمسة ستة ستة سبعة سبعة تمانية تمانية');
    });

    test('acronyms and symbols', () {
      expect(ar('كود QR'), 'كود كيو آر');
      expect(ar('الـ HR'), 'الإتش آر');
      expect(ar('• عيد (2026-11-10 → 2026-11-12)'),
          'عيد (عشرة نوفمبر ألفين وستة وعشرين لحد اتناشر نوفمبر ألفين وستة وعشرين)');
      expect(ar('سطر\nسطر'), 'سطر. سطر');
    });

    test('English text is left alone apart from bullets and arrows', () {
      expect(SpeechText.prepare('• a → b\nc', 'en'), 'a to b. c');
    });
  });

  test('profile answer reads as sentences and drops only the missing ones', () {
    final entries = json.decode(File('assets/json/assistant/help_ar.json').readAsStringSync()) as List;
    final account = entries.cast<Map>().firstWhere((e) => e['id'] == 'my_account');
    final spoken = SpeechText.prepare(
        UserDataRepo.fill(account['speak'] as String, {'name': 'ابانوب', 'department': 'العقارات'})!, 'ar');
    expect(spoken, 'اسمَك ابانوب. وإنتَ تَبَع قِسم العقارات.');
  });

  test('every Arabic speak keeps the answer placeholders line by line', () {
    final entries = json.decode(File('assets/json/assistant/help_ar.json').readAsStringSync()) as List;
    final ph = RegExp(r'\{[a-z_]+\}');
    for (final e in entries.cast<Map>()) {
      final speak = e['speak'] as String?;
      expect(speak, isNotNull, reason: '${e['id']} has no speak');
      final a = (e['answer'] as String).split('\n'), s = speak!.split('\n');
      expect(s.length, a.length, reason: '${e['id']} line count');
      for (var i = 0; i < a.length; i++) {
        expect(ph.allMatches(s[i]).map((m) => m[0]).toList(), ph.allMatches(a[i]).map((m) => m[0]).toList(),
            reason: '${e['id']} line $i');
      }
    }
  });
}
