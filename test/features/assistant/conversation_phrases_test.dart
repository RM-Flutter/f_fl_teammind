import 'dart:convert';
import 'dart:io';
import 'package:app_test/features/assistant/data/models/help_entry_model.dart';
import 'package:app_test/features/assistant/data/repos/help_repo.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test('who am I, who are you, about the app, date and time phrasings', () {
    final cases = {
      'ar': {
        'my_account': ['من انا', 'مين أنا', 'أنا مين', 'تعرف عني ايه', 'قولي عني', 'بياناتي', 'معلومات حسابي'],
        'who_are_you': ['من أنت', 'مين إنت', 'إنت مين', 'مين حضرتك', 'عرفني بنفسك', 'انت روبوت؟', 'انا بكلم مين'],
        'about_app': ['كلمني عن التطبيق', 'احكيلي عن الابلكيشن', 'ايه هو تيم مايند', 'التطبيق ده بيعمل ايه', 'مميزات التطبيق', 'اشرحلي التطبيق'],
        'date_today': ['تاريخ اليوم', 'تاريخ النهارده', 'النهارده كام', 'النهارده ايه', 'إيه تاريخ النهارده', 'اليوم كام في الشهر', 'ما هو تاريخ اليوم', 'احنا في يوم ايه', 'النهارده يوم ايه'],
        'time_now': ['الوقت الان', 'الوقت دلوقتي', 'الساعة كام', 'كم الساعة', 'الساعة كام دلوقتي', 'ما هو الوقت الآن', 'قولي الساعة', 'الساعه كام معاك'],
      },
      'en': {
        'my_account': ['who am I', 'tell me about me', 'my profile', 'what do you know about me'],
        'who_are_you': ['who are you', 'who is this', 'who am I talking to', 'are you a robot'],
        'about_app': ['tell me about the app', 'what is TeamMind', 'what does this app do', 'app features'],
        'date_today': ["what's the date", 'what is the date today', "today's date", 'what day is it', 'what day is today'],
        'time_now': ['what time is it', "what's the time", 'current time', 'time now', 'tell me the time'],
      },
    };
    for (final lang in cases.keys) {
      final entries = (json.decode(File('assets/json/assistant/help_$lang.json').readAsStringSync()) as List)
          .map((e) => HelpEntryModel.fromJson(Map<String, dynamic>.from(e))).toList();
      cases[lang]!.forEach((want, qs) {
        for (final q in qs) {
          final got = HelpRepo.match(q, entries).best?.id;
          expect(got, want, reason: '$lang "$q"');
        }
      });
    }
  });
}
