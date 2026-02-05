import 'dart:convert';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/fingerprint_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

abstract class FingerprintRepo {
  Future<OperationResult<Map<String, dynamic>>> getFingerprints({
    required BuildContext context,
    String? empId,
  });

  Future<Response> addFingerPrints({
    required BuildContext context,
    required List<dynamic> fingerprints,
  });
}

class FingerprintRepoImpl implements FingerprintRepo {
  @override
  Future<OperationResult<Map<String, dynamic>>> getFingerprints({
    required BuildContext context,
    String? empId,
  }) async {
    return await FingerprintService.getFingerprints(
      context: context,
      pfor: empId,
    );
  }

  @override
  Future<Response> addFingerPrints({
    required BuildContext context,
    required List<dynamic> fingerprints,
  }) async {
    FormData formData = await _buildFormData(fingerprints);
    return await DioHelper.postFormData(
      context: context,
      url: "/rm_fingerprint/v1/add_fingerprints",
      formdata: formData,
      query: null,
      data: null,
    );
  }

  Future<FormData> _buildFormData(List<dynamic> fingerprints) async {
    FormData formData = FormData();

    for (int i = 0; i < fingerprints.length; i++) {
      var fingerprint = fingerprints[i];

      // Basic fields
      formData.fields.addAll([
        MapEntry('fingerprints[$i][type]', fingerprint['type']),
        MapEntry('fingerprints[$i][data]', fingerprint['data']),
        MapEntry('fingerprints[$i][finger_day]', fingerprint['finger_day']),
      ]);

      // Add double_check_type and double_check_data if provided (for QR code fingerprints)
      if (fingerprint['double_check_type'] != null) {
        formData.fields.add(MapEntry(
            'fingerprints[$i][double_check_type]', fingerprint['double_check_type']));
      }
      if (fingerprint['double_check_data'] != null) {
        formData.fields.add(MapEntry(
            'fingerprints[$i][double_check_data]', fingerprint['double_check_data']));
      }

      // Add note if provided
      if (fingerprint['note'] != null || fingerprint['noteReport'] != null) {
        final noteValue = fingerprint['note'] ?? fingerprint['noteReport'];
        if (noteValue is String) {
          formData.fields.add(MapEntry('fingerprints[$i][note]', noteValue));
        } else {
          formData.fields.add(
              MapEntry('fingerprints[$i][note]', jsonEncode(noteValue)));
        }
      }

      // Files
      if (fingerprint['files'] != null) {
        // Decode if it's a JSON string
        var filesList = fingerprint['files'];
        if (filesList is String) {
          filesList = jsonDecode(filesList);
        }

        for (var file in filesList) {
          final fileBytes = base64Decode(file['bytes']);
          final fileName = file['fileName'];
          final mimeType = file['mimeType'] ?? 'application/octet-stream';

          final multipartFile = MultipartFile.fromBytes(
            fileBytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          );

          formData.files.add(
              MapEntry('fingerprints[$i][files][]', multipartFile));
        }
      }
    }

    return formData;
  }
}
