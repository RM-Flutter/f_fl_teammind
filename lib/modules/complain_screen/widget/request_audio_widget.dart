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

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.setUrl(widget.audioUrl);
    _audioPlayer.durationStream.listen((d) {
      if (d != null) {
        setState(() {
          _duration = d;
        });
      }
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
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


