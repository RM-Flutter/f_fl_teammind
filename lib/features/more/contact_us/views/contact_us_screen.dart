import 'dart:convert';
import 'dart:ui' as ui;

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/more/contact_us/controllers/contact_us_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact us: three cards (phone, address, email) and one with the social links, under the
/// same navy header as the rest of the app. Every action sits inside the card it belongs to.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
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

  List<String> _stringList(dynamic v) =>
      v is List ? v.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList() : <String>[];

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMap(dynamic lat, dynamic lng) async {
    final la = double.tryParse(lat?.toString() ?? '');
    final ln = double.tryParse(lng?.toString() ?? '');
    if (la == null || ln == null) return;
    await _open('https://www.google.com/maps/search/?api=1&query=$la,$ln');
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('copied'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);
    final phones = <String>[
      if (_contacts['phone'] != null && _contacts['phone'].toString().isNotEmpty)
        _contacts['phone'].toString(),
      ..._stringList(_contacts['otherphones']),
    ];
    final emails = <String>[
      if (_contacts['email'] != null && _contacts['email'].toString().isNotEmpty)
        _contacts['email'].toString(),
      ..._stringList(_contacts['otheremails']),
    ].toSet().toList();
    final branches = _contacts['branches'] is List ? _contacts['branches'] as List : const [];

    final socials = <MapEntry<String, String>>[
      for (final e in const {
        'whatsapp': 'whatsapp',
        'linkedin': 'linkedin',
        'youtube': 'youtube',
        'instagram': 'instagram',
        'facebook': 'facebook',
        'tiktok': 'tiktok',
        'twitter': 'twitter',
        'messenger': 'messenger',
        'snapchat': 'snapchat',
        'telegram': 'telegram',
      }.entries)
        if (_contacts[e.key] != null && _contacts[e.key].toString().isNotEmpty)
          MapEntry(e.value, _contacts[e.key].toString()),
    ];

    return ChangeNotifierProvider(
      create: (_) => ContactUsController(),
      child: Consumer<ContactUsController>(
        builder: (context, controller, _) => TemplatePage(
          pageContext: context,
          title: AppStrings.contactUs.tr(),
          backgroundColor: Color(AppColors.background),
          body: Padding(
            padding: AppSpacing.listPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (phones.isNotEmpty)
                  _ContactCard(
                    icon: "assets/images/svg/contact-phone.svg",
                    title: AppStrings.phone.tr(),
                    children: [
                      for (final p in phones)
                        _Line(
                          text: p,
                          actionLabel: 'call'.tr(),
                          onAction: () => _open('tel:$p'),
                          onLongPress: () => _copy(p),
                        ),
                    ],
                  ),
                if (branches.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  _ContactCard(
                    icon: "assets/images/svg/contact-address.svg",
                    title: AppStrings.address.tr(),
                    children: [
                      for (final b in branches)
                        _Line(
                          title: (b['title']?[isArabic ? 'ar' : 'en'] ?? '').toString(),
                          text: (b['co_info_address']?[isArabic ? 'ar' : 'en'] ?? '').toString(),
                          actionLabel: AppStrings.showMap.tr(),
                          onAction: () => _openMap(b['lat'], b['lng']),
                        ),
                    ],
                  ),
                ],
                if (emails.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  _ContactCard(
                    icon: "assets/images/svg/contact-email.svg",
                    title: AppStrings.email.tr(),
                    children: [
                      for (final m in emails)
                        _Line(
                          text: m,
                          actionLabel: AppStrings.sendEmail.tr(),
                          onAction: () => controller.sendMailToCompany(
                              context: context, email: m, subject: null, body: null),
                          onLongPress: () => _copy(m),
                        ),
                    ],
                  ),
                ],
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
                                onTap: () => _open(s.value),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(AppColors.buttons),
                                  ),
                                  child: SvgPicture.asset(
                                    "assets/images/svg/${s.key}.svg",
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
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

/// One card: icon in a soft square + title, then its lines.
class _ContactCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<Widget> children;
  const _ContactCard({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: SvgPicture.asset(icon,
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn)),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(title,
                  style: AppStyles.heading(context)
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          for (final c in children) ...[
            const Divider(height: AppSpacing.lg * 2),
            c,
          ],
        ],
      ),
    );
  }
}

/// A value (and optional title) with its action chip on the end. Long press copies the value.
class _Line extends StatelessWidget {
  final String? title;
  final String text;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onLongPress;
  const _Line({
    this.title,
    required this.text,
    required this.actionLabel,
    required this.onAction,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onAction,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty)
                  Text(title!,
                      style: AppStyles.heading(context)
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(text,
                    textDirection: RegExp(r'^[\d+\s-]+$').hasMatch(text) ? ui.TextDirection.ltr : null,
                    style: AppStyles.greyContent(context).copyWith(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppStatusBadge(
            label: actionLabel,
            color: Color(AppColors.buttons),
            trailingIcon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}
