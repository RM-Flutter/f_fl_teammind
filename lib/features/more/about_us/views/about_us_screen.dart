import 'dart:convert';

import 'package:app_test/core/constants/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../../core/widgets/custom_elevated_button.widget.dart';
import '../../contact_us/controllers/contact_us_controller.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  var gCache;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ContactUsController(),
      child: Consumer<ContactUsController>(
        builder: (context, values, child) {
          final jsonString = CacheHelper.getString("USG");
          if (jsonString != null) {
            gCache = json.decode(jsonString) as Map<String, dynamic>;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Custom Header
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppSizes.s40),
                          bottomRight: Radius.circular(AppSizes.s40),
                        ),
                        child: Image.asset(
                          "assets/images/png/tasks-app-bar.png",
                          width: double.infinity,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 15,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 15,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            AppStrings.aboutApplication.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 70,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            "assets/images/team-mind-logo.png",
                            // height: 100,
                            // fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Description Content
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Text(
                      AppStrings.aboutAppDescription.tr(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // FOLLOW US section
                  Text(
                    AppStrings.followUs.tr().toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Social Icons Row
                  if (gCache != null && gCache['company_contacts'] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (gCache['company_contacts']['whatsapp'] != null && gCache['company_contacts']['whatsapp'] != "")
                            _buildSocialIcon("assets/images/svg/whatsapp.svg", () => launchUrl(Uri.parse(gCache['company_contacts']['whatsapp']))),
                          if (gCache['company_contacts']['linkedin'] != null && gCache['company_contacts']['linkedin'] != "")
                            _buildSocialIcon("assets/images/svg/linkedin.svg", () => launchUrl(Uri.parse(gCache['company_contacts']['linkedin']))),
                          if (gCache['company_contacts']['youtube'] != null && gCache['company_contacts']['youtube'] != "")
                            _buildSocialIcon("assets/images/svg/youtube.svg", () => launchUrl(Uri.parse(gCache['company_contacts']['youtube']))),
                          if (gCache['company_contacts']['instagram'] != null && gCache['company_contacts']['instagram'] != "")
                            _buildSocialIcon("assets/images/svg/instagram.svg", () => launchUrl(Uri.parse(gCache['company_contacts']['instagram']))),
                          if (gCache['company_contacts']['facebook'] != null && gCache['company_contacts']['facebook'] != "")
                            _buildSocialIcon("assets/images/svg/facebook.svg", () => launchUrl(Uri.parse(gCache['company_contacts']['facebook']))),
                          if (gCache['company_contacts']['twitter'] != null && gCache['company_contacts']['twitter'] != "")
                            _buildSocialIcon("assets/images/svg/twitter.svg", () => launchUrl(Uri.parse(gCache['company_contacts']['twitter']))),
                        ],
                      ),
                    ),
                   const SizedBox(height: 40),

                  // SEND BY EMAIL button
                  if (gCache != null && gCache['company_contacts'] != null && gCache['company_contacts']['email'] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: CustomElevatedButton(
                        backgroundColor:  Theme.of(context).colorScheme.secondary,
                        title: AppStrings.sendByEmail.tr().toUpperCase(),
                        onPressed: () async {
                          values.sendMailToCompany(
                            context: context,
                            email: gCache['company_contacts']['email'],
                            subject: null,
                            body: null,
                          );
                        },
                        // isPrimaryBackground: true, // Uses secondary color
                      ),
                    ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialIcon(String ico, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:  Theme.of(context).colorScheme.secondary,
        ),
        child: SvgPicture.asset(ico, color: Colors.white),
      ),
    );
  }
}
