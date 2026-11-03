import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.io) '../../../../../core/services/dart_html_stub.dart' as html;
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/widgets/files_carousel_dialog.dart';
import '../../../data/models/approvable_details_model.dart';
import 'package:app_test/core/constants/app_design.dart';

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

  /// Attachment URLs of this approval (normalized), from `files` or the single `file`.
  List<String> get _attachmentUrls {
    final raw = (item.files != null && item.files!.isNotEmpty)
        ? item.files!.map((f) => f.toString()).toList()
        : [if (item.file != null && item.file!.isNotEmpty) item.file!];
    return raw.map(_normalizeFileUrl).where((u) => u.isNotEmpty).toList();
  }

  String _normalizeFileUrl(String rawUrl) {
    final fileUrl = rawUrl.trim();
    final match = RegExp(r'https?://[^\s,\]}\"]+').firstMatch(fileUrl);
    if (match != null) return match.group(0)!;
    if (fileUrl.isEmpty) return '';
    if (fileUrl.startsWith('/')) return '${AppConstants.base}$fileUrl';
    return 'https://$fileUrl';
  }

  Future<void> _openFileUrl(String rawUrl) async {
    try {
      String fileUrl = rawUrl.trim();
      final match = RegExp(r'https?://[^\s,\]}\"]+').firstMatch(fileUrl);
      if (match != null) {
        fileUrl = match.group(0)!;
      } else if (fileUrl.startsWith('/')) {
        fileUrl = '${AppConstants.base}$fileUrl';
      } else if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
        fileUrl = 'https://$fileUrl';
      }

      if (kIsWeb) {
        try {
          html.window.open(fileUrl, '_blank');
          return;
        } catch (e) {
          debugPrint('Error opening file in web: $e');
        }
      }

      final Uri uri = Uri.parse(fileUrl);
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      if (!launched) {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_blank',
        );
      }
    } catch (e) {
      debugPrint('Error launching url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(item.status);
    final approverName = item.employee?.name ??
        item.department?.title ??
        item.role?.tr() ??
        item.type?.tr() ??
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
                        fontSize: 14,
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
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                item.statusLabel ?? (item.status ?? '').tr(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        if (item.role != null || item.department?.title != null) ...[
          const SizedBox(height: 6),
          Text(
            '${item.role?.tr() ?? ''} ${item.department?.title != null ? '(${item.department!.title!.tr()})' : ''}'
                .trim(),
            style: TextStyle(
              fontSize: 13,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                item.actor!.name!,
                style: const TextStyle(
                  fontSize: 12,
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
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              '${isArabic ? 'الرد' : 'Reply'}: ${item.replay!.trim()}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],

        if (_attachmentUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          Material(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () => showFilesCarouselDialog(
                context: context,
                urls: _attachmentUrls,
                onDownload: (url, _) => _openFileUrl(url),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file_rounded,
                          size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        _attachmentUrls.length == 1
                            ? (isArabic ? 'عرض المرفق' : 'View Attachment')
                            : (isArabic
                                ? 'عرض المرفقات (${_attachmentUrls.length})'
                                : 'View Attachments (${_attachmentUrls.length})'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        if (item.approvedAutoTime != null || item.startedTime != null) ...[
          const SizedBox(height: 6),
          Text(
            _formatDate(item.approvedAutoTime ?? item.startedTime, context),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }
}
