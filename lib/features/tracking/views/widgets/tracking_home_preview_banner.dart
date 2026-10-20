import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../screens/live_group_map_screen.dart';
import '../screens/tracking_demo_hub_screen.dart';

class TrackingHomePreviewBanner extends StatelessWidget {
  const TrackingHomePreviewBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(AppColors.secondaryButton), // 0xFF090B60
            const Color(0xFF1E2D74),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.secondaryButton).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrackingDemoHubScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Live Indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.amberAccent),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? 'ميزة جديدة (معاينة التصميم)' : 'New Feature (Design Preview)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xff2D6A4F).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 7, color: Colors.lightGreenAccent),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? 'Live Data 10 موظفين' : 'Live Data 10 Staff',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title & Description
                Text(
                  isAr ? 'نظام تتبع الموظفين المرتبط بالطلبات 📍' : 'Request-Linked Employee Tracking 📍',
                  style: AppStyles.whiteHeading(context).copyWith(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isAr
                      ? 'تتبع المسار الفعلي، تسجيل المحطات الرئيسية، وساعات النشاط الميداني.'
                      : 'Real-time route tracking, milestone logging, and field active hours.',
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Navigation Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _BannerQuickButton(
                        icon: Icons.map_rounded,
                        label: isAr ? 'الخريطة المجمعة' : 'Group Map',
                        color: Color(AppColors.buttons), // 0xFF3389EE
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LiveGroupMapScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BannerQuickButton(
                        icon: Icons.person_pin_circle_outlined,
                        label: isAr ? 'شاشة الموظف' : 'Staff View',
                        color: Colors.white.withOpacity(0.18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TrackingDemoHubScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _BannerQuickButton(
                        icon: Icons.admin_panel_settings_outlined,
                        label: isAr ? 'شاشة المدير' : 'Manager View',
                        color: Colors.white.withOpacity(0.18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TrackingDemoHubScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerQuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BannerQuickButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
