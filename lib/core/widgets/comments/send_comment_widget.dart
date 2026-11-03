import 'package:app_test/core/services/app_error_reporter.dart';
import 'dart:async';
import 'dart:io';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

class _SendCommentWidgetState extends State<SendCommentWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;
  Timer? _timer;
  int _elapsedTime = 0;

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String? path;

        // على الويب، لا نستخدم مسار ملف
        if (kIsWeb || PlatformIs.web) {
          // على الويب، record package يتعامل مع المسار تلقائياً
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
            // على الويب، استخدام إعدادات مختلفة
            numChannels: (kIsWeb || PlatformIs.web) ? 1 : 2,
          ),
          path: path ?? '', // على الويب، استخدام string فارغ
        );

        setState(() {
          _currentRecordingPath = path;
          _isRecording = true;
          _elapsedTime = 0;
          _timer = Timer.periodic(Duration(seconds: 1), (timer) {
            setState(() {
              _elapsedTime++;
            });
          });
        });
      } else {
        print("Recording permission denied");
      }
    } catch (e) {
      print("Error starting recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorReporter.safeMessage(e))),
        );
      }
    }
  }
  Future<Duration?> _getAudioDuration(String? filePath) async {
    try {
      if (filePath == null && (kIsWeb || PlatformIs.web)) {
        // على الويب، قد لا نحتاج إلى مسار ملف
        // يمكننا استخدام duration افتراضي أو تخطي هذا
        return const Duration(seconds: 1); // قيمة افتراضية
      }

      if (filePath == null) return null;

      final player = AudioPlayer();

      // على الويب، استخدام setUrl بدلاً من setFilePath
      if (kIsWeb || PlatformIs.web) {
        // على الويب، نحتاج إلى تحويل المسار إلى URL
        // لكن في هذه الحالة، قد لا نحتاج إلى duration
        await player.dispose();
        return const Duration(seconds: 1);
      } else {
        await player.setFilePath(filePath);
        Duration? duration = player.duration;
        await player.dispose();
        return duration;
      }
    } catch (e) {
      print("Error getting duration: $e");
      return const Duration(seconds: 1); // قيمة افتراضية
    }
  }

  Future<void> _cleanUpRecording({bool deleteFile = false}) async {
    _timer?.cancel();
    _timer = null;

    // على الويب، لا نحذف الملفات لأنها blob URLs
    if (deleteFile && _currentRecordingPath != null && !(kIsWeb || PlatformIs.web)) {
      try {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print("Error deleting file: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
        _elapsedTime = 0;
      });
    } else {
      _isRecording = false;
      _elapsedTime = 0;
    }
    _currentRecordingPath = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
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
        Future<void> _stopRecording() async {
          try {
            final path = await _audioRecorder.stop();
            
            _timer?.cancel();
            _timer = null;
            if (mounted) {
              setState(() {
                _isRecording = false;
              });
            }

            // على الويب، path قد يكون null أو يكون blob URL
            if (path != null || (kIsWeb || PlatformIs.web)) {
              // على الويب، التحقق من وجود التسجيل بطريقة مختلفة
              if (kIsWeb || PlatformIs.web) {
                // على الويب، إرسال التسجيل مباشرة
                // record package على الويب يعيد path كـ blob URL أو file path
                if (path != null && path.isNotEmpty) {
                  await value.addComment(context, id: widget.id, voicePath: path, slug: widget.slug.toString());
                } else {
                  print("Warning: Recording path is null on web");
                }
              } else {
                // على الموبايل، التحقق من وجود الملف
                if (path != null && path.isNotEmpty) {
                  final file = File(path);
                  if (await file.exists()) {
                    Duration? duration = await _getAudioDuration(path);
                    if (duration != null && duration.inSeconds > 0) {
                      print("Audio Duration: ${duration.inSeconds} seconds");
                      await value.addComment(context, id: widget.id, voicePath: path, slug: widget.slug.toString());
                      try {
                        if (await file.exists()) {
                          await file.delete();
                        }
                      } catch (e) {
                        print("Error deleting file: $e");
                      }
                    } else {
                      print("Error: Recorded audio has zero duration!");
                    }
                  } else {
                    print("Error: Recorded file does not exist.");
                  }
                } else {
                  print("Error: Recording path is null");
                }
              }
            } else {
              print("Error: Recording path is null");
            }
          } catch (e) {
            print("Error stopping recording: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppErrorReporter.safeMessage(e))),
              );
            }
          } finally {
            _currentRecordingPath = null;
            _elapsedTime = 0;
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isRecording) ...[
                      // Recording Indicator
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.mic, color: Colors.red, size: 24),
                      ),
                      Text(
                        '00:${_elapsedTime.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.red,
                        ),
                      ),
                      const Spacer(),
                      // Cancel Button
                      GestureDetector(
                        onTap: () => _cleanUpRecording(deleteFile: true),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.delete_outline, color: Colors.grey, size: 24),
                        ),
                      ),
                      // Stop Button
                      GestureDetector(
                        onTap: () => _stopRecording(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(Icons.send_rounded, color: Colors.red, size: 28),
                        ),
                      ),
                    ] else ...[
                      // Normal Text Field
                      Expanded(
                        child: TextField(
                          controller: value.contentController,
                          minLines: 1,
                          maxLines: 4,
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty ||
                                value.listXAttachmentPersonalImage.isNotEmpty) {
                              value.addComment(context,
                                  id: widget.id,
                                  slug: widget.slug.toString());
                            }
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: AppStrings.typeYourMessage.tr().toUpperCase(),
                            hintStyle:  const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Color(0xFFB0B7C3)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Image Icon
                      GestureDetector(
                        onTap: () async {
                          final previousImagesLength = value.listXAttachmentPersonalImage.length;
                          await value.getImage(
                              context,
                              image1: value.attachmentPersonalImage,
                              image2: value.XImageFileAttachmentPersonal,
                              list2: value.listXAttachmentPersonalImage,
                              one: false,
                              list: value.listAttachmentPersonalImage);
                          if (value.listXAttachmentPersonalImage.isNotEmpty &&
                              value.listXAttachmentPersonalImage.length > previousImagesLength) {
                            value.addComment(context,
                                id: widget.id,
                                slug: widget.slug.toString(),
                                images: value.listXAttachmentPersonalImage);
                          } else if (value.listXAttachmentPersonalImage.isNotEmpty) {
                            value.addComment(context,
                                id: widget.id,
                                slug: widget.slug.toString(),
                                images: value.listXAttachmentPersonalImage);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SvgPicture.asset("assets/images/svg/image.svg",
                              color:  Color(AppColors.buttons),
                              width: 24,
                              height: 24),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Mic Icon
                      GestureDetector(
                        onTap: () => _startRecording(),
                        onLongPress: () => _startRecording(),
                        onLongPressUp: () => _stopRecording(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SvgPicture.asset("assets/images/svg/voice.svg",
                              color:  Color(AppColors.buttons),
                              width: 24,
                              height: 24),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!_isRecording) ...[
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration:  BoxDecoration(
                  color: Color(AppColors.buttons),
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // إرسال التعليق عند الضغط على أيقونة الإرسال
                      if (value.contentController.text.trim().isNotEmpty ||
                          value.listXAttachmentPersonalImage.isNotEmpty) {
                        value.addComment(context,
                            id: widget.id,
                            slug: widget.slug.toString());
                      }
                    },
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Center(
                      child: (value.isAddCommentLoading == false)
                          ? const Icon(Icons.send_rounded, color: Colors.white, size: 22) // Paper plane icon
                          : const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
