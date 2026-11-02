/// صوت مختار للنطق: [voice] بالشكل الذي يقبله FlutterTts.setVoice (أو null =
/// صوت اللغة الافتراضي)، و[pitch] لتخشين الصوت لو لم نجد صوتاً رجالياً.
class VoiceChoice {
  final Map<String, String>? voice;
  final String language;
  final double pitch;
  final bool isMale;

  const VoiceChoice({this.voice, required this.language, this.pitch = 1, this.isMale = false});

  @override
  String toString() =>
      '${voice?['name'] ?? 'default'} ($language, ${isMale ? 'male' : 'not male, pitch $pitch'})';
}

/// قطعة من النص بلغة واحدة: الصوت الإنجليزي لا ينطق الحروف العربية (يتخطى
/// "ابانوب")، والعربي يتلخبط في الإنجليزي، فنقرأ كل قطعة بصوتها.
class SpeechSegment {
  final String lang; // 'ar' أو 'en'
  final String text;
  const SpeechSegment(this.lang, this.text);

  @override
  String toString() => '$lang:"$text"';
}

abstract class VoicePicker {
  /// أصوات Google TTS الرجالية على أندرويد (الجزء بعد -x- في اسم الصوت).
  static const Set<String> _maleCodes = {
    'iol', 'iom', 'tpd', // en-US
    'gbb', 'gbd', 'rjs', // en-GB
    'ard', 'arz', // ar-XA
  };

  /// لو لم نجد صوتاً رجالياً نخفض طبقة الصوت المتاح.
  static const double fallbackMalePitch = 0.8;

  static String _norm(String locale) => locale.replaceAll('_', '-').toLowerCase();

  static bool _isMale(Map v) {
    final gender = '${v['gender'] ?? ''}'.toLowerCase(); // iOS يرسل gender
    if (gender == 'male') return true;
    if (gender == 'female') return false;
    final name = '${v['name'] ?? ''}'.toLowerCase();
    if (name.contains('female')) return false;
    final code = RegExp(r'-x-([a-z]{3})').firstMatch(name)?.group(1);
    if (code != null) return _maleCodes.contains(code);
    return RegExp(r'(^|[^a-z])male').hasMatch(name);
  }

  /// يختار صوتاً رجالياً للغة [lang]، مع تفضيل المنطقة [region] (مثل EG للعربي)
  /// والأصوات المحلية (تعمل بدون إنترنت).
  static VoiceChoice pick(List<dynamic> voices, String lang, {String? region}) {
    final fallbackLanguage = lang == 'ar' ? 'ar' : 'en-US';
    final candidates = voices
        .whereType<Map>()
        .where((v) => _norm('${v['locale']}').startsWith(lang))
        .toList();
    if (candidates.isEmpty) {
      return VoiceChoice(language: fallbackLanguage, pitch: fallbackMalePitch);
    }

    int rank(Map v) {
      final locale = _norm('${v['locale']}');
      final name = '${v['name']}'.toLowerCase();
      var r = 0;
      if (_isMale(v)) r += 100;
      if (region != null && locale == '$lang-${region.toLowerCase()}') r += 20;
      if (lang == 'en' && locale == 'en-us') r += 10;
      if (name.contains('local')) r += 5;
      if (name.contains('network')) r -= 5;
      return r;
    }

    candidates.sort((a, b) => rank(b).compareTo(rank(a)));
    final best = candidates.first;
    final male = _isMale(best);
    return VoiceChoice(
      voice: {'name': '${best['name']}', 'locale': '${best['locale']}'},
      language: '${best['locale']}',
      pitch: male ? 1 : fallbackMalePitch,
      isMale: male,
    );
  }

  static final RegExp _arabicLetter = RegExp(r'[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]');
  static final RegExp _latinLetter = RegExp(r'[A-Za-z]');

  /// يقسم [text] إلى قطع حسب الحروف. الأرقام والرموز والمسافات تبقى مع القطعة
  /// الحالية، والقطعة الأولى بلغة الواجهة [defaultLang] لو بدأ النص بها.
  static List<SpeechSegment> split(String text, String defaultLang) {
    final segments = <SpeechSegment>[];
    var current = defaultLang;
    final buf = StringBuffer();
    for (final ch in text.split('')) {
      final lang = _arabicLetter.hasMatch(ch)
          ? 'ar'
          : _latinLetter.hasMatch(ch)
              ? 'en'
              : null;
      if (lang != null && lang != current) {
        if (buf.toString().trim().isNotEmpty) {
          segments.add(SpeechSegment(current, buf.toString().trim()));
          buf.clear();
        }
        current = lang;
      }
      buf.write(ch);
    }
    if (buf.toString().trim().isNotEmpty) segments.add(SpeechSegment(current, buf.toString().trim()));
    return segments;
  }
}
