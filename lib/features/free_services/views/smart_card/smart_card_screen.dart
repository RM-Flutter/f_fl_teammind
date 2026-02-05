import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';

class SmartCardScreen extends StatefulWidget {
  const SmartCardScreen({super.key});

  @override
  State<SmartCardScreen> createState() => _SmartCardScreenState();
}

class _SmartCardScreenState extends State<SmartCardScreen> {
  final List<String> employeeProfiles = [
    'Mohamed Hassan Mohamed',
    'Mohamed Hassan Mohamed',
    'Mohamed Hassan Mohamed',
    'Mohamed Hassan Mohamed',
    'Mohamed Hassan Mohamed',
  ];

  void _navigateTo(String routeName) {
    try {
      GoRouter.of(context).pushNamed(
        routeName,
        pathParameters: {'lang': context.locale.languageCode},
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback navigation
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithBookmark(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(AppColors.dark),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
          onPressed: () {
            try {
              GoRouter.of(context).pop();
            } catch (e) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: AppStrings.smartCard2.tr(),
        titleStyle: TextStyle(
          color: Color(AppColors.dark),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        routeName: AppRoutes.smartCardScreen.name,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new employee profile
        },
        backgroundColor: Color(AppColors.primary),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name
            const Center(
              child: Text(
                'Right Mind Company',
                style: TextStyle(
                  color: Color(AppColors.black),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons Grid - First Row
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.business,
                    label: AppStrings.updateCompanyInfo.tr(),
                    onTap: () => _navigateTo(AppRoutes.updateMyInfoScreen.name),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.dashboard_customize,
                    label: AppStrings.selectTemplate.tr(),
                    onTap: () => _navigateTo(AppRoutes.selectTemplateScreen.name),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons Grid - Second Row
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.qr_code,
                    label: AppStrings.downloadQrCode.tr(),
                    onTap: () {
                      // Download QR Code
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.link,
                    label: AppStrings.copyProfileLink.tr(),
                    onTap: () {
                      // Copy profile link
                      Clipboard.setData(const ClipboardData(text: 'https://profile.link'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.profileLinkCopied.tr())),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Employee Profiles Section
            Center(
              child: Text(
                AppStrings.employeeProfiles.tr(),
                style: const TextStyle(
                  color: Color(AppColors.black),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Employee List
            ...employeeProfiles.map((name) => _buildEmployeeCard(name)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: Color(AppColors.dark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(String name) {
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
      child: Text(
        name,
        style: const TextStyle(
          color: Color(AppColors.black),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
