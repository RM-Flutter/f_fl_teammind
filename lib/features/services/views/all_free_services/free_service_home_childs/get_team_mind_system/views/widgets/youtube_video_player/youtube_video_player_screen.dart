import 'package:app_test/core/constants/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/services/string_helpers_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


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
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Start the player after the page transition, so opening the screen stays smooth.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _initializeWebView();
    });
  }

  void _initializeWebView() {
    // Extract video ID from URL (نفس Leeds)
    final videoId = StringHelpers.getVideoID(url: widget.videoUrl);
    if (videoId.isEmpty) {
      if (mounted) {
        setState(() {
        isLoading = false;
        _invalidUrl = true;
      });
      }
      return;
    }

    final embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&modestbranding=1&playsinline=1&origin=https://www.youtube.com';

    // Build HTML content with iframe for YouTube embed (used for mobile)
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
            src="$embedUrl" 
            frameborder="0" 
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
            allowfullscreen>
        </iframe>
    </div>
</body>
</html>
''';

    // Proper initialization for WebViewController to allow media playback
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance.runtimeType.toString() == 'WebKitWebViewPlatform') {
      params = const PlatformWebViewControllerCreationParams(); 
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params);

    if (kIsWeb) {
      // On web, some methods like setJavaScriptMode throw UnimplementedError.
      // We also must use loadRequest instead of loadHtmlString to render the iframe properly.
      controller!.loadRequest(Uri.parse(embedUrl));
      
      if (mounted) {
        setState(() {
          isLoading = false; // It loads immediately as an iframe on web
        });
      }
    } else {
      // Mobile specific configurations
      controller!
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
                  if (error.isForMainFrame ?? true) _failed = true;
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
        ..loadHtmlString(htmlContent, baseUrl: 'https://www.youtube.com');

      // Disable user gesture requirement for Android
      if (controller?.platform.runtimeType.toString() == 'AndroidWebViewController') {
        try {
          final dynamic androidController = controller?.platform;
          androidController.setMediaPlaybackRequiresUserGesture(false);
        } catch (e) {
          // Fallback
        }
      }
    }
    
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final inDialog = widget.showCloseButton;
    final title = widget.videoTitle.isEmpty ? 'Video' : widget.videoTitle;

    final Widget player;
    if (_invalidUrl || _failed) {
      player = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined, color: Colors.white70, size: 40),
              const SizedBox(height: AppSpacing.md),
              Text(
                _invalidUrl ? 'invalid_video_url'.tr() : 'video_failed_to_load'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    } else {
      player = Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null) WebViewWidget(controller: controller!),
          if (isLoading || controller == null)
            const ShimmerAnimatedLoading(circularRaduis: 0),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarWithBookmark(
        backgroundColor: Color(AppColors.background),
        elevation: 0,
        leading: AppBackButton(
          onPressed: inDialog ? () => Navigator.of(context).pop() : null,
        ),
        title: title,
        centerTitle: true,
        showBookmark: !inDialog,
        // Opens the video in YouTube: always there, in case the owner blocked the embedded player.
        actions: [
          IconButton(
            tooltip: AppStrings.openInBrowser.tr(),
            icon: Icon(Icons.open_in_new_rounded, color: Color(AppColors.secondaryButton)),
            onPressed: () => launchUrl(Uri.parse(widget.videoUrl),
                mode: LaunchMode.externalApplication),
          ),
        ],
        routeName: AppRoutes.youtubeVideoScreen.name,
      ),
      // The whole page is the video.
      body: Stack(
        fit: StackFit.expand,
        children: [
          player,
        ],
      ),
    );
  }
}
