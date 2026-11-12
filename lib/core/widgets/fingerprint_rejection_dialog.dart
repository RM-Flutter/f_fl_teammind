import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/routing/app_router.dart' show rootNavigatorKey;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Reasons a punch was refused, from a failed OperationResult:
/// - `errors` set by the app when a mandatory security check failed on the phone
/// - `data['errors']` sent by the server (security rejection or validation errors)
List<String> fingerprintRejectionReasons(dynamic result) {
  if (result == null || result.success == true) return const [];
  dynamic errors = result.errors;
  final bool empty = errors == null || (errors is List && errors.isEmpty) || (errors is Map && errors.isEmpty);
  if (empty && result.data is Map) errors = result.data['errors'];
  if (errors is Map) {
    errors = errors.values.expand((value) => value is List ? value : [value]).toList();
  }
  if (errors is! List) return const [];
  return errors.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
}

/// Shows the list of reasons when the punch was refused with reasons.
/// Returns false (nothing shown) when there are no reasons, so the caller shows its usual alert.
Future<bool> showFingerprintRejection(dynamic result) async {
  final reasons = fingerprintRejectionReasons(result);
  final context = rootNavigatorKey.currentContext;
  if (reasons.isEmpty || context == null || !context.mounted) return false;

  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      titlePadding: const EdgeInsets.fromLTRB(AppSizes.s20, AppSizes.s20, AppSizes.s20, AppSizes.s8),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s20, vertical: AppSizes.s8),
      actionsPadding: const EdgeInsets.all(AppSizes.s16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.s8),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.block, color: Colors.red, size: 26),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Text(
              'fingerprint_rejected'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(AppColors.black)),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('fingerprint_rejected_reasons'.tr(),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              const SizedBox(height: AppSizes.s8),
              ...reasons.map((reason) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.s5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: AppSizes.s2),
                          child: Icon(Icons.close_rounded, color: Colors.red, size: 18),
                        ),
                        const SizedBox(width: AppSizes.s8),
                        Expanded(child: Text(reason, style: const TextStyle(fontSize: 14, height: 1.4))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(45),
            backgroundColor: Color(AppColors.secondaryButton),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text('ok'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  return true;
}
