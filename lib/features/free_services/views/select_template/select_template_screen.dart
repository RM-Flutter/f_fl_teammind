import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/modules/free_services/views/premium_templates/premium_templates_screen.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';

class SelectTemplateScreen extends StatefulWidget {
  const SelectTemplateScreen({super.key});

  @override
  State<SelectTemplateScreen> createState() => _SelectTemplateScreenState();
}

class _SelectTemplateScreenState extends State<SelectTemplateScreen> {
  int selectedTemplateIndex = 0;
  
  final List<String> templates = [
    'Template 1',
    'Template 2',
    'Template 3',
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
        title: AppStrings.cvGenerator2.tr(),
        titleStyle: TextStyle(
          color: Color(AppColors.dark),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        routeName: AppRoutes.selectTemplateScreen.name,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          
          // Title
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PremiumTemplatesScreen(),));
            },
            child: Text(
              AppStrings.selectTemplate.tr(),
              style: TextStyle(
                color: Color(AppColors.dark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Templates Carousel
          Expanded(
            child: PageView.builder(
              itemCount: templates.length,
              onPageChanged: (index) {
                setState(() {
                  selectedTemplateIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    border: selectedTemplateIndex == index
                        ? Border.all(color: Color(AppColors.primary), width: 3)
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.templateImage.tr(),
                          style: TextStyle(
                            color: Color(AppColors.dark),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppStrings.templateDescription.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(AppColors.dark),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(templates.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedTemplateIndex == index
                      ? Color(AppColors.primary)
                      : Colors.grey[400],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 24),
          
          // Update Button
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Update/Select template
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.templateSelected.tr().replaceAll('{number}', '${selectedTemplateIndex + 1}'))),
                );
                _goBack();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.dark),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                AppStrings.update.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
