import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_shortcut_card.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/more/contact_us/controllers/contact_us_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// About the app: the logo, the description in readable paragraphs, the social links and the
/// e-mail shortcut, as cards under the normal app bar.
class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  static const _socialKeys = ['whatsapp', 'linkedin', 'youtube', 'instagram', 'facebook', 'twitter'];
  Map<String, dynamic> _contacts = {};

  @override
  void initState() {
    super.initState();
    final jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty) {
      final g = json.decode(jsonString) as Map<String, dynamic>;
      final c = g['company_contacts'];
      if (c is Map) _contacts = Map<String, dynamic>.from(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    final paragraphs = AppStrings.aboutAppDescription
        .tr()
        .split(RegExp(r'\n\s*\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final socials = [
      for (final k in _socialKeys)
        if (_contacts[k] != null && _contacts[k].toString().isNotEmpty) MapEntry(k, _contacts[k].toString()),
    ];
    final email = _contacts['email']?.toString() ?? '';

    return ChangeNotifierProvider(
      create: (_) => ContactUsController(),
      child: Consumer<ContactUsController>(
        builder: (context, controller, _) => TemplatePage(
          pageContext: context,
          title: AppStrings.aboutApplication.tr(),
          showBookmark: false,
          backgroundColor: Color(AppColors.background),
          body: Padding(
            padding: AppSpacing.listPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo card
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.section * 1.5),
                  child: Center(
                    child: Image.asset(AppImages.loginLogoColored, height: 96, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                // Description: one paragraph per block, comfortable line height
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < paragraphs.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.lg),
                        Text(
                          paragraphs[i],
                          style: AppStyles.aboutUsContent(context)
                              .copyWith(fontSize: 14, height: 1.7, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ],
                  ),
                ),
                if (socials.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.followUs.tr(),
                            style: AppStyles.heading(context)
                                .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            for (final s in socials)
                              InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () async {
                                  final uri = Uri.tryParse(s.value);
                                  if (uri != null) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                                  child: SvgPicture.asset(
                                    "assets/images/svg/${s.key}.svg",
                                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  AppShortcutCard(
                    icon: Icons.mail_outline_rounded,
                    title: AppStrings.sendByEmail.tr(),
                    subtitle: email,
                    onTap: () => controller.sendMailToCompany(
                        context: context, email: email, subject: null, body: null),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
