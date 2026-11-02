import 'dart:convert';
import 'dart:math' as math;

import 'package:app_test/core/helpers/package_helper.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:flutter/services.dart';

import '../models/help_entry_model.dart';

/// نتيجة المطابقة: [best] لو الثقة كافية، وإلا [suggestions] (أقرب 3 مواضيع).
class HelpMatchResult {
  final HelpEntryModel? best;
  final List<HelpEntryModel> suggestions;

  const HelpMatchResult({this.best, this.suggestions = const []});
}

/// تحميل ملف المساعدة ومطابقة السؤال معه (بدون إنترنت وبدون نموذج ذكاء).
abstract class HelpRepo {
  static const double matchThreshold = 2.5;
  static const int maxSuggestions = 3;

  static final Map<String, List<HelpEntryModel>> _cache = {};

  static const Set<String> _fillers = {
    // English
    'how', 'can', 'could', 'do', 'does', 'did', 'i', 'we', 'you', 'the', 'a',
    'an', 'to', 'my', 'me', 'what', 'whats', 'is', 'are', 'where', 'should',
    'want', 'need', 'please', 'of', 'for', 'in', 'on', 'it', 'be', 'get',
    'would', 'like', 'know', 'tell', 'about', 'with', 'there', 'way',
    // Arabic
    'كيف', 'ممكن', 'عايز', 'عايزه', 'اريد', 'ابغي', 'ابي', 'اقدر', 'ازاي',
    'ايش', 'شو', 'هل', 'انا', 'لو', 'سمحت', 'من', 'في', 'علي', 'الي', 'او',
    'طريقه', 'اعمل', 'اسوي', 'وين', 'فين', 'ماذا', 'ما', 'هو', 'هي', 'لي',
    'يمكنني', 'استطيع', 'بدي', 'احتاج',
    // Egyptian
    'ايه', 'امتي', 'كام', 'عاوز', 'عاوزه', 'بتاعي', 'بتاعتي', 'عندي', 'ليا', 'هنا',
    'بقالي', 'قد', 'ولا', 'لا', 'دلوقتي', 'ينفع', 'اعرف', 'بقي', 'كده', 'يعني', 'طب',
  };

  static final RegExp _diacritics = RegExp('[ً-ٰٟـ]');
  static final RegExp _nonWord = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);

  /// يحمّل مدخلات اللغة ([lang] = en | ar) من الـ assets مع كاش في الذاكرة.
  static Future<List<HelpEntryModel>> load(String lang) async {
    final code = lang == 'ar' ? 'ar' : 'en';
    final cached = _cache[code];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/json/assistant/help_$code.json');
    final entries = (json.decode(raw) as List)
        .map((e) => HelpEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return _cache[code] = entries;
  }

  /// المدخلات الظاهرة للمستخدم الحالي (حسب الباكدج ودور المدير).
  static List<HelpEntryModel> visibleEntries(List<HelpEntryModel> all) {
    final manager = isManagerUser();
    return all
        .where((e) =>
            (e.package == null || PackageHelper.hasPackage(e.package!)) &&
            (!e.managerOnly || manager))
        .toList();
  }

  /// مدير = `is_manager_in` غير فارغ أو HR أو إدارة عليا (من كاش US1).
  static bool isManagerUser() {
    try {
      final raw = CacheHelper.getString('US1');
      if (raw == null || raw.toString().isEmpty) return false;
      final us1 = json.decode(raw) as Map<String, dynamic>;
      final managerIn = us1['is_manager_in'];
      return (managerIn is List && managerIn.isNotEmpty) ||
          us1['is_hr'] == true ||
          us1['top_management'] == true;
    } catch (_) {
      return false;
    }
  }

  /// تطبيع النص: lowercase، إزالة التشكيل والتطويل، توحيد الحروف العربية.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(_diacritics, '')
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll("'", '')
        .replaceAll(_nonWord, ' ');
  }

  /// كلمات السؤال بعد التطبيع وحذف الكلمات الشائعة وتبسيط بسيط للجذر.
  static List<String> tokens(String text) {
    return normalize(text)
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !_fillers.contains(w))
        .map(_stem)
        .where((w) => w.isNotEmpty)
        .toList();
  }

  static String _stem(String w) {
    if (w.length > 4 && w.startsWith('ال')) w = w.substring(2);
    if (w.length > 3 && w.endsWith('s') && !w.endsWith('ss')) {
      w = w.substring(0, w.length - 1);
    }
    return w;
  }

  /// درجة مدخل واحد للسؤال [q] (كلماته بعد [tokens]).
  static double score(HelpEntryModel entry, Set<String> q) {
    if (q.isEmpty) return 0;
    var score = 0.0;

    // +3 لكل كلمة مفتاحية (كل كلماتها موجودة في السؤال). الكلمات التي تصبح
    // متطابقة بعد التطبيع (اجازة / اجازه) تُحسب مرة واحدة.
    final seen = <String>{};
    for (final k in entry.keywords) {
      final kt = tokens(k);
      if (kt.isEmpty || !seen.add(kt.join(' '))) continue;
      if (kt.every(q.contains)) score += 3;
    }

    // تقاطع الكلمات مع أمثلة الأسئلة، مقيّس من 0 إلى 2
    var best = 0.0;
    for (final s in entry.questions) {
      final st = tokens(s).toSet();
      if (st.isEmpty) continue;
      final common = st.intersection(q).length;
      final dice = 2 * common / (st.length + q.length);
      if (dice > best) best = dice;
    }
    score += 2 * best;

    // +1 لو ظهرت كلمة من العنوان
    if (tokens(entry.title).any(q.contains)) score += 1;
    return score;
  }

  // كلمات تكشف نوع السؤال قبل حذف الكلمات الشائعة: سؤال بيانات أم كيفية.
  static const Set<String> _dataWords = {
    'what', 'whats', 'which', 'when', 'who', 'tell', 'show', 'list', 'am',
    'ما', 'ماذا', 'متي', 'مين', 'ايش', 'شو', 'وش', 'اعرض', 'اخبرني', 'عرفني',
    'قولي', 'هو', 'هي', 'ايه', 'امتي',
  };
  static const Set<String> _countWords = {'many', 'much', 'كم', 'كام'};
  static const Set<String> _howWords = {
    'how', 'change', 'edit', 'update', 'modify', 'reset', 'add', 'create',
    'submit', 'request', 'apply', 'send', 'كيف', 'ازاي', 'اغير', 'اعدل', 'تغيير',
    'تعديل', 'احدث', 'اضيف', 'اطلب', 'اقدم', 'ارسل', 'اعمل',
  };

  /// 'data' أو 'howto' أو null حسب كلمات السؤال ("how many" سؤال بيانات).
  static String? intentOf(String question) {
    final words = normalize(question).split(RegExp(r'\s+')).toSet();
    if (words.any(_countWords.contains)) return 'data';
    if (words.any(_howWords.contains)) return 'howto';
    if (words.any(_dataWords.contains)) return 'data';
    return null;
  }

  /// يختار أفضل مدخل، أو يرجّع أقرب 3 مواضيع لو الدرجة أقل من الحد.
  static HelpMatchResult match(String question, List<HelpEntryModel> entries) {
    final q = tokens(question).toSet();
    if (q.isEmpty || entries.isEmpty) {
      return HelpMatchResult(suggestions: entries.take(maxSuggestions).toList());
    }
    // ميل بسيط نحو نوع المدخل المطابق لنوع السؤال، فيفرّق بين
    // "ما رقم هاتفي؟" و"كيف أغير رقم هاتفي؟" رغم تشابه الكلمات.
    final intent = intentOf(question);
    // المكافأة فقط لمطابقة جيدة أصلاً (حتى لا ترفع سؤالاً خارج الموضوع فوق الحد).
    double total(HelpEntryModel e) {
      final s = score(e, q);
      if (intent == null || s <= 0) return s;
      if (e.kind == intent) return s >= 2 ? s + 1.5 : s;
      return math.max(0, s - 1.5);
    }

    final scored = entries.map((e) => MapEntry(e, total(e))).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (scored.first.value >= matchThreshold) {
      return HelpMatchResult(best: scored.first.key);
    }
    return HelpMatchResult(
      suggestions: scored
          .where((e) => e.value > 0)
          .take(maxSuggestions)
          .map((e) => e.key)
          .toList(),
    );
  }
}
