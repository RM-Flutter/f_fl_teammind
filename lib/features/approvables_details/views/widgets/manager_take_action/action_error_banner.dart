import 'package:app_test/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class ActionErrorBanner extends StatelessWidget {
  final String errorMessage;

  const ActionErrorBanner({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSizes.s12),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.red),
          const SizedBox(width: AppSizes.s8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
