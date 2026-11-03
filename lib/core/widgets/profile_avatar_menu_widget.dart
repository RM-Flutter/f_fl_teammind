import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_design.dart';

/// Wraps the user's avatar. With an employee profile, a tap opens a small menu (personal profile or
/// employee profile) and another tap, or a tap outside, closes it. Without one there is nothing to
/// choose, so a tap goes straight to the personal profile.
class ProfileAvatarMenuWidget extends StatelessWidget {
  final Widget child;

  /// `employee_profile_id` from the cached user settings
  final dynamic employeeProfileId;

  const ProfileAvatarMenuWidget({
    super.key,
    required this.child,
    required this.employeeProfileId,
  });

  bool get _hasEmployeeProfile {
    final id = employeeProfileId?.toString() ?? '';
    return id.isNotEmpty && id != 'null' && id != '0';
  }

  void _openPersonalProfile(BuildContext context) {
    context.pushNamed(AppRoutes.personalProfile.name,
        pathParameters: {'lang': context.locale.languageCode});
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasEmployeeProfile) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openPersonalProfile(context),
        child: child,
      );
    }

    return MenuAnchor(
      // MenuAnchor (not PopupMenuButton): tapping the avatar again toggles it closed, and so does a tap outside
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(10),
        shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.25)),
        minimumSize: const WidgetStatePropertyAll(Size(210, 0)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg))),
      ),
      menuChildren: [
        _item(context,
            icon: Icons.person_outline_rounded,
            label: AppStrings.personalProfile.tr(),
            onPressed: () => _openPersonalProfile(context)),
        _item(context,
            icon: Icons.badge_outlined,
            label: AppStrings.employeeProfile.tr(),
            onPressed: () => context.pushNamed(AppRoutes.employeeDetails.name,
                pathParameters: {
                  'id': employeeProfileId.toString(),
                  'lang': context.locale.languageCode
                })),
      ],
      builder: (context, controller, _) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: child,
      ),
    );
  }

  MenuItemButton _item(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    return MenuItemButton(
      onPressed: onPressed,
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(210, 48)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
      ),
      leadingIcon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Color(AppColors.buttons).withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 18, color: Color(AppColors.buttons)),
      ),
      child: Text(
        label,
        style: AppStyles.blackContent(context).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
