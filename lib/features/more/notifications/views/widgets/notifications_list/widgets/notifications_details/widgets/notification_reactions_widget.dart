import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/features/more/notifications/controllers/notification_controller.dart';
import 'package:app_test/features/more/notifications/data/models/notification_emotion_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationReactionsWidget extends StatefulWidget {
  final dynamic notificationId;

  const NotificationReactionsWidget({
    required this.notificationId,
    super.key,
  });

  @override
  State<NotificationReactionsWidget> createState() =>
      _NotificationReactionsWidgetState();
}

class _NotificationReactionsWidgetState
    extends State<NotificationReactionsWidget> {
  static const Map<String, String> _emojiMap = {
    'like': '👍',
    'love': '❤️',
    'care': '🤗',
    'haha': '😂',
    'wow': '😮',
    'sad': '😢',
    'angry': '😡',
  };

  static const Map<String, Color> _colorMap = {
    'like': Color(0xFF1877F2),
    'love': Color(0xFFE0245E),
    'care': Color(0xFFF7B928),
    'haha': Color(0xFFF7B928),
    'wow': Color(0xFFF7B928),
    'sad': Color(0xFF5B88CB),
    'angry': Color(0xFFE9710F),
  };

  static const Map<String, String> _labelMap = {
    'like': 'Like',
    'love': 'Love',
    'care': 'Care',
    'haha': 'Haha',
    'wow': 'Wow',
    'sad': 'Sad',
    'angry': 'Angry',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProviderModel>(
      builder: (context, controller, _) {
        final emotionData = controller.emotionData;

        if (emotionData == null || emotionData.allowed != true) {
          return const SizedBox.shrink();
        }

        final String? userReaction = emotionData.userReaction;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if ((emotionData.totalCount ?? 0) > 0)
              _buildSummaryBar(emotionData),
            if ((emotionData.totalCount ?? 0) > 0) const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _emojiMap.keys.map((emotionKey) {
                  final bool isSelected = userReaction == emotionKey;
                  final String e = _emojiMap[emotionKey] ?? '';
                  final Color c = _colorMap[emotionKey] ??  Color(AppColors.secondaryButton);
                  
                  return GestureDetector(
                    onTap: () {
                      if (controller.isEmotionLoading) return;
                      controller.reactToNotification(
                        context,
                        widget.notificationId,
                        emotion: isSelected ? null : emotionKey,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? c.withOpacity(0.15) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? c.withOpacity(0.5) : Colors.transparent,
                        )
                      ),
                      child: Text(e, style: TextStyle(fontSize: isSelected ? 28 : 22)),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (controller.isEmotionLoading) ...[
              const SizedBox(height: 12),
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSummaryBar(NotificationEmotionModel emotionData) {
    final summary = emotionData.summary;
    if (summary == null) return const SizedBox.shrink();

    final sorted = _emojiMap.keys
        .where((k) => summary.getCount(k) > 0)
        .toList()
      ..sort((a, b) => summary.getCount(b).compareTo(summary.getCount(a)));

    if (sorted.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Column(
                children: [
                  const Text(
                    'Reactions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade200, height: 1),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: sorted.map((key) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(_emojiMap[key]!, style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 14),
                            Text(
                              _labelMap[key] ?? key,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ],
                        ),
                        Text(
                          '${summary.getCount(key)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor:  Color(AppColors.secondaryButton),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...sorted.take(3).map(
                  (k) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Text(_emojiMap[k]!, style: const TextStyle(fontSize: 16)),
                  ),
                ),
            const SizedBox(width: 6),
            Text(
              '${emotionData.totalCount ?? 0}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
