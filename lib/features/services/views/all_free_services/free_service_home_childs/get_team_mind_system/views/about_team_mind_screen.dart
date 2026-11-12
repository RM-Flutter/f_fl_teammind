import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/services/app_error_reporter.dart';
import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/styles.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/full_image_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/model/team_page_model.dart';
import 'widgets/youtube_video_player/youtube_video_player_screen.dart';

import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/styles.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/full_image_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/model/team_page_model.dart';
import 'widgets/youtube_video_player/youtube_video_player_screen.dart';
import 'package:app_test/core/constants/app_design.dart';

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
    if (_page == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.failed.tr())),
        );
      }
      return;
    }

    final bool isAr = LocalizationService.isArabic(context: context);
    final pdfList = isAr ? _page!.pdfAr : _page!.pdfEn;

    if (pdfList.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.failed.tr())),
        );
      }
      return;
    }

    final String? pdfUrl = pdfList[0].file;
    final String pdfFileName = pdfUrl?.split('/').last ?? 'team_mind.pdf';

    if (pdfUrl == null || pdfUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.failed.tr())),
        );
      }
      return;
    }

    if (PlatformIs.web) {
      final uri = Uri.parse(pdfUrl);
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
      final filePath = '${dir.path}/$pdfFileName';
      final dio = Dio();
      await dio.download(pdfUrl, filePath);
      if (!mounted) return;
      await OpenFilex.open(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.downloaded.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorReporter.safeMessage(e))),
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

  /// Thumbnail of the YouTube video, or a plain tinted block when the url is not a YouTube one.
  Widget _videoThumb() {
    final videoId = _youtubeVideoId(_page!.videoUrl!);
    final tint = Color(AppColors.secondaryButton).withValues(alpha: 0.1);
    if (videoId == null) return Container(color: tint);
    return CachedNetworkImage(
      imageUrl: _youtubeThumbnailUrl(videoId),
      fit: BoxFit.cover,
      placeholder: (_, __) => const ShimmerAnimatedLoading(circularRaduis: 0),
      errorWidget: (_, __, ___) =>
          Container(color: tint, child: const Icon(Icons.videocam_off, size: 40)),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const _AboutLoading();
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: AppCard(
          child: Column(
            children: [
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: _loadPage, child: Text(AppStrings.retry.tr())),
            ],
          ),
        ),
      );
    }
    final page = _page;
    final hasContent = page?.content != null && page!.content!.isNotEmpty;
    final hasImages = page?.images != null && page!.images.isNotEmpty;
    final hasVideo = page?.videoUrl != null && page!.videoUrl!.isNotEmpty;
    final wide = LayoutService.isExpanded(context);
    final contentBlock = <Widget>[
          if (hasContent) ...[
            AppCard(animateIn: true, child: _HtmlContent(content: page!.content!)),
            const SizedBox(height: AppSpacing.section),
          ],
    ];
    final imagesBlock = <Widget>[
          if (hasImages) ...[
            SizedBox(
              height: AppSizes.s120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: page!.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final img = page.images[index];
                  final url = img.file ?? img.thumbnail ?? '';
                  if (url.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          imageUrls: page.images,
                          file: true,
                          initialIndex: index,
                          url: true,
                          thum: false,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const ShimmerAnimatedLoading(width: 120, height: 120),
                        errorWidget: (_, __, ___) => Container(
                          width: 120,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.section),
          ],
    ];
    final videoBlock = <Widget>[
          if (hasVideo) ...[
            GestureDetector(
              onTap: () => context.pushNamed(
                AppRoutes.mediaCenterYoutubeScreenView.name,
                pathParameters: {
                  'lang': context.locale.languageCode,
                  'url': page!.videoUrl.toString(),
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _videoThumb(),
                        Container(color: Colors.black.withValues(alpha: 0.12)),
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                size: 36, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.section),
          ],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wide windows: text and photos on one side, the video on the other.
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [...contentBlock, ...imagesBlock],
                  ),
                ),
                if (videoBlock.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.page),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: videoBlock,
                    ),
                  ),
                ],
              ],
            )
          else ...[
            ...contentBlock,
            ...imagesBlock,
            ...videoBlock,
          ],
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppButtonSize.height,
                  child: ElevatedButton(
                    onPressed: () => context.pushNamed(
                      AppRoutes.contactUs.name,
                      pathParameters: {"lang": context.locale.languageCode},
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: AppButtonSize.padding,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    child: Text(AppStrings.contactUs.tr(),
                        style: const TextStyle(
                            fontSize: AppButtonSize.fontSize,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: AppButtonSize.height,
                  child: OutlinedButton(
                    onPressed: _downloadAndOpenPdf,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(AppColors.secondaryButton),
                      side: BorderSide(color: Color(AppColors.secondaryButton)),
                      padding: AppButtonSize.padding,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    child: Text(AppStrings.downloadPdf.tr(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: AppButtonSize.fontSize,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      pageContext: context,
      title: _page?.title ?? AppStrings.aboutTeamMind.tr(),
      routeName: AppRoutes.aboutTeamMindScreen.name,
      backgroundColor: Color(AppColors.background),
      onRefresh: _loadPage,
      body: _body(context),
    );
  }
}

/// Skeleton in the order of the real page: text card, image strip, video, two buttons.
class _AboutLoading extends StatelessWidget {
  const _AboutLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerAnimatedLoading(width: 170, height: 16),
                SizedBox(height: AppSpacing.md),
                ShimmerAnimatedLoading(height: 12),
                SizedBox(height: AppSpacing.sm),
                ShimmerAnimatedLoading(height: 12),
                SizedBox(height: AppSpacing.sm),
                ShimmerAnimatedLoading(width: 220, height: 12),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          SizedBox(
            height: AppSizes.s120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ShimmerAnimatedLoading(width: 120, height: 120, circularRaduis: AppRadius.md),
                SizedBox(width: AppSpacing.md),
                ShimmerAnimatedLoading(width: 120, height: 120, circularRaduis: AppRadius.md),
                SizedBox(width: AppSpacing.md),
                ShimmerAnimatedLoading(width: 120, height: 120, circularRaduis: AppRadius.md),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          const AspectRatio(
            aspectRatio: 16 / 9,
            child: ShimmerAnimatedLoading(circularRaduis: AppRadius.lg),
          ),
          const SizedBox(height: AppSpacing.section),
          Row(
            children: const [
              Expanded(
                  child: ShimmerAnimatedLoading(
                      height: AppButtonSize.height, circularRaduis: AppRadius.pill)),
              SizedBox(width: AppSpacing.md),
              Expanded(
                  child: ShimmerAnimatedLoading(
                      height: AppButtonSize.height, circularRaduis: AppRadius.pill)),
            ],
          ),
        ],
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
