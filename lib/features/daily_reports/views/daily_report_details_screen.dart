import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    String dateFormatted = widget.report.createdAt != null 
      ? DateFormat('EEEE, dd MMMM yyyy', context.locale.languageCode).format(widget.report.createdAt!)
      : 'Unknown Date';
    String? employeeName = widget.report.employeeProfile?.name;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CommentProvider()..getComment(context, "employee-daily-reports", widget.report.id.toString()),
        )
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 220.h,
              pinned: true,
              backgroundColor: Color(AppColors.buttons),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(AppColors.buttons),
                        Color(AppColors.buttons).withBlue(150),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50.w,
                        top: -50.h,
                        child: CircleAvatar(
                          radius: 130.r,
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      Positioned(
                        left: -30.w,
                        bottom: -20.h,
                        child: CircleAvatar(
                          radius: 80.r,
                          backgroundColor: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16.r),
                                    SizedBox(width: 8.w),
                                    Text(
                                      dateFormatted,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                AppStrings.reportDetails.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (employeeName != null) ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline_rounded, color: Colors.white70, size: 18.r),
                                    SizedBox(width: 6.w),
                                    Text(
                                      employeeName,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -20.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
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
                        SizedBox(height: 24.h),
                        
                        _buildSection(
                          title: AppStrings.inProgressTasks.tr(),
                          icon: Icons.sync_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          bgColor: const Color(0xFFDBEAFE),
                          content: widget.report.inProgress ?? AppStrings.noOngoingTasksRecorded.tr(),
                        ),
                        SizedBox(height: 24.h),

                        _buildSection(
                          title: AppStrings.blockersAndProblems.tr(),
                          icon: Icons.warning_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          bgColor: const Color(0xFFFEF3C7),
                          content: widget.report.problems ?? AppStrings.noProblemsRecorded.tr(),
                        ),
                        SizedBox(height: 24.h),

                        if (widget.report.attachments != null && widget.report.attachments!.isNotEmpty) ...[
                          _buildAttachmentsSection(widget.report.attachments!),
                          SizedBox(height: 40.h),
                        ],

                        // Comments Section
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                AppStrings.comments.tr().toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ),
                        SizedBox(height: 24.h),
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
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(24.r),
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
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, size: 22.r, color: iconColor),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 15.sp, 
                  height: 1.6, 
                  color: const Color(0xFF4B5563),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(List<ReportAttachmentModel> attachments) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
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
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.attach_file_rounded, size: 22.r, color: Color(AppColors.buttons)),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    AppStrings.attachments.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.1,
              ),
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                final isImage = attachment.fileType?.toLowerCase() == 'png' || 
                                attachment.fileType?.toLowerCase() == 'jpg' || 
                                attachment.fileType?.toLowerCase() == 'jpeg';

                if (isImage && attachment.imageList != null && attachment.imageList!['thumbnail'] != null) {
                  final String imageUrl = attachment.imageList!['thumbnail'];
                  return GestureDetector(
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
                                          Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64.r),
                                          SizedBox(height: 16.h),
                                          Text("Failed to load image", style: TextStyle(color: Colors.white54, fontSize: 14.sp)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 16.h,
                                    right: 16.w,
                                    child: IconButton(
                                      icon: Container(
                                        padding: EdgeInsets.all(8.r),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Hero(
                      tag: 'image_${attachment.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
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
                                  Icon(Icons.broken_image_rounded, color: Colors.grey.shade400, size: 32.r),
                                  SizedBox(height: 4.h),
                                  Text("Error", style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Color(AppColors.buttons).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.insert_drive_file_rounded, size: 28.r, color: Color(AppColors.buttons)),
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            attachment.fileName ?? attachment.fileType ?? "File", 
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4B5563))
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
