import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/controllers/smart_card_view_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/repos/repo/smart_card_repo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SelectSmartCardTemplateScreen extends StatefulWidget {
  final bool isPersonal;
  final int? companyId;
  const SelectSmartCardTemplateScreen({
    super.key,
    required this.isPersonal,
    this.companyId,
  });

  @override
  State<SelectSmartCardTemplateScreen> createState() => _SelectSmartCardTemplateScreenState();
}

class _SelectSmartCardTemplateScreenState extends State<SelectSmartCardTemplateScreen> {
  int selectedTemplateIndex = 0;
  bool _isSaving = false;

  // Colors state
  Color primaryColor = const Color(0xFF244B78);
  Color secondaryColor = const Color(0xFFF5F5F5);
  Color thirdColor = const Color(0xFF000000);

  final List<Color> colorOptions = [
    const Color(0xFF244B78), // Dark Blue
    const Color(0xFF000000), // Black
    const Color(0xFFE53935), // Red
    const Color(0xFF43A047), // Green
    const Color(0xFF8E24AA), // Purple
    const Color(0xFFF5F5F5), // Light Grey
    const Color(0xFFFFB300), // Amber
    const Color(0xFF1E88E5), // Light Blue
  ];

  @override
  void initState() {
    super.initState();
  }

  void _goBack() {
    try {
      GoRouter.of(context).pop(true);
    } catch (e) {
      Navigator.of(context).pop(true);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  Future<void> _handleSelectTemplate(Map<String, dynamic> template) async {
    final templateId = template['id'] as int?;
    if (templateId == null) return;

    final templateData = {
      'primary_color': _colorToHex(primaryColor),
      'secondary_color': _colorToHex(secondaryColor),
      'third_color': _colorToHex(thirdColor),
    };

    setState(() => _isSaving = true);
    try {
      if (widget.isPersonal) {
        await SmartCardRepo.updateEmployeeTemplate(
          context,
          templateId: templateId,
          templateData: templateData,
        );
      } else {
        if (widget.companyId == null) {
          throw Exception('Company ID is required');
        }
        await SmartCardRepo.updateCompanyTemplate(
          context,
          companyId: widget.companyId!,
          templateId: templateId,
          templateData: templateData,
        );
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.updatedSuccessfully.tr())),
      );
      
      try {
        GoRouter.of(context).pop(true);
      } catch (e) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildColorSelector(String label, Color selectedColor, Function(Color) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: colorOptions.length,
            itemBuilder: (context, index) {
              final color = colorOptions[index];
              final isSelected = color == selectedColor;
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SmartCardViewModel()..loadTemplates(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWithBookmark(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryButton),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
            onPressed: _goBack,
          ),
          title: AppStrings.selectTemplate.tr(),
          titleStyle: TextStyle(
            color: Color(AppColors.secondaryButton),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          routeName: 'selectSmartCardTemplateScreen',
        ),
        body: Consumer<SmartCardViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.buttons)),
                ),
              );
            }

            if (vm.errorMessage != null && vm.templates.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.loadTemplates(context),
                      child: Text(AppStrings.retry.tr()),
                    ),
                  ],
                ),
              );
            }

            final templates = vm.templates;

            if (templates.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noDataFounded.tr(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: PageView.builder(
                    itemCount: templates.length,
                    onPageChanged: (index) => setState(() => selectedTemplateIndex = index),
                    itemBuilder: (context, index) {
                      return _buildTemplateCard(templates[index], index);
                    },
                  ),
                ),
                const SizedBox(height: 12),
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
                            ? Color(AppColors.buttons)
                            : Colors.grey[400],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                
                // Colors selection section
                _buildColorSelector("Primary Color", primaryColor, (c) => setState(() => primaryColor = c)),
                _buildColorSelector("Secondary Color", secondaryColor, (c) => setState(() => secondaryColor = c)),
                _buildColorSelector("Third Color", thirdColor, (c) => setState(() => thirdColor = c)),
                
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _handleSelectTemplate(templates[selectedTemplateIndex]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.secondaryButton),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppStrings.confirm.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template, int index) {
    String? imageUrl;
    if (template['image'] is List && (template['image'] as List).isNotEmpty) {
      final imgMap = template['image'][0];
      if (imgMap is Map) {
        imageUrl = (imgMap['file'] ?? imgMap['thumbnail'])?.toString();
      }
    } else if (template['image'] is String) {
      imageUrl = template['image'] as String;
    }
    
    final isSelected = selectedTemplateIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Color(AppColors.buttons), width: 3)
            : Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Color(AppColors.buttons),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              if (template['slug'] != null && template['slug'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      template['slug'].toString(),
                      style: TextStyle(
                        color: Color(AppColors.secondaryButton),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
