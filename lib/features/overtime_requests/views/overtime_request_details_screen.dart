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
import '../../../../core/services/alert_service/alerts_service.dart';
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
    _durationController = TextEditingController(text: widget.request.overtime?.toString() ?? '');
    _replyController = TextEditingController();

    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      gCache = json.decode(jsonString);
      // Use employee_profile_id first (matches what the API stores on the request)
      if (gCache!['employee_profile_id'] != null) {
        currentUserId = int.tryParse(gCache!['employee_profile_id'].toString());
      }
      // Fallback to user id if employee_profile_id is missing
      if (currentUserId == null && gCache!['id'] != null) {
        currentUserId = int.tryParse(gCache!['id'].toString());
      }
    }
  }

  void _updateStatus(String status) async {
    if (_replyController.text.isEmpty) {
      AlertsService.error(
        context: context,
        message: AppStrings.pleaseEnterReason.tr(),
        title: 'error'.tr(),
      );
      return;
    }
    final provider = Provider.of<OvertimeRequestsProvider>(context, listen: false);
    final success = await provider.updateRequestStatus(
      context, 
      widget.request.id.toString(), 
      status, 
      _replyController.text
    );
    if (success && mounted) {
      context.pop();
    }
  }

  void _updateDuration() async {
    if (_durationController.text.isEmpty) {
      AlertsService.error(
        context: context,
        message: AppStrings.durationIsRequired.tr(),
        title: 'error'.tr(),
      );
      return;
    }
    final provider = Provider.of<OvertimeRequestsProvider>(context, listen: false);
    final success = await provider.updateRequestDuration(
      context, 
      widget.request.id.toString(), 
      _durationController.text
    );
    if (success && mounted) {
      AlertsService.success(
        context: context,
        message: AppStrings.updatedSuccessfully.tr(),
        title: 'success'.tr(),
      );
      setState(() {
        widget.request.overtime = int.tryParse(_durationController.text) ?? widget.request.overtime;
      });
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
    bool isHrOrTopManagement = gCache != null && (
        gCache!['is_hr'] == true || gCache!['top_management'] == true || gCache!['is_hr'] == 'true' || gCache!['top_management'] == 'true'
    );
    bool isManager = gCache != null && (
        (gCache!['is_manager_in'] != null && gCache!['is_manager_in'].isNotEmpty) ||
        (gCache!['is_teamleader_in'] != null && gCache!['is_teamleader_in'].isNotEmpty) ||
        (gCache!['role'] != null && (gCache!['role'] as List<dynamic>).map((e) => e.toString().toLowerCase()).contains('manager'))
    );

    bool canEditDuration = false;
    bool canApproveReject = false;

    if (!isMyRequest) {
      final currentStatus = widget.request.status ?? 'pending';
      if (currentStatus == 'pending' || currentStatus == 'waiting') {
        canEditDuration = isManager || isHrOrTopManagement;
        canApproveReject = isManager || isHrOrTopManagement;
      } else if (currentStatus == 'managerApproved') {
        canEditDuration = isHrOrTopManagement;
        canApproveReject = isHrOrTopManagement;
      }
    }

    final mainColor = Color(AppColors.buttons);

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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Manager Reply Section
                      if (widget.request.theManagerReply != null && widget.request.theManagerReply!.isNotEmpty) ...[
                        _buildSectionHeader(AppStrings.managerResponse.tr(), Icons.quickreply_outlined),
                        SizedBox(height: 12),
                        ...widget.request.theManagerReply!.map((reply) => _buildReplyCard(reply)).toList(),
                        SizedBox(height: 30),
                      ],

                      // Duration Edit (for Manager & HR)
                      if (canEditDuration) ...[
                        _buildSectionHeader(AppStrings.durationMinutes.tr(), Icons.timer_outlined),
                        SizedBox(height: 12),
                        _buildDurationUpdateField(provider),
                        SizedBox(height: 30),
                      ],

                      // Manager / HR Action Buttons
                      if (canApproveReject) ...[
                        _buildSectionHeader(AppStrings.reason.tr(), Icons.notes_outlined),
                        SizedBox(height: 12),
                        _buildReasonTextField(),
                        SizedBox(height: 24),
                        _buildActionButtons(provider),
                        SizedBox(height: 30),
                      ],

                      // Complaint Button
                      if (isMyRequest && (widget.request.status == 'rejected' || widget.request.status == 'refused')) ...[
                        SizedBox(
                          height: 55,
                          child: Row(
                            children: [
                              CustomRequestDetailsButton(
                                title: AppStrings.complaint.tr(),
                                onPressed: () async {
                                   context.pushNamed(
                                      AppRoutes.newComplainScreen.name,
                                      pathParameters: {'lang': context.locale.languageCode}
                                   );
                                },
                              ),
                            ],
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
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(AppColors.buttons).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Color(AppColors.buttons)),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: AppStyles.primaryContent(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(AppColors.secondaryButton),
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
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reply.managerName ?? "", style: AppStyles.darkContent(context).copyWith(fontWeight: FontWeight.bold)),
                      Text(reply.managerJobTitle ?? "", style: AppStyles.greyContent(context).copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade300),
              ],
            ),
          ),
          Divider(height: 24, color: Colors.grey.shade100),
          Text(reply.replay ?? "", style: AppStyles.darkContent(context).copyWith(fontSize: 14, height: 1.4)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (time.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: Colors.grey.shade400),
                    SizedBox(width: 4),
                    Text(time, style: AppStyles.greyContent(context).copyWith(fontSize: 10)),
                  ],
                ),
              Text(date, style: AppStyles.greyContent(context).copyWith(fontSize: 10, fontStyle: FontStyle.italic)),
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
        borderRadius: BorderRadius.circular(15),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: AppStrings.enterMinutes.tr(),
                      suffixText: AppStrings.minutes.tr(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: Colors.grey.shade200, indent: 10, endIndent: 10),
                TextButton(
                  onPressed: provider.isActionLoading ? null : _updateDuration,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15))),
                  ),
                  child: provider.isActionLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(AppStrings.update.tr(), style: TextStyle(color: Color(AppColors.buttons), fontWeight: FontWeight.bold, fontSize: 15)),
                )
              ],
            ),
          ),
          if (minutes > 0)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
              ),
              child: Text(
                preview,
                style: AppStyles.greyContent(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: Color(AppColors.buttons)),
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
        borderRadius: BorderRadius.circular(15),
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
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: EdgeInsets.all(16),
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
            height: 55,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppStrings.approve.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Container(
            height: 55,
            child: OutlinedButton(
              onPressed: provider.isActionLoading ? null : () => _updateStatus('rejected'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppStrings.reject.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color mainColor, bool isMyRequest) {
    String? displayName = widget.request.employeeName ?? widget.request.employeeProfile?.name;

    return Container(
      height: 290,
      width: 1.sw,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
                titleStyle: AppStyles.whiteHeading(context).copyWith(fontSize: 12),
                bookmarkIconColor: Colors.white,
                leading: Padding(
                  padding: EdgeInsets.all(10),
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
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              
              // Employee Name in Header
              if (!isMyRequest && displayName != null) ...[
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                  ),
                ),
                if (widget.request.employeeProfile?.department != null)
                   Text(
                      widget.request.employeeProfile!.department!,
                      style: AppStyles.whiteContent(context).copyWith(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                SizedBox(height: 12),
              ],

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status box
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 65,
                          height: 85,
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: RequestsServices.getRequestsStatusIcon(
                              context: context,
                              status: widget.request.status?.toLowerCase().contains('approved') == true ? 'approved' : 
                                      widget.request.status?.toLowerCase().contains('rejected') == true ? 'refused' : 'waiting',
                              iconSize: 30,
                              iconColor: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(width: 8),

                    // Info tiles
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            InfoTileWidget(
                              background: Color(AppColors.secondaryButton),
                              imgPath: Icons.calendar_month,
                              title: widget.request.date ?? "",
                              isFullRow: true,
                              trailing: InfoTileWidget(
                                width: 100,
                                background: Color(AppColors.secondaryButton).withOpacity(0.08),
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
              SizedBox(height: 12),
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

  Color get _imgColor => imgColor ?? Color(AppColors.buttons);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? (isFullRow == true ? 1.sw - 97 : (1.sw - 116) / 2),
        decoration: BoxDecoration(
          color: isHighLight == true ? _imgColor : background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    if (imagePath != null)
                      Image.asset(
                        imagePath!,
                        width: 14,
                        height: 14,
                        color: isHighLight == true ? Color(AppColors.background) : _imgColor,
                      )
                    else if (imgPath != null)
                      Icon(
                        imgPath,
                        size: 20,
                        color: isHighLight == true ? Color(AppColors.background) : _imgColor,
                      ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppStyles.whiteContent(context).copyWith(
                          fontSize: 11,
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
