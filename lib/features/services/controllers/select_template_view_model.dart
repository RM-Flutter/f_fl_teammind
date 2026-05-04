import 'dart:convert';
import 'dart:io';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/features/services/data/models/cv_template_model.dart';
import 'package:app_test/features/services/data/repos/cv_templates_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/dart_html_stub.dart' as html;
/// Result of "generate CV" — either data to save/download or an error.
sealed class GenerateCvResult {}

class GenerateCvNeedSaveBytes extends GenerateCvResult {
  final List<int> pdfBytes;
  final String fileName;

  GenerateCvNeedSaveBytes({required this.pdfBytes, required this.fileName});
}

class GenerateCvNeedDownloadUrl extends GenerateCvResult {
  final String pdfUrl;
  final String fileName;

  GenerateCvNeedDownloadUrl({required this.pdfUrl, required this.fileName});
}

class GenerateCvErrorResult extends GenerateCvResult {
  final String message;

  GenerateCvErrorResult(this.message);
}

class SelectTemplateViewModel extends ChangeNotifier {
  List<CvTemplateModel>? templates;
  bool isLoading = false;
  String? errorMessage;
  bool _disposed = false;

  /// True while generating CV (print + save/download).
  bool isLoadingTemplate = false;

  /// Download progress per template id: 0.0 .. 1.0.
  final Map<int, double> downloadProgress = {};

  bool get hasTemplates => templates != null && templates!.isNotEmpty;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Fetch CV templates from res-cv-templates (images from data[].image[].file).
  Future<void> fetchTemplates(BuildContext context, {int itemsCount = 200}) async {
    if (_disposed) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final list = await CvTemplatesService.getTemplates(context, itemsCount: itemsCount);
      if (_disposed) return;
      templates = list;
      errorMessage = null;
    } catch (e) {
      if (_disposed) return;
      errorMessage = e.toString();
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Set download progress for a template (0.0 .. 1.0). Notifies listeners.
  void setDownloadProgress(int templateId, double value) {
    if (_disposed) return;
    downloadProgress[templateId] = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Clear loading and progress for a template.
  void clearGenerateState(int? templateId) {
    if (_disposed) return;
    isLoadingTemplate = false;
    if (templateId != null) downloadProgress.remove(templateId);
    notifyListeners();
  }

  /// Build suggested file name for CV PDF.
  static String cvFileName(CvTemplateModel template) {
    return 'CV_${template.slug ?? 'template'}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  /// Full flow: generate CV with template, then save or download and show toasts.
  /// Call from screen on "Generate CV" press.
  Future<void> onGenerateCv(BuildContext context, CvTemplateModel template) async {
    if (template.id == null) {
      _showToast(AppStrings.invalidTemplate.tr(), isError: true);
      return;
    }

    final result = await generateCvWithTemplate(context, template);
    if (_disposed) return;

    switch (result) {
      case GenerateCvNeedSaveBytes(: final pdfBytes, : final fileName):
        await savePDFFromBytes(context, pdfBytes, fileName);
        break;
      case GenerateCvNeedDownloadUrl(: final pdfUrl, : final fileName):
        await handleDownloadUrl(context, pdfUrl, fileName, template.id!);
        break;
      case GenerateCvErrorResult(: final message):
        _showToast('${AppStrings.errorGeneratingCv.tr()} $message', isError: true);
    }
  }

  /// Call print CV endpoint and return result (save bytes, download URL, or error).
  Future<GenerateCvResult> generateCvWithTemplate(
    BuildContext context,
    CvTemplateModel template,
  ) async {
    if (template.id == null) {
      return GenerateCvErrorResult('Invalid template');
    }
    if (_disposed) return GenerateCvErrorResult('Disposed');

    isLoadingTemplate = true;
    downloadProgress[template.id!] = 0.0;
    notifyListeners();

    try {
      final result = await CvTemplatesService.printCv(context, cvTemplateId: template.id!);
      if (_disposed) return GenerateCvErrorResult('Disposed');

      if (result.hasBytes) {
        return GenerateCvNeedSaveBytes(
          pdfBytes: result.pdfBytes!,
          fileName: cvFileName(template),
        );
      }
      if (result.hasUrl) {
        return GenerateCvNeedDownloadUrl(
          pdfUrl: result.pdfUrl!,
          fileName: cvFileName(template),
        );
      }
      return GenerateCvErrorResult(result.error ?? 'Unknown error');
    } catch (e) {
      if (_disposed) return GenerateCvErrorResult('Disposed');
      return GenerateCvErrorResult(e.toString());
    } finally {
      if (!_disposed) {
        isLoadingTemplate = false;
        downloadProgress.remove(template.id);
        notifyListeners();
      }
    }
  }

  /// Save PDF bytes to file (web: download via anchor, mobile: write file + open).
  Future<void> savePDFFromBytes(
    BuildContext context,
    List<int> pdfBytes,
    String fileName,
  ) async {
    if (PlatformIs.web) {
      try {
        final base64String = base64Encode(pdfBytes);
        final dataUrl = 'data:application/pdf;base64,$base64String';
        final html.AnchorElement downloadAnchor = html.AnchorElement(href: dataUrl);
        downloadAnchor.download = fileName;
        downloadAnchor.style.display = 'none';
        html.document.body?.append(downloadAnchor);
        downloadAnchor.click();
        downloadAnchor.remove();

        _showToast(AppStrings.cvDownloadedSuccessfully.tr(), isError: false);
      } catch (e) {
        debugPrint('Error saving PDF on web: $e');
        _showToast('${AppStrings.errorSavingPdf.tr()} $e', isError: true);
      }
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      await OpenFilex.open(filePath);

      _showToast(AppStrings.cvSavedSuccessfully.tr(), isError: false);
    } catch (e) {
      _showToast('${AppStrings.errorSavingPdf.tr()} $e', isError: true);
    }
  }

  /// Download PDF from URL (web: blob download, mobile: DioHelper + open file).
  Future<void> handleDownloadUrl(
    BuildContext context,
    String pdfUrl,
    String fileName,
    int templateId,
  ) async {
    if (PlatformIs.web) {
      try {
        if (kIsWeb) {
          final fetchResult = html.window.fetch(pdfUrl);
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
            debugPrint('Error downloading PDF: $e');
          });
        } else {
          final uri = Uri.parse(pdfUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }

        _showToast(AppStrings.cvDownloadedSuccessfully.tr(), isError: false);
      } catch (e) {
        _showToast('${AppStrings.errorDownloadingPdf.tr()} $e', isError: true);
      }
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      final savedPath = await downloadPdfFromUrl(
        context,
        pdfUrl: pdfUrl,
        savePath: filePath,
        templateId: templateId,
      );

      clearGenerateState(templateId);

      if (savedPath != null) {
        await OpenFilex.open(savedPath);
        _showToast(AppStrings.cvDownloadedSuccessfully.tr(), isError: false);
      } else {
        _showToast(AppStrings.errorDownloadingPdf.tr(), isError: true);
      }
    } catch (e) {
      clearGenerateState(templateId);
      _showToast('${AppStrings.errorDownloadingPdf.tr()} $e', isError: true);
    }
  }

  /// Download PDF from URL with progress. Returns saved file path or null.
  Future<String?> downloadPdfFromUrl(
    BuildContext context, {
    required String pdfUrl,
    required String savePath,
    required int templateId,
  }) async {
    try {
      await CvTemplatesService.downloadPdf(
        context: context,
        pdfUrl: pdfUrl,
        savePath: savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) setDownloadProgress(templateId, received / total);
        },
      );
      return savePath;
    } catch (e) {
      debugPrint('SelectTemplateViewModel.downloadPdfFromUrl: $e');
      return null;
    }
  }

  void _showToast(String msg, {required bool isError}) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      toastLength: isError ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
    );
  }
}
