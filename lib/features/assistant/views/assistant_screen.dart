import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/assistant_controller.dart';
import '../data/models/assistant_message_model.dart';
import 'widgets/assistant_floating_widget.dart';
import 'widgets/assistant_message_bubble_widget.dart';
import 'widgets/assistant_avatar_widget.dart';
import 'widgets/assistant_mic_button_widget.dart';

/// شاشة مساعد TeamMind: محادثة نصية وصوتية بإجابات من ملف مساعدة محلي.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late final AssistantController _controller;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = context.read<AssistantController>();
    _lastCount = _controller.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.setScreenOpen(true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.setScreenOpen(false));
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    _controller.ask(text);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssistantController>(
      builder: (context, c, _) {
        c.syncLanguage(context.locale.languageCode);
        if (c.messages.length != _lastCount) {
          _lastCount = c.messages.length;
          _scrollToEnd();
        }
        return Scaffold(
          backgroundColor: const Color(0xffFFFFFF),
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: const Color(0xffFFFFFF),
            title: Text(
              AppStrings.teamMindAssistant.tr(),
              style: AppStyles.heading(context)
                  .copyWith(fontSize: AppSizes.s16, fontWeight: FontWeight.w700),
            ),
            actions: [
              if (c.isSpeaking)
                IconButton(
                  onPressed: c.stopSpeaking,
                  icon: const Icon(Icons.volume_off),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (!kIsWeb)
                  SwitchListTile(
                    value: c.wakeEnabled,
                    onChanged: c.setWakeEnabled,
                    activeThumbColor: Color(AppColors.secondaryButton),
                    title: Text(AppStrings.assistantWakeSwitch.tr(),
                        style: AppStyles.content(context)),
                    subtitle: Text(AppStrings.assistantWakeSwitchHint.tr(),
                        style: AppStyles.hintContent(context)),
                  ),
                if (!kIsWeb && c.enrolling)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                    padding: const EdgeInsets.all(AppSizes.s12),
                    decoration: BoxDecoration(
                      color: Color(AppColors.chipBackground),
                      borderRadius: BorderRadius.circular(AppSizes.s16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.assistantEnrollPrompt.tr(args: [
                            '${(c.enrollDone + 1).clamp(1, AssistantController.enrollTotal)}',
                            '${AssistantController.enrollTotal}',
                          ]),
                          textAlign: TextAlign.center,
                          style: AppStyles.content(context),
                        ),
                        const SizedBox(height: AppSizes.s8),
                        LinearProgressIndicator(
                          value: c.enrollDone / AssistantController.enrollTotal,
                          color: Color(AppColors.secondaryButton),
                        ),
                        const SizedBox(height: AppSizes.s4),
                        Text(AppStrings.assistantEnrollNote.tr(),
                            textAlign: TextAlign.center,
                            style: AppStyles.hintContent(context)),
                        TextButton(
                          onPressed: c.cancelEnrollment,
                          style: TextButton.styleFrom(
                            textStyle: AppStyles.content(context).copyWith(fontSize: 13),
                          ),
                          child: Text(AppStrings.assistantEnrollCancel.tr()),
                        ),
                      ],
                    ),
                  )
                else if (!kIsWeb && c.hasVoiceprint)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                      child: TextButton.icon(
                        onPressed: c.startEnrollment,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(AppColors.brandBlue),
                          textStyle: AppStyles.content(context)
                              .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        icon: const Icon(Icons.mic_none_rounded, size: 18),
                        label: Text(AppStrings.assistantEnrollRedo.tr()),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(AppSizes.s16),
                    children: [
                      AssistantMessageBubbleWidget(
                        message: _greeting,
                        onOpen: (_) {},
                        onSuggestion: (_) {},
                      ),
                      for (final m in c.messages)
                        AssistantMessageBubbleWidget(
                          message: m,
                          onOpen: (e) => c.openEntry(context, e),
                          onSuggestion: c.answerWithEntry,
                        ),
                    ],
                  ),
                ),
                if (c.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16),
                    child: Text(c.error!, style: AppStyles.redContent(context)),
                  ),
                if (c.isListeningQuestion || c.isSpeaking)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s16, vertical: AppSizes.s4),
                    child: Row(
                      children: [
                        AssistantLiveAvatarWidget(
                          mode: c.isSpeaking
                              ? AssistantAvatarMode.speaking
                              : AssistantAvatarMode.listening,
                          size: 44,
                        ),
                        const SizedBox(width: AppSizes.s12),
                        if (c.isListeningQuestion)
                          Expanded(
                            child: Text(
                              c.partialText.isEmpty
                                  ? AppStrings.assistantListening.tr()
                                  : c.partialText,
                              style: AppStyles.hintContent(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.s12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: AppStrings.assistantTypeHint.tr(),
                            suffixIcon: IconButton(
                              onPressed: _send,
                              icon: const Icon(Icons.send),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.s8),
                      AssistantMicButtonWidget(
                        listening: c.isListeningQuestion,
                        onPressed: c.toggleListening,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// أول رسالة ثابتة (لا تُخزَّن في المحادثة حتى تتبع لغة التطبيق).
  AssistantMessageModel get _greeting => AssistantMessageModel(
        text: AppStrings.assistantGreeting.tr(),
        isUser: false,
      );
}
