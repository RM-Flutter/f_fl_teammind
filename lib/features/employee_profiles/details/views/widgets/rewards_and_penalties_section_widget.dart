import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RewardsAndPenaltiesSectionWidget extends StatefulWidget {
  final EmployeeProfileModel? employee;
  const RewardsAndPenaltiesSectionWidget({super.key, required this.employee});

  @override
  State<RewardsAndPenaltiesSectionWidget> createState() =>
      _RewardsAndPenaltiesSectionWidgetState();
}

class _RewardsAndPenaltiesSectionWidgetState
    extends State<RewardsAndPenaltiesSectionWidget> {
  // 0 = all, 1 = rewards, 2 = penalties
  int _filter = 0;

  List<EmpRewardPenalty> get _items {
    final all = widget.employee?.rewardsAndPenalties ?? [];
    if (_filter == 1) return all.where((e) => e.type == 'reward').toList();
    if (_filter == 2) return all.where((e) => e.type == 'penalty').toList();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.employee?.rewardsAndPenalties ?? [];

    if (all.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(AppStrings.noDataFounded.tr()),
        ),
      );
    }

    final rewards = all.where((e) => e.type == 'reward').length;
    final penalties = all.where((e) => e.type == 'penalty').length;

    return Column(
      children: [
        gapH12,

        // ── Summary chips ─────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _SummaryChip(
              label: 'all'.tr(),
              count: all.length,
              isSelected: _filter == 0,
              color: Color(AppColors.buttons),
              onTap: () => setState(() => _filter = 0),
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: 'rewards'.tr(),
              count: rewards,
              isSelected: _filter == 1,
              color: const Color(0xFF2D6A4F),
              onTap: () => setState(() => _filter = 1),
            ),
            const SizedBox(width: 8),
            _SummaryChip(
              label: 'penalties'.tr(),
              count: penalties,
              isSelected: _filter == 2,
              color: const Color(0xFFC72C41),
              onTap: () => setState(() => _filter = 2),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: _items.isEmpty
              ? Center(child: Text(AppStrings.noDataFounded.tr()))
              : ListView.separated(
                  reverse: false,
                  padding: EdgeInsets.zero,
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _RewardPenaltyCard(item: _items[index]),
                ),
        ),
      ],
    );
  }
}

// ── Summary chip ──────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? color : color.withOpacity(0.25), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reward / Penalty card ─────────────────────────────────────────────────────
class _RewardPenaltyCard extends StatelessWidget {
  final EmpRewardPenalty item;
  const _RewardPenaltyCard({required this.item});

  bool get _isReward => item.type == 'reward';

  Color get _accentColor =>
      _isReward ? const Color(0xFF2D6A4F) : const Color(0xFFC72C41);

  IconData get _typeIcon =>
      _isReward ? Icons.star_rounded : Icons.warning_amber_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(color: _accentColor.withOpacity(0.15)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Color strip
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: type badge + action badge
                    Row(
                      children: [
                        // Type icon + label
                        Icon(_typeIcon, color: _accentColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          item.type?.tr().toUpperCase() ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        // Action badge
                        _ActionBadge(action: item.action),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Reason
                    if (item.reason?.isNotEmpty == true)
                      Text(
                        item.reason!,
                        style: AppStyles.blackContent(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Amount + Category + Due date row
                    Row(
                      children: [
                        // Amount pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _accentColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.category == 'days'
                                    ? Icons.calendar_month_rounded
                                    : Icons.attach_money_rounded,
                                size: 14,
                                color: _accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.category == 'days'
                                    ? '${item.amount} ${'days'.tr()}'
                                    : '${item.amount}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Due date
                        if (item.dueDate?.isNotEmpty == true)
                          Row(children: [
                            Icon(Icons.event_rounded,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              _fmt(item.dueDate),
                              style: AppStyles.greyContent(context)
                                  .copyWith(fontSize: 12),
                            ),
                          ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }
}

// ── Action badge ──────────────────────────────────────────────────────────────
class _ActionBadge extends StatelessWidget {
  final String? action;
  const _ActionBadge({this.action});

  Color get _bgColor {
    switch (action) {
      case 'approved':
        return const Color(0xFF2D6A4F);
      case 'applied':
        return const Color(0xFF3389EE);
      case 'waiting':
        return const Color(0xFFFCA652);
      case 'cancelled':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (action == null || action!.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bgColor.withOpacity(0.3)),
      ),
      child: Text(
        action!.tr().toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _bgColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
