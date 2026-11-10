import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/utils/string_extensions.dart';
import 'package:app_test/core/widgets/app_page_dots.widget.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_screen_shimmers.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';
import 'package:app_test/features/services/data/models/cv_template_model.dart';
import 'package:app_test/features/services/controllers/select_template_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_bar_with_bookmark.widget.dart';
import '../../../../core/widgets/app_content_width.widget.dart';
import 'package:app_test/core/constants/app_design.dart';

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
        backgroundColor: Color(AppColors.background),
        appBar: AppBarWithBookmark(
          backgroundColor: Color(AppColors.background),
          elevation: 0,
          leading: AppBackButton(onPressed: _goBack),
          title: AppStrings.selectTemplate.tr(),
          centerTitle: true,
          routeName: AppRoutes.selectTemplateScreen.name,
        ),
        body: Consumer<SelectTemplateViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const AppPagerShimmer();
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

            return AppContentWidth(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutService.isExpanded(context)
                        // Wide windows: all the templates at once, tap one to select it.
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                            child: AppResponsiveGrid(
                              expanded: 4,
                              children: [
                                for (var i = 0; i < templates.length; i++)
                                  GestureDetector(
                                    onTap: () => setState(() => selectedTemplateIndex = i),
                                    child: _buildTemplateCard(vm, templates[i], i),
                                  ),
                              ],
                            ),
                          )
                        : PageView.builder(
                            itemCount: templates.length,
                            onPageChanged: (index) => setState(() => selectedTemplateIndex = index),
                            itemBuilder: (context, index) {
                              return _buildTemplateCard(vm, templates[index], index);
                            },
                          ),
                  ),
                  if (!LayoutService.isExpanded(context))
                    AppPageDots(count: templates.length, index: selectedTemplateIndex),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: vm.isLoadingTemplate
                          ? null
                          : () => vm.onGenerateCv(context, templates[selectedTemplateIndex]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.buttons),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, AppButtonSize.height),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
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
                                fontSize: AppButtonSize.fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
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

    return Center(
      child: AspectRatio(
        aspectRatio: 1 / 1.35,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: isSelected ? Color(AppColors.buttons) : Color(AppColors.border),
            width: isSelected ? 1.5 : 1),
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg - 1)),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? (kIsWeb
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const ShimmerAnimatedLoading(circularRaduis: 0);
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => const ShimmerAnimatedLoading(circularRaduis: 0),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ))
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
                      template.slug!.replaceAll('_', ' ').titleCase,
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
          if (isDownloading && template.id != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadius.md),
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
    )));
  }
}
