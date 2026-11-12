import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/string_extensions.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/views/common_ui/build_action_card.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/repos/repo/smart_card_repo.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/controllers/smart_card_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gal/gal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/constants/app_design.dart';

class SmartCardCompanyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const SmartCardCompanyDetailScreen({super.key, required this.company});

  @override
  State<SmartCardCompanyDetailScreen> createState() =>
      _SmartCardCompanyDetailScreenState();
}

class _SmartCardCompanyDetailScreenState
    extends State<SmartCardCompanyDetailScreen> {
  late final SmartCardViewModel viewModel;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    viewModel = SmartCardViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.setCompanyAndLoadEmployees(context, widget.company);
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  String get _companyProfileUrl {
    final slug = viewModel.selectedCompany?['slug'] ?? viewModel.selectedCompany?['id'];
    if (slug == null) return '';
    return SmartCardRepo.getCompanyProfilePublicUrl(slug.toString());
  }

  void _showCopyProfileLinkSheet() {
    final url = _companyProfileUrl;
    if (url.isEmpty) {
      _showSnack(AppStrings.noProfileLinkAvailable.tr());
      return;
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
              AppStrings.copyProfileLink.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.black),
              ),
            ),
            const SizedBox(height: AppSizes.s12),
            SelectableText(url, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            const SizedBox(height: AppSizes.s20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      Navigator.of(ctx).pop();
                      _showSnack(AppStrings.profileLinkCopied.tr());
                    },
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white,),
                    label: Text(AppStrings.copy.tr(), style:  TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),),
                  ),
                ),
                const SizedBox(width: AppSizes.s8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                    ),
                    icon: const Icon(Icons.open_in_browser, size: 16),
                    label: Text(AppStrings.openInBrowser.tr(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadQrSheet() {
    final url = _companyProfileUrl;
    if (url.isEmpty) {
      _showSnack(AppStrings.noProfileLinkAvailable.tr());
      return;
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
          children: [
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppSizes.s16),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Color(AppColors.background),
                  dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.s20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _downloadQr(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: Color(AppColors.buttons),
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
                ),
                icon: SvgPicture.asset("assets/images/svg/downloadQr.svg"),
                label: Text(AppStrings.downloadQr.tr(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadQr(BuildContext sheetContext) async {
    try {
      final boundary =
      _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted && mounted) {
          _showSnack(AppStrings.errorSavingQr.tr());
          return;
        }
      }
      await Gal.putImageBytes(bytes);
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      _showSnack(AppStrings.qrSaved.tr());
    } catch (e) {
      _showSnack(AppStrings.errorSavingQr.tr());
    }
  }
  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  void _showAddProfileSheet(SmartCardViewModel vm) {
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
                    ),
                    filled: true,
                    fillColor: Color(AppColors.cardBackground),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s12),
                  ),
                ),
                const SizedBox(height: AppSizes.s20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;
                      Navigator.of(ctx).pop();
                      final ok = await vm.addEmployeeToCompany(context, name: name);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? AppStrings.profileAdded.tr()
                              : (vm.errorMessage ?? 'error'.tr())),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
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

  void _showFreeCompanySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.s24, AppSizes.s24, AppSizes.s24, AppSizes.s32),
        decoration: BoxDecoration(
          color: Color(AppColors.modalBackground),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.smartCardCompanyPromo.tr(),
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(AppColors.black),
              ),
            ),
            const SizedBox(height: AppSizes.s24),
            OutlinedButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                const yt = 'https://www.youtube.com';
                final uri = Uri.parse(yt);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.play_circle_outline),
              label: Text(AppStrings.learnMoreYoutube.tr()),
            ),
            const SizedBox(height: AppSizes.s12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pushNamed(
                  AppRoutes.contactUs.name,
                  pathParameters: {'lang': context.locale.languageCode},
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Color(AppColors.buttons),
                padding: const EdgeInsets.symmetric(vertical: AppSizes.s14),
              ),
              icon: const Icon(Icons.contact_support),
              label: Text(AppStrings.contactUs.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToUpdateCompanyInfo() {
    context.pushNamed(
      AppRoutes.updateCompanyInfoScreen.name,
      pathParameters: {'lang': context.locale.languageCode},
      extra: viewModel.selectedCompany,
    );
  }
  Future<void> _navigateToSelectTemplate() async {
    // Read current template_id and template_data from the loaded company data.
    final company = viewModel.selectedCompany ?? widget.company;
    final templateId   = company['template_id'] != null ? int.tryParse(company['template_id'].toString()) : null;
    dynamic tData = company['template_data'];
    if (tData is String) {
      try { tData = jsonDecode(tData); } catch (_) {}
    }
    final templateData = tData is Map ? Map<String, dynamic>.from(tData as Map) : null;

    final result = await context.pushNamed(
      AppRoutes.selectSmartCardTemplateScreen.name,
      pathParameters: {'lang': context.locale.languageCode},
      queryParameters: {
        'isPersonal': 'false',
        if (widget.company['id'] != null) 'companyId': widget.company['id'].toString(),
      },
      extra: {
        if (templateId != null) 'initialTemplateId': templateId,
        if (templateData != null) 'initialTemplateData': templateData,
      },
    );
    if (result == true) {
      if (!context.mounted) return;
      try {
        GoRouter.of(context).pop();
      } catch (e) {
        Navigator.of(context).pop();
      }
    }
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
          leading: AppBackButton(onPressed: () {
              try {
                GoRouter.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
              }
            }),
          title: AppStrings.smartCard2.tr(),
          centerTitle: true,
          routeName: AppRoutes.smartCardCompanyDetailScreen.name,
        ),
        floatingActionButton: Consumer<SmartCardViewModel>(
          builder: (_, vm, __) {
            final isFree = vm.isSelectedCompanyFree;
            final hasEmployees = vm.companyEmployees.isNotEmpty;
            if (isFree) {
              return FloatingActionButton(
                heroTag: 'smart_card_company_free',
                onPressed: vm.isLoading ? null : _showFreeCompanySheet,
                backgroundColor: Color(AppColors.buttons),
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
            if (!hasEmployees) {
              return FloatingActionButton(
                heroTag: 'smart_card_company_add',
                onPressed: vm.isLoading ? null : () => _showAddProfileSheet(vm),
                backgroundColor: Color(AppColors.buttons),
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
            return FloatingActionButton(
              heroTag: 'smart_card_company_add_employees',
              onPressed: vm.isLoading ? null : () => _showAddProfileSheet(vm),
              backgroundColor: Color(AppColors.buttons),
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
        body: Consumer<SmartCardViewModel>(
          builder: (_, vm, __) {
            final companyName =
                vm.selectedCompany?['name']?.toString() ?? widget.company['name']?.toString() ?? '';
            return RefreshIndicator(
              onRefresh: () => vm.setCompanyAndLoadEmployees(context, widget.company),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        companyName.titleCase,
                        style: AppStyles.heading(context)
                            .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: AppSizes.s24),
                    AppResponsiveGrid(
                      compact: 2,
                      medium: 2,
                      expanded: 4,
                      children: [
                        buildActionCard(
                          icon: "assets/images/svg/updateInfo.svg",
                          label: AppStrings.updateCompanyInfo.tr(),
                          onTap: _navigateToUpdateCompanyInfo,
                        ),
                        buildActionCard(
                          icon: "assets/images/svg/selectTemp.svg",
                          label: AppStrings.selectTemplate.tr(),
                          onTap: _navigateToSelectTemplate,
                        ),
                        buildActionCard(
                          icon: "assets/images/svg/copyLink.svg",
                          label: AppStrings.copyProfileLink.tr(),
                          onTap: _showCopyProfileLinkSheet,
                        ),
                        buildActionCard(
                          icon: "assets/images/svg/downloadQr.svg",
                          label: AppStrings.downloadQrCode.tr(),
                          onTap: _showDownloadQrSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.section),
                    if (vm.isLoading && vm.companyEmployees.isEmpty)
                      const AppShimmerList(padding: EdgeInsets.zero, count: 2),
                    if (vm.companyEmployees.isNotEmpty) ...[
                      Text(
                        AppStrings.employeeProfiles.tr(),
                        style: AppStyles.heading(context)
                            .copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.sectionHeaderGap),
                      AppResponsiveGrid(children: vm.companyEmployees.map(
                        (e) => _buildEmployeeCard(
                          e,
                          onTap: () async {
                            final deleted = await context.pushNamed<bool>(
                              AppRoutes.smartCardProfileDetailScreen.name,
                              pathParameters: {
                                'lang': context.locale.languageCode,
                              },
                              extra: {
                                'employee': e,
                                'isPersonal': false,
                                'companyId': vm.selectedCompanyId,
                              },
                            );
                            if (deleted == true && context.mounted) {
                              vm.setCompanyAndLoadEmployees(context, widget.company);
                            }
                          },
                        ),
                      ).toList()),
                      ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> emp, {VoidCallback? onTap}) {
    final name = emp['name']?.toString() ?? emp['id']?.toString() ?? '';
    return AppCard(
      animateIn: true,
      onTap: onTap,
      child: Row(
        children: [
          AppCardLeadingAvatar(
            fallbackText: name,
            icon: Icons.person_outline,
            accentColor: Color(AppColors.buttons),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              name.titleCase,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.heading(context)
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
