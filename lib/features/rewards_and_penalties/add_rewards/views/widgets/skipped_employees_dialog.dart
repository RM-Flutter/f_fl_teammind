import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Lists the employees the backend skipped while adding a reward / penalty, with the reason for each.
class SkippedEmployeesDialog extends StatelessWidget {
  final int createdCount;
  final List<Map<String, dynamic>> skipped;
  const SkippedEmployeesDialog({super.key, required this.createdCount, required this.skipped});

  static Future<void> show(BuildContext context, {required int createdCount, required List<Map<String, dynamic>> skipped}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SkippedEmployeesDialog(createdCount: createdCount, skipped: skipped),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s24, vertical: AppSizes.s24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s28, AppSizes.s24, AppSizes.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s14),
                decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 30),
              ),
              const SizedBox(height: AppSizes.s16),
              Text(
                'skipped_employees_title'.tr(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.s8),
              Text(
                'skipped_employees_message'.tr(args: [createdCount.toString(), skipped.length.toString()]),
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.s16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
 padding: EdgeInsets.zero,
                  itemCount: skipped.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.s8),
                  itemBuilder: (_, index) {
                    final item = skipped[index];
                    final name = item['name']?.toString() ?? '#${item['profile_id'] ?? ''}';
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.s12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                          const SizedBox(height: AppSizes.s4),
                          Text(item['reason']?.toString() ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.s20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.buttons),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                  ),
                  child: Text('got_it'.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
