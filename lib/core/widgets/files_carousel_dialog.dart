import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shows [urls] in a dialog with a horizontally scrollable carousel (current file centered and
/// enlarged). Each file has its own download button that calls [onDownload].
void showFilesCarouselDialog({
  required BuildContext context,
  required List<String> urls,
  required void Function(String url, String fileName) onDownload,
}) {
  if (urls.isEmpty) return;
  final mainColor = Color(AppColors.buttons);
  const imageExt = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
  final controller = PageController(viewportFraction: 0.62);
  int current = 0;

  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 20, end: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${AppStrings.attachments.tr()} (${urls.length})',
                        style: AppStyles.heading(context)
                            .copyWith(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 380,
                child: PageView.builder(
                  controller: controller,
                  itemCount: urls.length,
                  onPageChanged: (i) => setDialogState(() => current = i),
                  itemBuilder: (_, i) {
                    final url = urls[i];
                    final fileName =
                        Uri.decodeFull(url.split('?').first.split('/').last);
                    final ext = fileName.contains('.')
                        ? fileName.split('.').last.toLowerCase()
                        : '';
                    final isImage = imageExt.contains(ext);
                    final isCurrent = i == current;
                    return AnimatedScale(
                      scale: isCurrent ? 1.0 : 0.85,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedOpacity(
                        opacity: isCurrent ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCurrent
                                  ? mainColor
                                  : Colors.grey.shade300,
                              width: isCurrent ? 2 : 1,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: mainColor.withOpacity(0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: isImage
                                      ? Image.network(
                                          url,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.broken_image_outlined,
                                            size: 64,
                                            color: Colors.grey.shade500,
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            ext == 'pdf'
                                                ? Icons
                                                    .picture_as_pdf_outlined
                                                : Icons
                                                    .insert_drive_file_outlined,
                                            size: 84,
                                            color: mainColor,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                fileName,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: () =>
                                      onDownload(url, fileName),
                                  icon: const Icon(
                                      Icons.file_download_outlined,
                                      size: 20),
                                  label: Text(
                                    AppStrings.download.tr(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (urls.length > 1) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    urls.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == current ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == current
                            ? mainColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  ).whenComplete(controller.dispose);
}
