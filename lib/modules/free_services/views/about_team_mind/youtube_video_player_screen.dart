import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../general_services/string_helpers.service.dart';

/// نسخة مطابقة من leeds: lib/modules/guidelines_video/widgets/youtube_video_player.dart
/// عند الاستخدام داخل بوب أب: showCloseButton = true
class YoutubeVideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  /// عند true يظهر زر إغلاق في الـ AppBar (للاستخدام داخل showDialog)
  final bool showCloseButton;

  const YoutubeVideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.videoTitle = '',
    this.showCloseButton = false,
  });

  @override
  State<YoutubeVideoPlayerScreen> createState() => _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  WebViewController? controller;
  bool isLoading = true;
  bool _invalidUrl = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Extract video ID from URL (نفس Leeds)
    final videoId = StringHelpers.getVideoID(url: widget.videoUrl);
    if (videoId.isEmpty) {
      if (mounted) setState(() {
        isLoading = false;
        _invalidUrl = true;
      });
      return;
    }

    // Build HTML content with iframe for YouTube embed
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #000;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .video-container {
            position: relative;
            width: 100%;
            height: 100%;
        }
        iframe {
            width: 100%;
            height: 100%;
            border: none;
        }
    </style>
</head>
<body>
    <div class="video-container">
        <iframe 
            src="https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1&playsinline=1" 
            frameborder="0" 
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
            allowfullscreen>
        </iframe>
    </div>
</body>
</html>
''';

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onNavigationRequest: (navigation) {
            // Allow navigation within YouTube embed
            if (navigation.url.contains('youtube.com') ||
                navigation.url.contains('youtu.be') ||
                navigation.url.contains('google.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadHtmlString(htmlContent);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.showCloseButton
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          widget.videoTitle.isEmpty ? 'Video' : widget.videoTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF1E2D74),
        foregroundColor: Colors.white,
      ),
      body: _invalidUrl
          ? const Center(child: Text('رابط الفيديو غير صالح', style: TextStyle(fontSize: 16)))
          : Stack(
        children: [
          if (controller != null) WebViewWidget(controller: controller!),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );  // closes Stack then body
  }
}
