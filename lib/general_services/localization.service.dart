import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../routing/app_router.dart';

abstract class LocalizationService {
  static void setLocaleAndUpdateUrl(
      {required BuildContext context, required String newLangCode}) {
    // Set the locale
    print("i will put lang");
    final locale = Locale(newLangCode);
    CacheHelper.setString(key: "lang", value: newLangCode);
    context.setLocale(locale);
    
    // على الويب، تجنب إعادة التحميل الكامل
    // استخدام addPostFrameCallback لتأخير التنقل قليلاً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        try {
          // محاولة الحصول على المسار الحالي
          final router = GoRouter.of(context);
          final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
          
          // إذا كنا في splash، نذهب إلى splash
          // وإلا نحدث المسار فقط
          if (currentLocation.contains('splash')) {
            context.goNamed(AppRoutes.splash.name, pathParameters: {'lang': newLangCode});
          } else {
            // تحديث المسار مع اللغة الجديدة
            final newPath = currentLocation.replaceFirst(RegExp(r'^/(ar|en)'), '/$newLangCode');
            if (newPath != currentLocation) {
              context.go(newPath);
            }
          }
        } catch (e) {
          // في حالة الخطأ، نذهب إلى splash كحل بديل
          print("Error updating route: $e");
          context.goNamed(AppRoutes.splash.name, pathParameters: {'lang': newLangCode});
        }
      }
    });
  }

  static bool isArabic({required BuildContext context}) =>
      context.locale.languageCode == 'ar';
}
