import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
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

  /// If API returns status: false (or "false" string), throw so callers show error message
  static void _checkResponse(Map<String, dynamic> data) {
    final status = data['status'];
    bool isFailure = status == false ||
        status == 'false' ||
        status == '0' ||
        status == 0;

    // Some endpoints (like smart-card/employee) return validation errors with no explicit `status`,
    // e.g. { "message": "...", "errors": { field: [msg] } }.
    // Treat presence of `errors` without a truthy status as failure.
    if (!isFailure && status == null && data['errors'] != null) {
      isFailure = true;
    }

    if (isFailure) {
      // Build a readable error message, preferring detailed field errors when available.
      final errors = data['errors'];
      final List<String> messages = [];

      if (errors is Map) {
        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            for (final v in value) {
              messages.add('$key: ${v.toString()}');
            }
          } else if (value != null) {
            messages.add('$key: ${value.toString()}');
          }
        });
      } else if (errors is List) {
        messages.addAll(errors.map((e) => e.toString()));
      }

      String msg;
      if (messages.isNotEmpty) {
        msg = messages.join('\n');
      } else {
        msg = data['message']?.toString() ??
            data['msg']?.toString() ??
            data['errors']?.toString() ??
            data['error']?.toString() ??
            'Request failed';
      }

      throw Exception(msg);
    }
  }

  // ─── Templates ─────────────────────────────────────────────────────────
  /// GET templates – Smart Card templates list
  static Future<Map<String, dynamic>> getTemplates(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: _templatesPath,
        context: context,
        query: {'itemsCount': '200', 'with': 'type_id'},
      );
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
    List<String>? logoBase64,
    List<String>? worksGalleryBase64,
    List<String>? videoGalleryBase64,
  }) async {
    try {
      // Build multipart FormData like PersonalProfileService.updateProfile (avatar)
      // but with smart-card fields + media (logo, works_gallery, video_gallery)
      //
      // IMPORTANT BEHAVIOUR:
      // - الـ API بيشتغل بنموذج "full model": لازم تبعت كل الحقول في الـ body
      //   (بما فيها logo / works_gallery / video_gallery) عشان ما يمسحش القيم القديمة.
      // - وفي نفس الوقت، أول مرة نرفع الميديا (أو لما نضيف ميديا جديدة) كنا بنبعتها
      //   كـ ملفات multipart فقط بدون ما نبعت الـ base64 جوه JSON => وده اللي شغال صح.
      //
      // المطلوب:
      // - لو المستخدم "ما رفعش" ميديا جديدة: نبعت القيم الحالية زي ما هي في الـ body (روابط من الـ API).
      // - لو المستخدم "رفع" ميديا جديدة (base64): نبعت الميديا دي كـ multipart فقط
      //   ونشيلها من JSON (زي أول مرة اتبعتت صح) عشان ما يحصلش 500 من الـ API.

      // نفصل بين:
      // - بيانات الميديا (logo / works_gallery / video_gallery) كـ Arrays
      // - باقي الحقول العادية
      final Map<String, dynamic> original = Map<String, dynamic>.from(body);

      List<dynamic> _ensureList(dynamic value) {
        if (value == null) return <dynamic>[];
        if (value is List) return value;
        return <dynamic>[value];
      }

      final List<dynamic> logoList = _ensureList(original['logo']);
      final List<dynamic> worksList = _ensureList(original['works_gallery']);
      final List<dynamic> videoList = _ensureList(original['video_gallery']);

      // بقية الحقول بدون مفاتيح الميديا
      final Map<String, dynamic> baseMap = Map<String, dynamic>.from(original)
        ..remove('logo')
        ..remove('works_gallery')
        ..remove('video_gallery');

      // العناصر الموجودة من الـ API: Map فيها id → نبعت الـ id فقط. العناصر الجديدة: String base64 → نرفعها كملف.
      int? _parseId(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        if (v is String) return int.tryParse(v);
        return null;
      }

      List<String> _extractBase64Strings(List<dynamic> list) {
        final result = <String>[];
        for (final item in list) {
          if (item is String) {
            try {
              base64Decode(item);
              result.add(item);
            } catch (_) {}
          }
        }
        return result;
      }

      final logoNewBase64 = _extractBase64Strings(logoList);
      final worksNewBase64 = _extractBase64Strings(worksList);
      final videoNewBase64 = _extractBase64Strings(videoList);

      final formData = FormData.fromMap(baseMap);

      List<MultipartFile> _filesFromBase64List(List<String> list, String prefix, String extension) {
        final List<MultipartFile> results = [];
        for (var i = 0; i < list.length; i++) {
          try {
            final Uint8List bytes = base64Decode(list[i]);
            results.add(MultipartFile.fromBytes(
              bytes,
              filename: '$prefix\_$i.$extension',
              contentType: extension == 'mp4'
                  ? MediaType('video', extension)
                  : MediaType('image', extension),
            ));
          } catch (_) {}
        }
        return results;
      }

      // إرسال الميديا بنفس ترتيب القائمة وبفهرس صريح [0],[1],[2]... عشان الباك ما يخلطش (ما يبدلش الجديد بالأول)
      void addMediaInOrder(String key, List<dynamic> list, List<String> base64List, String filePrefix, String ext) {
        final files = _filesFromBase64List(base64List, filePrefix, ext);
        var fileIndex = 0;
        for (var i = 0; i < list.length; i++) {
          final item = list[i];
          final indexKey = '$key[$i]';
          if (item is Map) {
            final id = _parseId(item['id']);
            if (id != null) {
              formData.fields.add(MapEntry(indexKey, id.toString()));
            } else {
              final url = (item['file'] ?? item['thumbnail'])?.toString();
              if (url != null && url.isNotEmpty) formData.fields.add(MapEntry(indexKey, url));
            }
          } else if (item is String) {
            final isBase64 = base64List.contains(item);
            if (isBase64 && fileIndex < files.length) {
              formData.files.add(MapEntry(indexKey, files[fileIndex++]));
            } else if (!isBase64 && item.isNotEmpty) {
              formData.fields.add(MapEntry(indexKey, item));
            }
          }
        }
      }

      addMediaInOrder('logo', logoList, logoNewBase64, 'logo', 'jpg');
      addMediaInOrder('works_gallery', worksList, worksNewBase64, 'work', 'jpg');
      addMediaInOrder('video_gallery', videoList, videoNewBase64, 'video', 'mp4');

      // Use POST with _method=PUT to send multipart (Laravel-style override)
      final response = await DioHelper.postFormData(
        url: '$_companyBase/$companyId?_method=PUT',
        context: context,
        query: null,
        formdata: formData,
        data: const {},
      );

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
        context: context,
        url: '$_companyBase/$companyId',
        query: null,
        data: null,
        token: token,
      );
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
    } catch (e) {
      debugPrint('SmartCardService.getCompanyEmployees: $e');
      rethrow;
    }
  }

  /// GET Get single Employee in Company (لجلب بيانات الموظف عند فتح صفحة التحديث)
  static Future<Map<String, dynamic>> getEmployeeInCompany(
    BuildContext context, {
    required int companyId,
    required int employeeId,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: '$_companyBase/$companyId/employees/$employeeId',
        context: context,
        query: null,
      );
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
    } catch (e) {
      debugPrint('SmartCardService.getEmployeeInCompany: $e');
      rethrow;
    }
  }

  /// PUT Update Employee in Company – FormData (photo[], works_gallery[], video_gallery[]) بنفس أسلوب updateEmployee
  static Future<Map<String, dynamic>> updateEmployeeInCompany(
    BuildContext context, {
    required int companyId,
    required int employeeId,
    required Map<String, dynamic> body,
  }) async {
    return _updateEmployeeFormData(
      context,
      url: '$_companyBase/$companyId/employees/$employeeId',
      body: body,
    );
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
        context: context,
        url: '$_companyBase/$companyId/employees/$employeeId',
        query: null,
        data: null,
        token: token,
      );
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
    } catch (e) {
      debugPrint('SmartCardService.createEmployee: $e');
      rethrow;
    }
  }

  /// PUT Update Employee Profile (current user) – with FormData for photo / works_gallery / video_gallery (نفس أسلوب company لكن المفتاح photo بدل logo)
  static Future<Map<String, dynamic>> updateEmployee(
    BuildContext context, {
    required Map<String, dynamic> body,
  }) async {
    return _updateEmployeeFormData(context, url: _employeeBase, body: body);
  }

  static Future<Map<String, dynamic>> _updateEmployeeFormData(
    BuildContext context, {
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      final Map<String, dynamic> original = Map<String, dynamic>.from(body);

      List<dynamic> _ensureList(dynamic value) {
        if (value == null) return <dynamic>[];
        if (value is List) return value;
        return <dynamic>[value];
      }

      final List<dynamic> photoList = _ensureList(original['photo']);
      final List<dynamic> worksList = _ensureList(original['works_gallery']);
      final List<dynamic> videoList = _ensureList(original['video_gallery']);

      final Map<String, dynamic> baseMap = Map<String, dynamic>.from(original)
        ..remove('photo')
        ..remove('works_gallery')
        ..remove('video_gallery')
        ..remove('educations')
        ..remove('experiences')
        ..remove('portfolios');

      int? _parseId(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        if (v is String) return int.tryParse(v);
        return null;
      }

      List<String> _extractBase64Strings(List<dynamic> list) {
        final result = <String>[];
        for (final item in list) {
          if (item is String) {
            try {
              base64Decode(item);
              result.add(item);
            } catch (_) {}
          }
        }
        return result;
      }

      final photoNewBase64 = _extractBase64Strings(photoList);
      final worksNewBase64 = _extractBase64Strings(worksList);
      final videoNewBase64 = _extractBase64Strings(videoList);

      final formData = FormData.fromMap(baseMap);

      List<MultipartFile> _filesFromBase64List(List<String> list, String prefix, String extension) {
        final List<MultipartFile> results = [];
        for (var i = 0; i < list.length; i++) {
          try {
            final Uint8List bytes = base64Decode(list[i]);
            results.add(MultipartFile.fromBytes(
              bytes,
              filename: '$prefix\_$i.$extension',
              contentType: extension == 'mp4'
                  ? MediaType('video', extension)
                  : MediaType('image', extension),
            ));
          } catch (_) {}
        }
        return results;
      }

      // إرسال الميديا بنفس ترتيب القائمة وبفهرس صريح [0],[1],[2]... عشان الباك ما يبدلش الجديد بالأول
      void addMediaInOrder(String key, List<dynamic> list, List<String> base64List, String filePrefix, String ext) {
        final files = _filesFromBase64List(base64List, filePrefix, ext);
        var fileIndex = 0;
        for (var i = 0; i < list.length; i++) {
          final item = list[i];
          final indexKey = '$key[$i]';
          if (item is Map) {
            final id = _parseId(item['id']);
            if (id != null) {
              formData.fields.add(MapEntry(indexKey, id.toString()));
            } else {
              final url = (item['file'] ?? item['thumbnail'])?.toString();
              if (url != null && url.isNotEmpty) formData.fields.add(MapEntry(indexKey, url));
            }
          } else if (item is String) {
            final isBase64 = base64List.contains(item);
            if (isBase64 && fileIndex < files.length) {
              formData.files.add(MapEntry(indexKey, files[fileIndex++]));
            } else if (!isBase64 && item.isNotEmpty) {
              formData.fields.add(MapEntry(indexKey, item));
            }
          }
        }
      }

      addMediaInOrder('photo', photoList, photoNewBase64, 'photo', 'jpg');
      addMediaInOrder('works_gallery', worksList, worksNewBase64, 'work', 'jpg');
      addMediaInOrder('video_gallery', videoList, videoNewBase64, 'video', 'mp4');

      // educations – نفس الطريقة والكي كما في Create CV: حقل واحد educations = json.encode(list)
      final educationsRaw = original['educations'];
      if (educationsRaw is List && educationsRaw.isNotEmpty) {
        final filtered = educationsRaw
            .where((e) => e is Map && e.isNotEmpty)
            .toList();
        if (filtered.isNotEmpty) {
          formData.fields.add(MapEntry('educations', json.encode(filtered)));
        }
      }

      // experiences – الباك يتوقع array، بنبعت بالمفتاح company_name وغيره صراحة
      final experiencesRaw = original['experiences'];
      if (experiencesRaw is List && experiencesRaw.isNotEmpty) {
        final filtered = experiencesRaw
            .where((e) => e is Map && e.isNotEmpty)
            .cast<Map<String, dynamic>>()
            .toList();
        const experienceKeys = ['company_name', 'country_id', 'state_id', 'date_from', 'date_to', 'job_title'];
        for (var i = 0; i < filtered.length; i++) {
          final item = filtered[i];
          for (final key in experienceKeys) {
            final v = item[key];
            formData.fields.add(MapEntry(
              'experiences[$i][$key]',
              v?.toString() ?? '',
            ));
          }
        }
      }

      // portfolios – نفس الفكرة: portfolios[0][project_name], portfolios[0][project_link], ...
      final portfoliosRaw = original['portfolios'];
      if (portfoliosRaw is List && portfoliosRaw.isNotEmpty) {
        final filtered = portfoliosRaw
            .where((e) => e is Map && e.isNotEmpty)
            .cast<Map<String, dynamic>>()
            .toList();
        for (var i = 0; i < filtered.length; i++) {
          for (final entry in filtered[i].entries) {
            if (entry.value != null && entry.value.toString().isNotEmpty) {
              formData.fields.add(MapEntry(
                'portfolios[$i][${entry.key}]',
                entry.value.toString(),
              ));
            }
          }
        }
      }

      final response = await DioHelper.postFormData(
        url: '$url?_method=PUT',
        context: context,
        query: null,
        formdata: formData,
        data: const {},
      );

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      _checkResponse(data);
      return data;
    } catch (e) {
      debugPrint('SmartCardService.updateEmployee(FormData): $e');
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
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
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
        context: context,
        url: _employeeBase,
        query: null,
        data: null,
        token: token,
      );
      final data = response.data is Map ? Map<String, dynamic>.from(response.data as Map) : <String, dynamic>{};
      _checkResponse(data);
      return data;
    } catch (e) {
      debugPrint('SmartCardService.deleteEmployee: $e');
      rethrow;
    }
  }
}
