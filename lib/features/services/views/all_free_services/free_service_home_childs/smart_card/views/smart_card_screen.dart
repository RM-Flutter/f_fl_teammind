import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/widgets/app_intro_banner.widget.dart';
import 'package:app_test/core/utils/string_extensions.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/views/common_ui/build_action_card.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/views/common_ui/smart_card_loading_widget.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/models/smart_card_profile_models.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/repos/repo/smart_card_repo.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/controllers/smart_card_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

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

  void _showInfoBottomSheet(String messageKey, {bool isFromPremiumSmartCard = false, }) {
    final jsonString = CacheHelper.getString("USG");
    var gCache;
    if (jsonString != null && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s20, AppSizes.s24, AppSizes.s24),
        decoration: BoxDecoration(
          color: Color(AppColors.modalBackground),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              messageKey.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(AppColors.black),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.s20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      if (isFromPremiumSmartCard) {
                        final uri = Uri.parse('${gCache['premiumSmartCardLearnMoreUrl']}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      }else{
                        final uri = Uri.parse('${gCache['nfcCardsLearnMoreUrl']}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    child: Text(
                      AppStrings.learnMore.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                          context.pushNamed(
                                  AppRoutes.contactUs.name,
                                  pathParameters: {
                                    "lang": context.locale.languageCode,
                                  },
                                );
                      // Contact - يمكن ربطه بشاشة تواصل أو رقم
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.secondaryButton),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    child: Text(
                      AppStrings.contact.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SmartCardViewModel>.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: Color(AppColors.background),
        appBar: AppBarWithBookmark(
          backgroundColor: Color(AppColors.background),
          elevation: 0,
          leading: AppBackButton(
            onPressed: () {
              try {
                GoRouter.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: AppStrings.smartCard2.tr(),
          centerTitle: true,
          routeName: AppRoutes.smartCardScreen.name,
        ),
        // في أول نسخة من شاشة الـ Smart Card: الفلوتينج بوتون هيكون مسئول عن إضافة بروفايل شخصي
        floatingActionButton: Consumer<SmartCardViewModel>(
          builder: (_, vm, __) {
            // لو فيه بروفايل بالفعل، لا نعرض زر الإضافة
            if (vm.employeeProfile != null) return const SizedBox.shrink();
            return FloatingActionButton(
              heroTag: 'smart_card_add_profile',
              onPressed:
                  vm.isLoading ? null : () async {
                  final result = await context.pushNamed(
                    AppRoutes.updateEmployeeInfoScreen.name,
                    pathParameters: {'lang': context.locale.languageCode},
                    queryParameters: {'isPersonal': 'true'},
                    extra: <String, dynamic>{},
                  );
                  if (result == true) {
                    vm.loadSmartCardScreen(context);
                  }
                },
              backgroundColor: Color(AppColors.buttons),
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
        body: Consumer<SmartCardViewModel>(
          builder: (_, vm, __) {
            final jsonString = CacheHelper.getString("USG");
            var gCache;
            if (jsonString != null && jsonString != "") {
              gCache = json.decode(jsonString) as Map<String, dynamic>;
            }
            if (vm.isLoading && vm.myCompanies.isEmpty && vm.employeeProfile == null) {
              return const SmartCardLoadingWidget();
            }
            if (vm.errorMessage != null && vm.myCompanies.isEmpty && vm.employeeProfile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.s24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: AppSizes.s16),
                      FilledButton(
                        onPressed: () => vm.loadSmartCardScreen(context),
                        child: Text(AppStrings.retry.tr()),
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
                padding: const EdgeInsets.all(AppSizes.s16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppIntroBanner(
                      description: AppStrings.smartCardDigitalProfileDesc.tr(),
                      onLearnMore: () {
                        context.pushNamed(
                          AppRoutes.youtubeVideoScreen.name,
                          pathParameters: {
                            'lang': context.locale.languageCode,
                            'url': Uri.encodeComponent(gCache['smartCardVideoUrl'].toString()),
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.section),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle(AppStrings.selectCompanyProfile.tr()),
                        InkWell(
                          onTap: vm.isLoading ? null : () { _showAddCompanyBottomSheet(vm); },
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.s4),
                            decoration: BoxDecoration(
                              color: Color(AppColors.buttons).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: Color(AppColors.buttons),
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sectionHeaderGap),
                    if (vm.myCompanies.isEmpty)
                      AppCard(
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            AppStrings.noCompaniesFound.tr(),
                            textAlign: TextAlign.center,
                            style: AppStyles.greyContent(context).copyWith(fontSize: 13),
                          ),
                        ),
                      )
                    else
                      AppResponsiveGrid(
                        children: vm.myCompanies
                            .map(
                              (c) => _buildCompanyCard(
                                company: c,
                                isSelected: false,
                                onTap: () {
                                  context.pushNamed(
                                    AppRoutes.smartCardCompanyDetailScreen.name,
                                    pathParameters: {
                                      'lang': context.locale.languageCode,
                                    },
                                    extra: c,
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),

                    const SizedBox(height: AppSpacing.section),

                    // 2) Personal QR Profile section
                    _sectionTitle(AppStrings.personalQrProfile.tr()),
                    const SizedBox(height: AppSpacing.sectionHeaderGap),
                    if (vm.employeeProfile != null)
                      InkWell(
                        onTap: () async {
                          final deleted = await context.pushNamed<bool>(
                            AppRoutes.smartCardProfileDetailScreen.name,
                            pathParameters: {
                              'lang': context.locale.languageCode,
                            },
                            extra: {
                              'employee': vm.employeeProfile!,
                              'isPersonal': true,
                              'companyId': null,
                            },
                          );
                          if (deleted == true && context.mounted) {
                            vm.loadSmartCardScreen(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: _buildProfileCard(vm.employeeProfile!),
                      )
                    else
                      AppCard(
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            AppStrings.noProfileYet.tr(),
                            textAlign: TextAlign.center,
                            style: AppStyles.greyContent(context).copyWith(fontSize: 13),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.section),
                    _sectionTitle(AppStrings.callUsFor.tr()),
                    const SizedBox(height: AppSpacing.sectionHeaderGap),
                    AppResponsiveGrid(
                      compact: 2,
                      medium: 3,
                      expanded: 4,
                      children: [
                        buildActionCard(
                          icon: "assets/images/svg/downloadQr.svg",
                          label: AppStrings.premiumSmartCard.tr(),
                          onTap: () => _showInfoBottomSheet(AppStrings.premiumSmartCardSheetMessage, isFromPremiumSmartCard: true),
                        ),
                        buildActionCard(
                          icon: "assets/images/svg/updateInfo.svg",
                          label: AppStrings.nfcCards.tr(),
                          onTap: () => _showInfoBottomSheet(AppStrings.nfcCardsSheetMessage, isFromPremiumSmartCard: false),
                        ),
                      ],
                    ),
                  ],
                ),
              ))),
            );
          },
        ),
      ),
    );
  }

  void _showCreateProfileBottomSheet(SmartCardViewModel vm) {
    final nameController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: BoxDecoration(
              color: Color(AppColors.modalBackground),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s16, AppSizes.s24, AppSizes.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSizes.s8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
                const SizedBox(height: AppSizes.s24),
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.profileName.tr(),
                    labelStyle: TextStyle(
                      color: Color(0xFFA3A3A3),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                    filled: true,
                    fillColor: Color(AppColors.cardBackground),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSizes.s14,
                      horizontal: AppSizes.s16,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) async {
                    await _handleCreateProfile(ctx, vm, nameController.text);
                  },
                ),
                const SizedBox(height: AppSizes.s20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await _handleCreateProfile(ctx, vm, nameController.text);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                    child: Text(
                      'create'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCreateProfile(
    BuildContext bottomSheetContext,
    SmartCardViewModel vm,
    String rawName,
  ) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterProfileName.tr())),
      );
      return;
    }
    Navigator.of(bottomSheetContext).pop();
    final ok = await vm.createEmployeeProfile(context, name: name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? AppStrings.profileCreatedSuccessfully.tr()
            : (vm.errorMessage ?? AppStrings.errorCreatingProfile.tr())),
      ),
    );
  }

  void _showAddCompanyBottomSheet(SmartCardViewModel vm) {
    final nameController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: BoxDecoration(
              color: Color(AppColors.modalBackground),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s16, AppSizes.s24, AppSizes.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSizes.s8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
                const SizedBox(height: AppSizes.s24),
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.companyName.tr(),
                    labelStyle: TextStyle(
                      color: Color(0xFFA3A3A3),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                    filled: true,
                    fillColor: Color(AppColors.cardBackground),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSizes.s14,
                      horizontal: AppSizes.s16,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) async {
                    await _handleCreateCompany(ctx, vm, nameController.text);
                  },
                ),
                const SizedBox(height: AppSizes.s20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await _handleCreateCompany(ctx, vm, nameController.text);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                    child: Text(
                      'create'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCreateCompany(
    BuildContext bottomSheetContext,
    SmartCardViewModel vm,
    String rawName,
  ) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterCompanyName.tr())),
      );
      return;
    }
    Navigator.of(bottomSheetContext).pop();
    try {
      // الـ API يتوقع الموديل كامل (كل المفاتيح، null لو مفيش)
      final fullModel = SmartCardCompanyProfileModel(name: name);
      await SmartCardRepo.createCompany(
        context,
        body: fullModel.toFullJson(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.companyCreatedSuccessfully.tr())),
      );
      vm.loadSmartCardScreen(context);
    } catch (e) {
      if (!mounted) return;
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCompanyCard({
    required Map<String, dynamic> company,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final name = company['name']?.toString() ?? '';
    final companyId = company['id'] as int?;

    return AppCard(
      animateIn: true,
      border: isSelected
          ? Border.all(color: Color(AppColors.secondaryButton), width: 2)
          : null,
      onTap: onTap,
      padding: const EdgeInsetsDirectional.fromSTEB(AppSizes.s14, AppSizes.s12, AppSizes.s6, AppSizes.s12),
      child: Row(
        children: [
          AppCardLeadingAvatar(
            icon: Icons.business_outlined,
            accentColor: Color(AppColors.secondaryButton),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.titleCase,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.heading(context)
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSizes.s3),
                Text(
                  AppStrings.companyProfile.tr(),
                  style: AppStyles.greyContent(context).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          if (company['profile_url'] != null && company['profile_url'].toString().isNotEmpty)
            IconButton(
              icon: Icon(Icons.qr_code_2_rounded, color: Color(AppColors.secondaryButton)),
              tooltip: 'View Profile',
              onPressed: () async {
                final url = Uri.parse(company['profile_url'].toString());
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          if (companyId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              tooltip: 'Delete Company',
              onPressed: () => _showDeleteCompanyBottomSheet(companyId, name),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final displayName = profile['name']?.toString() ??
        profile['full_name']?.toString() ??
        profile['email']?.toString() ??
        '';
    return AppCard(
      animateIn: true,
      padding: const EdgeInsetsDirectional.fromSTEB(AppSizes.s14, AppSizes.s12, AppSizes.s6, AppSizes.s12),
      child: Row(
        children: [
          AppCardLeadingAvatar(
            fallbackText: displayName,
            icon: Icons.person_outline,
            accentColor: Color(AppColors.buttons),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isEmpty ? AppStrings.notSet.tr() : displayName.titleCase,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.heading(context)
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSizes.s3),
                Text(
                  AppStrings.personalProfile.tr(),
                  style: AppStyles.greyContent(context).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          if (profile['profile_url'] != null && profile['profile_url'].toString().isNotEmpty)
            IconButton(
              icon: Icon(Icons.qr_code_2_rounded, color: Color(AppColors.buttons)),
              tooltip: 'View Profile',
              onPressed: () async {
                final url = Uri.parse(profile['profile_url'].toString());
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: AppStyles.heading(context).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
      );

  void _showDeleteCompanyBottomSheet(int companyId, String companyName) {
    bool isDeleting = false;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s20, AppSizes.s24, AppSizes.s24),
            decoration: BoxDecoration(
              color: Color(AppColors.modalBackground),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.s20),
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: AppSizes.s16),
                Text(
                  'deleteCompanyConfirm'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSizes.s8),
                Text(
                  companyName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: AppSizes.s24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: isDeleting ? null : () => Navigator.of(ctx).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                        child: Text(
                          'cancel'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s12),
                    Expanded(
                      child: FilledButton(
                        onPressed: isDeleting
                            ? null
                            : () async {
                                setModalState(() {
                                  isDeleting = true;
                                });
                                final ok = await viewModel.deleteCompany(context, companyId);
                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }
                                if (ok && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('deleted_successfully'.tr())),
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                        child: isDeleting
                            ? const SizedBox(
                                height: AppSizes.s20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'delete'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
