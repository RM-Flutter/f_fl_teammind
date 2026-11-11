import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

/// Pieces of every "details" bottom sheet (Penalty Info, Reward Info, Commission Details ...), so
/// they all look the same and differ only by colour and icon.

/// Top of the sheet: a coloured icon circle, the name, a small line under it and an optional
/// status badge.
class AppDetailsHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String? badgeLabel;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const AppDetailsHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.badgeLabel,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tones = AppColors.statusTones(color);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tones.tint,
              border: Border.all(color: tones.ring, width: 1.5),
            ),
            child: Icon(icon, color: tones.text, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppStyles.heading(context)),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(subtitle!, style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
              ],
            ),
          ),
          if (badgeLabel != null) ...[
            const SizedBox(width: AppSpacing.sm),
            AppStatusBadge(label: badgeLabel!, color: badgeColor ?? color),
          ],
        ],
      ),
    );
  }
}

/// The one number that matters (amount, hours), big and centred, with a small line under it.
class AppDetailsHighlight extends StatelessWidget {
  final String value;
  final String? caption;
  final Color color;

  const AppDetailsHighlight({super.key, required this.value, this.caption, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppStyles.heading(context)
              .copyWith(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.statusTones(color).text),
        ),
        if (caption != null && caption!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(caption!, textAlign: TextAlign.center, style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
        ],
      ],
    );
  }
}

/// A card of [AppInfoRow]s with dividers between them.
class AppInfoCard extends StatelessWidget {
  final List<Widget> rows;
  const AppInfoCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: Color(AppColors.divider)),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// "Label ........ Value": the label is grey at the start, the value is bold at the end. A long
/// value (a reason, a note) wraps under the label.
class AppInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const AppInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppStyles.greyContent(context).copyWith(fontSize: 13);
    final valueStyle = AppStyles.heading(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: value.length > 32
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(label, style: labelStyle), const SizedBox(height: 4), Text(value, style: valueStyle)],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(value, textAlign: TextAlign.end, style: valueStyle)),
              ],
            ),
    );
  }
}

/// The buttons at the bottom of a details sheet: a navy main action and a red outlined danger
/// action (cancel), the same height and text as every other button.
class AppSheetActions extends StatelessWidget {
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? dangerLabel;
  final VoidCallback? onDanger;

  const AppSheetActions({super.key, this.primaryLabel, this.onPrimary, this.dangerLabel, this.onDanger});

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: AppRadius.button);
    const text = TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600);
    final buttons = <Widget>[
      if (primaryLabel != null)
        Expanded(
          child: SizedBox(
            height: AppButtonSize.height,
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.secondaryButton),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: shape,
              ),
              child: Text(primaryLabel!, style: text),
            ),
          ),
        ),
      if (primaryLabel != null && dangerLabel != null) const SizedBox(width: AppSpacing.md),
      if (dangerLabel != null)
        Expanded(
          child: SizedBox(
            height: AppButtonSize.height,
            child: OutlinedButton(
              onPressed: onDanger,
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(AppColors.failureRed),
                side: BorderSide(color: Color(AppColors.failureRed)),
                shape: shape,
              ),
              child: Text(dangerLabel!, style: text),
            ),
          ),
        ),
    ];
    return Row(children: buttons);
  }
}
