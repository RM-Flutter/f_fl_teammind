import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:app_test/features/more/team_today_status/data/models/team_today_status_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A single member card displayed in the team today status list.
class TeamMemberStatusCard extends StatelessWidget {
  final TeamMemberStatus member;

  const TeamMemberStatusCard({required this.member, super.key});

  // ── Status color & icon ──────────────────────────────────────────────────

  static Color _statusColor(String? status) =>
      AppStatusBadge.colorForStatus((status ?? '').toLowerCase());

  static IconData _statusIcon(String? status) =>
      AppStatusBadge.iconForStatus((status ?? '').toLowerCase());

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(member.status);

    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          AppCardLeadingAvatar(
            imageUrl: member.avatar,
            nameForInitials: member.name,
            borderColor: statusColor,
          ),
          const SizedBox(width: 12),

          // ── Name + meta ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name ?? '-',
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitle(),
                  style: AppStyles.subtitleContent(context).copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_hasTimes()) ...[
                  const SizedBox(height: 5),
                  _buildTimesRow(context),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Status badge ─────────────────────────────────────────────────
          AppStatusBadge(
            label: (member.status ?? '-').tr(),
            color: statusColor,
            icon: _statusIcon(member.status),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildTimesRow(BuildContext context) {
    return Row(
      children: [
        if (member.clockInTime != null)
          _timeChip(
              Icons.login_rounded, member.clockInTime!, Colors.green.shade700),
        if (member.clockInTime != null && member.clockOutTime != null)
          const SizedBox(width: 8),
        if (member.clockOutTime != null)
          _timeChip(
              Icons.logout_rounded, member.clockOutTime!, Colors.red.shade700),
      ],
    );
  }

  Widget _timeChip(IconData icon, String time, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(time,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _subtitle() {
    final parts = <String>[];
    if (member.jobTitle != null && member.jobTitle!.isNotEmpty) {
      parts.add(member.jobTitle!);
    }
    if (member.department != null && member.department!.isNotEmpty) {
      parts.add(member.department!);
    }
    if (member.vacationTitle != null && member.vacationTitle!.isNotEmpty) {
      parts.add(member.vacationTitle!);
    }
    return parts.join(' · ');
  }

  bool _hasTimes() =>
      member.clockInTime != null || member.clockOutTime != null;
}
