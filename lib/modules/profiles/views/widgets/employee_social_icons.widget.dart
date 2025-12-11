import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/platform/platform_is.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../general_services/url_launcher.service.dart';
import '../../models/employee_profile.model.dart';

class EmployeeSocialContacts extends StatelessWidget {
  final EmpSocialMedia? socialData;
  const EmployeeSocialContacts({super.key, required this.socialData});

  @override
  Widget build(BuildContext context) {
    final socialIcons = {
      'whatsapp': FontAwesomeIcons.whatsapp,
      'telegram': FontAwesomeIcons.telegram,
      'facebook': FontAwesomeIcons.facebook,
      'linkedin': FontAwesomeIcons.linkedin,
      'messenger': FontAwesomeIcons.facebookMessenger,
      'instagram': FontAwesomeIcons.instagram,
      'youtube': FontAwesomeIcons.youtube,
      'twitter': FontAwesomeIcons.twitter,
      'pinterest': FontAwesomeIcons.pinterest,
      'snapchat': FontAwesomeIcons.snapchat,
      'tiktok': FontAwesomeIcons.tiktok,
      'discord': FontAwesomeIcons.discord,
      'quora': FontAwesomeIcons.quora,
      'mail': FontAwesomeIcons.envelope,
      'sms': FontAwesomeIcons.message,
      'facetime': FontAwesomeIcons.apple,
      'whatassp': FontAwesomeIcons.whatsapp,
      'location': FontAwesomeIcons.locationCrosshairs,
      'phone': FontAwesomeIcons.phone
    };

    final Map<String, String?> socialLinks = {
      'whatsapp': socialData?.whatsapp,
      'facebook': socialData?.facebook,
      'twitter': socialData?.twitter,
      'instagram': socialData?.instagram,
      'linkedin': socialData?.linkedin,
      'youtube': socialData?.youtube,
      'pinterest': socialData?.pinterest,
      'snapchat': socialData?.snapchat,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (kIsWeb || PlatformIs.web) ? AppSizes.s16 : 0,
        vertical: (kIsWeb || PlatformIs.web) ? AppSizes.s8 : 0,
      ),
      margin: EdgeInsets.only(
        bottom: (kIsWeb || PlatformIs.web) ? AppSizes.s16 : 0,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: (kIsWeb || PlatformIs.web) ? AppSizes.s12 : AppSizes.s8,
        runSpacing: (kIsWeb || PlatformIs.web) ? AppSizes.s12 : AppSizes.s8,
        children: [
          for (var entry in socialLinks.entries)
            if (entry.value?.isNotEmpty ?? false)
              SocailIconButton(
                  icon: socialIcons[entry.key] ?? FontAwesomeIcons.circleQuestion,
                  label: entry.key,
                  url: _getUrl(entry: entry),
                  mode: entry.key == 'location'
                      ? LaunchMode.externalApplication
                      : null),
        ],
      ),
    );
  }
}

String _getUrl({required MapEntry<String, String?> entry}) {
  if (entry.key == 'location' &&
      entry.value != null &&
      entry.value?.isNotEmpty == true) {
    // Extract the URL from the iframe string
    final locationUrl =
        RegExp(r'src="([^"]+)"').firstMatch(entry.value!)?.group(1) ?? '';
    if (locationUrl.isNotEmpty) {
      return locationUrl;
    }
  }
  if (entry.key == 'phone' &&
      entry.value != null &&
      entry.value?.isNotEmpty == true) {
    return "tel:${entry.value}";
  }

  return entry.value ?? '';
}

class SocailIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final LaunchMode? mode;
  const SocailIconButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.url,
      this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async => UrlLauncherServiceEx.launch(
            context: context, url: url, mode: mode ?? LaunchMode.platformDefault),
        child: CircleAvatar(
          backgroundColor: const Color(AppColors.dark),
          radius: AppSizes.s20,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s4),
            child: Center(child: FaIcon(icon, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
