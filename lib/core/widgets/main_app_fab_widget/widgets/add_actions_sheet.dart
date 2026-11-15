import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/proxy_actions_service.dart';
import 'package:app_test/core/widgets/app_filter_actions.widget.dart';
import 'package:app_test/core/widgets/app_shortcut_card.widget.dart';

/// What the "+" floating button offers. A user with on-behalf actions (`proxy_actions`) gets a
/// small sheet: a request for themselves, a leave on behalf of an employee, attendance on behalf.
/// Everyone else goes straight to "add request", as before.
///
/// The on-behalf entries open the `proxyActions` screen with `extra: {'autoStart': ...}`, so this
/// core widget does not depend on the proxy_actions feature.
abstract class AddActionsSheet {
  static bool get hasChoices => ProxyActionsService.canCreateLeave || ProxyActionsService.canAttendance;

  static Future<void> openAddRequest(BuildContext context) async {
    await context.pushNamed(AppRoutes.addRequest.name,
        pathParameters: {'type': 'mine', 'lang': context.locale.languageCode});
  }

  /// The "+" action: the sheet when there is a choice, otherwise "add request" directly.
  static Future<void> onPlusPressed(BuildContext context) async {
    if (!hasChoices) return openAddRequest(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(AppColors.background),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        void pick(String value) => Navigator.of(sheetContext).pop(value);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSizes.s12, AppSpacing.page, AppSpacing.section),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 63,
                    height: AppSizes.s5,
                    decoration: BoxDecoration(
                      color: Color(AppColors.disableButton),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.s20),
                AppFilterTitle('add_actions_title'.tr()),
                const SizedBox(height: AppSpacing.md),
                AppShortcutCard(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'add_actions_my_request'.tr(),
                  subtitle: 'add_actions_my_request_hint'.tr(),
                  onTap: () => pick('mine'),
                ),
                if (ProxyActionsService.canCreateLeave) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  AppShortcutCard(
                    icon: Icons.event_available_rounded,
                    title: 'proxy_new_request'.tr(),
                    subtitle: 'proxy_new_request_hint'.tr(),
                    onTap: () => pick('leave'),
                  ),
                ],
                if (ProxyActionsService.canAttendance) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  AppShortcutCard(
                    icon: Icons.fingerprint_rounded,
                    title: 'proxy_attendance'.tr(),
                    subtitle: 'proxy_attendance_hint'.tr(),
                    onTap: () => pick('attendance'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (choice == null || !context.mounted) return;
    if (choice == 'mine') return openAddRequest(context);
    await context.pushNamed(AppRoutes.proxyActions.name,
        pathParameters: {'lang': context.locale.languageCode}, extra: {'autoStart': choice});
  }
}
