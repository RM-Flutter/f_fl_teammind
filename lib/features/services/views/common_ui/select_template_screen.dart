import 'package:app_test/features/services/data/models/cv_template_model.dart';
import 'package:app_test/features/services/controllers/select_template_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar_with_bookmark.widget.dart';

class SelectTemplateScreen extends StatefulWidget {
  const SelectTemplateScreen({super.key});

  @override
  State<SelectTemplateScreen> createState() => _SelectTemplateScreenState();
}

class _SelectTemplateScreenState extends State<SelectTemplateScreen> {
  late SelectTemplateViewModel viewModel;
  int selectedTemplateIndex = 0;

  @override
  void initState() {
    super.initState();
    viewModel = SelectTemplateViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchTemplates(context, itemsCount: 200);
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SelectTemplateViewModel>.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWithBookmark(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.titleText),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
            onPressed: _goBack,
          ),
          title: AppStrings.selectTemplate.tr(),
          titleStyle: TextStyle(
            color: Color(AppColors.titleText),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          routeName: AppRoutes.selectTemplateScreen.name,
        ),
        body: Consumer<SelectTemplateViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      vm.errorMessage!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.fetchTemplates(context, itemsCount: 200),
                      child: Text(AppStrings.retry.tr()),
                    ),
                  ],
                ),
              );
            }

            final templates = vm.templates ?? [];

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
                      return _buildTemplateCard(vm, templates[index], index);
                    },
                  ),
                ),
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
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: vm.isLoadingTemplate
                        ? null
                        : () => vm.onGenerateCv(context, templates[selectedTemplateIndex]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.titleText),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: vm.isLoadingTemplate
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            AppStrings.generateCvWithTemplate.tr(),
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

  Widget _buildTemplateCard(
    SelectTemplateViewModel vm,
    CvTemplateModel template,
    int index,
  ) {
    final imageUrl = template.imageUrl;
    final isSelected = selectedTemplateIndex == index;
    final isDownloading =
        template.id != null && vm.downloadProgress.containsKey(template.id);

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
              if (template.slug != null && template.slug!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      template.slug!,
                      style: TextStyle(
                        color: Color(AppColors.titleText),
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
          if (isDownloading && template.id != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: vm.downloadProgress[template.id],
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.buttons)),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${((vm.downloadProgress[template.id] ?? 0) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
