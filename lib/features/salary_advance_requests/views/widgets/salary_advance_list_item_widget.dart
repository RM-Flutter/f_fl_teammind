import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/requests_services.dart';
import '../../../../core/widgets/glassmorphism_card.widget.dart';
import '../../shared/models/salary_advance_request_model.dart';
import '../update_salary_advance_screen.dart';

class SalaryAdvanceListItemWidget extends StatefulWidget {
  final SalaryAdvanceRequestModel request;
  final bool isIncoming;

  /// Whether the current logged-in user can edit this request
  /// (owner employee OR manager/HR for any request)
  final bool canEdit;

  /// Called when the list should be refreshed (e.g. after an edit)
  final VoidCallback? onRefresh;

  const SalaryAdvanceListItemWidget({
    super.key,
    required this.request,
    required this.isIncoming,
    this.canEdit = false,
    this.onRefresh,
  });

  @override
  State<SalaryAdvanceListItemWidget> createState() =>
      _SalaryAdvanceListItemWidgetState();
}

class _SalaryAdvanceListItemWidgetState
    extends State<SalaryAdvanceListItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isApproved = (widget.request.employeeApproved == true &&
        widget.request.hrApproved == true &&
        widget.request.managerApproved == true);

    String status = widget.request.status?.toLowerCase() ?? (isApproved ? 'approved' : 'pending');
    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = Color(AppColors.successGreen);
        statusText = 'approved'.tr();
        break;
      case 'rejected':
        statusColor = Color(AppColors.failureRed);
        statusText = 'rejected'.tr();
        break;
      case 'cancelled' || 'canceled':
        statusColor = Color(AppColors.failureRed);
        statusText = 'cancelled'.tr();
        break;
      default:
        statusColor = Color(AppColors.warningYellow);
        statusText = 'pending'.tr();
    }

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _animationController.forward();
      },
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () async {
        final updated = await context.pushNamed<bool>(
          AppRoutes.salaryAdvanceDetails.name,
          pathParameters: {
            'id': widget.request.id.toString(),
            'lang': context.locale.languageCode,
          },
        );
        if (updated == true) {
          widget.onRefresh?.call();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: AppSizes.s16, left: 4, right: 4),
          child: GlassmorphismCard(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            opacity: 0.8,
            boxShadow: [
              BoxShadow(
                color: Color(AppColors.buttonColor).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Incoming: Employee name header ───
              if (widget.isIncoming &&
                  widget.request.employeeProfile != null) ...[
                Padding(
                  padding: EdgeInsets.only(
                      top: AppSizes.s14,
                      left: AppSizes.s16,
                      right: AppSizes.s16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (widget.request.employeeProfile?.id != null) {
                              context.pushNamed(
                                AppRoutes.employeeDetails.name,
                                pathParameters: {
                                  'id': widget.request.employeeProfile!.id.toString(),
                                  'lang': context.locale.languageCode,
                                },
                              );
                            }
                          },
                          child: Text(
                            widget.request.employeeProfile?.name ?? '',
                            style: AppStyles.primaryContent(context).copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.titleTextColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.s16, vertical: 10),
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),
              ],

              // ─── Main Content Row ───
              Padding(
                padding: EdgeInsets.only(
                  top: widget.isIncoming ? 0 : AppSizes.s16,
                  bottom: AppSizes.s16,
                  left: AppSizes.s16,
                  right: AppSizes.s16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── Left: Amount + details ───
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${widget.request.total ?? '0'}',
                                style: AppStyles.heading(context).copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(AppColors.buttonColor),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 4),
                              Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'egp'.tr(),
                                  style: AppStyles.content(context).copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_month,
                                  size: 14, color: Colors.grey.shade400),
                              SizedBox(width: 4),
                              Text(
                                '${'from_date'.tr()}: ${widget.request.from ?? ''}',
                                style: AppStyles.content(context).copyWith(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.update,
                                  size: 14, color: Colors.grey.shade400),
                              SizedBox(width: 4),
                              Text(
                                '${'how_long_to_pay'.tr()}: ${widget.request.howLongToPay ?? ''} ${'months'.tr()}',
                                style: AppStyles.content(context).copyWith(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 10),

                    // ─── Right: Status badge + Edit button ───
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: statusColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RequestsServices.getRequestsStatusIcon(
                                context: context,
                                status: status,
                                iconColor: statusColor,
                              ),
                              SizedBox(height: 4),
                              Text(
                                statusText,
                                style: AppStyles.content(context).copyWith(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Edit button — shown only when canEdit is true and status is editable
                        if (widget.canEdit && status != 'approved' && status != 'cancelled' && status != 'canceled') ...[
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              final updated =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => UpdateSalaryAdvanceScreen(
                                    existingRequest: widget.request,
                                  ),
                                ),
                              );
                              if (updated == true) {
                                widget.onRefresh?.call();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: Color(AppColors.buttons),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(AppColors.buttons)
                                        .withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_rounded,
                                      color: Colors.white, size: 13),
                                  SizedBox(width: 4),
                                  Text(
                                    'edit_request'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
