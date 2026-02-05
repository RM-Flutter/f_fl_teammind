import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_images.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';

class PremiumTemplatesScreen extends StatefulWidget {
  const PremiumTemplatesScreen({super.key});

  @override
  State<PremiumTemplatesScreen> createState() => _PremiumTemplatesScreenState();
}

class _PremiumTemplatesScreenState extends State<PremiumTemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedFileType;

  final List<Map<String, String>> templates = [
    {'type': 'File Types', 'name': 'File nameFile nameFile nameFile nameFile name'},
    {'type': 'File Types', 'name': 'File nameFile nameFile nameFile nameFile name'},
    {'type': 'File Types', 'name': 'File nameFile nameFile nameFile nameFile name'},
    {'type': 'File Types', 'name': 'File nameFile nameFile nameFile nameFile name'},
    {'type': 'File Types', 'name': 'File nameFile nameFile nameFile nameFile name'},
    {'type': 'File Types', 'name': 'File nameFile nameFile nameFile nameFile name'},
    {'type': 'File Types', 'name': 'File nameFile nameFile nameFile nameFile name'},
  ];

  final List<String> fileTypes = ['All', 'PDF', 'Word', 'Excel', 'PowerPoint'];

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Text(
                    AppStrings.filter.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff09051C),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // File Type Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(AppStrings.fileType.tr(), style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400)),
                        value: selectedFileType,
                        items: fileTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type, style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedFileType = value;
                          });
                          setState(() {
                            selectedFileType = value;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Filter Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Apply filter logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.dark),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(150, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(AppStrings.filter.tr(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: AppStrings.premiumTemplates2.tr(),
        titleStyle: TextStyle(
          color: Color(AppColors.dark),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        routeName: AppRoutes.premiumTemplatesScreen.name,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: AppStrings.searchByName.tr(),
                        fillColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: (){
                              _searchController.clear();
                            }
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(AppSizes.s8)),
                  ),
                ),

                IconButton(
                  icon: Image.asset(
                    AppImages.profileFilter,
                    width: AppSizes.s22,
                    height: AppSizes.s22,
                    fit: BoxFit.cover,
                  ),
                  onPressed: _showFilterBottomSheet,
                ),
              ],
            ),
          ),
          
          // Templates List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return _buildTemplateCard(templates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, String> template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Template Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Template Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template['type']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  template['name']!,
                  style: TextStyle(
                    color: Color(AppColors.dark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
