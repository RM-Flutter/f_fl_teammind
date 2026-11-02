import 'help_entry_model.dart';

/// رسالة في شاشة المساعد: سؤال المستخدم أو رد المساعد.
class AssistantMessageModel {
  final String text;
  final bool isUser;

  /// ما يُقرأ بصوت عالٍ لو يختلف عن [text] (نسخة مشكّلة من الإجابة).
  final String? speech;

  /// المدخل الذي أُجيب منه (لزر "Open").
  final HelpEntryModel? entry;

  /// أقرب المواضيع عند عدم التأكد من الإجابة.
  final List<HelpEntryModel> suggestions;

  const AssistantMessageModel({
    required this.text,
    required this.isUser,
    this.speech,
    this.entry,
    this.suggestions = const [],
  });
}
