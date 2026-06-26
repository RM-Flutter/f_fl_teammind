import 'package:app_test/features/daily_reports/models/daily_report_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/widgets/glassmorphism_card.widget.dart';

import '../controllers/salary_advance_details_controller.dart';
import 'update_salary_advance_screen.dart';

class SalaryAdvanceDetailsScreen extends StatefulWidget {
  final int requestId;

  const SalaryAdvanceDetailsScreen({super.key, required this.requestId});

  @override
  State<SalaryAdvanceDetailsScreen> createState() =>
      _SalaryAdvanceDetailsScreenState();
}

class _SalaryAdvanceDetailsScreenState
    extends State<SalaryAdvanceDetailsScreen> {
  late final SalaryAdvanceDetailsController viewModel;
  bool wasUpdated = false;

  @override
  void initState() {
    super.initState();
    viewModel = SalaryAdvanceDetailsController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchDetails(context, widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SalaryAdvanceDetailsController>.value(
      value: viewModel,
      child: Consumer<SalaryAdvanceDetailsController>(
        builder: (context, controller, child) {
          return TemplatePage(
            pageContext: context,
            title: 'request_details'.tr(),
            popResult: wasUpdated,
            body: controller.isLoading
                ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                : controller.requestDetails == null
                    ? Center(child: Text('error_loading_data'.tr()))
                    : SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroHeader(controller),
                            Padding(
                              padding: EdgeInsets.all(AppSizes.s16),
                              child: Column(
                                children: [
                                  _buildInfoCard(controller),
                                  if (controller.requestDetails?.attachments !=
                                          null &&
                                      controller.requestDetails!.attachments!
                                          .isNotEmpty) ...[
                                    SizedBox(height: 24),
                                    _buildAttachmentsSection(controller, controller
                                        .requestDetails!.attachments!),
                                  ],
                                  SizedBox(height: 20),
                                  _buildApprovalsCard(controller),
                                  SizedBox(height: 30),
                                  _buildActionButtons(controller),
                                  SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader(SalaryAdvanceDetailsController controller) {
    final request = controller.requestDetails!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(AppColors.buttonColor),
            Color(AppColors.buttonSecondaryColor)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.buttonColor).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white.withOpacity(0.8), size: 48),
          SizedBox(height: 16),
          Text(
            'total_amount'.tr(),
            style: AppStyles.content(context).copyWith(
                color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                request.total ?? '0',
                style: AppStyles.heading(context).copyWith(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'egp'.tr(),
                  style: AppStyles.content(context).copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(SalaryAdvanceDetailsController controller) {
    final request = controller.requestDetails!;
    return GlassmorphismCard(
      padding: EdgeInsets.all(AppSizes.s20),
      backgroundColor: Colors.white,
      opacity: 0.9,
      boxShadow: [
        BoxShadow(
          color: Color(AppColors.buttonSecondaryColor).withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(AppColors.buttonSecondaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info_rounded,
                    color: Color(AppColors.buttonSecondaryColor), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'request_info'.tr(),
                style: AppStyles.heading(context)
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildDetailRow('how_long_to_pay'.tr(),
              '${request.howLongToPay ?? ''} ${'months'.tr()}',
              icon: Icons.calendar_view_month),
          _buildDetailRow('from_date'.tr(), request.from ?? '',
              icon: Icons.calendar_month),
          if (request.employeeProfile != null)
            _buildDetailRow(
                'employee_name'.tr(), request.employeeProfile!.name ?? '',
                icon: Icons.person_outline),
          _buildDetailRow(
            'createdAt'.tr(),
            request.createdAt != null && request.createdAt!.length >= 7
                ? (request.createdAt!.contains(' ') 
                    ? request.createdAt!.split(' ')[0].substring(0, 7) // Extract YYYY-MM if it's "YYYY-MM-DD HH:MM:SS"
                    : request.createdAt!.substring(0, 7))
                : (request.createdAt ?? ''),
            icon: Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalsCard(SalaryAdvanceDetailsController controller) {
    final request = controller.requestDetails!;
    return GlassmorphismCard(
      padding: EdgeInsets.all(AppSizes.s20),
      backgroundColor: Colors.white,
      opacity: 0.9,
      boxShadow: [
        BoxShadow(
          color: Color(AppColors.buttonSecondaryColor).withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(AppColors.warningYellow).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fact_check_rounded,
                    color: Color(AppColors.warningYellow), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'approvals'.tr(),
                style: AppStyles.heading(context)
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildTimelineApprovalRow(
              'employee_approval'.tr(), request.employeeApproved,
              isFirst: true),
          _buildTimelineApprovalRow('hr_approval'.tr(), request.hrApproved),
          _buildTimelineApprovalRow(
              'manager_approval'.tr(), request.managerApproved,
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineApprovalRow(String label, bool? isApproved,
      {bool isFirst = false, bool isLast = false}) {
    Color iconColor = isApproved == true
        ? Color(AppColors.successGreen)
        : (isApproved == false
            ? Color(AppColors.failureRed)
            : Color(AppColors.warningYellow));
    IconData iconData = isApproved == true
        ? Icons.check_circle_rounded
        : (isApproved == false
            ? Icons.cancel_rounded
            : Icons.hourglass_empty_rounded);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1)
                ]),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          isApproved == true ? iconColor : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppStyles.content(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(AppColors.titleTextColor),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isApproved == true
                        ? 'approved'.tr()
                        : (isApproved == false
                            ? 'rejected'.tr()
                            : 'pending'.tr()),
                    style: AppStyles.content(context).copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey.shade400),
            SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppStyles.content(context).copyWith(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppStyles.content(context)
                  .copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // _buildApprovalRow removed as we now use _buildTimelineApprovalRow

  Widget _buildActionButtons(SalaryAdvanceDetailsController controller) {
    if (controller.isActionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Widget> buttons = [];
    List<Widget> actionButtons = [];

    // Edit Button
    if (controller.canEdit) {
      actionButtons.add(
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(AppColors.buttonColor),
                  Color(AppColors.buttonSecondaryColor),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Color(AppColors.buttonColor).withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
              label: Text(
                'edit_request'.tr(),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => UpdateSalaryAdvanceScreen(
                      existingRequest: controller.requestDetails!,
                    ),
                  ),
                );
                if (updated == true && mounted) {
                  setState(() {
                    wasUpdated = true;
                  });
                  viewModel.fetchDetails(context, widget.requestId);
                }
              },
            ),
          ),
        ),
      );
    }

    // Cancel Button (replacing Delete)
    if (controller.canCancel) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(SizedBox(width: 12));
      }
      actionButtons.add(
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade500,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.cancel_outlined, color: Colors.white, size: 20),
              label: Text(
                'cancel_request'.tr(),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final confirm = await AlertsService.customConfirm(
                  context: context,
                  title: 'cancel_request'.tr(),
                  message: 'cancel_request_confirm'.tr(),
                );
                if (confirm == true && mounted) {
                  bool success = await controller.cancelRequest(context);
                  if (success && mounted) {
                    context.pop(true); // Return true to refresh list
                  }
                }
              },
            ),
          ),
        ),
      );
    }

    if (actionButtons.isNotEmpty) {
      buttons.add(
        Row(
          children: actionButtons,
        ),
      );
    }

    // Review Buttons for Manager/HR
    if (controller.canReview &&
        controller.requestDetails?.employeeId !=
            controller.userSettings?.empId) {
      bool isFullyApproved =
          controller.requestDetails?.employeeApproved == true &&
              controller.requestDetails?.hrApproved == true &&
              controller.requestDetails?.managerApproved == true;
      bool isCancelled = controller.requestDetails?.status?.toLowerCase() == 'cancelled' || controller.requestDetails?.status?.toLowerCase() == 'canceled';
      bool isRejected = controller.requestDetails?.status?.toLowerCase() == 'rejected';

      // Show approve and reject only if it's not fully approved, not cancelled, and not rejected
      if (!isFullyApproved && !isCancelled && !isRejected) {
        buttons.add(
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  title: 'approve'.tr(),
                  backgroundColor: Colors.green,
                  onPressed: () async {
                    bool success = await controller.reviewRequest(context, 'approved');
                    if (success && mounted) {
                      setState(() { wasUpdated = true; });
                    }
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: CustomElevatedButton(
                  title: 'reject'.tr(),
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    bool success = await controller.reviewRequest(context, 'rejected');
                    if (success && mounted) {
                      setState(() { wasUpdated = true; });
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      children: buttons
          .map((btn) =>
              Padding(padding: EdgeInsets.only(bottom: 10), child: btn))
          .toList(),
    );
  }

  Widget _buildAttachmentsSection(SalaryAdvanceDetailsController controller, List<ReportAttachmentModel> attachments) {
    return GlassmorphismCard(
      backgroundColor: Colors.white,
      opacity: 0.9,
      boxShadow: [
        BoxShadow(
          color: Color(AppColors.buttonSecondaryColor).withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.attach_file_rounded,
                      size: 20, color: Color(AppColors.buttons)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'attachments'.tr(),
                    style: AppStyles.heading(context)
                        .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                // runSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                final isImage = attachment.fileType?.toLowerCase() == 'png' ||
                    attachment.fileType?.toLowerCase() == 'jpg' ||
                    attachment.fileType?.toLowerCase() == 'jpeg' ||
                    attachment.fileType?.toLowerCase() == 'webp' ||
                    attachment.fileType?.toLowerCase() == 'gif' ||
                    (attachment.imageList != null &&
                        attachment.imageList!['thumbnail'] != null);

                final status = controller.requestDetails?.status?.toLowerCase();
                final isPending = status != 'approved' && status != 'cancelled' && status != 'canceled';
                final isHr = controller.userSettings?.isHr == true;
                final isOwner = controller.userSettings?.empId.toString() ==
                    controller.requestDetails?.employeeId?.toString();
                final showDeleteIcon = isPending && isHr && !isOwner;

                Widget cardChild;

                if (isImage &&
                    attachment.imageList != null &&
                    attachment.imageList!['thumbnail'] != null) {
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
                                      placeholder: (context, url) =>
                                          const Center(
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2)),
                                      errorWidget: (context, url, error) =>
                                          Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image_rounded,
                                              color: Colors.white54,
                                              size: 64),
                                          SizedBox(height: 16),
                                          Text("Failed to load image",
                                              style: TextStyle(
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
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded,
                                            color: Colors.white, size: 24),
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
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_rounded,
                                      color: Colors.grey.shade400, size: 32),
                                  SizedBox(height: 4),
                                  Text("Error",
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
                  );
                } else {
                  cardChild = Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.grey.shade200, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(AppColors.buttons).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.insert_drive_file_rounded,
                              size: 28, color: Color(AppColors.buttons)),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                              attachment.fileName ??
                                  attachment.fileType ??
                                  "File",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF4B5563))),
                        ),
                      ],
                    ),
                  );
                }

                if (showDeleteIcon) {
                  return Stack(
                    children: [
                      Positioned.fill(child: cardChild),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () async {
                            final confirm = await AlertsService.customConfirm(
                              context: context,
                              title: 'remove_attachment'.tr(),
                              message: 'remove_attachment_confirm'.tr(),
                            );
                            if (confirm == true && context.mounted) {
                              bool success = await controller.removeAttachment(context, attachment.id!);
                              if (success && context.mounted) {
                                setState(() {
                                  wasUpdated = true;
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return cardChild;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
