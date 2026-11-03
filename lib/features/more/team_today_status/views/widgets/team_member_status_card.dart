import 'package:easy_localization/easy_localization.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/more/team_today_status/data/models/team_today_status_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

/// A single member card displayed in the team today status list.
class TeamMemberStatusCard extends StatelessWidget {
  final TeamMemberStatus member;

  const TeamMemberStatusCard({required this.member, super.key});

  // ── Status color & icon ──────────────────────────────────────────────────

  static Color _statusColor(String? status) {
    switch (status) {
      case 'present':
        return Color(AppColors.successGreen);
      case 'clocked_out':
        return Color(AppColors.helpBlue);
      case 'absent':
        return Color(AppColors.failureRed);
      case 'vacation':
        return Color(AppColors.warningYellow);
      case 'weekend':
        return Color(AppColors.tabInactive);
      default:
        return Color(AppColors.tabInactive);
    }
  }

  static IconData _statusIcon(String? status) {
    switch (status) {
      case 'present':
        return Icons.check_circle_outline_rounded;
      case 'clocked_out':
        return Icons.logout_rounded;
      case 'absent':
        return Icons.cancel_outlined;
      case 'vacation':
        return Icons.beach_access_rounded;
      case 'weekend':
        return Icons.weekend_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(member.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          _buildAvatar(statusColor),
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
                // Clock times row
                if (_hasTimes()) ...[
                  const SizedBox(height: 5),
                  _buildTimesRow(context),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Status badge ─────────────────────────────────────────────────
          _buildStatusBadge(statusColor),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildAvatar(Color borderColor) {
    final hasAvatar = member.avatar != null && member.avatar!.isNotEmpty;
    final initials = _initials(member.name);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ClipOval(
        child: hasAvatar
            ? CachedNetworkImage(
                imageUrl: member.avatar!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _initialsAvatar(initials, borderColor),
                placeholder: (_, __) => _initialsAvatar(initials, borderColor),
              )
            : _initialsAvatar(initials, borderColor),
      ),
    );
  }

  Widget _initialsAvatar(String initials, Color color) {
    return Container(
      color: color.withOpacity(0.12),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(member.status), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            (member.status ?? '-').tr(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimesRow(BuildContext context) {
    return Row(
      children: [
        if (member.clockInTime != null)
          _timeChip(Icons.login_rounded, member.clockInTime!, Colors.green.shade700),
        if (member.clockInTime != null && member.clockOutTime != null)
          const SizedBox(width: 8),
        if (member.clockOutTime != null)
          _timeChip(Icons.logout_rounded, member.clockOutTime!, Colors.red.shade700),
      ],
    );
  }

  Widget _timeChip(IconData icon, String time, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(time, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
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

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
