import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../../data/models/approvable_details_model.dart';

class ReasonTab extends StatelessWidget {
  final String? reason;
  final ApprovableDetailsModel? details;

  const ReasonTab({super.key, this.reason, this.details});

  String _formatDate(String? rawDate, BuildContext context, bool isArabic) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      return DateService.formatDate(
            isArabic ? 'ar' : 'en',
            context,
            rawDate,
            format: 'dd MMM yyyy',
          ) ??
          rawDate.split(' ').first;
    } catch (_) {
      return rawDate.split(' ').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);
    final defaultNoReasonText =
        isArabic ? "لا يوجد سبب مذكور" : "There is no reason";

    final bool isShiftChange = details?.isShiftChangeRequest == true;
    final bool hasProblem = details?.hasProblem == true ||
        details?.isValid == false ||
        (details?.problems != null && details!.problems!.isNotEmpty);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasProblem) ...[
              _buildProblemBanner(context, isArabic),
              const SizedBox(height: 16),
            ],
            if (isShiftChange && details != null) ...[
              _buildShiftSwapSummaryCard(context, details!, isArabic),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                reason != null && reason!.trim().isNotEmpty
                    ? reason!.trim()
                    : defaultNoReasonText,
                textAlign: TextAlign.center,
                style: AppStyles.darkContent(context).copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractProblemText(dynamic item) {
    if (item == null) return '';
    if (item is String) return item.trim();
    if (item is Map) {
      final val = item['message'] ??
          item['description'] ??
          item['reason'] ??
          item['title'] ??
          item['error'];
      if (val != null) return val.toString().trim();
    }
    return item.toString().trim();
  }

  Widget _buildProblemBanner(BuildContext context, bool isArabic) {
    final String primaryMsg = details?.problemMessage?.trim() ?? '';
    final List<String> problemItems = (details?.problems ?? const [])
        .map(_extractProblemText)
        .where((s) => s.isNotEmpty && s != primaryMsg)
        .toList();

    final String headerMsg = primaryMsg.isNotEmpty
        ? primaryMsg
        : (problemItems.isEmpty
            ? (isArabic
                ? 'يوجد تعارض في جدول الشيفتات يمنع الموافقة على هذا الطلب'
                : 'There is a shift schedule conflict preventing approval of this request')
            : '');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade700, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? 'تنبيه تعارض الشيفتات' : 'Shift Conflict Warning',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
          if (headerMsg.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              headerMsg,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: problemItems.isNotEmpty
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: Colors.red.shade900,
              ),
            ),
          ],
          if (problemItems.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...problemItems.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftSwapSummaryCard(
    BuildContext context,
    ApprovableDetailsModel d,
    bool isArabic,
  ) {
    final reqName = d.requesterEmployee?.name ?? d.employeeName?.toString() ?? '';
    final recName = d.receiverEmployee?.name ?? '';
    final reqShift = d.requesterShiftName ?? '';
    final recShift = d.receiverShiftName ?? '';
    final reqDate = _formatDate(d.requesterDate ?? d.dateFrom, context, isArabic);
    final recDate = _formatDate(d.receiverDate ?? d.dateTo, context, isArabic);
    final isTwoWay = d.isTwoWayShiftSwap;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(AppColors.buttons).withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Party 1: Requester
          _buildPartyRow(
            context: context,
            label: isArabic ? 'مقدم الطلب (المتنازل)' : 'Requester (Giving up)',
            employeeName: reqName,
            shiftName: reqShift,
            dateText: reqDate,
            icon: Icons.person_outline_rounded,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 12),
          // Party 2: Receiver
          _buildPartyRow(
            context: context,
            label: isArabic ? 'الزميل المستلم (البديل)' : 'Colleague (Receiver)',
            employeeName: recName,
            shiftName: isTwoWay
                ? recShift
                : (isArabic ? 'استلام بدون شيفت مقابل' : 'Receiving only (no swap shift)'),
            dateText: isTwoWay ? recDate : '',
            icon: Icons.person_pin_circle_outlined,
            color: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyRow({
    required BuildContext context,
    required String label,
    required String employeeName,
    required String shiftName,
    required String dateText,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  employeeName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (shiftName.isNotEmpty || dateText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (shiftName.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 13, color: Colors.grey.shade700),
                            const SizedBox(width: 4),
                            Text(
                              shiftName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      if (dateText.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade700),
                            const SizedBox(width: 4),
                            Text(
                              dateText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
