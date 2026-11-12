import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/requests/details/views/widgets/request_details_header_widget.dart'
    show InfoTileWidget;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cv_hub_models.dart';

/// Navy header of the interview details page, built like the approvals details header
/// (RequestDetailsHeaderWidget): white title on the navy background, a status box on the
/// start side and info tiles two per row (candidate, job, type, date, meeting link, files).
class InterviewDetailsHeaderWidget extends StatelessWidget {
  final InterviewModel interview;

  const InterviewDetailsHeaderWidget({super.key, required this.interview});

  static bool _has(String? v) => v != null && v.trim().isNotEmpty && v != 'null';

  /// Status box icon, same idea as RequestsServices.getRequestsStatusIcon.
  IconData _statusIcon(String? status) {
    switch ((status ?? '').toLowerCase().trim()) {
      case 'completed':
      case 'evaluated':
      case 'done':
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'canceled':
      case 'cancelled':
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.event_available_outlined; // scheduled / pending
    }
  }

  Color _statusIconColor(String? status) {
    switch ((status ?? '').toLowerCase().trim()) {
      case 'completed':
      case 'evaluated':
      case 'done':
      case 'accepted':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  void _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final candidate = interview.candidate;
    final location = interview.location;
    final isLink = _has(location) && location!.startsWith('http');

    final tiles = <Widget>[
      if (_has(candidate?.fullName))
        InfoTileWidget(
          imgPath: Icons.person_2_outlined,
          title: candidate!.fullName!,
          isHighLight: true,
        ),
      if (_has(candidate?.job?.title))
        InfoTileWidget(
          imgPath: Icons.work_outline_rounded,
          title: candidate!.job!.title!,
        ),
      if (_has(interview.interviewType))
        InfoTileWidget(
          imgPath: Icons.video_camera_front_outlined,
          title: interview.interviewType!,
        ),
      if (_has(interview.scheduledAt))
        InfoTileWidget(
          imgPath: Icons.calendar_month_outlined,
          title: interview.scheduledAt!,
        ),
      if (_has(location))
        InfoTileWidget(
          imgPath: isLink ? Icons.link_rounded : Icons.location_on_outlined,
          title: isLink ? 'Meeting Link'.tr() : location!,
          onTap: isLink ? () => _open(location) : null,
        ),
      for (final a in candidate?.attachments ?? const <AttachmentModel>[])
        if (_has(a.fileUrl))
          InfoTileWidget(
            imgPath: Icons.file_download_outlined,
            title: _has(a.fileType) ? a.fileType! : 'Attachment'.tr(),
            onTap: () => _open(a.fileUrl!),
          ),
    ];

    final rows = <Widget>[];
    for (int i = 0; i < tiles.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: AppSizes.s12));
      rows.add(Row(
        children: [
          Expanded(child: tiles[i]),
          const SizedBox(width: AppSizes.s12),
          Expanded(child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox()),
        ],
      ));
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/request-app-bar.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: LayoutService.contentConstraints(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBarWithBookmark(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  routeName: AppRoutes.cvHubInterviewDetails.name,
                  defaultTitle: 'Interview Details'.tr(),
                  title: 'Interview Details'.tr(),
                  titleStyle: AppStyles.whiteHeading(context).copyWith(fontSize: 20),
                  bookmarkIconColor: Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.all(AppSizes.s10),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.goNamed(AppRoutes.home.name,
                              pathParameters: {'lang': context.locale.languageCode}),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_sharp,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.s18),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.s12, 0, AppSizes.s12, AppSpacing.section),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status box, as in the approvals header.
                      Tooltip(
                        message: (interview.status ?? '').tr(),
                        child: Container(
                          width: 65,
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(AppColors.buttons).withOpacity(.3),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_statusIcon(interview.status),
                                  size: 30, color: _statusIconColor(interview.status)),
                              if (_has(interview.status)) ...[
                                const SizedBox(height: AppSizes.s4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s4),
                                  child: Text(
                                    interview.status!.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyles.whiteContent(context)
                                        .copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.s8),
                      Expanded(child: Column(children: rows)),
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
}
