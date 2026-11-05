import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_toast.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/more/ai_connect/controllers/ai_connect_controller.dart';
import 'package:app_test/features/more/ai_connect/views/ai_connect_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// More → "Connect ChatGPT / Claude": shows the company's connector link
/// and how to add it. Each user connects their own assistant account.
class AiConnectScreen extends StatelessWidget {
  const AiConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiConnectController(),
      child: const _AiConnectView(),
    );
  }
}

class _AiConnectView extends StatefulWidget {
  const _AiConnectView();

  @override
  State<_AiConnectView> createState() => _AiConnectViewState();
}

class _AiConnectViewState extends State<_AiConnectView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiConnectController>().loadInfo(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AiConnectController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AiConnectHeader(title: AppStrings.aiConnectTitle.tr()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => c.loadInfo(context),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Text(AppStrings.aiConnectIntro.tr(),
                        style: AppStyles.darkContent(context).copyWith(fontSize: 13, height: 1.5)),
                    const SizedBox(height: 16),
                    if (c.isInfoLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (!c.enabled || c.mcpUrl == null)
                      _Notice(
                        icon: Icons.info_outline,
                        color: Color(AppColors.warningYellow),
                        text: c.errorMessage ?? c.disabledReason ?? AppStrings.aiConnectNotEnabled.tr(),
                      )
                    else ...[
                      _LinkCard(url: c.mcpUrl!),
                      const SizedBox(height: 20),
                      Text(AppStrings.aiConnectHowTo.tr(),
                          style: AppStyles.heading(context).copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      _Step(number: 1, text: AppStrings.aiConnectStep1.tr()),
                      _Step(number: 2, text: AppStrings.aiConnectStep2.tr()),
                      _Step(number: 3, text: AppStrings.aiConnectStep3.tr()),
                      _Step(number: 4, text: AppStrings.aiConnectStep4.tr()),
                      const SizedBox(height: 12),
                      _Notice(
                        icon: Icons.lock_outline,
                        color: Color(AppColors.successGreen),
                        text: AppStrings.aiConnectPrivacy.tr(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.link_rounded),
                      label: Text(AppStrings.aiConnectedApps.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(AppColors.buttons),
                        side: BorderSide(color: Color(AppColors.buttons)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      onPressed: () => context.pushNamed(
                        AppRoutes.aiConnectedApps.name,
                        pathParameters: {'lang': context.locale.languageCode},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String url;
  const _LinkCard({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: Color(AppColors.buttons).withValues(alpha: 0.06),
        border: Border.all(color: Color(AppColors.buttons).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.aiConnectLinkLabel.tr(),
                    style: AppStyles.darkContent(context).copyWith(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                // URLs are always left-to-right, also in Arabic.
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: SelectableText(url,
                      style: AppStyles.darkContent(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppStrings.aiConnectCopy.tr(),
            icon: Icon(Icons.copy_rounded, color: Color(AppColors.buttons)),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              AppToast.showToast(msg: AppStrings.aiConnectCopied.tr());
            },
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: Color(AppColors.buttons),
            child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppStyles.darkContent(context).copyWith(fontSize: 13, height: 1.45)),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Notice({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppStyles.darkContent(context).copyWith(fontSize: 12, height: 1.45))),
        ],
      ),
    );
  }
}
