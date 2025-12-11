import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String audioUrl;

  const VoiceMessageWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadAudio();
    
    _durationSubscription = _audioPlayer.durationStream.listen((d) {
      if (!mounted || d == null) return;
        setState(() {
          _duration = d;
        });
    });

    _positionSubscription = _audioPlayer.positionStream.listen((p) {
      if (!mounted) return;
      setState(() {
        _position = p;
      });
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }
  
  Future<void> _loadAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
    } catch (e) {
      print("Error loading audio: $e");
      // محاولة إعادة التحميل بعد فترة قصيرة
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          _loadAudio();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant VoiceMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _resetAndLoadNewSource();
    }
  }

  Future<void> _resetAndLoadNewSource() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(widget.audioUrl);
      if (!mounted) return;
      setState(() {
        _duration = Duration.zero;
        _position = Duration.zero;
        _isPlaying = false;
      });
    } catch (_) {
      // ignore errors when updating the source
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      AudioPlaybackManager().registerPlayer(_audioPlayer); // Stop previous player
      await _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    AudioPlaybackManager().unregisterPlayer(_audioPlayer);
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
              value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                _audioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Text(
            "${_position.inSeconds}/${_duration.inSeconds}s",
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
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


