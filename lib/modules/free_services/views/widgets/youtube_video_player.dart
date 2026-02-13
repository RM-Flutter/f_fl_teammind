import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // لموبايل
import '../../../../constants/app_strings.dart';
class YouTubeVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const YouTubeVideoPlayer({super.key, required this.videoUrl});

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  YoutubePlayerController? _controller;
  late String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl.toString());

    if (!kIsWeb && _videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  String? _iframeId;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
      return Center(child: Text(AppStrings.invalidYouTubeUrl.tr()));
    }

    if (kIsWeb) {
      return Center(
        child: SizedBox(
          width: 560,
          height: 315,
          child: HtmlElementView(viewType: _iframeId!),
        ),
      );
    } else {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller!),
        builder: (context, player) => Center(child: player),
      );
    }
  }
}
