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
import '../../shared/models/salary_advance_request_model.dart';

class SalaryAdvanceListItemWidget extends StatefulWidget {
  final SalaryAdvanceRequestModel request;
  final bool isIncoming;

  const SalaryAdvanceListItemWidget({
    super.key,
    required this.request,
    required this.isIncoming,
  });

  @override
  State<SalaryAdvanceListItemWidget> createState() => _SalaryAdvanceListItemWidgetState();
}

class _SalaryAdvanceListItemWidgetState extends State<SalaryAdvanceListItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    
    // Status Logic Fix: Only 'approved' or 'waiting' (pending)
    String status = isApproved ? 'approved' : 'waiting';
    Color statusColor = status == 'approved' ? Color(AppColors.successGreen) : Color(AppColors.warningYellow);
    String statusText = status == 'approved' ? 'approved'.tr() : 'pending'.tr();

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _animationController.forward();
      },
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        context.pushNamed(
          AppRoutes.salaryAdvanceDetails.name,
          pathParameters: {
            'id': widget.request.id.toString(),
            'lang': context.locale.languageCode,
          },
        );
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: AppSizes.s16.h, left: 4.w, right: 4.w),
          padding: EdgeInsets.symmetric(vertical: AppSizes.s16.h, horizontal: AppSizes.s16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Color(AppColors.buttonColor).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isIncoming && widget.request.employeeProfile != null) ...[
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(AppColors.buttonColor).withOpacity(0.1),
                            Color(AppColors.buttonSecondaryColor).withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, color: Color(AppColors.buttonColor), size: 18.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      widget.request.employeeProfile?.name ?? '',
                      style: AppStyles.primaryContent(context).copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.titleTextColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(height: 1, color: Colors.grey.shade100),
                SizedBox(height: 12.h),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                color: Color(AppColors.buttonColor),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Text(
                                'egp'.tr(),
                                style: AppStyles.content(context).copyWith(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, size: 14.sp, color: Colors.grey.shade400),
                            SizedBox(width: 4.w),
                            Text(
                              '${'from_date'.tr()}: ${widget.request.from ?? ''}',
                              style: AppStyles.content(context).copyWith(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.update, size: 14.sp, color: Colors.grey.shade400),
                            SizedBox(width: 4.w),
                            Text(
                              '${'how_long_to_pay'.tr()}: ${widget.request.howLongToPay ?? ''} ${'months'.tr()}',
                              style: AppStyles.content(context).copyWith(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RequestsServices.getRequestsStatusIcon(
                          context: context,
                          status: status,
                          iconColor: statusColor,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          statusText,
                          style: AppStyles.content(context).copyWith(
                            color: statusColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
