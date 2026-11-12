import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:html'
    if (dart.library.io) '../../../../core/services/dart_html_stub.dart'
    as html;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/comments/comments_widget.dart';
import '../../../../core/widgets/comments/logic/controller.dart';
import '../models/daily_report_model.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/comments/comments_title.widget.dart';
import 'package:app_test/core/widgets/bookmark_widgets/bookmark_button.widget.dart';
import 'package:app_test/core/routing/app_router.dart';

class DailyReportDetailsScreen extends StatefulWidget {
  final DailyReportModel report;
  const DailyReportDetailsScreen({super.key, required this.report});

  @override
  State<DailyReportDetailsScreen> createState() =>
      _DailyReportDetailsScreenState();
}

class _DailyReportDetailsScreenState extends State<DailyReportDetailsScreen> {
  late ScrollController _scrollController;
  double _downloadProgress = 0.0;

  Future<void> _downloadFile(String url, String fileName) async {
    if (kIsWeb) {
      try {
        final fetchResult = html.window.fetch(url);
        fetchResult.then((response) {
          return (response as dynamic).blob();
        }).then((blob) {
          final blobUrl = html.Url.createObjectUrlFromBlob(blob as dynamic);
          final html.AnchorElement downloadAnchor =
              html.AnchorElement(href: blobUrl);
          downloadAnchor.download = fileName;
          downloadAnchor.style.display = 'none';
          html.document.body?.append(downloadAnchor);
          downloadAnchor.click();
          downloadAnchor.remove();
          html.Url.revokeObjectUrl(blobUrl);
        }).catchError((e) {
          AppToast.showToast(msg: "Download failed: $e");
        });
      } catch (e) {
        AppToast.showToast(msg: "Error: $e");
      }
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('downloading'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: AppSizes.s10),
                  Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            );
          },
        ),
      );

      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/$fileName";

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) Navigator.of(context).pop();
      await OpenFilex.open(filePath);

      AppToast.showToast(
        msg: '✅ ${'downloaded'.tr()}: $fileName',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      AppToast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _downloadProgress = 0.0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Same header as Notification Details: navy with the app texture, back + bookmark, the title
  /// centered and the metadata (date, employee) under it.
  Widget _buildHeroHeader(BuildContext context) {
    final dateFormatted = widget.report.createdAt != null
        ? DateFormat('EEEE, dd MMMM yyyy', context.locale.languageCode)
            .format(widget.report.createdAt!)
        : '';
    final employeeName = widget.report.employeeProfile?.name;
    const radius = BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl));

    Widget meta(IconData icon, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(AppColors.buttons), size: 16),
            const SizedBox(width: AppSizes.s6),
            Text(text,
                style: AppStyles.whiteContent(context)
                    .copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        );

    return SizedBox(
      height: AppSizes.detailsHeaderHeight,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/png/tasks-app-bar.png',
                  fit: BoxFit.cover),
            ),
            Positioned.fill(
                child: ColoredBox(
                    color: Color(AppColors.secondaryButton)
                        .withValues(alpha: 0.9))),
            SafeArea(
              bottom: false,
              child: AppContentWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page, AppSizes.s10, AppSpacing.page, AppSizes.s10),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSizes.s8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                              BookmarkButton(
                                routeName:
                                    AppRoutes.dailyReportDetailsScreen.name,
                                defaultTitle: AppStrings.reportDetails.tr(),
                                iconColor: Colors.white,
                              ),
                            ],
                          ),
                          Text(
                            AppStrings.reportDetails.tr(),
                            style: AppStyles.whiteHeading(context).copyWith(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (employeeName != null)
                        Text(
                          employeeName,
                          textAlign: TextAlign.center,
                          style: AppStyles.whiteHeading(context).copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.1),
                        ),
                      const SizedBox(height: AppSizes.s16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (dateFormatted.isNotEmpty)
                            meta(Icons.calendar_today_outlined, dateFormatted),
                          meta(Icons.description_outlined,
                              AppStrings.reportDetails.tr()),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CommentProvider()
            ..getComment(
                context, "employee-daily-reports", widget.report.id.toString()),
        )
      ],
      child: Scaffold(
        backgroundColor: Color(AppColors.background),
        body: RefreshIndicator.adaptive(
          onRefresh: () async {
            if (context.mounted) {
              context.read<CommentProvider>().getComment(context,
                  "employee-daily-reports", widget.report.id.toString());
            }
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(context),
                AppContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          title: AppStrings.accomplishments.tr(),
                          icon: Icons.check_circle_rounded,
                          iconColor: Color(AppColors.successGreen),
                          content: widget.report.done ??
                              AppStrings.noAccomplishmentsRecorded.tr(),
                        ),
                        const SizedBox(height: AppSpacing.cardGap),
                        _buildSection(
                          title: AppStrings.inProgressTasks.tr(),
                          icon: Icons.sync_rounded,
                          iconColor: Color(AppColors.buttons),
                          content: widget.report.inProgress ??
                              AppStrings.noOngoingTasksRecorded.tr(),
                        ),
                        const SizedBox(height: AppSizes.s16),

                        _buildSection(
                          title: AppStrings.blockersAndProblems.tr(),
                          icon: Icons.warning_rounded,
                          iconColor: Color(AppColors.warningYellow),
                          content: widget.report.problems ??
                              AppStrings.noProblemsRecorded.tr(),
                        ),
                        const SizedBox(height: AppSizes.s16),

                        if (widget.report.attachments != null &&
                            widget.report.attachments!.isNotEmpty) ...[
                          _buildAttachmentsSection(widget.report.attachments!),
                          const SizedBox(height: AppSizes.s24),
                        ],

                        // Comments Section
                        const CommentsTitle(),
                        const SizedBox(height: AppSizes.s12),
                        Consumer<CommentProvider>(
                            builder: (context, commentProvider, child) {
                          return CommentsWidget(
                            "employee-daily-reports",
                            enable: "enable",
                            comments: commentProvider.comments,
                            pageNumber: commentProvider.pageNumber,
                            loading: commentProvider.isGetCommentLoading,
                            scrollController: _scrollController,
                            id: widget.report.id.toString(),
                          );
                        }),
                        const SizedBox(height: AppSizes.s50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    final tones = AppColors.statusTones(iconColor);
    return AppCard(
      animateIn: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tones.tint,
                  border: Border.all(color: tones.ring, width: 1.5),
                ),
                child: Icon(icon, size: 18, color: tones.text),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: AppStyles.heading(context))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(content,
              style: AppStyles.greyContent(context)
                  .copyWith(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(List<ReportAttachmentModel> attachments) {
    final tones = AppColors.statusTones(Color(AppColors.buttons));
    return AppCard(
      animateIn: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tones.tint,
                    border: Border.all(color: tones.ring, width: 1.5),
                  ),
                  child: Icon(Icons.attach_file_rounded,
                      size: 18, color: tones.text),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                    child: Text(AppStrings.attachments.tr(),
                        style: AppStyles.heading(context))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.page,
                end: AppSpacing.page,
                bottom: AppSpacing.page),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(attachments.length, (index) {
                  final attachment = attachments[index];
                  final isImage = attachment.fileType?.toLowerCase() == 'png' ||
                      attachment.fileType?.toLowerCase() == 'jpg' ||
                      attachment.fileType?.toLowerCase() == 'jpeg' ||
                      attachment.fileType?.toLowerCase() == 'webp' ||
                      attachment.fileType?.toLowerCase() == 'gif' ||
                      (attachment.imageList != null &&
                          attachment.imageList!['thumbnail'] != null);

                  Widget cardChild;

                  if (isImage &&
                      attachment.imageList != null &&
                      attachment.imageList!['thumbnail'] != null) {
                    final double screenWidth =
                        MediaQuery.of(context).size.width;
                    final String thumbUrl = screenWidth > 600
                        ? (attachment.imageList!['large'] ??
                            attachment.imageList!['medium'] ??
                            attachment.imageList!['thumbnail'])
                        : (attachment.imageList!['medium'] ??
                            attachment.imageList!['thumbnail']);
                    final String originalUrl =
                        attachment.imageList!['original'] ??
                            attachment.imageList!['large'] ??
                            attachment.imageList!['medium'] ??
                            attachment.imageList!['thumbnail'];
                    cardChild = GestureDetector(
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.95),
                          barrierDismissible: true,
                          barrierLabel: 'close'.tr(),
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              body: SafeArea(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 4.0,
                                      child: CachedNetworkImage(
                                        imageUrl: originalUrl,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2)),
                                        errorWidget: (context, url, error) =>
                                            Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                                Icons.broken_image_rounded,
                                                color: Colors.white54,
                                                size: 64),
                                            const SizedBox(height: AppSizes.s16),
                                            Text("failed_to_load_image".tr(),
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 16,
                                      right: 16,
                                      child: IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(AppSizes.s8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close_rounded,
                                              color: Colors.white, size: 24),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    Positioned(
                                      top: 16,
                                      left: 16,
                                      child: IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(AppSizes.s8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.download_rounded,
                                              color: Colors.white,
                                              size: 24),
                                        ),
                                        onPressed: () {
                                          _downloadFile(originalUrl,
                                              "image_${attachment.id}.jpg");
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Hero(
                              tag: 'image_${attachment.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  boxShadow: AppShadows.card,
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  child: CachedNetworkImage(
                                    imageUrl: thumbUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey.shade100,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image_rounded,
                                              color: Colors.grey.shade400,
                                              size: 32),
                                          const SizedBox(height: AppSizes.s4),
                                          Text("error".tr(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade500)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: GestureDetector(
                              onTap: () {
                                _downloadFile(
                                    originalUrl, "image_${attachment.id}.jpg");
                              },
                              child: Container(
                                padding: const EdgeInsets.all(AppSizes.s6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.download_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    cardChild = GestureDetector(
                      onTap: () {
                        if (attachment.url != null) {
                          final fileUrl = attachment.url!;
                          final fileName = fileUrl.split('/').last;
                          _downloadFile(fileUrl, fileName);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                              color: Colors.grey.shade200, width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.s12),
                              decoration: BoxDecoration(
                                color:
                                    Color(AppColors.buttons).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.insert_drive_file_rounded,
                                  size: 28, color: Color(AppColors.buttons)),
                            ),
                            const SizedBox(height: AppSizes.s8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                              child: Text(
                                  attachment.fileName ??
                                      attachment.fileType ??
                                      "File",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4B5563))),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.s12),
                    child: SizedBox(
                      width: AppSizes.s140,
                      height: 140,
                      child: cardChild,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
