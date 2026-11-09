import 'package:go_router/go_router.dart';
import 'package:app_test/core/routing/app_router.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/more/team_today_status/controller/team_today_status_controller.dart';
import 'package:app_test/features/more/team_today_status/data/models/team_today_status_model.dart';
import 'package:app_test/features/more/team_today_status/views/widgets/team_member_status_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_design.dart';

class TeamTodayStatusScreen extends StatefulWidget {
  const TeamTodayStatusScreen({super.key});

  @override
  State<TeamTodayStatusScreen> createState() => _TeamTodayStatusScreenState();
}

class _TeamTodayStatusScreenState extends State<TeamTodayStatusScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filter chip definitions: key → display label
  List<_FilterOption> get _filters => [
    _FilterOption('all', 'all'.tr()),
    _FilterOption('present', 'present'.tr()),
    _FilterOption('clocked_out', 'clocked_out'.tr()),
    _FilterOption('absent', 'absent'.tr()),
    _FilterOption('vacation', 'on_leave'.tr()),
    _FilterOption('weekend', 'weekend'.tr()),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          TeamTodayStatusController()..fetchTeamStatus(context),
      child: Consumer<TeamTodayStatusController>(
        builder: (context, controller, _) {
          return TemplatePage(
            pageContext: context,
            title: AppStrings.teamTodayStatus.tr(),
            onRefresh: () async => controller.fetchTeamStatus(context),
            body: Center(
              child: ConstrainedBox(
                constraints: LayoutService.contentConstraints(context),
                child: controller.isLoading
                    ? const _LoadingShimmer()
                    : controller.errorMessage != null && controller.data == null
                        ? _ErrorView(
                            message: controller.errorMessage!,
                            onRetry: () => controller.fetchTeamStatus(context),
                          )
                        : _Content(
                            controller: controller,
                            searchController: _searchController,
                            filters: _filters,
                          ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Main content ─────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  final TeamTodayStatusController controller;
  final TextEditingController searchController;
  final List<_FilterOption> filters;

  const _Content({
    required this.controller,
    required this.searchController,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    final members = controller.filteredMembers;

    return Column(
      children: [
        // ── Summary cards ──────────────────────────────────────────────────
        if (controller.data?.summary != null)
          _SummaryRow(summary: controller.data!.summary!),
        const SizedBox(height: 16),

        // ── Search bar ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SearchBar(
            controller: searchController,
            onChanged: (q) => controller.setSearch(q),
          ),
        ),
        const SizedBox(height: 12),

        // ── Filter chips ───────────────────────────────────────────────────
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final f = filters[i];
              final selected = controller.selectedFilter == f.key;
              return _FilterChip(
                label: f.label,
                selected: selected,
                onTap: () => controller.setFilter(f.key),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // ── Member list ────────────────────────────────────────────────────
        if (members.isEmpty)
          NoExistingPlaceholderScreen(
            height: 0.5.sh,
            title: 'no_members_found'.tr(),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
            itemBuilder: (_, i) => InkWell(
                  onTap: () async {
                    if (members[i].id != null) {
                      await context.pushNamed(AppRoutes.employeeDetails.name,
                          pathParameters: {
                            'id': members[i].id.toString(),
                            'lang': context.locale.languageCode
                          });
                    }
                  },
                  child: TeamMemberStatusCard(member: members[i]),
                ),
          ),
      ],
    );
  }
}

// ── Summary Row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final TeamStatusSummary summary;

  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _SummaryCard(
            label: 'present'.tr(),
            count: summary.present,
            color: Color(AppColors.successGreen),
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'absent'.tr(),
            count: summary.absent,
            color: Color(AppColors.failureRed),
            icon: Icons.cancel_outlined,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'on_leave'.tr(),
            count: summary.vacation,
            color: Color(AppColors.warningYellow),
            icon: Icons.beach_access_rounded,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'weekend'.tr(),
            count: summary.weekend,
            color: Color(AppColors.tabInactive),
            icon: Icons.weekend_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'search_by_name'.tr(),
        hintStyle: AppStyles.subtitleContent(context)
            .copyWith(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon:
            Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded,
                    color: Colors.grey.shade400, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Color(AppColors.inputFill),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: Color(AppColors.inputBorder)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: Color(AppColors.inputBorder)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide:
              BorderSide(color: Color(AppColors.secondaryButton), width: 1.5),
        ),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Color(AppColors.secondaryButton)
              : Color(AppColors.inputFill),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected
                ? Color(AppColors.secondaryButton)
                : Color(AppColors.inputBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Color(AppColors.bodyText),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Loading Shimmer ──────────────────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // summary skeleton
          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // search skeleton
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
          const SizedBox(height: 16),
          // list skeletons
          ...List.generate(
            6,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: Color(AppColors.failureRed)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppStyles.subtitleContent(context)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('retry'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.buttons),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ───────────────────────────────────────────────────────────────

class _FilterOption {
  final String key;
  final String label;

  const _FilterOption(this.key, this.label);
}
