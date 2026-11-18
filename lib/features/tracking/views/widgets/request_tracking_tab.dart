import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import '../../controllers/request_tracking_controller.dart';
import 'tracking_map_view_dialog.dart';
import 'tracking_notice_banner.dart';
import 'tracking_section_employee.dart';
import 'tracking_section_manager.dart';

/// The "Tracking" tab of a request's details (`approvables_details`, employee requests only).
/// The owner sees the employee section (screen 2); the manager / HR see the summary (screen 3).
class RequestTrackingTab extends StatelessWidget {
  final int requestId;
  final bool isOwner;

  const RequestTrackingTab({super.key, required this.requestId, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RequestTrackingController>(
      create: (ctx) => RequestTrackingController(requestId: requestId, isOwner: isOwner)..load(ctx),
      child: Consumer<RequestTrackingController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.details == null) {
            return const AppShimmerList(count: 3, padding: EdgeInsets.zero);
          }
          if (controller.details == null) {
            return AppCard(
              child: Column(
                children: [
                  Text(controller.errorMessage ?? 'something_went_wrong'.tr(),
                      textAlign: TextAlign.center, style: AppStyles.greyContent(context).copyWith(fontSize: 12.5)),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(onPressed: () => controller.load(context), child: Text('retry'.tr())),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => controller.load(context, silent: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: isOwner
                  ? TrackingSectionEmployee(controller: controller, padding: EdgeInsets.zero)
                  : TrackingSectionManager(controller: controller, padding: EdgeInsets.zero),
            ),
          );
        },
      ),
    );
  }
}

/// Opens the request's full route (`GET /requests/{id}/path`) in the map pop-up; with
/// [sessionId] the pop-up starts on that session.
Future<void> openTrackingRouteMap(
  BuildContext context,
  RequestTrackingController controller, {
  int? sessionId,
  int? legIndex,
}) async {
  final path = await controller.loadPath(context);
  if (path == null || !context.mounted) return;
  TrackingMapViewDialog.show(
    context,
    title: legIndex == null
        ? 'full_request_route_map'.tr()
        : 'route_for_session'.tr(namedArgs: {'index_1': '${legIndex + 1}'}),
    sessions: path,
    initialSessionId: sessionId,
  );
}

/// Shown to the manager when tracking is required and the employee has not tracked the request
/// yet: the server refuses the approval until then. Refusing and cancelling stay allowed.
class TrackingApprovalWarning extends StatelessWidget {
  const TrackingApprovalWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return TrackingNoticeBanner(
      icon: Icons.location_off_outlined,
      color: Color(AppColors.warningYellow),
      title: 'tracking_approval_blocked'.tr(),
      message: 'tracking_approval_blocked_hint'.tr(),
    );
  }
}
