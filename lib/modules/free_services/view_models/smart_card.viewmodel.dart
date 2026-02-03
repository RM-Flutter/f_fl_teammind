import 'package:flutter/material.dart';
import '../services/smart_card.service.dart';

class SmartCardViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool _disposed = false;
  String? errorMessage;

  List<Map<String, dynamic>> myCompanies = [];
  Map<String, dynamic>? selectedCompany;
  int? selectedCompanyId;
  List<Map<String, dynamic>> companyEmployees = [];
  List<Map<String, dynamic>> templates = [];
  Map<String, dynamic>? employeeProfile;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  void _setLoading(bool value) {
    if (_disposed) return;
    isLoading = value;
    if (value) errorMessage = null;
    notifyListeners();
  }

  void _setError(String? msg) {
    if (_disposed) return;
    errorMessage = msg;
    notifyListeners();
  }

  /// Load "Get My Companies"
  Future<void> loadMyCompanies(BuildContext context) async {
    _setLoading(true);
    try {
      final res = await SmartCardService.getMyCompanies(context);
      final data = res['data'];
      if (data is List) {
        myCompanies = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (myCompanies.isNotEmpty && selectedCompanyId == null) {
          selectCompany(myCompanies.first['id'] as int? ?? 0);
        }
      } else {
        myCompanies = [];
      }
    } catch (e) {
      _setError(e.toString());
      myCompanies = [];
    } finally {
      _setLoading(false);
    }
  }

  void selectCompany(int id) {
    selectedCompanyId = id;
    try {
      selectedCompany = myCompanies.firstWhere((c) => (c['id'] as int?) == id);
    } catch (_) {
      selectedCompany = myCompanies.isEmpty ? null : myCompanies.first;
      selectedCompanyId = selectedCompany?['id'] as int?;
    }
    companyEmployees = [];
    notifyListeners();
  }

  /// Load "Get Company Profile" for selected company
  Future<void> loadCompanyProfile(BuildContext context) async {
    if (selectedCompanyId == null) return;
    _setLoading(true);
    try {
      final res = await SmartCardService.getCompanyProfile(context, companyId: selectedCompanyId!);
      final data = res['data'];
      if (data is Map) {
        selectedCompany = Map<String, dynamic>.from(data);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load "Get Company Employees"
  Future<void> loadCompanyEmployees(BuildContext context) async {
    if (selectedCompanyId == null) return;
    _setLoading(true);
    try {
      final res = await SmartCardService.getCompanyEmployees(context, companyId: selectedCompanyId!);
      final data = res['data'];
      if (data is List) {
        companyEmployees = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        companyEmployees = [];
      }
    } catch (e) {
      _setError(e.toString());
      companyEmployees = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Load templates – "templates" (GET)
  Future<void> loadTemplates(BuildContext context) async {
    _setLoading(true);
    try {
      final res = await SmartCardService.getTemplates(context);
      final data = res['data'];
      if (data is List) {
        templates = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        templates = [];
      }
    } catch (e) {
      _setError(e.toString());
      templates = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Load "Get Employee Profile" (current user)
  Future<void> loadEmployeeProfile(BuildContext context) async {
    _setLoading(true);
    try {
      final res = await SmartCardService.getEmployeeProfile(context);
      final data = res['data'];
      if (data is Map) {
        employeeProfile = Map<String, dynamic>.from(data);
      } else {
        employeeProfile = null;
      }
    } catch (e) {
      _setError(e.toString());
      employeeProfile = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Full load for Smart Card screen: companies then profile + employees for first company
  Future<void> loadSmartCardScreen(BuildContext context) async {
    _setLoading(true);
    try {
      final res = await SmartCardService.getMyCompanies(context);
      final data = res['data'];
      if (data is List) {
        myCompanies = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (myCompanies.isNotEmpty) {
          selectedCompanyId = myCompanies.first['id'] as int?;
          selectedCompany = myCompanies.first;
          await SmartCardService.getCompanyEmployees(context, companyId: selectedCompanyId!)
              .then((r) {
            final list = r['data'];
            if (list is List) {
              companyEmployees = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            } else {
              companyEmployees = [];
            }
          }).catchError((_) {
            companyEmployees = [];
          });
        } else {
          selectedCompanyId = null;
          selectedCompany = null;
          companyEmployees = [];
        }
      } else {
        myCompanies = [];
        selectedCompanyId = null;
        selectedCompany = null;
        companyEmployees = [];
      }
    } catch (e) {
      _setError(e.toString());
      myCompanies = [];
      selectedCompany = null;
      selectedCompanyId = null;
      companyEmployees = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Public URL for company (View Company Profile Public)
  String getCompanyPublicUrl() {
    if (selectedCompany == null) return '';
    final slug = selectedCompany!['slug'] ?? selectedCompany!['id'];
    return SmartCardService.getCompanyProfilePublicUrl(slug.toString());
  }

  /// Public URL for one employee (View Employee Profile Public)
  String getEmployeePublicUrl(Map<String, dynamic> emp) {
    final slug = emp['slug'] ?? emp['id'];
    return SmartCardService.getEmployeeProfilePublicUrl(slug.toString());
  }

  /// Add employee to company – "Add Employee to Company" (POST)
  Future<bool> addEmployeeToCompany(BuildContext context, {required String name}) async {
    if (selectedCompanyId == null) return false;
    _setLoading(true);
    try {
      await SmartCardService.addEmployeeToCompany(
        context,
        companyId: selectedCompanyId!,
        body: {'name': name},
      );
      await loadCompanyEmployees(context);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update company template – "Update Company Template" (PATCH)
  Future<bool> updateCompanyTemplate(BuildContext context, int templateId) async {
    if (selectedCompanyId == null) return false;
    _setLoading(true);
    try {
      await SmartCardService.updateCompanyTemplate(
        context,
        companyId: selectedCompanyId!,
        templateId: templateId,
      );
      await loadCompanyProfile(context);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
