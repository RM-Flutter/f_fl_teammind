import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:gal/gal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/features/services/views/smart_card/widgets/build_action_card.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar_with_bookmark.widget.dart';
import '../../services/smart_card.service.dart';

class SmartCardProfileDetailScreen extends StatefulWidget {
  final Map<String, dynamic> employee;
  final bool isPersonal;
  final int? companyId;

  const SmartCardProfileDetailScreen({
    super.key,
    required this.employee,
    required this.isPersonal,
    this.companyId,
  });

  @override
  State<SmartCardProfileDetailScreen> createState() =>
      _SmartCardProfileDetailScreenState();
}

class _SmartCardProfileDetailScreenState
    extends State<SmartCardProfileDetailScreen> {
  final GlobalKey _qrKey = GlobalKey();

  String get _profileUrl {
    final slug = widget.employee['slug'] ?? widget.employee['id'];
    if (slug == null) return '';
    return SmartCardService.getEmployeeProfilePublicUrl(slug.toString());
  }

  String get _displayName =>
      widget.employee['name']?.toString() ??
      widget.employee['full_name']?.toString() ??
      widget.employee['email']?.toString() ??
      '';


  void _showCopyProfileLinkSheet() {
    final url = _profileUrl;
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
                      backgroundColor: Theme.of(context).primaryColor,
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
                      backgroundColor: Theme.of(context).primaryColor,
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
    final url = _profileUrl;
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
                  backgroundColor: Theme.of(context).primaryColor,
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

  void _navigateToUpdateEmployeeInfo() {
    context.pushNamed(
      AppRoutes.updateEmployeeInfoScreen.name,
      pathParameters: {'lang': context.locale.languageCode},
      extra: {
        'employee': widget.employee,
        'isPersonal': widget.isPersonal,
        'companyId': widget.companyId,
      },
    );
  }

  void _navigateToSelectTemplate() {
    context.pushNamed(
      AppRoutes.selectTemplateScreen.name,
      pathParameters: {'lang': context.locale.languageCode},
    );
  }

  Future<void> _deleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteProfile.tr(), style: TextStyle(color: Theme.of(context).primaryColor),),
        content: Text(
          widget.isPersonal
              ? AppStrings.deleteSmartCardProfileConfirm.tr()
              : AppStrings.removeEmployeeProfileConfirm.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      if (widget.isPersonal) {
        await SmartCardService.deleteEmployee(context);
      } else {
        final cId = widget.companyId;
        final eId = widget.employee['id'] as int?;
        if (cId != null && eId != null) {
          await SmartCardService.removeEmployeeFromCompany(
            context,
            companyId: cId,
            employeeId: eId,
          );
        }
      }
      if (!mounted) return;
      _showSnack(AppStrings.profileDeleted.tr());
      GoRouter.of(context).pop(true);
    } catch (e) {
      _showSnack(e.toString());
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
        routeName: AppRoutes.smartCardProfileDetailScreen.name,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: buildActionCard(
                    icon: "assets/images/svg/updateInfo.svg",
                    label: AppStrings.updateMyInfo.tr(),
                    onTap: _navigateToUpdateEmployeeInfo,
                  ),
                ),
                if (widget.isPersonal) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildActionCard(
                      icon: "assets/images/svg/selectTemp.svg",
                      label: AppStrings.selectTemplate.tr(),
                      onTap: _navigateToSelectTemplate,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildActionCard(
                    icon: "assets/images/svg/downloadQr.svg",
                    label: AppStrings.downloadQrCode.tr(),
                    onTap: _showDownloadQrSheet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildActionCard(
                    icon: "assets/images/svg/copyLink.svg",
                    label: AppStrings.copyProfileLink.tr(),
                    onTap: _showCopyProfileLinkSheet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildActionCard(
                    icon: "assets/images/svg/deleteProfile.svg",
                    label: AppStrings.deleteProfileButton.tr(),
                    onTap: _deleteProfile,
                    isDestructive: true,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
