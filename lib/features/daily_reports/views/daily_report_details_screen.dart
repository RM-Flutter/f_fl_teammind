import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:html' if (dart.library.io) '../../../../core/services/dart_html_stub.dart' as html;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/comments/comments_widget.dart';
import '../../../../core/widgets/comments/logic/controller.dart';
import '../models/daily_report_model.dart';

class DailyReportDetailsScreen extends StatefulWidget {
  final DailyReportModel report;
  const DailyReportDetailsScreen({super.key, required this.report});

  @override
  State<DailyReportDetailsScreen> createState() => _DailyReportDetailsScreenState();
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
          final html.AnchorElement downloadAnchor = html.AnchorElement(href: blobUrl);
          downloadAnchor.download = fileName;
          downloadAnchor.style.display = 'none';
          html.document.body?.append(downloadAnchor);
          downloadAnchor.click();
          downloadAnchor.remove();
          html.Url.revokeObjectUrl(blobUrl);
        }).catchError((e) {
          Fluttertoast.showToast(msg: "Download failed: $e");
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
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
                  const SizedBox(height: 10),
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
      
      Fluttertoast.showToast(
        msg: '✅ ${'downloaded'.tr()}: $fileName',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      Fluttertoast.showToast(
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

  Widget _buildHeroHeader(BuildContext context) {
    String dateFormatted = widget.report.createdAt != null 
      ? DateFormat('EEEE, dd MMMM yyyy', context.locale.languageCode).format(widget.report.createdAt!)
      : 'Unknown Date';
    String? employeeName = widget.report.employeeProfile?.name;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.secondaryButton).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -60,
            child: CircleAvatar(
              radius: 140,
              backgroundColor: Colors.white.withOpacity(0.04),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -30,
            child: CircleAvatar(
              radius: 90,
              backgroundColor: Colors.white.withOpacity(0.06),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10, bottom: 40),
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular back button
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_sharp,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      Text(
                        AppStrings.reportDetails.tr(),
                        style: AppStyles.whiteHeading(context).copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 38), // placeholder to center title
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        dateFormatted,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (employeeName != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white70, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        employeeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CommentProvider()..getComment(context, "employee-daily-reports", widget.report.id.toString()),
        )
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: RefreshIndicator.adaptive(
          onRefresh: () async {
            if (context.mounted) {
              context.read<CommentProvider>().getComment(context, "employee-daily-reports", widget.report.id.toString());
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: AppStrings.accomplishments.tr(),
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF10B981),
                        bgColor: const Color(0xFFD1FAE5),
                        content: widget.report.done ?? AppStrings.noAccomplishmentsRecorded.tr(),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildSection(
                        title: AppStrings.inProgressTasks.tr(),
                        icon: Icons.sync_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        bgColor: const Color(0xFFDBEAFE),
                        content: widget.report.inProgress ?? AppStrings.noOngoingTasksRecorded.tr(),
                      ),
                      const SizedBox(height: 16),

                      _buildSection(
                        title: AppStrings.blockersAndProblems.tr(),
                        icon: Icons.warning_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFFEF3C7),
                        content: widget.report.problems ?? AppStrings.noProblemsRecorded.tr(),
                      ),
                      const SizedBox(height: 16),

                      if (widget.report.attachments != null && widget.report.attachments!.isNotEmpty) ...[
                        _buildAttachmentsSection(widget.report.attachments!),
                        const SizedBox(height: 24),
                      ],

                      // Comments Section
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppStrings.comments.tr().toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade500,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                        }
                      ),
                      const SizedBox(height: 50),
                    ],
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
    required Color bgColor,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: iconColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, size: 18, color: iconColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(List<ReportAttachmentModel> attachments) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.attach_file_rounded, size: 22, color: Color(AppColors.buttons)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppStrings.attachments.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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

                  if (isImage && attachment.imageList != null && attachment.imageList!['thumbnail'] != null) {
                    final String imageUrl = attachment.imageList!['thumbnail'];
                    cardChild = GestureDetector(
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.95),
                          barrierDismissible: true,
                          barrierLabel: 'Close',
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (context, animation, secondaryAnimation) {
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
                                        imageUrl: imageUrl,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                        ),
                                        errorWidget: (context, url, error) => Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
                                            const SizedBox(height: 16),
                                            Text("Failed to load image", style: const TextStyle(color: Colors.white54, fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 16,
                                      right: 16,
                                      child: IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    Positioned(
                                      top: 16,
                                      left: 16,
                                      child: IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.download_rounded, color: Colors.white, size: 24),
                                        ),
                                        onPressed: () {
                                          _downloadFile(imageUrl, "image_${attachment.id}.jpg");
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
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade100,
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey.shade100,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image_rounded, color: Colors.grey.shade400, size: 32),
                                          const SizedBox(height: 4),
                                          Text("Error", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
                                _downloadFile(imageUrl, "image_${attachment.id}.jpg");
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
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
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200, width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(AppColors.buttons).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.insert_drive_file_rounded, size: 28, color: Color(AppColors.buttons)),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                attachment.fileName ?? attachment.fileType ?? "File", 
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 140,
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
