import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';
import '../../view_models/smart_card.viewmodel.dart';
import 'widgets/smart_card_loading.widget.dart';

class SmartCardScreen extends StatefulWidget {
  const SmartCardScreen({super.key});

  @override
  State<SmartCardScreen> createState() => _SmartCardScreenState();
}

class _SmartCardScreenState extends State<SmartCardScreen> {
  late final SmartCardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = SmartCardViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadSmartCardScreen(context);
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _navigateTo(String routeName) {
    try {
      context.pushNamed(
        routeName,
        pathParameters: {'lang': context.locale.languageCode},
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      Navigator.of(context).pop();
    }
  }

  void _copyProfileLink() {
    final url = viewModel.getCompanyPublicUrl();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No company selected')),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.profileLinkCopied.tr())),
    );
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppStrings.employeeProfiles.tr()),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: AppStrings.enterYourName.tr(),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.of(ctx).pop();
                final ok = await viewModel.addEmployeeToCompany(context, name: name);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'OK' : (viewModel.errorMessage ?? 'Error')),
                    ),
                  );
                }
              },
              child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SmartCardViewModel>.value(
      value: viewModel,
      child: Scaffold(
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
        floatingActionButton: Consumer<SmartCardViewModel>(
          builder: (_, vm, __) {
            if (vm.selectedCompanyId == null) return const SizedBox.shrink();
            return FloatingActionButton(
              onPressed: vm.isLoading ? null : _showAddEmployeeDialog,
              backgroundColor: Color(AppColors.primary),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
        body: Consumer<SmartCardViewModel>(
          builder: (_, vm, __) {
            if (vm.isLoading && vm.myCompanies.isEmpty) {
              return const SmartCardLoadingWidget();
            }
            if (vm.errorMessage != null && vm.myCompanies.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => vm.loadSmartCardScreen(context),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => vm.loadSmartCardScreen(context),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Name
                    Center(
                      child: Text(
                        vm.selectedCompany?['name']?.toString() ?? '',
                        style: const TextStyle(
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.qr_code,
                            label: AppStrings.downloadQrCode.tr(),
                            onTap: () {
                              // Download QR Code – يمكن ربطه لاحقاً بـ public URL
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.link,
                            label: AppStrings.copyProfileLink.tr(),
                            onTap: _copyProfileLink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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
                    if (vm.companyEmployees.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No employees',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ...vm.companyEmployees.map((e) => _buildEmployeeCard(e)),
                  ],
                ),
              ),
            );
          },
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
        alignment: Alignment.center,
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: Color(AppColors.dark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildEmployeeCard(Map<String, dynamic> emp) {
    final name = emp['name']?.toString() ?? emp['id']?.toString() ?? '';
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
