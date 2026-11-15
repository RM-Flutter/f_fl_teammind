import 'package:app_test/core/models/employee_action_model.dart';

/// A reward or penalty as returned by the approval system
/// (`/approval-system/v1/rewards_and_penalties/...` → `approvables[]`).
///
/// The parser accepts the old payroll shape too (`type` / `category` as
/// `{key, value}` maps, `amount`, `due_date`), so it keeps working whatever
/// shape the backend sends.
class RewardPenaltyApprovableModel {
  int? id;
  String? status;
  bool? takeAction;
  bool? canTakeActionAsSomeoneElse;

  /// `reward` or `penalty`.
  String? type;
  String? categoryName;

  /// `days`, `hours` or `amount`.
  String? unit;
  String? amount;
  String? reason;
  String? dueDate;
  int? employeeId;
  String? employeeName;
  String? employeeAvatar;
  String? departmentName;
  String? createdAt;
  String? updatedAt;
  List<EmployeeActionModel>? employeeActions;

  RewardPenaltyApprovableModel({
    this.id,
    this.status,
    this.takeAction,
    this.canTakeActionAsSomeoneElse,
    this.type,
    this.categoryName,
    this.unit,
    this.amount,
    this.reason,
    this.dueDate,
    this.employeeId,
    this.employeeName,
    this.employeeAvatar,
    this.departmentName,
    this.createdAt,
    this.updatedAt,
    this.employeeActions,
  });

  bool get isReward => (type ?? '').toLowerCase().contains('reward');

  static String? _keyOrValue(dynamic v, {bool preferValue = false}) {
    if (v == null) return null;
    if (v is Map) {
      final a = preferValue ? v['value'] : v['key'];
      final b = preferValue ? v['key'] : v['value'];
      return (a ?? b ?? v['name'] ?? v['title'])?.toString();
    }
    return v.toString();
  }

  factory RewardPenaltyApprovableModel.fromApprovableJson(
      Map<String, dynamic> json) {
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : (json['employee'] is Map<String, dynamic>
            ? json['employee'] as Map<String, dynamic>
            : <String, dynamic>{});
    final department = json['department'];
    final unit = _keyOrValue(
        json['unit'] ?? json['amount_type'] ?? json['value_type']);
    // The backend sends the unit (days / hours / amount) in `category` too.
    String? category = _keyOrValue(json['category_name'] ?? json['category'],
        preferValue: true);
    if (category != null &&
        (category.toLowerCase() == unit?.toLowerCase() ||
            const ['days', 'hours', 'amount'].contains(category.toLowerCase()))) {
      category = null;
    }

    return RewardPenaltyApprovableModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      status: json['status']?.toString(),
      takeAction: (json['can_take_action'] ?? json['take_action']) as bool?,
      canTakeActionAsSomeoneElse: (json['can_take_action_as_someone_else'] ??
          json['take_action_as_someone_else']) as bool?,
      type: _keyOrValue(json['type'] ?? json['reward_type']),
      categoryName: category,
      unit: unit ?? _keyOrValue(json['category']),
      amount: (json['amount'] ?? json['money_value'] ?? json['value'])
          ?.toString(),
      reason: json['reason']?.toString(),
      dueDate: (json['due_date'] ?? json['date_from'] ?? json['date'])
          ?.toString(),
      employeeId: int.tryParse(
          '${profile['id'] ?? json['profile_id'] ?? json['employee_id']}'),
      employeeName:
          (profile['name'] ?? json['employee_name'])?.toString(),
      employeeAvatar: profile['avatar']?.toString(),
      departmentName: department is Map
          ? (department['title'] ?? department['name'])?.toString()
          : (json['department_name'] ?? profile['department'])?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      employeeActions: json['employee_actions'] is List
          ? (json['employee_actions'] as List)
              .map((e) => EmployeeActionModel.fromJson(e))
              .toList()
          : null,
    );
  }
}
