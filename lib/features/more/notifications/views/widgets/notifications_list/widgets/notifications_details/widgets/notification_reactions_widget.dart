import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/features/more/notifications/controllers/notification_controller.dart';
import 'package:app_test/features/more/notifications/data/models/notification_emotion_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Facebook-style reactions widget for notifications.
///
/// - Tap the button → like (or remove if already liked).
/// - Long-press the button → popup with all 7 reactions.
/// - Tapping any reaction in the popup applies it (or removes it if same).
/// - Renders nothing when reactions are not allowed (`emotionData.allowed != true`).
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
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  // ── Emotion meta ─────────────────────────────────────────────────────────

  static const Map<String, String> _emojiMap = {
    'like': '👍',
    'love': '❤️',
    'care': '🤗',
    'haha': '😂',
    'wow': '😮',
    'sad': '😢',
    'angry': '😡',
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

  static const Map<String, Color> _colorMap = {
    'like': Color(0xFF1877F2),
    'love': Color(0xFFE0245E),
    'care': Color(0xFFF7B928),
    'haha': Color(0xFFF7B928),
    'wow': Color(0xFFF7B928),
    'sad': Color(0xFF5B88CB),
    'angry': Color(0xFFE9710F),
  };

  // ── Overlay logic ─────────────────────────────────────────────────────────

  void _showReactionsPopup(
      BuildContext context, NotificationProviderModel controller) {
    _removeOverlay(); // remove any previous popup

    final RenderBox? box =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset pos = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final double screenW = MediaQuery.of(context).size.width;

    // Popup dimensions
    const double popupH = 78;
    const double popupW = 310;

    double left = pos.dx + size.width / 2 - popupW / 2;
    left = left.clamp(8, screenW - popupW - 8);
    double top = pos.dy - popupH - 8;
    if (top < 0) top = pos.dy + size.height + 8;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Invisible full-screen tap-away dismissal
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          // Reaction popup
          Positioned(
            left: left,
            top: top,
            child: _ReactionPopup(
              emojiMap: _emojiMap,
              labelMap: _labelMap,
              onSelect: (emotion) {
                _removeOverlay();
                controller.reactToNotification(
                  context,
                  widget.notificationId,
                  emotion: emotion,
                );
              },
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProviderModel>(
      builder: (context, controller, _) {
        final emotionData = controller.emotionData;

        // Hide widget if reactions are not allowed or data not loaded yet
        if (emotionData == null || emotionData.allowed != true) {
          return const SizedBox.shrink();
        }

        final String? userReaction = emotionData.userReaction;
        final bool hasReacted =
            userReaction != null && userReaction.isNotEmpty;

        final String emoji = hasReacted
            ? (_emojiMap[userReaction] ?? '👍')
            : '👍';
        final String label = hasReacted
            ? (_labelMap[userReaction] ?? 'Like')
            : 'Like';
        final Color reactionColor = hasReacted
            ? (_colorMap[userReaction] ?? Color(AppColors.secondaryButton))
            : const Color(0xFF65676B);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Summary bar ────────────────────────────────────────────────
            if ((emotionData.totalCount ?? 0) > 0)
              _buildSummaryBar(emotionData),
            if ((emotionData.totalCount ?? 0) > 0) const SizedBox(height: 10),

            // ── Reaction button ────────────────────────────────────────────
            GestureDetector(
              key: _buttonKey,
              onTap: () {
                if (controller.isEmotionLoading) return;
                if (hasReacted) {
                  // Remove current reaction
                  controller.reactToNotification(
                    context,
                    widget.notificationId,
                  );
                } else {
                  // Default: add 'like'
                  controller.reactToNotification(
                    context,
                    widget.notificationId,
                    emotion: 'like',
                  );
                }
              },
              onLongPress: () =>
                  _showReactionsPopup(context, controller),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: hasReacted
                      ? reactionColor.withOpacity(0.08)
                      : Colors.transparent,
                  border: Border.all(
                    color: hasReacted
                        ? reactionColor.withOpacity(0.4)
                        : const Color(0xFFCED0D4),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    controller.isEmotionLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: reactionColor,
                            ),
                          )
                        : Text(emoji,
                            style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: reactionColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      child: Text(label),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hold hint ──────────────────────────────────────────────────
            const SizedBox(height: 4),
            Text(
              'Hold to choose a reaction',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildSummaryBar(NotificationEmotionModel emotionData) {
    final summary = emotionData.summary;
    if (summary == null) return const SizedBox.shrink();

    // Sort reactions by count (desc) and keep non-zero ones
    final sorted = _emojiMap.keys
        .where((k) => summary.getCount(k) > 0)
        .toList()
      ..sort((a, b) => summary.getCount(b).compareTo(summary.getCount(a)));

    if (sorted.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top 3 emojis
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
    );
  }
}

// ── Popup widget ────────────────────────────────────────────────────────────

class _ReactionPopup extends StatefulWidget {
  final Map<String, String> emojiMap;
  final Map<String, String> labelMap;
  final void Function(String emotion) onSelect;

  const _ReactionPopup({
    required this.emojiMap,
    required this.labelMap,
    required this.onSelect,
  });

  @override
  State<_ReactionPopup> createState() => _ReactionPopupState();
}

class _ReactionPopupState extends State<_ReactionPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  String? _hoveredKey;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        alignment: Alignment.bottomCenter,
        child: Material(
          elevation: 10,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.emojiMap.entries.map((entry) {
                final isHovered = _hoveredKey == entry.key;
                return GestureDetector(
                  onTap: () => widget.onSelect(entry.key),
                  child: MouseRegion(
                    onEnter: (_) =>
                        setState(() => _hoveredKey = entry.key),
                    onExit: (_) =>
                        setState(() => _hoveredKey = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: isHovered ? 1.4 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              fontSize: isHovered ? 10 : 8,
                              color: isHovered
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                              fontWeight: isHovered
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            child:
                                Text(widget.labelMap[entry.key] ?? entry.key),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
