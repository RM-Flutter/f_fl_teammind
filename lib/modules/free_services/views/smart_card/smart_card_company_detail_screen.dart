import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gal/gal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rmemp/modules/free_services/views/smart_card/widgets/build_action_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';
import '../../view_models/smart_card.viewmodel.dart';
import '../../services/smart_card.service.dart';

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
    return SmartCardService.getCompanyProfilePublicUrl(slug.toString());
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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: Color(AppColors.modalBackgroundColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            const SizedBox(height: 12),
            SelectableText(url, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.primary),
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
                const SizedBox(width: 8),
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
                      backgroundColor: Color(AppColors.primary),
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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: Color(AppColors.modalBackgroundColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _downloadQr(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: Color(AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
              color: Color(AppColors.modalBackgroundColor),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                      color: Color(AppColors.hintTextColor),
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Color(AppColors.cardBackgroundColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
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
                      backgroundColor: Color(AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: Color(AppColors.modalBackgroundColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pushNamed(
                  AppRoutes.contactUs.name,
                  pathParameters: {'lang': context.locale.languageCode},
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Color(AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
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
  void _navigateToSelectTemplate() {
    context.pushNamed(
      AppRoutes.selectTemplateScreen.name,
      pathParameters: {'lang': context.locale.languageCode},
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
                backgroundColor: Color(AppColors.primary),
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
            if (!hasEmployees) {
              return FloatingActionButton(
                heroTag: 'smart_card_company_add',
                onPressed: vm.isLoading ? null : () => _showAddProfileSheet(vm),
                backgroundColor: Color(AppColors.primary),
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
            }
            return FloatingActionButton(
              heroTag: 'smart_card_company_add_employees',
              onPressed: vm.isLoading ? null : () => _showAddProfileSheet(vm),
              backgroundColor: Color(AppColors.primary),
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
            final companyName =
                vm.selectedCompany?['name']?.toString() ?? widget.company['name']?.toString() ?? '';
            return RefreshIndicator(
              onRefresh: () => vm.setCompanyAndLoadEmployees(context, widget.company),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        companyName,
                        style: const TextStyle(
                          color: Color(AppColors.black),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: buildActionCard(
                            icon: "assets/images/svg/updateInfo.svg",
                            label: AppStrings.updateCompanyInfo.tr(),
                            onTap: _navigateToUpdateCompanyInfo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildActionCard(
                            icon: "assets/images/svg/selectTemp.svg",
                            label: AppStrings.selectTemplate.tr(),
                            onTap: _navigateToSelectTemplate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: buildActionCard(
                            icon: "assets/images/svg/copyLink.svg",
                            label: AppStrings.copyProfileLink.tr(),
                            onTap: _showCopyProfileLinkSheet,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildActionCard(
                            icon: "assets/images/svg/downloadQr.svg",
                            label: AppStrings.downloadQrCode.tr(),
                            onTap: _showDownloadQrSheet,
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
                            AppStrings.noEmployees.tr(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ...vm.companyEmployees.map(
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


  Widget _buildEmployeeCard(Map<String, dynamic> emp,
      {VoidCallback? onTap}) {
    final name =
        emp['name']?.toString() ?? emp['id']?.toString() ?? '';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
      ),
    );
  }
}
