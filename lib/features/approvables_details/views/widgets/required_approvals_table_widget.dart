import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import '../../data/models/approvable_details_model.dart';

class RequiredApprovalsTableWidget extends StatelessWidget {
  final List<RequiredApprovalModel> requiredApprovals;

  const RequiredApprovalsTableWidget({
    super.key,
    required this.requiredApprovals,
  });

  Map<int, List<RequiredApprovalModel>> _groupApprovalsByLevel() {
    final Map<int, List<RequiredApprovalModel>> map = {};
    for (final item in requiredApprovals) {
      final lvl = item.level ?? 1;
      map.putIfAbsent(lvl, () => []).add(item);
    }
    return map;
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase().trim()) {
      case 'approved':
        return  Color(AppColors.successGreen);
      case 'refused':
      case 'rejected':
      case 'canceled':
        return  Color(AppColors.failureRed);
      case 'waiting':
      case 'waiting_seen':
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(String? rawDate, BuildContext context) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final lang = LocalizationService.isArabic(context: context) ? 'ar' : 'en';
      return DateService.formatDate(lang, context, rawDate) ?? rawDate.split('T').first;
    } catch (_) {
      return rawDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (requiredApprovals.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupedMap = _groupApprovalsByLevel();
    final sortedLevels = groupedMap.keys.toList()..sort();
    final isArabic = LocalizationService.isArabic(context: context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_bulleted_rounded,
                  size: 20, color: Color(AppColors.buttons)),
              const SizedBox(width: 8),
              Text(
                'approvals'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedLevels.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final levelNum = sortedLevels[index];
              final items = groupedMap[levelNum]!;
              return _buildLevelGroupCard(context, levelNum, items, isArabic);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGroupCard(
    BuildContext context,
    int levelNum,
    List<RequiredApprovalModel> items,
    bool isArabic,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(AppColors.buttons).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${'level'.tr()} $levelNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (items.length > 1) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${items.length} ${isArabic ? 'موافقات في هذا المستوى' : 'approvers'})',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Items inside this level
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    if (idx > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Colors.grey.shade300),
                      ),
                    _buildSingleApprovalRow(context, item, isArabic),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleApprovalRow(
    BuildContext context,
    RequiredApprovalModel item,
    bool isArabic,
  ) {
    final statusColor = _getStatusColor(item.status);
    final approverName = item.employee?.name ??
        item.department?.title ??
        item.role ??
        item.type ??
        '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top line: Name/Role & Status & Auto Icon
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    item.employee != null ? Icons.person : Icons.business,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      approverName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (item.isAuto == true) ...[
              const Icon(Icons.bolt, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                item.statusLabel ?? (item.status ?? '').tr(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        // Sub details: Role / Department
        if (item.role != null || item.department?.title != null) ...[
          const SizedBox(height: 4),
          Text(
            '${item.role ?? ''} ${item.department?.title != null ? '(${item.department!.title})' : ''}'
                .trim(),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],

        // Acted By / Actor (if acted by someone else)
        if (item.actor?.name != null && item.actor!.name!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${isArabic ? 'تم التنفيذ بواسطة' : 'Acted By'}: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                item.actor!.name!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],

        // Replay / Notes
        if (item.replay != null && item.replay!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              '${isArabic ? 'الرد' : 'Reply'}: ${item.replay!.trim()}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
        ],

        // File Attachment
        if (item.file != null && item.file!.isNotEmpty) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              try {
                final Uri url = Uri.parse(item.file!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              } catch (_) {}
            },
            child: Row(
              children: [
                const Icon(Icons.attach_file_rounded,
                    size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  isArabic ? 'عرض المرفق' : 'View Attachment',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Approved / Auto Time
        if (item.approvedAutoTime != null || item.startedTime != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatDate(item.approvedAutoTime ?? item.startedTime, context),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }
}
