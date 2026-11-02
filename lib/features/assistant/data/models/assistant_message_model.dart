import 'help_entry_model.dart';

/// رسالة في شاشة المساعد: سؤال المستخدم أو رد المساعد.
class AssistantMessageModel {
  final String text;
  final bool isUser;

  /// المدخل الذي أُجيب منه (لزر "Open").
  final HelpEntryModel? entry;

  /// أقرب المواضيع عند عدم التأكد من الإجابة.
  final List<HelpEntryModel> suggestions;

  const AssistantMessageModel({
    required this.text,
    required this.isUser,
    this.entry,
    this.suggestions = const [],
  });
}
