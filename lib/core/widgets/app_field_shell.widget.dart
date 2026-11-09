import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_design.dart';

/// The box of every dropdown / picker field (rule 15). Same height, corners, border and
/// padding as a text field, with the optional trailing icon always the same size, colour and
/// distance from the edge. Pass [trailingIcon] for a plain icon, or put the icon inside [child]
/// when the child must be tappable up to the edge (a [DropdownButton]).
class AppFieldShell extends StatelessWidget {
  final Widget child;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final double? height;

  const AppFieldShell({
    super.key,
    required this.child,
    this.trailingIcon,
    this.onTap,
    this.height,
  });

  /// The icon used by every field's end: always this size and colour.
  static Icon icon(IconData data) =>
      Icon(data, size: AppField.iconSize, color: AppField.iconColor);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: AppField.borderRadius,
        side: BorderSide(color: AppField.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height ?? AppField.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppField.horizontalPadding),
            child: Row(
              children: [
                Expanded(child: Align(alignment: AlignmentDirectional.centerStart, child: child)),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  icon(trailingIcon!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
