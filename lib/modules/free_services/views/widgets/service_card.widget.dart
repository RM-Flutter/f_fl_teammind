import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showProfileAvatar;
  final String? avatarUrl;
  final Color? backgroundColor;
  final Color? iconColor;

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.showProfileAvatar = false,
    this.avatarUrl,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Color(AppColors.dark),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showProfileAvatar && avatarUrl != null && avatarUrl!.isNotEmpty)
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(avatarUrl!),
                backgroundColor: Colors.grey[200],
              )
            else
              Icon(
                icon,
                size: 28,
                color: Color(AppColors.white),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

