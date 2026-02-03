import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../utils/custom_shimmer_loading/shimmer_animated_loading.dart';

class SmartCardLoadingWidget extends StatelessWidget {
  const SmartCardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company name placeholder
          Center(
            child: ShimmerAnimatedLoading(
              height: 20,
              width: 160,
              circularRaduis: 4,
            ),
          ),
          const SizedBox(height: 24),
          // Action cards - first row
          Row(
            children: [
              Expanded(child: _buildActionCardShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCardShimmer()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCardShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCardShimmer()),
            ],
          ),
          const SizedBox(height: 32),
          // Section title placeholder
          Center(
            child: ShimmerAnimatedLoading(
              height: 18,
              width: 140,
              circularRaduis: 4,
            ),
          ),
          const SizedBox(height: 16),
          // Employee cards placeholders
          ...List.generate(4, (_) => _buildEmployeeCardShimmer()),
        ],
      ),
    );
  }

  Widget _buildActionCardShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Color(AppColors.dark).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ShimmerAnimatedLoading(
            height: 28,
            width: 28,
            circularRaduis: 8,
          ),
          const SizedBox(height: 8),
          ShimmerAnimatedLoading(
            height: 14,
            width: double.infinity,
            circularRaduis: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCardShimmer() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ShimmerAnimatedLoading(
        height: 18,
        width: double.infinity,
        circularRaduis: 4,
      ),
    );
  }
}
