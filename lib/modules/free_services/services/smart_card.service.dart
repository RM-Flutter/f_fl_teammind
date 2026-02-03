import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/general_services/app_config.service.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/dio.dart';

/// Smart Card API Service
/// Implements all 4 folders from Postman Smart Card collection:
/// - Templates
/// - Company Profile
/// - Public Views (URL builders)
/// - Employee Profile
class SmartCardService {
  static const String _companyBase = '/emp_requests/v1/smart-card/company';
  static const String _employeeBase = '/emp_requests/v1/smart-card/employee';
  static const String _templatesPath = '/sm-card-templates/entities-operations';

  // ─── Templates ─────────────────────────────────────────────────────────
  /// GET templates – Smart Card templates list
  static Future<Map<String, dynamic>> getTemplates(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: _templatesPath,
        context: context,
        query: {'itemsCount': '200', 'with': 'type_id'},
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.getTemplates: $e');
      rethrow;
    }
  }

  // ─── Company Profile ───────────────────────────────────────────────────
  /// POST Create Company Profile
  static Future<Map<String, dynamic>> createCompany(
    BuildContext context, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await DioHelper.postData(
        context: context,
        url: _companyBase,
        query: null,
        data: body,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.createCompany: $e');
      rethrow;
    }
  }

  /// PUT Update Company Profile
  static Future<Map<String, dynamic>> updateCompany(
    BuildContext context, {
    required int companyId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await DioHelper.putData(
        context: context,
        url: '$_companyBase/$companyId',
        query: null,
        data: body,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.updateCompany: $e');
      rethrow;
    }
  }

  /// PATCH Update Company Template
  static Future<Map<String, dynamic>> updateCompanyTemplate(
    BuildContext context, {
    required int companyId,
    required int templateId,
  }) async {
    try {
      final response = await DioHelper.patchData(
        context: context,
        url: '$_companyBase/$companyId/template',
        query: null,
        data: {'template_id': templateId},
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.updateCompanyTemplate: $e');
      rethrow;
    }
  }

  /// GET Get My Companies
  static Future<Map<String, dynamic>> getMyCompanies(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: _companyBase,
        context: context,
        query: null,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.getMyCompanies: $e');
      rethrow;
    }
  }

  /// GET Get Company Profile
  static Future<Map<String, dynamic>> getCompanyProfile(
    BuildContext context, {
    required int companyId,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: '$_companyBase/$companyId',
        context: context,
        query: null,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.getCompanyProfile: $e');
      rethrow;
    }
  }

  /// DELETE Delete Company Profile
  static Future<Map<String, dynamic>> deleteCompany(
    BuildContext context, {
    required int companyId,
  }) async {
    try {
      final token = Provider.of<AppConfigService>(context, listen: false).token;
      final response = await DioHelper.deleteData(
        url: '$_companyBase/$companyId',
        query: null,
        data: null,
        token: token,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.deleteCompany: $e');
      rethrow;
    }
  }

  /// POST Add Employee to Company
  static Future<Map<String, dynamic>> addEmployeeToCompany(
    BuildContext context, {
    required int companyId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await DioHelper.postData(
        context: context,
        url: '$_companyBase/$companyId/employees',
        query: null,
        data: body,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.addEmployeeToCompany: $e');
      rethrow;
    }
  }

  /// GET Get Company Employees
  static Future<Map<String, dynamic>> getCompanyEmployees(
    BuildContext context, {
    required int companyId,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: '$_companyBase/$companyId/employees',
        context: context,
        query: null,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.getCompanyEmployees: $e');
      rethrow;
    }
  }

  /// PUT Update Employee in Company
  static Future<Map<String, dynamic>> updateEmployeeInCompany(
    BuildContext context, {
    required int companyId,
    required int employeeId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await DioHelper.putData(
        context: context,
        url: '$_companyBase/$companyId/employees/$employeeId',
        query: null,
        data: body,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.updateEmployeeInCompany: $e');
      rethrow;
    }
  }

  /// DELETE Remove Employee from Company
  static Future<Map<String, dynamic>> removeEmployeeFromCompany(
    BuildContext context, {
    required int companyId,
    required int employeeId,
  }) async {
    try {
      final token = Provider.of<AppConfigService>(context, listen: false).token;
      final response = await DioHelper.deleteData(
        url: '$_companyBase/$companyId/employees/$employeeId',
        query: null,
        data: null,
        token: token,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.removeEmployeeFromCompany: $e');
      rethrow;
    }
  }

  // ─── Public Views (URL builders – for WebView / copy link) ───────────────
  /// View Company Profile (Public) – full URL
  static String getCompanyProfilePublicUrl(String companySlug) {
    return '${AppConstants.base}/frontend/smart-card/company/$companySlug';
  }

  /// View Employee Profile (Public) – full URL
  static String getEmployeeProfilePublicUrl(String employeeSlug) {
    return '${AppConstants.base}/frontend/smart-card/employee/$employeeSlug';
  }

  // ─── Employee Profile (current user's smart card employee) ────────────────
  /// GET Get Employee Profile (current user)
  static Future<Map<String, dynamic>> getEmployeeProfile(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: _employeeBase,
        context: context,
        query: null,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.getEmployeeProfile: $e');
      rethrow;
    }
  }

  /// POST Create Employee Profile (current user)
  static Future<Map<String, dynamic>> createEmployee(
    BuildContext context, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await DioHelper.postData(
        context: context,
        url: _employeeBase,
        query: null,
        data: body,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.createEmployee: $e');
      rethrow;
    }
  }

  /// PUT Update Employee Profile (current user)
  static Future<Map<String, dynamic>> updateEmployee(
    BuildContext context, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await DioHelper.putData(
        context: context,
        url: _employeeBase,
        query: null,
        data: body,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.updateEmployee: $e');
      rethrow;
    }
  }

  /// PATCH Update Employee Template (current user)
  static Future<Map<String, dynamic>> updateEmployeeTemplate(
    BuildContext context, {
    required int templateId,
    Map<String, dynamic>? templateData,
  }) async {
    try {
      final Map<String, dynamic> body = {'template_id': templateId};
      if (templateData != null) body['template_data'] = templateData;
      final response = await DioHelper.patchData(
        context: context,
        url: '$_employeeBase/template',
        query: null,
        data: body,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.updateEmployeeTemplate: $e');
      rethrow;
    }
  }

  /// DELETE Delete Employee Profile (current user)
  static Future<Map<String, dynamic>> deleteEmployee(BuildContext context) async {
    try {
      final token = Provider.of<AppConfigService>(context, listen: false).token;
      final response = await DioHelper.deleteData(
        url: _employeeBase,
        query: null,
        data: null,
        token: token,
      );
      return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
    } catch (e) {
      debugPrint('SmartCardService.deleteEmployee: $e');
      rethrow;
    }
  }
}
