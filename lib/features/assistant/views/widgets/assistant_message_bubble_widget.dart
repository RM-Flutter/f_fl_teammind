import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter/material.dart';

import '../../data/models/assistant_message_model.dart';
import '../../data/models/help_entry_model.dart';
import 'assistant_actions_widget.dart';

/// فقاعة رسالة: سؤال المستخدم أو رد المساعد (مع زر Open وأقرب المواضيع).
class AssistantMessageBubbleWidget extends StatelessWidget {
  final AssistantMessageModel message;
  final void Function(HelpEntryModel entry) onOpen;
  final void Function(HelpEntryModel entry) onSuggestion;

  const AssistantMessageBubbleWidget({
    super.key,
    required this.message,
    required this.onOpen,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final entry = message.entry;
    return Align(
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSizes.s4),
          padding: const EdgeInsets.all(AppSizes.s12),
          decoration: BoxDecoration(
            color: isUser
                ? Color(AppColors.secondaryButton)
                : Color(AppColors.chipBackground),
            borderRadius: BorderRadius.circular(AppSizes.s16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                textDirection: assistantTextDirection(message.text),
                style: (isUser
                        ? AppStyles.whiteContent(context)
                        : AppStyles.content(context))
                    .copyWith(fontSize: 14, height: 1.45),
              ),
              if (entry?.route != null) ...[
                const SizedBox(height: AppSizes.s12),
                AssistantOpenButton(onPressed: () => onOpen(entry!)),
              ],
              if (message.suggestions.isNotEmpty) ...[
                const SizedBox(height: AppSizes.s8),
                Wrap(
                  spacing: AppSizes.s8,
                  runSpacing: AppSizes.s6,
                  children: [
                    for (final s in message.suggestions)
                      AssistantSuggestionChip(label: s.title, onPressed: () => onSuggestion(s)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
