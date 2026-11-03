import 'package:app_test/core/services/app_error_reporter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:app_test/core/platform/platform_is.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:app_test/core/widgets/comments/logic/controller.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/app_design.dart';

class SendCommentWidget extends StatefulWidget {
  final String id;
  final String slug;
  SendCommentWidget(this.id, this.slug);

  @override
  _SendCommentWidgetState createState() =>
      _SendCommentWidgetState();
}

/// WhatsApp-style input bar: hold the mic to record, slide toward the start
/// edge to cancel, slide up to lock hands-free, release to send.
class _SendCommentWidgetState extends State<SendCommentWidget> {
  static const _cancelDistance = 100.0;
  static const _lockDistance = 70.0;
  static const _minDuration = Duration(seconds: 1);
  static const _waveformSamples = 40;

  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isLocked = false;
  bool _starting = false;
  // Set when the finger lifts (or slides to cancel) while start() is in flight.
  bool? _pendingFinishSend;
  Timer? _timer;
  StreamSubscription<Amplitude>? _ampSub;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  Offset _dragOffset = Offset.zero;
  Offset? _downPosition;
  final List<double> _levels = [];

  Future<void> _startRecording() async {
    if (_starting || _isRecording) return;
    _starting = true;
    _pendingFinishSend = null;
    try {
      if (await _audioRecorder.hasPermission()) {
        String? path;

        if (kIsWeb || PlatformIs.web) {
          path = null;
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          path = '${directory.path}/recorded_audio_$timestamp.m4a';

          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }

        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            numChannels: (kIsWeb || PlatformIs.web) ? 1 : 2,
          ),
          path: path ?? '',
        );

        HapticFeedback.mediumImpact();
        _startedAt = DateTime.now();
        _levels.clear();
        _ampSub = _audioRecorder
            .onAmplitudeChanged(const Duration(milliseconds: 100))
            .listen((amp) {
          // dBFS (-60..0) -> 0.1..1.0
          final level = ((amp.current + 60) / 60).clamp(0.0, 1.0);
          _levels.add(0.1 + level * 0.9);
          if (_levels.length > _waveformSamples) _levels.removeAt(0);
        });
        _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
          if (!mounted || _startedAt == null) return;
          setState(() => _elapsed = DateTime.now().difference(_startedAt!));
        });

        if (mounted) {
          setState(() {
            _currentRecordingPath = path;
            _isRecording = true;
            _isLocked = false;
            _elapsed = Duration.zero;
            _dragOffset = Offset.zero;
          });
        }
      } else {
        _pendingFinishSend = null;
        _downPosition = null;
      }
    } catch (e) {
      print("Error starting recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorReporter.safeMessage(e))),
        );
      }
      _pendingFinishSend = null;
    } finally {
      _starting = false;
    }

    // The user already let go before the recorder was ready.
    final pending = _pendingFinishSend;
    if (pending != null && _isRecording) {
      _pendingFinishSend = null;
      await _finishRecording(send: pending);
    }
  }

  Future<Duration?> _getAudioDuration(String? filePath) async {
    try {
      if (filePath == null && (kIsWeb || PlatformIs.web)) {
        return const Duration(seconds: 1);
      }
      if (filePath == null) return null;
      if (kIsWeb || PlatformIs.web) return const Duration(seconds: 1);

      final player = AudioPlayer();
      await player.setFilePath(filePath);
      final duration = player.duration;
      await player.dispose();
      return duration;
    } catch (e) {
      print("Error getting duration: $e");
      return const Duration(seconds: 1);
    }
  }

  void _resetRecordingState() {
    _timer?.cancel();
    _timer = null;
    _ampSub?.cancel();
    _ampSub = null;
    _startedAt = null;
    _currentRecordingPath = null;
    _downPosition = null;
    _levels.clear();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _isLocked = false;
        _elapsed = Duration.zero;
        _dragOffset = Offset.zero;
      });
    } else {
      _isRecording = false;
      _isLocked = false;
      _elapsed = Duration.zero;
      _dragOffset = Offset.zero;
    }
  }

  /// Stops the recorder. Sends the note when [send] is true and it is long
  /// enough, otherwise discards the file.
  Future<void> _finishRecording({required bool send}) async {
    if (!_isRecording) {
      // start() still in flight: remember what the user wanted.
      if (_starting) _pendingFinishSend = send;
      return;
    }
    final recordedFor = _startedAt == null
        ? Duration.zero
        : DateTime.now().difference(_startedAt!);
    String? path;
    try {
      path = await _audioRecorder.stop();
    } catch (e) {
      print("Error stopping recording: $e");
    }
    _resetRecordingState();

    final tooShort = recordedFor < _minDuration;
    if (!send || tooShort) {
      await _deleteFile(path);
      if (send && tooShort && mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppStrings.holdToRecord.tr()),
            duration: const Duration(seconds: 2),
          ));
      }
      return;
    }
    await _sendVoice(path);
  }

  Future<void> _sendVoice(String? path) async {
    if (!mounted) return;
    final provider = Provider.of<CommentProvider>(context, listen: false);
    try {
      if (path == null || path.isEmpty) {
        print("Error: Recording path is null");
        return;
      }
      if (kIsWeb || PlatformIs.web) {
        await provider.addComment(context,
            id: widget.id, voicePath: path, slug: widget.slug.toString());
        return;
      }
      final file = File(path);
      if (!await file.exists()) {
        print("Error: Recorded file does not exist.");
        return;
      }
      final duration = await _getAudioDuration(path);
      if (duration != null && duration.inSeconds > 0) {
        if (!mounted) return;
        await provider.addComment(context,
            id: widget.id, voicePath: path, slug: widget.slug.toString());
      } else {
        print("Error: Recorded audio has zero duration!");
      }
      await _deleteFile(path);
    } catch (e) {
      print("Error sending voice: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorReporter.safeMessage(e))),
        );
      }
    }
  }

  Future<void> _deleteFile(String? path) async {
    if (path == null || path.isEmpty || kIsWeb || PlatformIs.web) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

  // --- Mic gesture (pointer events so we get the press immediately) ---

  void _onMicDown(PointerDownEvent e) {
    _downPosition = e.position;
    _startRecording();
  }

  void _onMicMove(PointerMoveEvent e) {
    if (_downPosition == null || _isLocked) return;
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final raw = e.position - _downPosition!;
    // Positive dx = toward the end edge; cancel is toward the start edge.
    final dx = (isRtl ? -raw.dx : raw.dx).clamp(-double.infinity, 0.0).toDouble();
    final dy = raw.dy.clamp(-double.infinity, 0.0).toDouble();

    if (-dy >= _lockDistance && -dx < _cancelDistance) {
      HapticFeedback.selectionClick();
      if (mounted) setState(() { _isLocked = true; _dragOffset = Offset.zero; });
      return;
    }
    if (-dx >= _cancelDistance) {
      HapticFeedback.selectionClick();
      _downPosition = null;
      _finishRecording(send: false);
      return;
    }
    if (_isRecording && mounted) {
      setState(() => _dragOffset = Offset(dx, dy));
    }
  }

  void _onMicUp(PointerUpEvent e) {
    if (_downPosition == null) return;
    _downPosition = null;
    if (_isLocked) return; // keep recording hands-free
    _finishRecording(send: true);
  }

  void _onMicCancel(PointerCancelEvent e) {
    if (_downPosition == null) return;
    _downPosition = null;
    if (_isLocked) return;
    _finishRecording(send: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _formatElapsed() {
    final m = _elapsed.inMinutes.toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _recordingBar(BuildContext context) {
    final blinkOn = _elapsed.inMilliseconds % 1000 < 600;
    final cancelProgress = (-_dragOffset.dx / _cancelDistance).clamp(0.0, 1.0);

    return Row(
      children: [
        if (_isLocked)
          GestureDetector(
            onTap: () => _finishRecording(send: false),
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.delete_outline, color: Colors.red, size: 26),
            ),
          )
        else
          AnimatedOpacity(
            opacity: blinkOn ? 1 : 0.2,
            duration: const Duration(milliseconds: 250),
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.mic, color: Colors.red, size: 24),
            ),
          ),
        Text(
          _formatElapsed(),
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff303030)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _isLocked
              ? SizedBox(
                  height: 28,
                  child: CustomPaint(
                    painter: _LiveWaveformPainter(
                      levels: List.of(_levels),
                      color: Color(AppColors.buttons),
                      slots: _waveformSamples,
                    ),
                  ),
                )
              : Opacity(
                  opacity: 1 - cancelProgress,
                  child: Transform.translate(
                    offset: Offset(_dragOffset.dx / 3, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chevron_left, size: 18, color: Color(0xff909090)),
                        Flexible(
                          child: Text(
                            AppStrings.slideToCancel.tr(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xff909090)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentProvider>(
      builder: (context, value, child) {
        if(value.isAddCommentSuccess == true){
          print("ADDED SUCCESS");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            value.getComment(context, widget.slug,widget.id, pages: 1);
          });
          value.isAddCommentSuccess = false;
        }

        void sendText() {
          if (value.contentController.text.trim().isNotEmpty ||
              value.listXAttachmentPersonalImage.isNotEmpty) {
            value.addComment(context,
                id: widget.id, slug: widget.slug.toString());
          }
        }

        final accent = Color(AppColors.buttons);
        final micActive = _isRecording && !_isLocked;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
                ),
                child: _isRecording
                    ? _recordingBar(context)
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: value.contentController,
                              minLines: 1,
                              maxLines: 4,
                              onSubmitted: (_) => sendText(),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: AppStrings.typeYourMessage.tr().toUpperCase(),
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Color(0xFFB0B7C3)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              await value.getImage(
                                  context,
                                  image1: value.attachmentPersonalImage,
                                  image2: value.XImageFileAttachmentPersonal,
                                  list2: value.listXAttachmentPersonalImage,
                                  one: false,
                                  list: value.listAttachmentPersonalImage);
                              if (value.listXAttachmentPersonalImage.isNotEmpty) {
                                value.addComment(context,
                                    id: widget.id,
                                    slug: widget.slug.toString(),
                                    images: value.listXAttachmentPersonalImage);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: SvgPicture.asset("assets/images/svg/image.svg",
                                  color: accent, width: 24, height: 24),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // One round button, like WhatsApp: send when there is text,
            // otherwise a hold-to-record mic.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: value.contentController,
              builder: (context, text, _) {
                final hasText = text.text.trim().isNotEmpty;
                final showSend = _isLocked || (hasText && !_isRecording);

                // Fixed layout size: growing it would resize the row and push
                // the page while the mic is held, so scale visually instead.
                final button = AnimatedScale(
                  scale: micActive ? 1.35 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: value.isAddCommentLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(
                            showSend ? Icons.send_rounded : Icons.mic,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                  ),
                );

                if (showSend) {
                  return GestureDetector(
                    onTap: _isLocked ? () => _finishRecording(send: true) : sendText,
                    child: button,
                  );
                }

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (micActive)
                      // Lock hint that the finger can slide up into.
                      Positioned(
                        bottom: 80,
                        child: Container(
                          width: 36,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(color: Color(0x22000000), blurRadius: 8)
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.lock_outline, size: 18, color: Color(0xff606060)),
                              Icon(Icons.keyboard_arrow_up, size: 18, color: Color(0xff909090)),
                            ],
                          ),
                        ),
                      ),
                    Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: _onMicDown,
                      onPointerMove: _onMicMove,
                      onPointerUp: _onMicUp,
                      onPointerCancel: _onMicCancel,
                      child: Transform.translate(
                        offset: micActive ? _dragOffset * 0.5 : Offset.zero,
                        child: button,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Scrolling bars of recent microphone levels, newest on the end edge.
class _LiveWaveformPainter extends CustomPainter {
  final List<double> levels;
  final Color color;
  final int slots;

  _LiveWaveformPainter({required this.levels, required this.color, required this.slots});

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / slots;
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.min(3.0, slot * 0.6);
    final mid = size.height / 2;
    final offset = slots - levels.length;
    for (var i = 0; i < levels.length; i++) {
      final x = slot * (offset + i) + slot / 2;
      final half = math.max(1.5, levels[i] * size.height / 2);
      canvas.drawLine(Offset(x, mid - half), Offset(x, mid + half), paint);
    }
  }

  @override
  bool shouldRepaint(_LiveWaveformPainter old) => true;
}
