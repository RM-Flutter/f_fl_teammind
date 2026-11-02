import 'package:app_test/features/assistant/data/models/help_entry_model.dart';
import 'package:app_test/features/assistant/data/repos/help_repo.dart';
import 'dart:convert';
import 'dart:io';

import 'package:app_test/core/routing/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const leave = HelpEntryModel(
    id: 'request_leave',
    title: 'request leave',
    keywords: ['leave', 'vacation', 'day off'],
    questions: ['how do I request a leave', 'how can I take a day off'],
    answer: 'a',
  );
  const pass = HelpEntryModel(
    id: 'change_password',
    title: 'change password',
    keywords: ['password'],
    questions: ['how do I change my password'],
    answer: 'b',
  );
  const arLeave = HelpEntryModel(
    id: 'request_leave',
    title: 'طلب اجازه',
    keywords: ['اجازة', 'إجازة'],
    questions: ['كيف أطلب إجازة'],
    answer: 'a',
  );
  final all = [leave, pass];

  test('matches english question', () {
    expect(HelpRepo.match('How do I request a leave?', all).best?.id, 'request_leave');
    expect(HelpRepo.match('I want to take a day off', all).best?.id, 'request_leave');
    expect(HelpRepo.match('change password please', all).best?.id, 'change_password');
  });

  test('unknown question gives suggestions, not an answer', () {
    final r = HelpRepo.match('what is the weather today', all);
    expect(r.best, isNull);
  });

  test('arabic normalisation', () {
    expect(HelpRepo.match('ممكن اطلب الاجازه ازاي', [arLeave]).best?.id, 'request_leave');
    expect(HelpRepo.match('كيف أطلب إجَازَة', [arLeave, pass]).best?.id, 'request_leave');
  });

  List<HelpEntryModel> loadFile(String lang) =>
      (json.decode(File('assets/json/assistant/help_$lang.json').readAsStringSync())
              as List)
          .map((e) => HelpEntryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

  group('help files', () {
    final routes = AppRoutes.values.map((e) => e.name).toSet();
    for (final lang in ['en', 'ar']) {
      test('$lang entries are valid', () {
        final entries = loadFile(lang);
        expect(entries.map((e) => e.id).toSet().length, entries.length);
        for (final e in entries) {
          expect(e.answer, isNotEmpty, reason: e.id);
          expect(e.keywords, isNotEmpty, reason: e.id);
          if (e.route != null) expect(routes, contains(e.route), reason: e.id);
        }
      });
    }
    test('same ids in both languages', () {
      expect(loadFile('en').map((e) => e.id), loadFile('ar').map((e) => e.id));
    });
  });

  // سؤال -> id المتوقع (null = يجب ألا يجاوب)
  const enSamples = {
    'how do I punch in': 'punch',
    'I want to clock out': 'punch',
    'why was my punch rejected': 'punch_rejected',
    'it says punch failed because of location': 'punch_rejected',
    'can I punch without internet': 'punch_offline',
    'show my attendance history': 'my_punches',
    'how do I ask for a vacation': 'request_leave',
    'I need a day off next week': 'request_leave',
    'how can I leave early today': 'request_permission',
    'how do I request work from home': 'request_mission',
    'how do I attach a document to my request': 'request_attachment',
    'are weekends counted in my leave': 'request_duration',
    'where can I see the status of my request': 'track_request',
    'how do I cancel my request': 'ask_ignore',
    'my request is taking long how do I remind': 'ask_remind',
    'show the calendar of my requests': 'requests_calendar',
    'how many vacation days do I have left': 'leave_balance',
    'where can I see my payslip': 'payslip',
    'how do I download my payslip as pdf': 'payslip_pdf',
    'how do I request a salary advance': 'salary_advance',
    'how do I get reimbursed for expenses': 'expense_claim',
    'did I get a penalty': 'rewards_penalties',
    'where are my tasks': 'tasks',
    'how do I create a new task': 'add_task',
    'how do I write my daily report': 'daily_report',
    'how do I request overtime': 'overtime',
    'how do I change my shift': 'shift_change',
    'how do I change my password': 'change_password',
    'how do I switch to arabic': 'change_language',
    'how do I log out': 'logout',
    'how do I approve a request': 'mgr_approve',
    'who is absent today': 'mgr_team_today',
    'how do I see my team punches': 'mgr_team_punches',
    // account data questions vs. how-to questions with the same words
    "what's my department name": 'my_department',
    'which department am I in': 'my_department',
    'tell me about my account': 'my_account',
    'who am I': 'my_account',
    'what is my phone number': 'my_phone',
    'how do I change my phone number': 'edit_profile',
    'what is my email': 'my_email',
    'when did I join the company': 'my_hire_date',
    'how long have I worked here': 'my_hire_date',
    'what are my working hours': 'my_work_hours',
    'what time do I start work': 'my_work_hours',
    'which days am I off': 'my_weekend',
    'when is the next holiday': 'next_holiday',
    'what is my leave balance': 'leave_balance',
    'am I a manager': 'my_roles',
    'what is my job title': 'my_job_title',
    'what assets do I have': 'my_assets',
    'what is the weather today': null,
    'tell me a joke': null,
  };
  const arSamples = {
    'كيف ابصم': 'punch',
    'ممكن اسجل الانصراف ازاي': 'punch',
    'لماذا تم رفض البصمة': 'punch_rejected',
    'هل استطيع البصم بدون انترنت': 'punch_offline',
    'اين ارى سجل حضوري': 'my_punches',
    'عايز اطلب اجازة': 'request_leave',
    'ازاي اخذ يوم عطلة': 'request_leave',
    'كيف استأذن واخرج مبكرا': 'request_permission',
    'كيف اطلب العمل من المنزل': 'request_mission',
    'كيف ارفق ملف بالطلب': 'request_attachment',
    'كيف اتابع حالة طلبي': 'track_request',
    'كيف الغي طلبي': 'ask_ignore',
    'اين رصيد اجازاتي': 'leave_balance',
    'اين ارى قسيمة راتبي': 'payslip',
    'كيف اطلب سلفة': 'salary_advance',
    'كيف اقدم مطالبة مصروفات': 'expense_claim',
    'هل تم خصم مني': 'rewards_penalties',
    'اين مهامي': 'tasks',
    'كيف اكتب التقرير اليومي': 'daily_report',
    'كيف اطلب ساعات اضافية': 'overtime',
    'كيف اغير الوردية': 'shift_change',
    'كيف اغير كلمة المرور': 'change_password',
    'ازاي اغير اللغة': 'change_language',
    'كيف اسجل الخروج': 'logout',
    'كيف اوافق على طلب': 'mgr_approve',
    'من الغائب اليوم': 'mgr_team_today',
    'كيف ارى بصمات الفريق': 'mgr_team_punches',
    'كيف اتواصل مع الشركة': 'contact_us',
    'ما هو قسمي': 'my_department',
    'ايش اسم قسمي': 'my_department',
    'اخبرني عن حسابي': 'my_account',
    'ما هو رقم هاتفي': 'my_phone',
    'كيف اغير رقم هاتفي': 'edit_profile',
    'متى انضممت للشركة': 'my_hire_date',
    'ما هي مواعيد عملي': 'my_work_hours',
    'متى يبدأ دوامي': 'my_work_hours',
    'كم رصيد اجازاتي': 'leave_balance',
    'متى الاجازة الرسمية القادمة': 'next_holiday',
    'هل انا مدير': 'my_roles',
    'ما هي عهدتي': 'my_assets',
    'كيف حال الطقس اليوم': null,
    'احكي لي نكتة': null,
  };

  // عامية مصرية
  const egSamples = {
      'عايز اخد اجازة بكرة': 'request_leave',
      'ازاي ابصم': 'punch',
      'البصمة مش راضية تتسجل': 'punch_rejected',
      'فين المرتب بتاعي': 'payslip',
      'عايز سلفة': 'salary_advance',
      'قسمي ايه': 'my_department',
      'انا في قسم ايه': 'my_department',
      'رصيد اجازاتي كام': 'leave_balance',
      'فاضلي كام يوم اجازة': 'leave_balance',
      'الاجازة الرسمية الجاية امتى': 'next_holiday',
      'مواعيد شغلي ايه': 'my_work_hours',
      'انا مدير ولا لا': 'my_roles',
      'رقم تليفوني ايه': 'my_phone',
      'ازاي اغير رقم تليفوني': 'edit_profile',
      'ازاي اغير الباسورد': 'change_password',
      'اقدم شكوى ازاي': 'complaint',
      'مين غايب النهارده': 'mgr_team_today',
      'قولي بياناتي': 'my_account',
      'انا بشتغل هنا بقالي قد ايه': 'my_hire_date',
      'عندي عهدة ايه': 'my_assets',
      'عايز اشتغل من البيت': 'request_mission',
      'عايز امشي بدري النهارده': 'request_permission',
      'ازاي اشوف طلباتي': 'track_request',
      'ازاي اوافق على طلب': 'mgr_approve',
      'ازاي اغير اللغة': 'change_language',
      'اجازتي الاسبوعية امتى': 'my_weekend',
      };

  for (final lang in ['en', 'ar', 'eg']) {
    test('$lang sample questions', () {
      final entries = loadFile(lang == 'en' ? 'en' : 'ar');
      final failures = <String>[];
      ({'en': enSamples, 'ar': arSamples, 'eg': egSamples}[lang]!).forEach((q, expected) {
        final r = HelpRepo.match(q, entries);
        if (r.best?.id != expected) {
          failures.add('"$q" -> ${r.best?.id} (expected $expected), '
              'suggestions: ${r.suggestions.map((e) => e.id).toList()}');
        }
      });
      expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
    });
  }
}
