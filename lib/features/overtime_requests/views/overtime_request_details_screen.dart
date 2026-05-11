import 'dart:convert';
import 'package:app_test/features/requests/shared/ui/widgets/custom_request_details_button.widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/app_bar_with_bookmark.widget.dart';
import '../controllers/overtime_requests_controller.dart';
import '../models/overtime_request_model.dart';
import '../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../../core/services/requests_services.dart';

class OvertimeRequestDetailsScreen extends StatefulWidget {
  final OvertimeRequestModel request;

  const OvertimeRequestDetailsScreen({super.key, required this.request});

  @override
  State<OvertimeRequestDetailsScreen> createState() => _OvertimeRequestDetailsScreenState();
}

class _OvertimeRequestDetailsScreenState extends State<OvertimeRequestDetailsScreen> {
  late TextEditingController _durationController;
  late TextEditingController _replyController;
  Map<String, dynamic>? gCache;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(text: widget.request.overtime?.toString() ?? "0");
    _replyController = TextEditingController();

    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      gCache = json.decode(jsonString);
      currentUserId = gCache!['id'];
      if (currentUserId == null && gCache!['employee_profile_id'] != null) {
        currentUserId = int.tryParse(gCache!['employee_profile_id'].toString());
      }
    }
  }

  void _updateStatus(String status) async {
    if (_replyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.pleaseEnterReason.tr())));
      return;
    }
    final provider = Provider.of<OvertimeRequestsProvider>(context, listen: false);
    final success = await provider.updateRequestStatus(
      context, 
      widget.request.id.toString(), 
      status, 
      _replyController.text
    );
    if (success) context.pop();
  }

  void _updateDuration() async {
    if (_durationController.text.isEmpty) return;
    final provider = Provider.of<OvertimeRequestsProvider>(context, listen: false);
    final success = await provider.updateRequestDuration(
      context, 
      widget.request.id.toString(), 
      _durationController.text
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.updatedSuccessfully.tr())));
    }
  }

  String formatStatus(String? status) {
    if (status == null) return '';
    switch (status) {
      case 'hrApproved': return AppStrings.hrApprovedStatus.tr();
      case 'managerApproved': return AppStrings.managerApprovedStatus.tr();
      case 'pending': return AppStrings.pendingStatus.tr();
      case 'waiting': return AppStrings.pendingStatus.tr();
      case 'rejected': return AppStrings.rejectedStatus.tr();
      case 'refused': return AppStrings.rejectedStatus.tr();
      default:
        return status.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim().replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase());
    }
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.toLowerCase().contains('approved')) return Colors.green;
    if (status.toLowerCase().contains('rejected') || status.toLowerCase().contains('refused')) return Colors.red;
    return Colors.orange;
  }

  String formatDuration(int? totalMinutes) {
    if (totalMinutes == null) return "0 ${AppStrings.minutes.tr()}";
    int hoursCount = totalMinutes ~/ 60;
    int minutesCount = totalMinutes % 60;
    
    String hoursText = AppStrings.hours.tr();
    String minutesText = AppStrings.minutes.tr();

    if (hoursCount == 0) return "$minutesCount $minutesText";
    if (minutesCount == 0) return "$hoursCount $hoursText";
    return "$hoursCount $hoursText $minutesCount $minutesText";
  }

  @override
  Widget build(BuildContext context) {
    bool isMyRequest = widget.request.employeeProfileId == currentUserId;
    bool isManager = gCache != null && (
        (gCache!['is_manager_in'] != null && gCache!['is_manager_in'].isNotEmpty) ||
        (gCache!['is_teamleader_in'] != null && gCache!['is_teamleader_in'].isNotEmpty)
    );

    final mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Color(AppColors.background),
      body: Consumer<OvertimeRequestsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildHeader(context, mainColor, isMyRequest),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Manager Reply Section
                      if (widget.request.theManagerReply != null && widget.request.theManagerReply!.isNotEmpty) ...[
                        _buildSectionHeader(AppStrings.managerResponse.tr(), Icons.quickreply_outlined),
                        SizedBox(height: 12.h),
                        ...widget.request.theManagerReply!.map((reply) => _buildReplyCard(reply)).toList(),
                        SizedBox(height: 30.h),
                      ],

                      // Duration Edit (for Manager)
                      if (!isMyRequest && isManager) ...[
                        _buildSectionHeader(AppStrings.durationMinutes.tr(), Icons.timer_outlined),
                        SizedBox(height: 12.h),
                        _buildDurationUpdateField(provider),
                        SizedBox(height: 30.h),
                      ],

                      // Manager Action Buttons
                      if (isManager && !isMyRequest && (widget.request.status == 'pending' || widget.request.status == 'waiting')) ...[
                        _buildSectionHeader(AppStrings.reason.tr(), Icons.notes_outlined),
                        SizedBox(height: 12.h),
                        _buildReasonTextField(),
                        SizedBox(height: 24.h),
                        _buildActionButtons(provider),
                        SizedBox(height: 30.h),
                      ],

                      // Complaint Button
                      if (isMyRequest && (widget.request.status == 'rejected' || widget.request.status == 'refused')) ...[
                        Center(
                          child: CustomRequestDetailsButton(
                            title: AppStrings.complaint.tr(),
                            onPressed: () async {
                               context.pushNamed(
                                  AppRoutes.newComplainScreen.name,
                                  pathParameters: {'lang': context.locale.languageCode}
                               );
                            },
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: Color(AppColors.buttons).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.r, color: Color(AppColors.buttons)),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: AppStyles.primaryContent(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Color(AppColors.titleText),
          ),
        ),
      ],
    );
  }

  Widget _buildReplyCard(ManagerReply reply) {
    String date = "";
    String time = "";
    if (reply.createdAt != null && reply.createdAt!.contains(" ")) {
      final parts = reply.createdAt!.split(" ");
      date = parts[0];
      time = parts[1];
    } else {
      date = reply.createdAt ?? "";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (reply.managerId != null) {
                context.pushNamed(
                  AppRoutes.employeeDetails.name,
                  pathParameters: {
                    'lang': context.locale.languageCode,
                    'id': reply.managerId.toString()
                  }
                );
              }
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Color(AppColors.buttons).withOpacity(0.1),
                  backgroundImage: (reply.managerPhoto != null && reply.managerPhoto!.isNotEmpty)
                      ? CachedNetworkImageProvider(reply.managerPhoto!)
                      : null,
                  child: (reply.managerPhoto == null || reply.managerPhoto!.isEmpty)
                      ? Icon(Icons.person, size: 22.r, color: Color(AppColors.buttons))
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reply.managerName ?? "", style: AppStyles.darkContent(context).copyWith(fontWeight: FontWeight.bold)),
                      Text(reply.managerJobTitle ?? "", style: AppStyles.greyContent(context).copyWith(fontSize: 11.sp)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12.r, color: Colors.grey.shade300),
              ],
            ),
          ),
          Divider(height: 24.h, color: Colors.grey.shade100),
          Text(reply.replay ?? "", style: AppStyles.darkContent(context).copyWith(fontSize: 14.sp, height: 1.4)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (time.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10.r, color: Colors.grey.shade400),
                    SizedBox(width: 4.w),
                    Text(time, style: AppStyles.greyContent(context).copyWith(fontSize: 10.sp)),
                  ],
                ),
              Text(date, style: AppStyles.greyContent(context).copyWith(fontSize: 10.sp, fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationUpdateField(OvertimeRequestsProvider provider) {
    int minutes = int.tryParse(_durationController.text) ?? 0;
    String preview = formatDuration(minutes);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    decoration: InputDecoration(
                      hintText: AppStrings.enterMinutes.tr(),
                      suffixText: AppStrings.minutes.tr(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: Colors.grey.shade200, indent: 10.h, endIndent: 10.h),
                TextButton(
                  onPressed: provider.isActionLoading ? null : _updateDuration,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15.r), bottomRight: Radius.circular(15.r))),
                  ),
                  child: provider.isActionLoading
                      ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(AppStrings.update.tr(), style: TextStyle(color: Color(AppColors.buttons), fontWeight: FontWeight.bold, fontSize: 15.sp)),
                )
              ],
            ),
          ),
          if (minutes > 0)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.r), bottomRight: Radius.circular(15.r)),
              ),
              child: Text(
                preview,
                style: AppStyles.greyContent(context).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Color(AppColors.buttons)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReasonTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: TextField(
        controller: _replyController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: AppStrings.typeYourMessage.tr(),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          contentPadding: EdgeInsets.all(16.r),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButtons(OvertimeRequestsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 55.h,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: ElevatedButton(
              onPressed: provider.isActionLoading ? null : () => _updateStatus('approved'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(AppStrings.approve.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Container(
            height: 55.h,
            child: OutlinedButton(
              onPressed: provider.isActionLoading ? null : () => _updateStatus('rejected'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(AppStrings.reject.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color mainColor, bool isMyRequest) {
    String? displayName = widget.request.employeeName ?? widget.request.employeeProfile?.name;

    return Container(
      height: 290.h,
      width: 1.sw,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(AppColors.titleText),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        image: const DecorationImage(
          image: AssetImage("assets/images/request-app-bar.png"),
          fit: BoxFit.fill,
          opacity: 1.0,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1.sw),
          child: Column(
            children: [
              AppBarWithBookmark(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                routeName: AppRoutes.overtimeRequestDetailsScreen.name,
                title: AppStrings.details.tr(),
                titleStyle: AppStyles.whiteHeading(context).copyWith(fontSize: 12.sp),
                bookmarkIconColor: Colors.white,
                leading: Padding(
                  padding: EdgeInsets.all(10.r),
                  child: InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(AppRoutes.home.name,
                            pathParameters: {'lang': context.locale.languageCode});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.white,
                        size: 18.r,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              
              // Employee Name in Header
              if (!isMyRequest && displayName != null) ...[
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                  ),
                ),
                if (widget.request.employeeProfile?.department != null)
                   Text(
                      widget.request.employeeProfile!.department!,
                      style: AppStyles.whiteContent(context).copyWith(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                SizedBox(height: 12.h),
              ],

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status box
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 65.w,
                          height: 85.h,
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(.3),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: RequestsServices.getRequestsStatusIcon(
                              context: context,
                              status: widget.request.status?.toLowerCase().contains('approved') == true ? 'approved' : 
                                      widget.request.status?.toLowerCase().contains('rejected') == true ? 'refused' : 'waiting',
                              iconSize: 30.r,
                              iconColor: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(width: 8.w),

                    // Info tiles
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: [
                            InfoTileWidget(
                              imgPath: Icons.calendar_month,
                              title: widget.request.date ?? "",
                              isFullRow: true,
                              trailing: InfoTileWidget(
                                width: 100.w,
                                background: const Color(AppColors.black).withOpacity(0.08),
                                imgPath: Icons.access_time,
                                title: formatDuration(widget.request.overtime),
                              ),
                            ),
                            InfoTileWidget(
                              imgPath: Icons.info_outline,
                              title: formatStatus(widget.request.status),
                              background: getStatusColor(widget.request.status).withOpacity(0.2),
                              imgColor: getStatusColor(widget.request.status),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoTileWidget extends StatelessWidget {
  final IconData? imgPath;
  final String? imagePath;
  final Color? background;
  final Color? imgColor;
  final String title;
  final double? width;
  final VoidCallback? onTap;
  final bool? isFullRow;
  final bool? isHighLight;
  final Widget? trailing;

  const InfoTileWidget({
    super.key,
    this.isHighLight = false,
    this.isFullRow = false,
    this.imgPath,
    this.imagePath,
    this.width,
    this.onTap,
    required this.title,
    this.background = const Color(AppColors.navyBlue),
    this.trailing,
    this.imgColor,
  });

  Color get _imgColor => imgColor ?? Color(AppColors.secondaryButton);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? (isFullRow == true ? 1.sw - 97.w : (1.sw - 116.w) / 2),
        decoration: BoxDecoration(
          color: isHighLight == true ? _imgColor : background,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                child: Row(
                  children: [
                    if (imagePath != null)
                      Image.asset(
                        imagePath!,
                        width: 14.r,
                        height: 14.r,
                        color: isHighLight == true ? Color(AppColors.background) : _imgColor,
                      )
                    else if (imgPath != null)
                      Icon(
                        imgPath,
                        size: 20.r,
                        color: isHighLight == true ? Color(AppColors.background) : _imgColor,
                      ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        title,
                        style: AppStyles.whiteContent(context).copyWith(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isFullRow == true && trailing != null) trailing!
          ],
        ),
      ),
    );
  }
}
