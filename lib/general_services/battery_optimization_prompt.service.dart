import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'backend_services/api_service/dio_api_service/shared.dart';

/// Keys for caching prompt state.
class _CacheKeys {
  static const String batteryOptimizationPromptShown = 'battery_optimization_prompt_shown';
}

/// Method channel: battery optimization check + open Android settings.
const _channel = MethodChannel('com.rightminddev.rmemp/secure');

/// Service that prompts the user to exclude the app from Power Management
/// (Battery optimization). Popup is shown only when the device has battery
/// optimization on and the app is being optimized (not excluded).
class BatteryOptimizationPromptService {
  BatteryOptimizationPromptService._();
  static final BatteryOptimizationPromptService instance = BatteryOptimizationPromptService._();

  /// Returns true if the app is currently subject to battery optimization (should show prompt).
  Future<bool> isAppBatteryOptimized() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isAppBatteryOptimized');
      return result ?? false;
    } catch (e) {
      debugPrint('BatteryOptimizationPrompt: isAppBatteryOptimized $e');
      return false;
    }
  }

  /// Call when the app is ready. Shows the dialog only on Android and only when
  /// the app is actually being battery-optimized (not for users who already excluded us).
  /// [showOnlyOncePerSession] avoids showing again in the same app session.
  Future<void> maybeShowPrompt(
    BuildContext context, {
    bool showOnlyOncePerSession = true,
  }) async {
    if (!Platform.isAndroid) return;
    if (context.mounted == false) return;

    final optimized = await isAppBatteryOptimized();
    if (!optimized) return; // لا تظهر إلا لو التطبيق داخل توفير البطارية

    if (showOnlyOncePerSession) {
      final alreadyShown = CacheHelper.getString(_CacheKeys.batteryOptimizationPromptShown) == '1';
      if (alreadyShown) return;
    }

    if (context.mounted == false) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BatteryOptimizationDialog(
        onOpenBatterySettings: () => _openBatteryOptimizationSettings(),
        onOpenDataUsageSettings: () => _openDataUsageSettings(),
        onDismiss: () {
          CacheHelper.setString(key: _CacheKeys.batteryOptimizationPromptShown, value: '1');
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  /// Opens Android Battery Optimization settings (IGNORE_BATTERY_OPTIMIZATION_SETTINGS).
  Future<void> _openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
    } catch (e) {
      debugPrint('BatteryOptimizationPrompt: openBatteryOptimizationSettings $e');
    }
  }

  /// Opens Android Data usage settings (DATA_USAGE_SETTINGS).
  Future<void> _openDataUsageSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('openDataUsageSettings');
    } catch (e) {
      debugPrint('BatteryOptimizationPrompt: openDataUsageSettings $e');
    }
  }

  /// Reset so the prompt can show again (e.g. from app settings).
  static Future<void> resetPromptShown() async {
    await CacheHelper.deleteData(key: _CacheKeys.batteryOptimizationPromptShown);
  }
}

/// Popup محترم: رسالة واحدة واضحة + أزرار إعدادات البطارية والبيانات.
/// يستخدم IGNORE_BATTERY_OPTIMIZATION_SETTINGS و DATA_USAGE_SETTINGS.
class _BatteryOptimizationDialog extends StatelessWidget {
  const _BatteryOptimizationDialog({
    required this.onOpenBatterySettings,
    required this.onOpenDataUsageSettings,
    required this.onDismiss,
  });

  final VoidCallback onOpenBatterySettings;
  final VoidCallback onOpenDataUsageSettings;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.battery_charging_full, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'استمرار الاتصال',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'لضمان استمرار الاتصال، برجاء تعطيل توفير البطارية للتطبيق.',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          Text(
            'يمكنك فتح إعدادات البطارية لاستثناء التطبيق، أو إعدادات البيانات للتحقق من الاستهلاك.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('لاحقاً'),
        ),
        FilledButton.icon(
          onPressed: () {
            onOpenBatterySettings();
            onDismiss();
          },
          icon: const Icon(Icons.battery_charging_full, size: 20),
          label: const Text('إعدادات البطارية'),
        ),
        FilledButton.icon(
          onPressed: () {
            onOpenDataUsageSettings();
            onDismiss();
          },
          icon: const Icon(Icons.data_usage, size: 20),
          label: const Text('إعدادات البيانات'),
        ),
      ],
    );
  }
}
