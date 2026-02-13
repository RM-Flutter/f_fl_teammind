import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../../general_services/localization.service.dart';
import '../../../../platform/platform_is.dart';
import '../../../../routing/app_router.dart';
import 'youtube_video_player_screen.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';
import '../../../../utils/styles.dart';
import '../../../complain_screen/widget/full_image_screen.dart';
import 'team_page.service.dart';

class AboutTeamMindScreen extends StatefulWidget {
  const AboutTeamMindScreen({super.key});

  @override
  State<AboutTeamMindScreen> createState() => _AboutTeamMindScreenState();
}

class _AboutTeamMindScreenState extends State<AboutTeamMindScreen> {
  bool _loading = true;
  String? _error;
  TeamPage? _page;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await TeamPageService.getTeamPage(context);
      if (!mounted) return;
      if (res.status && res.page != null) {
        setState(() {
          _page = res.page;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res.message ?? AppStrings.failed.tr();
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  /// Get YouTube video ID from URL.
  String? _youtubeVideoId(String videoUrl) {
    final match = RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+)').firstMatch(videoUrl.trim());
    return match?.group(1);
  }

  /// YouTube thumbnail URL (hqdefault is widely available).
  String _youtubeThumbnailUrl(String videoId) =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  Future<void> _downloadAndOpenPdf() async {
  final jsonString = CacheHelper.getString("USG");
  var gCache;
  if (jsonString != null && jsonString != "") {
  gCache = json.decode(jsonString) as Map<String, dynamic>;
  }
   String? _teamMindPdfUrl = LocalizationService.isArabic(context: context)?gCache['teamMindPdfAr'][0]['file'].toString() : gCache['teamMindPdfEn'][0]['file'].toString();
   String? _teamMindPdfFileName = LocalizationService.isArabic(context: context)?"${gCache['teamMindPdfAr'][0]['file']}" : "${gCache['teamMindPdfEn'][0]['file']}";
    if (PlatformIs.web) {
      final uri = Uri.parse(_teamMindPdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.downloadStarted.tr())),
        );
      }
      return;
    }
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.downloadStarted.tr())),
        );
      }
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$_teamMindPdfFileName';
      final dio = Dio();
      await dio.download(_teamMindPdfUrl, filePath);
      if (!mounted) return;
      await OpenFile.open(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.downloaded.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.failed.tr()}: $e')),
        );
      }
    }
  }

  /// فتح الفيديو في بوب أب (ديالوج) مثل المشروع التاني — نفس ويدجت ويب فيو بالظبط.
  void _openVideo(String videoUrl) {
    final url = videoUrl.trim();
    if (url.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: Color(0xFF1E2D74)),
          child: YoutubeVideoPlayerScreen(
            videoUrl: url,
            videoTitle: 'Video',
            showCloseButton: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithBookmark(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(AppColors.dark),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
          onPressed: _goBack,
        ),
        title: _page?.title ?? AppStrings.aboutTeamMind.tr(),
        titleStyle: TextStyle(
          color: Color(AppColors.dark),
          fontSize: 20,
        ),
        centerTitle: true,
        routeName: AppRoutes.aboutTeamMindScreen.name,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadPage,
                          child: Text(AppStrings.retry.tr()),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_page?.content != null && _page!.content!.isNotEmpty) ...[
                        _HtmlContent(content: _page!.content!),
                        const SizedBox(height: 24),
                      ],
                      if (_page?.images != null && _page!.images.isNotEmpty) ...[
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _page!.images.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final img = _page!.images[index];
                              final url = img.file ?? img.thumbnail ?? '';
                              if (url.isEmpty) return const SizedBox.shrink();
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImageViewer(
                                          imageUrls: _page!.images,
                                          file: true,
                                          initialIndex: index,
                                          url: true,
                                          thum: false,
                                        ),
                                      )
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (_page?.videoUrl != null && _page!.videoUrl!.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              AppRoutes.mediaCenterYoutubeScreenView.name,
                              pathParameters: {
                                'lang': context.locale.languageCode,
                                'url': _page!.videoUrl.toString(),
                              },
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final videoId = _youtubeVideoId(_page!.videoUrl!);
                                      final thumbUrl = videoId != null
                                          ? _youtubeThumbnailUrl(videoId)
                                          : null;
                                      if (thumbUrl != null) {
                                        return CachedNetworkImage(
                                          imageUrl: thumbUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(
                                            color: Color(AppColors.dark).withOpacity(0.1),
                                            child: const Center(child: CircularProgressIndicator()),
                                          ),
                                          errorWidget: (_, __, ___) => Container(
                                            color: Color(AppColors.dark).withOpacity(0.1),
                                            child: const Icon(Icons.videocam_off, size: 48),
                                          ),
                                        );
                                      }
                                      return Container(
                                        color: Color(AppColors.dark).withOpacity(0.1),
                                      );
                                    },
                                  ),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  context.pushNamed(
                                    AppRoutes.contactUs.name,
                                    pathParameters: {
                                      "lang": context.locale.languageCode,
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(AppColors.primary),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.contactUs.tr(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async => _downloadAndOpenPdf(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(AppColors.primary),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.downloadPdf.tr(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _HtmlContent extends StatelessWidget {
  final String content;

  const _HtmlContent({required this.content});

  @override
  Widget build(BuildContext context) {
    return Html(
      shrinkWrap: true,
      data: content,
      style: TextsStyles.htmlStyle,
    );
  }
}
