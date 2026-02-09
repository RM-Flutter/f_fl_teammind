import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/views/free_service/views/widgets/smart_card/widgets/select_template_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTeamMindScreen extends StatefulWidget {
  const AboutTeamMindScreen({super.key});

  @override
  State<AboutTeamMindScreen> createState() => _AboutTeamMindScreenState();
}

class _AboutTeamMindScreenState extends State<AboutTeamMindScreen> {
  final List<String> featureImages = [
    'Feature 1',
    'Feature 2',
    'Feature 3',
  ];

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
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
          onPressed: _goBack,
        ),
        title: AppStrings.aboutTeamMind.tr(),
        titleStyle: TextStyle(
          color: Color(AppColors.dark),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        routeName: AppRoutes.aboutTeamMindScreen.name,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    AppStrings.teamMindDescription.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(AppColors.black),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Feature Images Row
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildFeatureImagePlaceholder(AppStrings.templateImage.tr()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureImagePlaceholder(''),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFeatureImagePlaceholder(''),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Video Placeholder
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_outline, size: 50, color: Color(AppColors.lightGrey)),
                          const SizedBox(height: 8),
                          Text(
                            'فيديو',
                            style: TextStyle(
                              color: Color(AppColors.dark),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // More Feature Images
                  SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(AppColors.dark),
                borderRadius:  BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  // Contact Us Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _launchContactUs();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primary),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        AppStrings.contactUs.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Download Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _launchDownload();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primary),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        AppStrings.downloadProfile.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureImagePlaceholder(String text) {
    return InkWell(
      onTap: () {
        // Open full image
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(AppColors.dark),
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchContactUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@teammind.com',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchDownload() async {
    // Download profile or app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.downloadStarted.tr())),
    );
  }
}
