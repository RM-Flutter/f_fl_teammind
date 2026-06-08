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

import '../controllers/salary_advance_details_controller.dart';

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
                              padding: EdgeInsets.all(AppSizes.s16.r),
                              child: Column(
                                children: [
                                  _buildInfoCard(controller),
                                  if (controller.requestDetails?.attachments !=
                                          null &&
                                      controller.requestDetails!.attachments!
                                          .isNotEmpty) ...[
                                    SizedBox(height: 24.h),
                                    _buildAttachmentsSection(controller
                                        .requestDetails!.attachments!),
                                  ],
                                  SizedBox(height: 20.h),
                                  _buildApprovalsCard(controller),
                                  SizedBox(height: 30.h),
                                  _buildActionButtons(controller),
                                  SizedBox(height: 30.h),
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
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
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
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
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
              color: Colors.white.withOpacity(0.8), size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'total_amount'.tr(),
            style: AppStyles.content(context).copyWith(
                color: Colors.white.withOpacity(0.8), fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                request.total ?? '0',
                style: AppStyles.heading(context).copyWith(
                  color: Colors.white,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  'egp'.tr(),
                  style: AppStyles.content(context).copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.sp,
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
    return Container(
      padding: EdgeInsets.all(AppSizes.s20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.buttonSecondaryColor).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Color(AppColors.buttonSecondaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.info_rounded,
                    color: Color(AppColors.buttonSecondaryColor), size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'request_info'.tr(),
                style: AppStyles.heading(context)
                    .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildDetailRow('how_long_to_pay'.tr(),
              '${request.howLongToPay ?? ''} ${'months'.tr()}',
              icon: Icons.calendar_view_month),
          _buildDetailRow('from_date'.tr(), request.from ?? '',
              icon: Icons.calendar_month),
          if (request.employeeProfile != null)
            _buildDetailRow(
                'employee_name'.tr(), request.employeeProfile!.name ?? '',
                icon: Icons.person_outline),
          _buildDetailRow('created_at'.tr(), request.createdAt ?? '',
              icon: Icons.access_time),
        ],
      ),
    );
  }

  Widget _buildApprovalsCard(SalaryAdvanceDetailsController controller) {
    final request = controller.requestDetails!;
    return Container(
      padding: EdgeInsets.all(AppSizes.s20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.buttonSecondaryColor).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Color(AppColors.warningYellow).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.fact_check_rounded,
                    color: Color(AppColors.warningYellow), size: 20),
              ),
              SizedBox(width: 12.w),
              Text(
                'approvals'.tr(),
                style: AppStyles.heading(context)
                    .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 24.h),
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
                child: Icon(iconData, color: iconColor, size: 24.sp),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      color:
                          isApproved == true ? iconColor : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppStyles.content(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(AppColors.titleTextColor),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isApproved == true
                        ? 'approved'.tr()
                        : (isApproved == false
                            ? 'rejected'.tr()
                            : 'pending'.tr()),
                    style: AppStyles.content(context).copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 13.sp,
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.sp, color: Colors.grey.shade400),
            SizedBox(width: 8.w),
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

    // Delete Button for Employee
    if (controller.canDelete) {
      buttons.add(
        CustomElevatedButton(
          title: 'delete_request'.tr(),
          backgroundColor: Colors.red,
          onPressed: () async {
            bool success = await controller.deleteRequest(context);
            if (success && mounted) {
              context.pop(true); // Return true to refresh list
            }
          },
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

      // Show approve and reject only if it's not fully approved
      if (!isFullyApproved) {
        buttons.add(
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  title: 'approve'.tr(),
                  backgroundColor: Colors.green,
                  onPressed: () async {
                    await controller.reviewRequest(context, 'approved');
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomElevatedButton(
                  title: 'reject'.tr(),
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await controller.reviewRequest(context, 'rejected');
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
              Padding(padding: EdgeInsets.only(bottom: 10.h), child: btn))
          .toList(),
    );
  }

  Widget _buildAttachmentsSection(List<ReportAttachmentModel> attachments) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.buttonSecondaryColor).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.attach_file_rounded,
                      size: 20.r, color: Color(AppColors.buttons)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'attachments'.tr(),
                    style: AppStyles.heading(context)
                        .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
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

                if (isImage &&
                    attachment.imageList != null &&
                    attachment.imageList!['thumbnail'] != null) {
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
                                              size: 64.r),
                                          SizedBox(height: 16.h),
                                          Text("Failed to load image",
                                              style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 14.sp)),
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
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
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
                                      color: Colors.grey.shade400, size: 32.r),
                                  SizedBox(height: 4.h),
                                  Text("Error",
                                      style: TextStyle(
                                          fontSize: 10.sp,
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
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16.r),
                      border:
                          Border.all(color: Colors.grey.shade200, width: 1.5),
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
                          child: Icon(Icons.insert_drive_file_rounded,
                              size: 28.r, color: Color(AppColors.buttons)),
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                              attachment.fileName ??
                                  attachment.fileType ??
                                  "File",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF4B5563))),
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
