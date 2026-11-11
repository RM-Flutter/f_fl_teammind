import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';

/// A pill used to pick one thing (a leg, an employee, a time range) in the tracking screens.
/// Selected: soft brand tint with a brand border; otherwise white with the field border.
/// [dotColor] adds the route colour in front of the label.
class TrackingChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;
  final IconData? icon;

  const TrackingChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    final tones = AppColors.statusTones(accent);
    return Material(
      color: selected ? tones.tint : Colors.white,
      shape: StadiumBorder(side: BorderSide(color: selected ? accent : AppField.borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpacing.sm),
              ] else if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? tones.text : AppField.iconColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? tones.text : AppField.iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontal row of [TrackingChoiceChip]s that scrolls past the page edge (page padding is on
/// the scroll view, layout rule 1).
class TrackingChipsRow extends StatelessWidget {
  final List<Widget> chips;
  final EdgeInsetsGeometry padding;
  const TrackingChipsRow({super.key, required this.chips, this.padding = AppSpacing.pagePadding});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            chips[i],
          ],
        ],
      ),
    );
  }
}
