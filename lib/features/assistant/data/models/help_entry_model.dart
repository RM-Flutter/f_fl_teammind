/// مدخل واحد في ملف المساعدة (assets/json/assistant/help_<lang>.json).
class HelpEntryModel {
  final String id;
  final String title;
  final List<String> keywords;
  final List<String> questions;
  final String answer;

  /// اسم الـ route (من AppRoutes) لزر "Open"، اختياري.
  final String? route;
  final Map<String, String> params;
  final Map<String, dynamic>? extra;

  /// يُخفى المدخل لو الباكدج غير مفعّل.
  final String? package;

  /// يُخفى المدخل لغير المديرين.
  final bool managerOnly;

  /// `howto` (كيف أفعل...)، `data` (سؤال عن بيانات حسابي: ما قسمي؟ كم رصيدي؟)،
  /// أو `chat` (دردشة: أهلاً، ازيك، الساعة كام).
  /// إجابات `data` قوالب مثل {department} تُملأ من UserDataRepo.
  final String kind;

  /// الرد عندما لا توجد أي بيانات لملء القالب.
  final String? noData;

  bool get isData => kind == 'data';

  /// دردشة عادية: تحية، ازيك، الساعة كام، مين عملك...
  bool get isChat => kind == 'chat';

  const HelpEntryModel({
    required this.id,
    required this.title,
    required this.keywords,
    required this.questions,
    required this.answer,
    this.route,
    this.params = const {},
    this.extra,
    this.package,
    this.managerOnly = false,
    this.kind = 'howto',
    this.noData,
  });

  factory HelpEntryModel.fromJson(Map<String, dynamic> json) {
    List<String> strings(dynamic v) =>
        (v is List) ? v.map((e) => e.toString()).toList() : const [];
    final id = json['id'].toString();
    return HelpEntryModel(
      id: id,
      title: (json['title'] ?? id.replaceAll('_', ' ')).toString(),
      keywords: strings(json['keywords']),
      questions: strings(json['questions']),
      answer: (json['answer'] ?? '').toString(),
      route: json['route']?.toString(),
      params: (json['params'] is Map)
          ? (json['params'] as Map)
              .map((k, v) => MapEntry(k.toString(), v.toString()))
          : const {},
      extra: json['extra'] is Map
          ? Map<String, dynamic>.from(json['extra'] as Map)
          : null,
      package: json['package']?.toString(),
      managerOnly: json['managerOnly'] == true,
      kind: json['kind']?.toString() ?? 'howto',
      noData: json['noData']?.toString(),
    );
  }
}
