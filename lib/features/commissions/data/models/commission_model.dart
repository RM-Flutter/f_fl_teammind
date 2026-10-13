import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommissionModel {
  final int? id;
  final String? title;
  final num? commissionAmount;
  final String? amountFormatted;
  final String? currency;
  final String? status;
  final String? statusLabel;
  final String? statusBadge;
  final String? payrollMonth;
  final String? payrollMonthLabel;
  final String? appliedAt;
  final String? paymentDate;
  final String? paymentDateLabel;
  final String? paymentReason;
  final String? notes;
  final String? createdAt;

  CommissionModel({
    this.id,
    this.title,
    this.commissionAmount,
    this.amountFormatted,
    this.currency,
    this.status,
    this.statusLabel,
    this.statusBadge,
    this.payrollMonth,
    this.payrollMonthLabel,
    this.appliedAt,
    this.paymentDate,
    this.paymentDateLabel,
    this.paymentReason,
    this.notes,
    this.createdAt,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      commissionAmount: json['commission_amount'] as num?,
      amountFormatted: json['amount_formatted'] as String?,
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      statusBadge: json['status_badge'] as String?,
      payrollMonth: json['payroll_month'] as String?,
      payrollMonthLabel: json['payroll_month_label'] as String?,
      appliedAt: json['applied_at'] as String?,
      paymentDate: json['payment_date'] as String?,
      paymentDateLabel: json['payment_date_label'] as String?,
      paymentReason: json['payment_reason'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  /// Translates currency code (e.g. "EGP" -> "جنية" in Arabic, "EGP" in English).
  String get localizedCurrency {
    if (currency == null || currency!.isEmpty) return '';
    return currency!.toLowerCase().tr();
  }

  /// Formatted amount + localized currency.
  String get localizedAmount {
    final amt = amountFormatted ?? commissionAmount?.toString() ?? '0';
    final curr = localizedCurrency;
    return curr.isNotEmpty ? '$amt $curr' : amt;
  }

  static DateTime? _parseDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw.trim());
  }

  /// Returns formatted date part (e.g. "12 أكتوبر 2026" or "12 Oct 2026").
  static String? formatDatePart(BuildContext context, String? raw) {
    final dt = _parseDateTime(raw);
    if (dt == null) return raw;
    final locale = context.locale.languageCode;
    return DateFormat('dd MMM yyyy', locale).format(dt);
  }

  /// Returns formatted time part (e.g. "07:33 ص" or "07:33 AM").
  static String? formatTimePart(BuildContext context, String? raw) {
    final dt = _parseDateTime(raw);
    if (dt == null) return null;
    final locale = context.locale.languageCode;
    return DateFormat('hh:mm a', locale).format(dt);
  }

  /// Returns formatted full date & time (e.g. "12 أكتوبر 2026 • 07:33 ص").
  static String formatDateTimeFull(BuildContext context, String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-';
    final dt = _parseDateTime(raw);
    if (dt == null) return raw;
    final locale = context.locale.languageCode;
    final datePart = DateFormat('dd MMM yyyy', locale).format(dt);
    final timePart = DateFormat('hh:mm a', locale).format(dt);
    return '$datePart  •  $timePart';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'commission_amount': commissionAmount,
      'amount_formatted': amountFormatted,
      'currency': currency,
      'status': status,
      'status_label': statusLabel,
      'status_badge': statusBadge,
      'payroll_month': payrollMonth,
      'payroll_month_label': payrollMonthLabel,
      'applied_at': appliedAt,
      'payment_date': paymentDate,
      'payment_date_label': paymentDateLabel,
      'payment_reason': paymentReason,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  @override
  String toString() =>
      'CommissionModel(id: $id, title: $title, commissionAmount: $commissionAmount, status: $status)';
}
