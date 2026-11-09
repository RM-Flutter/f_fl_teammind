import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_design.dart';
import '../utils/app_styles.dart';

/// The standard card of the app (matching `TeamMemberStatusCard`):
/// - White background
/// - 12px corners (`AppRadius.md`)
/// - 1px grey border (`Colors.grey.withOpacity(0.12)`)
/// - Soft 3% black shadow (`blurRadius: 6, offset: Offset(0, 2)`)
/// - `horizontal: 14, vertical: 12` default padding
///
/// Use [AppCard] or [AppCard.listItem] instead of hand-made Container/BoxDecoration cards
/// so every screen in the app matches.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? radius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = AppSpacing.cardPadding,
    this.margin,
    this.color,
    this.radius,
    this.border,
    this.boxShadow,
  });

  /// Builds a standardized list-item card matching the `TeamMemberStatusCard` layout:
  /// Leading circular avatar (`46x46` with `2px` colored border) + Title (`14px w600`) +
  /// Subtitle (`11px grey.shade600`) + optional extra content + Trailing status badge/action.
  factory AppCard.listItem({
    Key? key,
    required BuildContext context,
    required String title,
    String? subtitle,
    String? thirdLine,
    Widget? extraContent,
    Widget? leading,
    String? avatarUrl,
    String? avatarInitialsText,
    IconData? leadingIcon,
    Color? accentColor,
    Widget? trailing,
    List<Widget>? topBadges,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry padding = AppSpacing.cardPadding,
    EdgeInsetsGeometry? margin,
    Color? color,
  }) {
    final effectiveAccent = accentColor ?? Color(AppColors.buttons);
    return AppCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      padding: padding,
      margin: margin,
      color: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ??
              AppCardLeadingAvatar(
                imageUrl: avatarUrl,
                nameForInitials: avatarInitialsText ?? title,
                icon: leadingIcon,
                borderColor: effectiveAccent,
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (topBadges != null && topBadges.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: topBadges,
                  ),
                  const SizedBox(height: 5),
                ],
                Text(
                  title,
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppStyles.subtitleContent(context).copyWith(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (thirdLine != null && thirdLine.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    thirdLine,
                    style: AppStyles.subtitleContent(context).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (extraContent != null) ...[
                  const SizedBox(height: 5),
                  extraContent,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shape = radius ?? AppRadius.card;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: shape,
        border: border ?? AppBorders.card,
        boxShadow: boxShadow ?? AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: (onTap != null || onLongPress != null)
            ? InkWell(
                borderRadius: shape,
                onTap: onTap,
                onLongPress: onLongPress,
                child: Padding(padding: padding, child: child),
              )
            : Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Circular `46x46` avatar with `2px` colored border matching `TeamMemberStatusCard`.
/// Shows a network image if [imageUrl] is provided, an [icon] if provided,
/// or 2-letter initials extracted from [nameForInitials] / [name] / [fallbackText].
class AppCardLeadingAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? nameForInitials;
  final String? name;
  final String? fallbackText;
  final IconData? icon;
  final Color? borderColor;
  final Color? accentColor;
  final double size;

  const AppCardLeadingAvatar({
    super.key,
    this.imageUrl,
    this.nameForInitials,
    this.name,
    this.fallbackText,
    this.icon,
    this.borderColor,
    this.accentColor,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    final tones = AppColors.statusTones(
        borderColor ?? accentColor ?? Color(AppColors.buttons));
    final hasImage = imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        imageUrl!.startsWith('http');
    final initials =
        extractInitials(nameForInitials ?? name ?? fallbackText);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: tones.ring, width: 2),
      ),
      child: ClipOval(
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    _buildFallback(initials, tones),
                placeholder: (_, __) =>
                    _buildFallback(initials, tones),
              )
            : _buildFallback(initials, tones),
      ),
    );
  }

  Widget _buildFallback(String initials, StatusTones tones) {
    return Container(
      color: tones.tint,
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: tones.text, size: size * 0.45)
          : Text(
              initials,
              style: TextStyle(
                color: tones.text,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.32,
              ),
            ),
    );
  }

  static String extractInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
