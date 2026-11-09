import 'dart:ui' as ui;

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/assistant_controller.dart';
import 'assistant_actions_widget.dart';
import 'assistant_avatar_widget.dart';
import 'package:app_test/core/constants/app_design.dart';

/// نافذة المساعد عند "Hey TeamMind": لوحة في النصف السفلي من الشاشة فوق أي
/// صفحة، والجزء العلوي ضبابي ومعتم (الضغط عليه يغلقها). فيها الشعار المتحرك،
/// شخصية Mr. TeamMind المتحركة، ما يسمعه المساعد ثم رده، وزر فتح الشاشة المرتبطة، والتكبير، والميكروفون.
class AssistantFloatingWidget extends StatelessWidget {
  const AssistantFloatingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AssistantController>();
    final reply = c.messages.isNotEmpty && !c.messages.last.isUser
        ? c.messages.last
        : null;
    final showReply = !c.isListeningQuestion && reply != null;
    final mode = c.isSpeaking
        ? AssistantAvatarMode.speaking
        : c.isListeningQuestion
            ? AssistantAvatarMode.listening
            : AssistantAvatarMode.idle;

    final String text;
    if (c.isListeningQuestion) {
      text = c.partialText.isEmpty
          ? AppStrings.assistantListening.tr()
          : c.partialText;
    } else if (showReply) {
      text = reply.text;
    } else {
      text = c.error ?? AppStrings.assistantListening.tr();
    }

    final height = MediaQuery.sizeOf(context).height * 0.5;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Stack(
        children: [
          // الخلفية: ضبابية وتعتيم يظهران تدريجياً
          Positioned.fill(
            child: GestureDetector(
              onTap: c.hideFloating,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8 * t, sigmaY: 8 * t),
                child:
                    ColoredBox(color: Colors.black.withValues(alpha: 0.25 * t)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -height * (1 - t),
            height: height,
            child: child!,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          boxShadow: AppShadows.raised,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.s16, AppSizes.s8, AppSizes.s16, AppSizes.s12),
              child: Column(
                children: [
                  // مقبض السحب + الإغلاق والتكبير
                  Row(
                    children: [
                      IconButton(
                        onPressed: c.expandFloating,
                        icon:
                            const Icon(Icons.open_in_full, size: AppSizes.s20),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: c.hideFloating,
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  AssistantLiveAvatarWidget(mode: mode, size: 110),
                  const SizedBox(height: AppSizes.s12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            text,
                            textAlign: TextAlign.center,
                            textDirection: assistantTextDirection(text),
                            style: c.isListeningQuestion
                                ? AppStyles.hintContent(context)
                                    .copyWith(fontSize: AppSizes.s16)
                                : AppStyles.content(context),
                          ),
                          if (showReply && reply.suggestions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSizes.s12),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: AppSizes.s8,
                                runSpacing: AppSizes.s4,
                                children: [
                                  for (final s in reply.suggestions)
                                    AssistantSuggestionChip(
                                      label: s.title,
                                      onPressed: () => c.answerWithEntry(s),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showReply && reply.entry?.route != null) ...[
                        AssistantOpenButton(
                            onPressed: () => c.openEntry(context, reply.entry!)),
                        const SizedBox(width: AppSizes.s12),
                      ],
                      IconButton.filled(
                        onPressed:
                            c.isSpeaking ? c.stopSpeaking : c.toggleListening,
                        style: IconButton.styleFrom(
                          backgroundColor: c.isListeningQuestion
                              ? Colors.redAccent
                              : Color(AppColors.secondaryButton),
                        ),
                        icon: Icon(
                          c.isSpeaking
                              ? Icons.volume_off
                              : c.isListeningQuestion
                                  ? Icons.stop
                                  : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// شخصية Mr. TeamMind مربوطة بمستوى الصوت ونبضات الكلمات من الكنترولر.
class AssistantLiveAvatarWidget extends StatelessWidget {
  final AssistantAvatarMode mode;
  final double size;
  const AssistantLiveAvatarWidget(
      {super.key, required this.mode, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final c = context.read<AssistantController>();
    return ValueListenableBuilder<double>(
      valueListenable: c.soundLevel,
      builder: (_, level, __) => ValueListenableBuilder<int>(
        valueListenable: c.wordTick,
        builder: (_, tick, __) => AssistantAvatarWidget(
          mode: mode,
          level: level,
          wordTick: tick,
          size: size,
        ),
      ),
    );
  }
}
