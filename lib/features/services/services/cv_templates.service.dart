import 'dart:convert';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/cv_template.model.dart';

/// CV templates and print CV API using DioHelper (res-cv-templates, emp_requests/v1/cv/print).
class CvTemplatesService {
  /// GET res-cv-templates/entities-operations — list templates (display image from data[].image[].file).
  static Future<List<CvTemplateModel>> getTemplates(
    BuildContext context, {
    int itemsCount = 200,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: '/res-cv-templates/entities-operations',
        context: context,
        query: {'itemsCount': itemsCount},
      );

      if (response.data != null &&
          response.data['status'] == true &&
          response.data['data'] != null) {
        final List<dynamic> list = response.data['data'] as List<dynamic>;
        return list
            .map((e) => CvTemplateModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('CvTemplatesService.getTemplates: $e');
      rethrow;
    }
  }

  /// GET emp_requests/v1/cv/print — returns PDF bytes or JSON with pdf_url.
  static Future<CvPrintResult> printCv(
    BuildContext context, {
    required int cvTemplateId,
  }) async {
    try {
      final response = await DioHelper.getDataAsBytes(
        context: context,
        url: '${AppConstants.baseUrl}/emp_requests/v1/cv/print',
        query: {'cv_template_id': cvTemplateId},
        acceptHeader: 'application/pdf',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List<int>) {
          if (data.length >= 4 &&
              data[0] == 0x25 &&
              data[1] == 0x50 &&
              data[2] == 0x44 &&
              data[3] == 0x46) {
            return CvPrintResult(pdfBytes: data);
          }
          final jsonString = utf8.decode(data);
          final jsonResponse = jsonDecode(jsonString) as Map<String, dynamic>;
          if (jsonResponse['status'] == true) {
            final pdfUrl = jsonResponse['data']?['pdf_url'] ?? jsonResponse['pdf_url'];
            if (pdfUrl != null && pdfUrl.toString().isNotEmpty) {
              return CvPrintResult(pdfUrl: pdfUrl.toString());
            }
          }
          return CvPrintResult(
            error: jsonResponse['message']?.toString() ?? 'PDF URL not found',
          );
        }
      }
      return CvPrintResult(
        error: 'Failed to generate CV: Status ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('CvTemplatesService.printCv: $e');
      return CvPrintResult(error: e.toString());
    }
  }

  /// Download PDF from URL to savePath (uses DioHelper).
  static Future<Response> downloadPdf({
    required BuildContext context,
    required String pdfUrl,
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    return await DioHelper.downloadDataWithProgress(
      context: context,
      url: pdfUrl,
      savePath: savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

/// Result of print CV: either PDF bytes, or PDF URL, or error.
class CvPrintResult {
  final List<int>? pdfBytes;
  final String? pdfUrl;
  final String? error;

  CvPrintResult({this.pdfBytes, this.pdfUrl, this.error});

  bool get hasBytes => pdfBytes != null && pdfBytes!.isNotEmpty;
  bool get hasUrl => pdfUrl != null && pdfUrl!.isNotEmpty;
  bool get isError => error != null && error!.isNotEmpty;
}
