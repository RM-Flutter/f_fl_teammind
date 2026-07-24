import 'package:app_test/features/daily_reports/models/daily_report_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/widgets/glassmorphism_card.widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:html' if (dart.library.io) '../../../../core/services/dart_html_stub.dart' as html;


import '../../../core/routing/app_router.dart';
import '../controllers/salary_advance_details_controller.dart';
import 'update_salary_advance_screen.dart';
import '../../../../core/models/employee_action_model.dart';
import '../../../../core/constants/app_strings.dart';

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
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: controller.isLoading
                ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                : controller.requestDetails == null
                    ? Center(child: Text('error_loading_data'.tr()))
                    : RefreshIndicator.adaptive(
                        onRefresh: () =>
                            controller.fetchDetails(context, widget.requestId),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroHeader(controller),
                              Padding(
                                padding: EdgeInsets.all(AppSizes.s16),
                                child: Column(
                                  children: [
                                    _buildInfoCard(controller),
                                    if (controller
                                                .requestDetails?.attachments !=
                                            null &&
                                        controller.requestDetails!.attachments!
                                            .isNotEmpty) ...[
                                      SizedBox(height: 24),
                                      _buildAttachmentsSection(
                                          controller,
                                          controller
                                              .requestDetails!.attachments!),
                                    ],
                                    SizedBox(height: 20),
                                    _buildApprovalsCard(controller),
                                    SizedBox(height: 20),
                                    if (controller.requestDetails?.employeeActions != null && controller.requestDetails!.employeeActions!.isNotEmpty) ...[
                                      _buildActionsCard(controller),
                                      SizedBox(height: 20),
                                    ],
                                    _buildActionButtons(controller),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget _buildHeroHeader(SalaryAdvanceDetailsController controller) {
    final request = controller.requestDetails!;
    
    bool isMyRequest = request.employeeId == controller.userSettings?.empId;
    String defaultTitleText = 'request_details'.tr();
    String headerTitleText = isMyRequest ? defaultTitleText : (request.employeeProfile?.name ?? defaultTitleText);

    Widget? titleWidget;
    if (!isMyRequest && request.employeeProfile?.id != null) {
      titleWidget = GestureDetector(
        onTap: () {
          context.pushNamed(
            AppRoutes.employeeDetails.name,
            pathParameters: {
              'id': request.employeeProfile!.id.toString(),
              'lang': context.locale.languageCode,
            },
          );
        },
        child: Text(
          headerTitleText,
          style: AppStyles.whiteHeading(context).copyWith(fontSize: 20),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10, bottom: 30),
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.secondaryButton).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          AppBarWithBookmark(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            routeName: AppRoutes.salaryAdvanceDetails.name,
            defaultTitle: defaultTitleText,
            title: titleWidget == null ? headerTitleText : null,
            titleWidget: titleWidget,
            titleStyle: AppStyles.whiteHeading(context).copyWith(fontSize: 20),
            bookmarkIconColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop(wasUpdated);
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
                  child: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white.withOpacity(0.8), size: 48),
          SizedBox(height: 16),
          Text(
            'total_amount'.tr(),
            style: AppStyles.content(context)
                .copyWith(color: Colors.white.withOpacity(0.8), fontSize: 14),
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
                icon: Icons.person_outline,
                isLink: false,
                onTap: request.employeeProfile!.id != null
                    ? () {
                        context.pushNamed(
                          AppRoutes.employeeDetails.name,
                          pathParameters: {
                            'id': request.employeeProfile!.id.toString(),
                            'lang': context.locale.languageCode,
                          },
                        );
                      }
                    : null),
          _buildDetailRow(
            'createdAt'.tr(),
            request.createdAt != null && request.createdAt!.length >= 7
                ? (request.createdAt!.contains(' ')
                    ? request.createdAt!.split(' ')[0].substring(
                        0, 7) // Extract YYYY-MM if it's "YYYY-MM-DD HH:MM:SS"
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
              approverName: request.employeeId == controller.userSettings?.empId ? null : request.employeeProfile?.name,
              isFirst: true),
          if (UserSettingConst.generalSettingsModel?.managerAbleToApproveSalaryAdvances == true)
            _buildTimelineApprovalRow(
                'manager_approval'.tr(),
                request.managerId == null ? null : request.managerApproved,
                approverName: request.managerId == controller.userSettings?.empId ? null : request.managerProfile?.name),
          _buildTimelineApprovalRow(
              'hr_approval'.tr(),
              request.hrId == null ? null : request.hrApproved,
              approverName: request.hrId == controller.userSettings?.empId ? null : request.hrProfile?.name,
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineApprovalRow(String label, bool? isApproved,
      {String? approverName, bool isFirst = false, bool isLast = false}) {
    Color iconColor = isApproved == true
        ? const Color(0xFF10B981) // Clean, premium success green
        : (isApproved == false
            ? const Color(0xFFEF4444) // Clean, premium error red
            : const Color(0xFFD1D5DB)); // Clean, premium pending grey
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
                decoration: const BoxDecoration(shape: BoxShape.circle),
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
                    approverName != null && approverName.isNotEmpty ? "$label ($approverName)" : label,
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
                            : 'has_not_decided_yet'.tr()),
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

  Widget _buildDetailRow(String label, String value, {IconData? icon, VoidCallback? onTap, bool isLink = false}) {
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
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: AppStyles.content(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLink ? Color(AppColors.buttonColor) : null,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildApprovalRow removed as we now use _buildTimelineApprovalRow

  Widget _buildActionsCard(SalaryAdvanceDetailsController controller) {
    final actions = controller.requestDetails!.employeeActions!;
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
                  color: Color(AppColors.buttons).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.history_rounded,
                    color: Color(AppColors.buttons), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                AppStrings.history.tr(),
                style: AppStyles.heading(context)
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 24),
          ...actions.map((action) => _buildActionCard(action)).toList(),
        ],
      ),
    );
  }

  Widget _buildActionCard(EmployeeActionModel action) {
    String date = "";
    String time = "";
    if (action.createdAt != null && action.createdAt!.contains(" ")) {
      final parts = action.createdAt!.split(" ");
      date = parts[0];
      time = parts[1];
    } else {
      date = action.createdAt ?? "";
    }

    Color actionColor;
    IconData actionIcon;
    String actionLabel = "";
    
    switch (action.action) {
      case 'approve':
        actionColor = Colors.green;
        actionIcon = Icons.check_circle_outline;
        actionLabel = 'approve'.tr();
        break;
      case 'reject':
      case 'refused':
        actionColor = Colors.red;
        actionIcon = Icons.cancel_outlined;
        actionLabel = 'reject'.tr();
        break;
      case 'update-amount':
        actionColor = Colors.blue;
        actionIcon = Icons.attach_money_rounded;
        actionLabel = 'update_amount'.tr();
        break;
      case 'update-duration':
        actionColor = Colors.orange;
        actionIcon = Icons.update_rounded;
        actionLabel = 'update_duration'.tr();
        break;
      default:
        actionColor = Colors.grey;
        actionIcon = Icons.info_outline;
        actionLabel = action.action ?? '';
    }

    Widget actionWidget;
    if (action.action == 'update-duration' || action.action == 'update-amount') {
      actionWidget = Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: actionColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(actionIcon, color: actionColor, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actionLabel, style: TextStyle(fontWeight: FontWeight.bold, color: actionColor.withOpacity(0.8), fontSize: 12)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(action.valueFrom ?? "", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey.shade500, fontSize: 13)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey.shade400),
                      ),
                      Text(action.valueTo ?? "", style: TextStyle(fontWeight: FontWeight.bold, color: actionColor, fontSize: 14)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else {
      actionWidget = Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: actionColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: actionColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(actionIcon, color: actionColor, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actionLabel, style: TextStyle(fontWeight: FontWeight.bold, color: actionColor, fontSize: 14)),
                  if (action.message != null && action.message!.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(action.message!, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.4)),
                  ]
                ],
              ),
            )
          ],
        ),
      );
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
              if (action.profileId != null) {
                context.pushNamed(
                  AppRoutes.employeeDetails.name,
                  pathParameters: {
                    'lang': context.locale.languageCode,
                    'id': action.profileId.toString()
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
                      Text(action.profileName ?? "", style: AppStyles.darkContent(context).copyWith(fontWeight: FontWeight.bold)),
                      Text(action.profileJobTitle ?? "", style: AppStyles.greyContent(context).copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade300),
              ],
            ),
          ),
          Divider(height: 16, color: Colors.transparent),
          actionWidget,
          SizedBox(height: 8),
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
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCleanButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          child: _buildCleanButton(
            label: 'edit_request'.tr(),
            backgroundColor: Color(AppColors.buttons),
            textColor: Colors.white,
            icon: Icons.edit_note_rounded,
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
      );
    }

    // Cancel Button (replacing Delete)
    if (controller.canCancel) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(SizedBox(width: 12));
      }
      actionButtons.add(
        Expanded(
          child: _buildCleanButton(
            label: 'cancel_request'.tr(),
            backgroundColor: Colors.red.shade500,
            textColor: Colors.white,
            icon: Icons.cancel_outlined,
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
      );
    }

    if (actionButtons.isNotEmpty) {
      buttons.add(
        Row(
          children: actionButtons,
        ),
      );
    }

    // Employee Approve Button (if employee approval is rejected)
    if (controller.requestDetails?.employeeId == controller.userSettings?.empId &&
        controller.requestDetails?.employeeApproved == false &&
        controller.requestDetails?.status?.toLowerCase() != 'cancelled' &&
        controller.requestDetails?.status?.toLowerCase() != 'canceled') {
      buttons.add(
        _buildCleanButton(
          label: 'approve'.tr(),
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
          icon: Icons.check_circle_outline_rounded,
          onPressed: () async {
            bool success = await controller.reviewRequest(context, 'approved');
            if (success && mounted) {
              setState(() {
                wasUpdated = true;
              });
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
              (UserSettingConst.generalSettingsModel?.managerAbleToApproveSalaryAdvances != true ||
                  controller.requestDetails?.managerApproved == true);
      bool isCancelled =
          controller.requestDetails?.status?.toLowerCase() == 'cancelled' ||
              controller.requestDetails?.status?.toLowerCase() == 'canceled';
      bool isRejected =
          controller.requestDetails?.status?.toLowerCase() == 'rejected';

      // Show approve and reject only if it's not fully approved, not cancelled, and not rejected
      if (!isFullyApproved && !isCancelled && !isRejected) {
        buttons.add(
          Row(
            children: [
              Expanded(
                child: _buildCleanButton(
                  label: 'approve'.tr(),
                  backgroundColor: Colors.green.shade600,
                  textColor: Colors.white,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () async {
                    bool success =
                        await controller.reviewRequest(context, 'approved');
                    if (success && mounted) {
                      setState(() {
                        wasUpdated = true;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildCleanButton(
                  label: 'reject'.tr(),
                  backgroundColor: Colors.red.shade500,
                  textColor: Colors.white,
                  icon: Icons.cancel_outlined,
                  onPressed: () async {
                    bool success =
                        await controller.reviewRequest(context, 'rejected');
                    if (success && mounted) {
                      setState(() {
                        wasUpdated = true;
                      });
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
              Padding(padding: EdgeInsets.only(bottom: 12), child: btn))
          .toList(),
    );
  }

  Widget _buildAttachmentsSection(SalaryAdvanceDetailsController controller,
      List<ReportAttachmentModel> attachments) {
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.attach_file_rounded,
                      size: 20, color: Color(AppColors.buttons)),
                ),
                const SizedBox(width: 12),
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

                  final status = controller.requestDetails?.status?.toLowerCase();
                  final isPending = status != 'approved' &&
                      status != 'cancelled' &&
                      status != 'canceled';
                  final isHrOrTopManagement = controller.userSettings?.isHr == true ||
                      controller.userSettings?.topManagement == true;
                  final isOwner = controller.userSettings?.empId.toString() ==
                      controller.requestDetails?.employeeId?.toString();
                  final showDeleteIcon = isPending && isHrOrTopManagement && !isOwner;

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
                                            const Icon(Icons.broken_image_rounded,
                                                color: Colors.white54, size: 64),
                                            const SizedBox(height: 16),
                                            Text("Failed to load image",
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
                                          padding: const EdgeInsets.all(8),
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
                                          child: const Icon(Icons.download_rounded,
                                              color: Colors.white, size: 24),
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
                                          const SizedBox(height: 4),
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
                          border:
                              Border.all(color: Colors.grey.shade200, width: 1.5),
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
                              child: Icon(Icons.insert_drive_file_rounded,
                                  size: 28, color: Color(AppColors.buttons)),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
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

                  Widget mainWidget = cardChild;

                  if (showDeleteIcon) {
                    mainWidget = Stack(
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
                                bool success = await controller.removeAttachment(
                                    context, attachment.id!);
                                if (success && context.mounted) {
                                  setState(() {
                                    wasUpdated = true;
                                  });
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
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
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: mainWidget,
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
