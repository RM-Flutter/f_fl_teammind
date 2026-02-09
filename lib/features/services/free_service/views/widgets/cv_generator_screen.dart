import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/free_service/views/widgets/smart_card/widgets/select_template_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CVGeneratorScreen extends StatefulWidget {
  const CVGeneratorScreen({super.key});

  @override
  State<CVGeneratorScreen> createState() => _CVGeneratorScreenState();
}

class _CVGeneratorScreenState extends State<CVGeneratorScreen> {
  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  void _navigateTo(String routeName) {
    try {
      GoRouter.of(context).pushNamed(
        routeName,
        pathParameters: {'lang': context.locale.languageCode},
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
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
        title: AppStrings.cvGenerator2.tr(),
        titleStyle: TextStyle(
          color: Color(AppColors.dark),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        routeName: AppRoutes.cvGeneratorScreen.name,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Description Text
                  Text(
                    AppStrings.cvGeneratorDescription.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // UPDATE INFO Button
                  ElevatedButton(
                    onPressed: () => _navigateTo(AppRoutes.updateMyInfoScreen.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.dark),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      AppStrings.updateInfo.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Color(AppColors.dark),
                borderRadius: BorderRadius.circular(35)
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // NEXT Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SelectTemplateScreen(),));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(AppColors.dark),
                        side: const BorderSide(color: Colors.transparent, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        AppStrings.next.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // SELECT CV TEMPLATE Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SelectTemplateScreen(),));
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
                        AppStrings.selectCvTemplate.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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
}
