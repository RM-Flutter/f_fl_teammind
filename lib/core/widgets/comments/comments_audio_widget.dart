import 'package:app_test/core/constants/app_sizes.dart';
import 'dart:math' as math;

import 'package:app_test/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// WhatsApp-style voice note player: round play/pause button, a seekable
/// waveform that fills as it plays, remaining time and a 1x/1.5x/2x speed chip.
class VoiceMessageWidget extends StatefulWidget {
  final String audioUrl;

  const VoiceMessageWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  static const _speeds = [1.0, 1.5, 2.0];

  late final AudioPlayer _audioPlayer;
  late final List<double> _bars;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  int _speedIndex = 0;
  double? _dragFraction;

  @override
  void initState() {
    super.initState();
    _bars = _WaveformPainter.barsFor(widget.audioUrl);
    _audioPlayer = AudioPlayer();

    _audioPlayer.setUrl(widget.audioUrl).catchError((_) {
      if (mounted) setState(() => _hasError = true);
      return null;
    });

    _audioPlayer.durationStream.listen((d) {
      if (!mounted || d == null) return;
      setState(() => _duration = d);
    });

    _audioPlayer.positionStream.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        // Rewind like WhatsApp so the next tap replays from the start.
        _audioPlayer.pause();
        _audioPlayer.seek(Duration.zero);
      }
      setState(() {
        _isPlaying = state.playing && state.processingState != ProcessingState.completed;
        _isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });
  }

  Future<void> _togglePlayPause() async {
    if (_hasError) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      AudioPlaybackManager().registerPlayer(_audioPlayer); // Stop previous player
      await _audioPlayer.play();
    }
  }

  Future<void> _cycleSpeed() async {
    _speedIndex = (_speedIndex + 1) % _speeds.length;
    await _audioPlayer.setSpeed(_speeds[_speedIndex]);
    if (mounted) setState(() {});
  }

  void _seekToFraction(double fraction) {
    if (_duration == Duration.zero) return;
    _audioPlayer.seek(Duration(
        milliseconds: (_duration.inMilliseconds * fraction.clamp(0.0, 1.0)).round()));
  }

  @override
  void dispose() {
    AudioPlaybackManager().unregisterPlayer(_audioPlayer);
    _audioPlayer.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    final totalMs = _duration.inMilliseconds;
    final progress = _dragFraction ??
        (totalMs == 0 ? 0.0 : (_position.inMilliseconds / totalMs).clamp(0.0, 1.0));
    // Idle: show total length. Playing/seeked: show elapsed, like WhatsApp.
    final label = (_isPlaying || _position > Duration.zero)
        ? _format(_position)
        : _format(_duration);

    return Container(
      margin: const EdgeInsets.only(top: AppSizes.s6),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s6),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: _isLoading && !_hasError
                  ? const Padding(
                      padding: EdgeInsets.all(AppSizes.s10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      _hasError
                          ? Icons.error_outline
                          : (_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      color: Colors.white,
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _seekToFraction(d.localPosition.dx / width),
                  onHorizontalDragUpdate: (d) => setState(
                      () => _dragFraction = (d.localPosition.dx / width).clamp(0.0, 1.0)),
                  onHorizontalDragEnd: (_) {
                    if (_dragFraction != null) _seekToFraction(_dragFraction!);
                    setState(() => _dragFraction = null);
                  },
                  child: SizedBox(
                    height: AppSizes.s32,
                    child: CustomPaint(
                      size: Size(width, 32),
                      painter: _WaveformPainter(
                        bars: _bars,
                        progress: progress,
                        activeColor: accent,
                        inactiveColor: accent.withOpacity(0.28),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSizes.s8),
          GestureDetector(
            onTap: _cycleSpeed,
            child: _isPlaying || _speedIndex != 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s3),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_speeds[_speedIndex] == 1.0 ? '1' : _speeds[_speedIndex]}x',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: accent),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff606060)),
                  ),
          ),
          if (_isPlaying || _speedIndex != 0) ...[
            const SizedBox(width: AppSizes.s6),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff606060)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Draws rounded vertical bars; bars before [progress] use [activeColor].
/// The shape is derived from the audio URL so each voice note keeps a
/// stable, distinct waveform without decoding the audio.
class _WaveformPainter extends CustomPainter {
  static const barCount = 36;

  final List<double> bars;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  _WaveformPainter({
    required this.bars,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  static List<double> barsFor(String seed) {
    final rnd = math.Random(seed.hashCode);
    return List.generate(barCount, (_) => 0.25 + rnd.nextDouble() * 0.75);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / bars.length;
    final barWidth = math.min(3.0, slot * 0.6);
    final paint = Paint()..strokeCap = StrokeCap.round..strokeWidth = barWidth;
    final mid = size.height / 2;
    for (var i = 0; i < bars.length; i++) {
      final x = slot * i + slot / 2;
      final half = math.max(barWidth / 2, bars[i] * size.height / 2);
      paint.color = (i + 0.5) / bars.length <= progress ? activeColor : inactiveColor;
      canvas.drawLine(Offset(x, mid - half), Offset(x, mid + half), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.activeColor != activeColor || old.bars != bars;
}

class AudioPlaybackManager {
  static final AudioPlaybackManager _instance = AudioPlaybackManager._internal();

  factory AudioPlaybackManager() => _instance;
  AudioPlaybackManager._internal();

  AudioPlayer? _currentPlayer;

  void registerPlayer(AudioPlayer player) {
    if (_currentPlayer != null && _currentPlayer != player) {
      _currentPlayer!.stop();
    }
    _currentPlayer = player;
  }

  void unregisterPlayer(AudioPlayer player) {
    if (_currentPlayer == player) {
      _currentPlayer = null;
    }
  }
}
