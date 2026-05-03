import 'package:flutter/material.dart';
import '../models/smart_card_profile_models.dart';
import '../services/smart_card_service.dart';

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
      _setError(e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString());
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

  /// استخدم في شاشة تفاصيل الشركة: تعيين شركة من خارج القائمة ثم تحميل موظفيها
  Future<void> setCompanyAndLoadEmployees(
      BuildContext context, Map<String, dynamic> company) async {
    selectedCompany = company;
    selectedCompanyId = company['id'] as int?;
    companyEmployees = [];
    notifyListeners();
    if (selectedCompanyId != null) {
      await loadCompanyEmployees(context);
    }
  }

  /// هل الشركة "مجانية" حسب الـ API (للعرض التسويقي)
  bool get isSelectedCompanyFree {
    if (selectedCompany == null) return false;
    return selectedCompany!['is_free'] == true ||
        selectedCompany!['isFree'] == true ||
        selectedCompany!['free'] == true;
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
      _setError(e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString());
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
      _setError(e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString());
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
      _setError(e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString());
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
      _setError(e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString());
      employeeProfile = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Full load for Smart Card screen: companies then profile + employees for first company
  Future<void> loadSmartCardScreen(BuildContext context) async {
    _setLoading(true);
    try {
      // 1) تحميل الشركات (My Companies)
      final res = await SmartCardService.getMyCompanies(context);
      final data = res['data'];
      if (data is List) {
        myCompanies =
            data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (myCompanies.isNotEmpty) {
          selectedCompanyId = myCompanies.first['id'] as int?;
          selectedCompany = myCompanies.first;
        } else {
          selectedCompanyId = null;
          selectedCompany = null;
        }
      } else {
        myCompanies = [];
        selectedCompanyId = null;
        selectedCompany = null;
      }

      // قائمة الموظفين الخاصين بالشركة مش جزء من أول شاشة الجديدة
      // لكن نفضيها عشان ما تبقاش بيانات قديمة
      companyEmployees = [];

      // 2) تحميل بروفايل الموظف الشخصي (Personal QR Profile)
      try {
        final profileRes = await SmartCardService.getEmployeeProfile(context);
        final profileData = profileRes['data'];
        if (profileData is Map) {
          employeeProfile =
              Map<String, dynamic>.from(profileData);
        } else {
          employeeProfile = null;
        }
      } catch (e) {
        // لو حصل خطأ في تحميل البروفايل، ما نكسرش الشاشة؛ نكتفي بعدم وجود بروفايل
        debugPrint('SmartCardViewModel.loadSmartCardScreen profile error: $e');
        employeeProfile = null;
      }
    } catch (e) {
      _setError(e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString());
      myCompanies = [];
      selectedCompany = null;
      selectedCompanyId = null;
      companyEmployees = [];
      employeeProfile = null;
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

  /// Create personal employee profile (current user) – used from Smart Card bottom sheet
  /// الـ API يتوقع الموديل كامل (كل المفاتيح، null لو مفيش)
  Future<bool> createEmployeeProfile(BuildContext context,
      {required String name}) async {
    _setLoading(true);
    try {
      final fullModel = SmartCardEmployeeProfileModel(name: name);
      await SmartCardService.createEmployee(
        context,
        body: fullModel.toFullJson(),
      );
      // بعد الإنشاء نعيد تحميل بيانات البروفايل
      await loadEmployeeProfile(context);
      return true;
    } catch (e) {
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      _setError(msg);
      return false;
    } finally {
      _setLoading(false);
    }
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
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      _setError(msg);
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
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      _setError(msg);
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
