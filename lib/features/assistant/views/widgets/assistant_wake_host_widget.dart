import 'package:app_test/core/routing/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../controllers/assistant_controller.dart';
import 'assistant_floating_widget.dart';

/// يضعه الـ shell بعد تسجيل الدخول: وجوده يسمح للمساعد بالاستماع لعبارة
/// التنشيط، وزواله (خروج/تسجيل خروج) يوقفه. ويعرض النافذة العائمة فوق كل
/// الشاشات (في overlay الـ navigator الرئيسي).
class AssistantWakeHost extends StatefulWidget {
  final Widget child;
  const AssistantWakeHost({super.key, required this.child});

  @override
  State<AssistantWakeHost> createState() => _AssistantWakeHostState();
}

class _AssistantWakeHostState extends State<AssistantWakeHost> {
  late final AssistantController _controller;

  /// نافذة واحدة مشتركة، لأن نسختين من الـ host قد تتواجدان لحظة تبديل الـ shell.
  static OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _controller = context.read<AssistantController>();
    // الـ shell يُعاد بناؤه بـ UniqueKey مع كل تنقل: نسجّل الجديد فوراً ونؤخر
    // إلغاء تسجيل القديم لما بعد الإطار، فلا يتوقف الميكروفون ولا يُستدعى
    // notifyListeners أثناء قفل شجرة الـ widgets.
    _controller.attachHost();
    _controller.addListener(_syncFloating);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFloating());
  }

  @override
  void dispose() {
    _controller.removeListener(_syncFloating);
    final controller = _controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.detachHost();
      // آخر host (تسجيل خروج): لا أحد سيستمع بعدها، فنزيل النافذة هنا.
      if (!controller.floatingVisible && _entry != null) {
        _entry!.remove();
        _entry = null;
      }
    });
    super.dispose();
  }

  void _syncFloating() {
    if (!mounted) return;
    // لا يجوز تعديل الـ overlay أثناء البناء؛ نؤجله لما بعد الإطار.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncFloating());
      return;
    }
    final show = _controller.floatingVisible;
    if (show && _entry == null) {
      final overlay = rootNavigatorKey.currentState?.overlay;
      if (overlay == null) return;
      _entry = OverlayEntry(
        builder: (_) => ChangeNotifierProvider<AssistantController>.value(
          value: _controller,
          child: const AssistantFloatingWidget(),
        ),
      );
      overlay.insert(_entry!);
    } else if (!show && _entry != null) {
      _entry!.remove();
      _entry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller.syncLanguage(context.locale.languageCode);
    return widget.child;
  }
}
