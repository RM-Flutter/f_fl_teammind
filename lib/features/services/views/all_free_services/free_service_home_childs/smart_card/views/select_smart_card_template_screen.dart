import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_page_dots.widget.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_screen_shimmers.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/controllers/smart_card_view_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/repos/repo/smart_card_repo.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_design.dart';

class SelectSmartCardTemplateScreen extends StatefulWidget {
  final bool isPersonal;
  final int? companyId;

  /// The template_id currently saved on the profile (from API response).
  final int? initialTemplateId;

  /// The template_data currently saved on the profile (from API response).
  /// e.g. {'primary_color': '#112233', 'secondary_color': '#445566', 'third_color': '#778899'}
  final Map<String, dynamic>? initialTemplateData;

  const SelectSmartCardTemplateScreen({
    super.key,
    required this.isPersonal,
    this.companyId,
    this.initialTemplateId,
    this.initialTemplateData,
  });

  @override
  State<SelectSmartCardTemplateScreen> createState() =>
      _SelectSmartCardTemplateScreenState();
}

class _SelectSmartCardTemplateScreenState
    extends State<SelectSmartCardTemplateScreen> {
  late PageController _pageController;
  int selectedTemplateIndex = 0;

  /// Guard so we only jump to the initial template once after templates load.
  bool _initialJumpDone = false;

  bool _isSaving = false;

  // ── Colors state ────────────────────────────────────────────────────────
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

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Parse '#RRGGBB' / '#AARRGGBB' into a Flutter [Color].
  Color? _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      final value = int.tryParse('FF$clean', radix: 16);
      return value != null ? Color(value) : null;
    } else if (clean.length == 8) {
      final value = int.tryParse(clean, radix: 16);
      return value != null ? Color(value) : null;
    }
    return null;
  }

  /// Find the closest color in [colorOptions] to [target] (by hex equality).
  Color _closestColor(Color target) {
    final targetHex = _colorToHex(target).toUpperCase();
    for (final c in colorOptions) {
      if (_colorToHex(c).toUpperCase() == targetHex) return c;
    }
    return target; // keep custom color if not in palette
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Pre-fill colors from initialTemplateData when available.
    final data = widget.initialTemplateData;
    if (data != null) {
      final pc = _parseHex(data['primary_color']?.toString());
      final sc = _parseHex(data['secondary_color']?.toString());
      final tc = _parseHex(data['third_color']?.toString());
      if (pc != null) primaryColor = _closestColor(pc);
      if (sc != null) secondaryColor = _closestColor(sc);
      if (tc != null) thirdColor = _closestColor(tc);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Jump to initial template once templates are loaded ───────────────────

  void _maybeJumpToInitialTemplate(List<Map<String, dynamic>> templates) {
    if (_initialJumpDone || widget.initialTemplateId == null) {
      _initialJumpDone = true;
      return;
    }
    final idx = templates.indexWhere(
      (t) {
        final tid = t['id'] != null ? int.tryParse(t['id'].toString()) : null;
        return tid == widget.initialTemplateId;
      },
    );
    if (idx >= 0 && idx != selectedTemplateIndex) {
      // Jump instantly to the previously selected template.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(idx);
        }
        setState(() => selectedTemplateIndex = idx);
      });
    }
    _initialJumpDone = true;
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void _goBack() {
    try {
      GoRouter.of(context).pop(true);
    } catch (e) {
      Navigator.of(context).pop(true);
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────

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
      final msg =
          e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Color Selector Widget ─────────────────────────────────────────────────

  Widget _buildColorSelector(
      String label, Color selectedColor, Function(Color) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.heading(context)
              .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Equal gaps, so the swatches always fit the card and never run off the edge.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final color in colorOptions)
              _swatch(color, color == selectedColor, () => onSelect(color)),
          ],
        ),
      ],
    );
  }

  Widget _swatch(Color color, bool isSelected, VoidCallback onTap) {
    final ring = Color(AppColors.buttons);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        width: 34,
        height: 34,
        padding: const EdgeInsets.all(AppSizes.s3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: isSelected ? ring : Colors.transparent, width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: isSelected
              ? Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                )
              : null,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SmartCardViewModel()..loadTemplates(context),
      child: Scaffold(
        backgroundColor: Color(AppColors.background),
        appBar: AppBarWithBookmark(
          backgroundColor: Color(AppColors.background),
          elevation: 0,
          leading: AppBackButton(onPressed: _goBack),
          title: AppStrings.selectTemplate.tr(),
          centerTitle: true,
          routeName: 'selectSmartCardTemplateScreen',
        ),
        body: Consumer<SmartCardViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const AppPagerShimmer();
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
                    const SizedBox(height: AppSizes.s16),
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
                    const SizedBox(height: AppSizes.s16),
                    Text(
                      AppStrings.noDataFounded.tr(),
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            // Once templates are loaded, jump to the pre-selected template.
            _maybeJumpToInitialTemplate(templates);

            return Column(
              children: [
                const SizedBox(height: AppSizes.s16),
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
                                  child: _buildTemplateCard(templates[i], i),
                                ),
                            ],
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: templates.length,
                          onPageChanged: (index) =>
                              setState(() => selectedTemplateIndex = index),
                          itemBuilder: (context, index) {
                            return _buildTemplateCard(templates[index], index);
                          },
                        ),
                ),
                const SizedBox(height: AppSizes.s12),
                if (!LayoutService.isExpanded(context))
                  AppPageDots(count: templates.length, index: selectedTemplateIndex),
                const SizedBox(height: AppSizes.s16),

                // Colors selection section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: AppCard(
                    child: Column(
                      children: [
                        _buildColorSelector(
                    AppStrings.primaryColor.tr(),
                    primaryColor,
                    (c) => setState(() => primaryColor = c)),
                        const SizedBox(height: AppSpacing.lg),
                        _buildColorSelector(
                    AppStrings.secondaryColor.tr(),
                    secondaryColor,
                    (c) => setState(() => secondaryColor = c)),
                        const SizedBox(height: AppSpacing.lg),
                        _buildColorSelector(
                    AppStrings.thirdColor.tr(),
                    thirdColor,
                    (c) => setState(() => thirdColor = c)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSizes.s16),
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _handleSelectTemplate(
                            templates[selectedTemplateIndex]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, AppButtonSize.height),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: AppSizes.s20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
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

  // ── Template Card ─────────────────────────────────────────────────────────

  Widget _buildTemplateCard(Map<String, dynamic> template, int index) {
    String? imageUrl;
    final dynamic imageSource = template['images'] ?? template['image'];
    if (imageSource is List && imageSource.isNotEmpty) {
      final imgMap = imageSource[0];
      if (imgMap is Map) {
        imageUrl = imgMap['file']?.toString();
      }
    } else if (imageSource is String) {
      imageUrl = imageSource;
    }

    final isSelected = selectedTemplateIndex == index;

    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s8),
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(AppRadius.lg - 1)),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const ShimmerAnimatedLoading(circularRaduis: 0);
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
              if (template['slug'] != null &&
                  template['slug'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSizes.s12),
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
    )));
  }
}
