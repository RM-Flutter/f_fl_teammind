import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/views/common_ui/select_template_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_design.dart';

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
      backgroundColor: Color(AppColors.background),
      appBar: AppBarWithBookmark(
        backgroundColor: Color(AppColors.background),
        elevation: 0,
        leading: AppBackButton(onPressed: _goBack),
        title: AppStrings.cvGenerator2.tr(),
        centerTitle: true,
        routeName: AppRoutes.cvGeneratorScreen.name,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.s24),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.s60),
                  
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
                  
                  const SizedBox(height: AppSizes.s24),
                  
                  // UPDATE INFO Button
                  ElevatedButton(
                    onPressed: () => _navigateTo(AppRoutes.myCVScreen.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Color(AppColors.secondaryButton),
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s32, vertical: AppSizes.s14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    child: Text(
                      AppStrings.updateInfo.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.only(bottom: AppSizes.s20, right: AppSizes.s10, left: AppSizes.s10),
            child: Container(
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryButton),
                borderRadius: BorderRadius.circular(AppRadius.xl)
              ),
              padding: const EdgeInsets.all(AppSizes.s16),
              child: Row(
                children: [
                  // NEXT Text
                  Expanded(
                    child: Center(
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

                  const SizedBox(width: AppSizes.s12),

                  // SELECT CV TEMPLATE Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SelectTemplateScreen(),));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.buttons),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.s16),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
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
