import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api.service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint_service.dart';
import 'package:app_test/core/services/connections.service.dart';
import 'package:app_test/core/services/db_hive.service.dart';
import 'package:app_test/core/models/endpoint.model.dart';
import 'package:app_test/core/models/operation_result.model.dart';

enum Order { asc, desc }

abstract class FingerprintService {

  // Add a QR code fingerprint with form data
  static Future<OperationResult<Map<String, dynamic>>> addQRCodeFingerprint({
    required BuildContext context,
    required String data,
    DateTime? fingerDay,
    required List<FilePickerResult> files,
  }) async {

    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('dd-MM-yyyy', "en").format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final formData = {
      'type': 'fp_scan',
      'data': encoded,
      'finger_day': DateFormat('dd-MM-yyyy', "en").format(fingerDay ?? DateTime.now()),
    };
    debugPrint("formData is --> $formData");
    if (await ConnectionsService.isOnline() == true) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
        url,
        context: context,
        formData,
        dataKey: 'data',
        files: files,
        allData: true,
      );
    } else {
      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(formData)
          .then((_) => OperationResult<Map<String, dynamic>>(
          success: true,
          message: 'Fingerprint Saved successfully in Locale Storage'))
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a GPS fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addGPSFingerprint({
    required BuildContext context,
    required String type,
    DateTime? fingerDay,
    required double lat,
    required double long,
    required List<FilePickerResult> files,
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    final requestBody = {
      'type': 'fp_navigate',
      'data': '{"lat":${lat.toString()},"long":${long.toString()}}',
      'finger_day':
      DateFormat('yyyy-MM-dd', "en").format(fingerDay ?? DateTime.now()),
    };
    if (await ConnectionsService.isOnline() == true) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(requestBody)
          .then((_) => OperationResult<Map<String, dynamic>>(
          success: true,
          message: 'Fingerprint Saved successfully in Locale Storage'))
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a Bluetooth fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addBluetoothFingerprint(
      {required BuildContext context,
        required String data,
        DateTime? fingerDay,
        required List<FilePickerResult> files}) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('dd-MM-yyyy', "en").format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final requestBody = {
      'type': 'fp_bluetooth',
      'data': encoded,
      'finger_day':
      DateFormat('yyyy-MM-dd', "en").format(fingerDay ?? DateTime.now()),
    };
    if (await ConnectionsService.isOnline() == true) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(requestBody)
          .then((_) => OperationResult<Map<String, dynamic>>(
          success: true,
          message: 'Fingerprint Saved successfully in Locale Storage'))
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a wifi fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addWifiFingerprint(
      {required BuildContext context,
        required String data,
        DateTime? fingerDay,
        required List<FilePickerResult> files}) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('dd-MM-yyyy', "en").format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final requestBody = {
      'type': 'fp_wifi',
      'data': encoded,
      'finger_day': DateFormat('yyyy-MM-dd', "en").format(fingerDay ?? DateTime.now()),
    };
    if (await ConnectionsService.isOnline() == true) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(requestBody)
          .then((_) => OperationResult<Map<String, dynamic>>(
          success: true,
          message: 'Fingerprint Saved successfully in Locale Storage'))
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a NFC fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addNFCFingerprint(
      {required BuildContext context,
        required String data,
        DateTime? fingerDay,
        required List<FilePickerResult> files}) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    final requestBody = {
      'type': 'fp_nfc',
      'data': data,
      'finger_day':
      DateFormat('yyyy-MM-dd HH:mm').format(fingerDay ?? DateTime.now()),
    };
    if (await ConnectionsService.isOnline() == true) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(requestBody)
          .then((_) => OperationResult<Map<String, dynamic>>(
          success: true,
          message: 'Fingerprint Saved successfully in Locale Storage'))
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }
}
