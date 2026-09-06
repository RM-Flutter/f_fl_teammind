import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import '../../../data/models/approvable_details_model.dart';

class SingleApprovalRow extends StatelessWidget {
  final RequiredApprovalModel item;
  final bool isArabic;

  const SingleApprovalRow({
    super.key,
    required this.item,
    required this.isArabic,
  });

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
      return DateService.formatDate(lang, context, rawDate) ??
          rawDate.split('T').first;
    } catch (_) {
      return rawDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(item.status);
    final approverName = item.employee?.name ??
        item.department?.title ??
        item.role ??
        item.type ??
        '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        if (item.file != null && item.file!.isNotEmpty) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              try {
                String fileUrl = item.file!;
                if (fileUrl.startsWith('/')) {
                  fileUrl = '${AppConstants.base}$fileUrl';
                } else if (!fileUrl.startsWith('http')) {
                  fileUrl = 'https://$fileUrl';
                }
                
                final Uri url = Uri.parse(fileUrl);
                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                  webOnlyWindowName: '_blank',
                );
              } catch (e) {
                debugPrint('Error launching url: $e');
              }
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
