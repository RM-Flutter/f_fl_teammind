import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../view_models/smart_card.viewmodel.dart';
import '../../models/smart_card_profile_models.dart';
import '../../services/smart_card.service.dart';
import 'widgets/smart_card_loading.widget.dart';
import 'package:flutter/rendering.dart';
import 'package:app_test/features/services/views/smart_card/widgets/build_action_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar_with_bookmark.widget.dart';

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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: Color(AppColors.modalBackground),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            const SizedBox(height: 20),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 12),
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
                      backgroundColor: Color(AppColors.titleText),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
        backgroundColor: Colors.white,
        appBar: AppBarWithBookmark(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.titleText),
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
            color: Color(AppColors.titleText),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
                  vm.isLoading ? null : () => _showCreateProfileBottomSheet(vm),
              backgroundColor: Color(AppColors.buttons),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.add, color: Colors.white),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.smartCardDigitalProfileDesc.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    gapH12,
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(
                          AppRoutes.youtubeVideoScreen.name,
                          pathParameters: {
                            'lang': context.locale.languageCode,
                            'url': Uri.encodeComponent(gCache['smartCardVideoUrl'].toString()),
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.learnMoreAboutOpportunities.tr(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30,),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.selectCompanyProfile.tr(),
                        style: const TextStyle(
                          color: Color(AppColors.darkBlue),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (vm.myCompanies.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          AppStrings.noCompaniesFound.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      )
                    else
                      Column(
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
                    const SizedBox(height: 12),
                    Container(
                      height: 40,
                      width: 160,
                      child: FilledButton(
                        onPressed: vm.isLoading
                            ? null
                            : () => _showAddCompanyBottomSheet(vm),
                        style: FilledButton.styleFrom(
                          backgroundColor: Color(AppColors.darkBlue),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          AppStrings.addNewCompany.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 2) Personal QR Profile section
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.personalQrProfile.tr(),
                        style: const TextStyle(
                          color: Color(AppColors.darkBlue),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        borderRadius: BorderRadius.circular(12),
                        child: _buildProfileCard(vm.employeeProfile!),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          AppStrings.noProfileYet.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ),
                    SizedBox(height: 30,),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.callUsFor.tr(),
                        style: const TextStyle(
                          color: Color(AppColors.black),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: buildActionCard(
                            icon: "assets/images/svg/downloadQr.svg",
                            label: AppStrings.premiumSmartCard.tr(),
                            onTap: () => _showInfoBottomSheet(AppStrings.premiumSmartCardSheetMessage, isFromPremiumSmartCard: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildActionCard(
                            icon: "assets/images/svg/updateInfo.svg",
                            label: AppStrings.nfcCards.tr(),
                            onTap: () => _showInfoBottomSheet(AppStrings.nfcCardsSheetMessage, isFromPremiumSmartCard: false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.profileName.tr(),
                    labelStyle: TextStyle(
                      color: Color(AppColors.hintText),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                    filled: true,
                    fillColor: Color(AppColors.cardBackground),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) async {
                    await _handleCreateProfile(ctx, vm, nameController.text);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await _handleCreateProfile(ctx, vm, nameController.text);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
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
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.companyName.tr(),
                    labelStyle: TextStyle(
                      color: Color(AppColors.hintText),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                    filled: true,
                    fillColor: Color(AppColors.cardBackground),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) async {
                    await _handleCreateCompany(ctx, vm, nameController.text);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await _handleCreateCompany(ctx, vm, nameController.text);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
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
      await SmartCardService.createCompany(
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(AppColors.buttons) : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
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
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final displayName = profile['name']?.toString() ??
        profile['full_name']?.toString() ??
        profile['email']?.toString() ??
        '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
        displayName.isEmpty ? AppStrings.notSet.tr() : displayName,
        style: const TextStyle(
          color: Color(AppColors.black),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
