import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:flutter/material.dart';

class CVReferenceDataService {
  /// Get Jobs List
  static Future<List<Map<String, dynamic>>> getJobs(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: "/res-jobs/entities-operations",
        context: context,
        query: {
          'itemsCount': 25,

        },
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
      return [];
    }
  }

  /// Get Skills List
  static Future<List<Map<String, dynamic>>> getSkills(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: "/res-skills/entities-operations",
        context: context,
        query: {
          'itemsCount': 25,

        },
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching skills: $e');
      return [];
    }
  }

  /// Get Levels List
  static Future<List<Map<String, dynamic>>> getLevels(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: "/res-levels/entities-operations",
        context: context,
        query: {
          'itemsCount': 25,
        },
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching levels: $e');
      return [];
    }
  }

  /// Get Languages List
  static Future<List<Map<String, dynamic>>> getLanguages(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: "/languages/entities-operations",
        context: context,
        query: {
          'itemsCount': 25,

        },
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching languages: $e');
      return [];
    }
  }

  /// Get Countries List
  static Future<List<Map<String, dynamic>>> getCountries(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: "/countries/entities-operations",
        context: context,
        query: {
          'itemsCount': 200,

        },
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        final list = List<Map<String, dynamic>>.from(response.data['data']);
        return _ensureTitleKey(list);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching countries: $e');
      return [];
    }
  }

  /// Get States/Provinces List by Country ID
  static Future<List<Map<String, dynamic>>> getStates(BuildContext context, int countryId) async {
    try {
      final response = await DioHelper.getData(
        url: "/states/entities-operations",
        context: context,
        query: {
          'itemsCount': 200,
          'country_id': countryId,
        },
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        final list = List<Map<String, dynamic>>.from(response.data['data']);
        return _ensureTitleKey(list);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching states: $e');
      return [];
    }
  }

  /// الدروب داون بتستخدم nameKey: 'title' — نتأكد إن كل عنصر عنده title (من name لو الـ API رجع name)
  static List<Map<String, dynamic>> _ensureTitleKey(List<Map<String, dynamic>> list) {
    return list.map((e) {
      final m = Map<String, dynamic>.from(e);
      if (!m.containsKey('title') || m['title'] == null) {
        m['title'] = m['name']?.toString() ?? '';
      }
      return m;
    }).toList();
  }

  /// Get Cities List by State ID
  static Future<List<Map<String, dynamic>>> getCities(BuildContext context, int stateId) async {
    try {
      final response = await DioHelper.getData(
        url: "/info-cities/entities-operations",
        context: context,
        query: {
          'itemsCount': 200,
          'state_id': stateId,
        },
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        final list = List<Map<String, dynamic>>.from(response.data['data']);
        return _ensureTitleKey(list);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching cities: $e');
      return [];
    }
  }

  /// Get Nationalities List
  static Future<List<Map<String, dynamic>>> getNationalities(BuildContext context) async {
    try {
      final response = await DioHelper.getData(
        url: "/nationalities/entities-operations",
        context: context,
        query: {
          'itemsCount': 200,

        },
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching nationalities: $e');
      return [];
    }
  }
}

