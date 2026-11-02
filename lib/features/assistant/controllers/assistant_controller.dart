import 'dart:async';
import 'dart:convert';

import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/cache_constants.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/models/assistant_message_model.dart';
import '../data/models/help_entry_model.dart';
import '../data/repos/help_repo.dart';
import '../data/repos/user_data_repo.dart';
import '../data/services/voice_matcher.dart';
import '../data/services/voice_picker.dart';
import '../data/services/wake_word_service.dart';

enum AssistantState { idle, wakeListening, listeningQuestion, speaking }

/// مساعد TeamMind (صوت ونص، بدون إنترنت). عام على مستوى التطبيق حتى يستمر
/// الاستماع لعبارة التنشيط عند التنقل بين الشاشات.
class AssistantController extends ChangeNotifier with WidgetsBindingObserver {
  AssistantController() {
    _voiceprint = _loadVoiceprint();
    _wakeEnabled = CacheHelper.getBool(CacheConsts.assistantWakeEnabled) == true &&
        _voiceprint != null;
    WidgetsBinding.instance.addObserver(this);
  }

  /// شاشات التبويبات السفلية: يُنتقل إليها بـ goNamed بدل pushNamed.
  static const _tabRoutes = {'fingerprint', 'more', 'notifications', 'requests', 'home'};

  /// عدد مرات نطق العبارة عند تسجيل الصوت.
  static const enrollTotal = 3;

  /// اللهجة العربية المفضلة للتعرف على الكلام والصوت (مصري). لو غير متوفرة
  /// على الجهاز نرجع للعربية العامة.
  static const arabicRegion = 'EG';
  static final RegExp _arabicRegionLocale = RegExp('^ar[-_]$arabicRegion\$', caseSensitive: false);
  static const _enrollIdleTimeout = Duration(seconds: 25);

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final WakeWordService _wakeService = WakeWordService();
  StreamSubscription<List<List<double>>>? _utteranceSub;
  VoiceprintModel? _voiceprint;

  AssistantState _state = AssistantState.idle;
  bool _wakeEnabled = false;
  bool _speechReady = false;
  bool _ttsReady = false;
  bool _appInForeground = true;
  bool _screenOpen = false;
  int _hosts = 0;
  String _partialText = '';
  String? _error;
  Timer? _restartTimer;
  Timer? _healthTimer;
  Timer? _listenWatchdog;
  Timer? _speakWatchdog;
  int _startFailures = 0;
  String _lastHeard = '';
  int _speakGen = 0;
  // الصوت المختار لكل لغة (يُحسب مرة واحدة).
  final Map<String, VoiceChoice> _voiceByLang = {};
  Timer? _enrollTimer;
  bool _enrolling = false;
  final List<List<List<double>>> _enrollSamples = [];
  final List<AssistantMessageModel> messages = [];
  bool _floatingVisible = false;
  Timer? _floatingTimer;

  /// مستوى صوت المستخدم 0..1 أثناء الاستماع، ونبضة لكل كلمة أثناء الكلام
  /// (ValueNotifier حتى يتحرك الشعار دون إعادة بناء الشاشة كلها).
  final ValueNotifier<double> soundLevel = ValueNotifier(0);
  final ValueNotifier<int> wordTick = ValueNotifier(0);
  List<HelpEntryModel> _entries = [];
  String _entriesLang = '';

  AssistantState get state => _state;
  bool get wakeEnabled => _wakeEnabled && !kIsWeb;
  bool get hasVoiceprint => _voiceprint != null;
  bool get enrolling => _enrolling;

  /// عدد تسجيلات الصوت المكتملة أثناء الإعداد (0..[enrollTotal]).
  int get enrollDone => _enrollSamples.length;
  bool get isListeningQuestion => _state == AssistantState.listeningQuestion;
  bool get isSpeaking => _state == AssistantState.speaking;
  String get partialText => _partialText;
  String? get error => _error;

  /// النافذة العائمة التي تظهر عند "Hey TeamMind" بدل فتح الشاشة.
  bool get floatingVisible => _floatingVisible;

  /// لغة الواجهة كما تراها الشاشات الظاهرة (تبلغ بها عبر [syncLanguage]).
  String? _uiLang;

  /// تستدعيها الشاشات من build بلغة الـ context الخاص بها. هذا أدق من
  /// rootNavigatorKey، الذي كان أحياناً يرجع null فيعتبر المساعد اللغة إنجليزية
  /// (يتعرف على الكلام بالإنجليزية ويجيب من ملف المساعدة الإنجليزي).
  void syncLanguage(String languageCode) {
    if (languageCode != _uiLang) debugPrint('Assistant: ui language = $languageCode');
    _uiLang = languageCode;
  }

  String get _lang {
    final ui = _uiLang;
    if (ui == 'ar' || ui == 'en') return ui!;
    final cached = CacheHelper.getString('lang');
    if (cached == 'ar' || cached == 'en') return cached;
    final ctx = rootNavigatorKey.currentContext;
    return ctx != null ? ctx.locale.languageCode : 'en';
  }

  bool get _wakeAllowed =>
      wakeEnabled && !_enrolling && _hosts > 0 && _appInForeground && !_screenBusy;

  /// أثناء الإجابة أو الاستماع للسؤال لا نستمع للعبارة.
  bool get _screenBusy =>
      _state == AssistantState.listeningQuestion ||
      _state == AssistantState.speaking;

  // ---------------------------------------------------------------- lifecycle

  /// تستدعيه الشاشة عند الفتح/الإغلاق، لتفادي تكرار فتحها من عبارة التنشيط.
  void setScreenOpen(bool open) {
    _screenOpen = open;
    if (!open) {
      // خروج من الشاشة: إيقاف الصوت والاستماع للسؤال ثم الرجوع للتنشيط.
      _stopAll();
      _setState(AssistantState.idle);
      _scheduleWakeRestart();
    }
  }

  /// يُستدعى من داخل الـ shell بعد تسجيل الدخول فقط.
  void attachHost() {
    _hosts++;
    if (_hosts == 1) _scheduleWakeRestart();
  }

  void detachHost() {
    if (_hosts > 0) _hosts--;
    if (_hosts == 0) {
      _stopAll();
      _floatingVisible = false;
      if (_state == AssistantState.wakeListening) _setState(AssistantState.idle);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (foreground == _appInForeground) return;
    _appInForeground = foreground;
    if (foreground) {
      _scheduleWakeRestart();
    } else {
      _stopAll();
      _floatingVisible = false;
      _setState(AssistantState.idle);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restartTimer?.cancel();
    _healthTimer?.cancel();
    _listenWatchdog?.cancel();
    _speakWatchdog?.cancel();
    _enrollTimer?.cancel();
    _floatingTimer?.cancel();
    soundLevel.dispose();
    wordTick.dispose();
    _utteranceSub?.cancel();
    _wakeService.dispose();
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  // ----------------------------------------------------------------- settings

  VoiceprintModel? _loadVoiceprint() {
    try {
      final raw = CacheHelper.getString(CacheConsts.assistantVoiceprint);
      if (raw == null || raw.toString().isEmpty) return null;
      return VoiceprintModel.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// تفعيل/إيقاف الاستماع للعبارة. التفعيل يتطلب بصمة صوت محفوظة.
  Future<void> setWakeEnabled(bool value) async {
    _error = null;
    if (!value && _enrolling) {
      await cancelEnrollment();
      return;
    }
    if (value && !hasVoiceprint) {
      await startEnrollment();
      return;
    }
    _wakeEnabled = value;
    CacheHelper.setBool(CacheConsts.assistantWakeEnabled, value);
    if (value) {
      _scheduleWakeRestart();
    } else {
      await _stopAll();
      _setState(AssistantState.idle);
    }
    notifyListeners();
  }

  /// يمسح بصمة الصوت ويوقف الاستماع.
  Future<void> resetVoiceprint() async {
    _voiceprint = null;
    _wakeEnabled = false;
    CacheHelper.setBool(CacheConsts.assistantWakeEnabled, false);
    await CacheHelper.deleteData(key: CacheConsts.assistantVoiceprint);
    await _stopAll();
    _setState(AssistantState.idle);
    notifyListeners();
  }

  // --------------------------------------------------------------- enrollment

  /// يسجّل صوت المستخدم وهو ينطق العبارة [enrollTotal] مرات ويحفظ بصمتها.
  Future<void> startEnrollment() async {
    await _stopAll();
    _error = null;
    _enrollSamples.clear();
    if (await _wakeService.start() != WakeStartResult.started) {
      _error = AppStrings.assistantMicDenied.tr();
      notifyListeners();
      return;
    }
    _enrolling = true;
    _setState(AssistantState.idle);
    _listenUtterances();
    _armEnrollTimeout();
    notifyListeners();
  }

  Future<void> cancelEnrollment() async {
    await _finishEnrollment();
    _scheduleWakeRestart();
  }

  void _armEnrollTimeout() {
    _enrollTimer?.cancel();
    _enrollTimer = Timer(_enrollIdleTimeout, () async {
      _error = AppStrings.assistantEnrollTimeout.tr();
      await _finishEnrollment();
    });
  }

  Future<void> _finishEnrollment() async {
    _enrollTimer?.cancel();
    _enrolling = false;
    _enrollSamples.clear();
    await _utteranceSub?.cancel();
    _utteranceSub = null;
    await _wakeService.stop();
    notifyListeners();
  }

  void _onEnrollUtterance(List<List<double>> features) {
    _enrollSamples.add(features);
    _armEnrollTimeout();
    if (_enrollSamples.length < enrollTotal) {
      notifyListeners();
      return;
    }
    final voiceprint = VoiceMatcher.enroll(List.of(_enrollSamples));
    if (voiceprint == null) {
      // التسجيلات غير متسقة (كلام مختلف أو مقطوع): نبدأ من جديد.
      _enrollSamples.clear();
      _error = AppStrings.assistantEnrollInconsistent.tr();
      notifyListeners();
      return;
    }
    _voiceprint = voiceprint;
    CacheHelper.setString(
        key: CacheConsts.assistantVoiceprint, value: json.encode(voiceprint.toJson()));
    _wakeEnabled = true;
    CacheHelper.setBool(CacheConsts.assistantWakeEnabled, true);
    _finishEnrollment().then((_) => _scheduleWakeRestart());
  }

  // ------------------------------------------------------------------- engine

  Future<bool> _ensureSpeech() async {
    if (_speechReady) return true;
    try {
      _speechReady = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
    } catch (e) {
      debugPrint('Assistant: speech init failed: $e');
      _speechReady = false;
    }
    if (!_speechReady) {
      _error = AppStrings.assistantMicDenied.tr();
      notifyListeners();
    }
    return _speechReady;
  }

  Future<void> _ensureTts() async {
    if (_ttsReady) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      // الانتهاء يُعالج بعد await speak (مع رقم الجملة) وليس هنا، لأن حدث
      // الإلغاء يصل أيضاً عند مقاطعة إجابة بأخرى.
      _tts.setErrorHandler((_) => _onSpeakDone());
      _tts.setProgressHandler((_, __, ___, ____) => wordTick.value++);
      _ttsReady = true;
    } catch (e) {
      debugPrint('Assistant: tts init failed: $e');
    }
  }

  /// معرّف لغة التعرف: للعربي نفضّل ar-EG، وإلا لغة النظام لو كانت نفس اللغة،
  /// وإلا أول لغة متاحة تبدأ بنفس الرمز.
  Future<String> _localeId() async {
    final lang = _lang;
    var id = lang == 'ar' ? 'ar-$arabicRegion' : 'en-US';
    try {
      final locales = await _speech.locales();
      final system = await _speech.systemLocale();
      final systemId = system?.localeId ?? '';
      if (lang == 'ar' && locales.any((l) => _arabicRegionLocale.hasMatch(l.localeId))) {
        id = locales.firstWhere((l) => _arabicRegionLocale.hasMatch(l.localeId)).localeId;
      } else if (systemId.toLowerCase().startsWith(lang) && lang != 'ar') {
        id = systemId;
      } else {
        for (final l in locales) {
          if (l.localeId.toLowerCase().startsWith(lang)) {
            id = l.localeId;
            break;
          }
        }
      }
    } catch (_) {}
    // لا نرجع أبداً لغة النظام لو كانت مختلفة عن لغة التطبيق: أندرويد الحديث
    // كثيراً لا يذكر العربية في قائمة اللغات لكنه يقبل ar-EG عند الطلب.
    debugPrint('Assistant: speech locale = $id (app language $lang)');
    return id;
  }

  /// يوقف كل ما يستخدم الميكروفون أو السماعة (الميكروفون لا يخدم إلا مستخدماً واحداً).
  Future<void> _stopAll() async {
    _restartTimer?.cancel();
    _healthTimer?.cancel();
    _listenWatchdog?.cancel();
    _speakWatchdog?.cancel();
    _partialText = '';
    soundLevel.value = 0;
    try {
      await _utteranceSub?.cancel();
      _utteranceSub = null;
      if (!_enrolling) await _wakeService.stop();
      if (_speech.isListening) await _speech.cancel();
      await _tts.stop();
    } catch (_) {}
  }

  // ------------------------------------------------------------- wake listening

  void _scheduleWakeRestart({Duration delay = const Duration(milliseconds: 400)}) {
    _restartTimer?.cancel();
    if (!_wakeAllowed) return;
    _restartTimer = Timer(delay, _startDetector);
  }

  /// يفتح الميكروفون كتدفق مستمر واحد ويقارن كل جملة مسموعة ببصمة المستخدم.
  Future<void> _startDetector() async {
    if (!_wakeAllowed || _wakeService.isRunning) return;
    final result = await _wakeService.start();
    if (result == WakeStartResult.denied) {
      _wakeEnabled = false;
      CacheHelper.setBool(CacheConsts.assistantWakeEnabled, false);
      _error = AppStrings.assistantMicDenied.tr();
      notifyListeners();
      return;
    }
    if (result == WakeStartResult.failed) {
      // الميكروفون مشغول لحظياً: نعيد المحاولة بتأخير متزايد بدل إيقاف الميزة.
      _startFailures++;
      final secs = (1 << (_startFailures - 1).clamp(0, 3)).clamp(1, 8);
      debugPrint('Assistant: mic busy, retry in ${secs}s');
      _scheduleWakeRestart(delay: Duration(seconds: secs));
      return;
    }
    _startFailures = 0;
    _listenUtterances();
    _setState(AssistantState.wakeListening);
    _startHealthCheck();
  }

  /// كل 4 ث: لو التدفق توقف عن إرسال صوت، أو الحالة "تستمع" والخدمة متوقفة،
  /// نعيد تشغيله. هذا ما كان يجعل "Hey TeamMind" لا يستجيب أحياناً.
  void _startHealthCheck() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_state != AssistantState.wakeListening || !_wakeAllowed) {
        _healthTimer?.cancel();
        return;
      }
      if (_wakeService.isStalled || !_wakeService.isRunning) {
        debugPrint('Assistant: wake stream stalled, restarting');
        await _wakeService.stop();
        _scheduleWakeRestart();
      }
    });
  }

  void _listenUtterances() {
    _utteranceSub?.cancel();
    _utteranceSub = _wakeService.utterances.listen((features) {
      if (_enrolling) {
        _onEnrollUtterance(features);
        return;
      }
      final vp = _voiceprint;
      if (vp == null || _state != AssistantState.wakeListening) return;
      final distances = vp.distancesTo(features);
      final votes = distances.where((d) => d <= vp.threshold).length;
      debugPrint('Assistant: voice distances '
          '${distances.map((d) => d.toStringAsFixed(2)).join(', ')} '
          '(threshold ${vp.threshold.toStringAsFixed(2)}, '
          'matched $votes/${vp.requiredVotes} needed)');
      if (votes >= vp.requiredVotes) _onWakeDetected();
    });
  }

  Future<void> _onWakeDetected() async {
    await _stopAll();
    if (!_screenOpen) {
      _floatingVisible = true;
      notifyListeners();
    }
    await startListening();
  }

  // ------------------------------------------------------------------ floating

  /// يغلق النافذة العائمة ويوقف أي استماع أو كلام، ثم يعود للاستماع للعبارة.
  Future<void> hideFloating() async {
    _floatingTimer?.cancel();
    if (!_floatingVisible) return;
    _floatingVisible = false;
    await _stopAll();
    _setState(AssistantState.idle);
    notifyListeners();
    _scheduleWakeRestart();
  }

  /// يكبّر النافذة العائمة إلى شاشة المساعد الكاملة (المحادثة نفسها).
  void expandFloating() {
    _floatingTimer?.cancel();
    _floatingVisible = false;
    notifyListeners();
    _openScreen();
  }

  void _armFloatingHide(Duration after) {
    _floatingTimer?.cancel();
    if (!_floatingVisible) return;
    _floatingTimer = Timer(after, hideFloating);
  }

  void _openScreen() {
    if (_screenOpen) return;
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    GoRouter.of(ctx).pushNamed(AppRoutes.teamMindAssistant.name,
        pathParameters: {'lang': _lang});
  }

  // --------------------------------------------------------- question listening

  /// زر الميكروفون: يبدأ الاستماع للسؤال، أو يوقفه لو كان يعمل.
  Future<void> toggleListening() async {
    if (isListeningQuestion) {
      await _speech.stop();
      return;
    }
    await startListening();
  }

  Future<void> startListening() async {
    await _stopAll();
    if (!await _ensureSpeech()) return;
    _floatingTimer?.cancel();
    _error = null;
    _partialText = '';
    _lastHeard = '';
    _setState(AssistantState.listeningQuestion);
    // حماية: لو لم تصل نهاية الجلسة لأي سبب لا نبقى عالقين في "أستمع".
    _listenWatchdog?.cancel();
    _listenWatchdog = Timer(const Duration(seconds: 25), () async {
      if (_speech.isListening) await _speech.stop();
      _finishQuestion();
    });
    try {
      await _speech.listen(
        // المستوى تقريباً من -2 إلى 10 dB على أندرويد؛ نحوله إلى 0..1 للشعار.
        onSoundLevelChange: (level) =>
            soundLevel.value = ((level + 2) / 12).clamp(0.0, 1.0),
        onResult: (r) {
          if (r.recognizedWords.trim().isNotEmpty) _lastHeard = r.recognizedWords;
          _partialText = r.recognizedWords;
          if (r.finalResult) {
            _finishQuestion();
          } else {
            notifyListeners();
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: await _localeId(),
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.search,
        ),
      );
    } catch (e) {
      debugPrint('Assistant: listen failed: $e');
      _finishQuestion();
    }
  }

  /// نهاية الاستماع للسؤال من أي طريق (نتيجة نهائية، انتهاء الجلسة، خطأ، أو
  /// المؤقت): نجيب عن آخر كلام ظهر للمستخدم. سابقاً كان أندرويد يرسل خطأ
  /// no_match بعد ظهور الكلام فنقول "لم أسمعك".
  void _finishQuestion() {
    if (_state != AssistantState.listeningQuestion) return;
    _listenWatchdog?.cancel();
    final text = _lastHeard.trim();
    _lastHeard = '';
    _partialText = '';
    soundLevel.value = 0;
    if (text.isEmpty) {
      _onNothingHeard();
      return;
    }
    _setState(AssistantState.idle);
    ask(text);
  }

  void _onNothingHeard() {
    _listenWatchdog?.cancel();
    _partialText = '';
    soundLevel.value = 0;
    _error = AppStrings.assistantSpeechError.tr();
    _setState(AssistantState.idle);
    _armFloatingHide(const Duration(seconds: 4));
    // مهلة صغيرة حتى يحرر التعرف على الكلام الميكروفون.
    _scheduleWakeRestart(delay: const Duration(milliseconds: 800));
  }

  void _onSpeechStatus(String status) {
    if (status != 'done' && status != 'notListening') return;
    if (_state != AssistantState.listeningQuestion) return;
    // ننتظر لحظة لعل النتيجة النهائية تصل، ثم ننهي بما سمعناه.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_state == AssistantState.listeningQuestion && !_speech.isListening) {
        _finishQuestion();
      }
    });
  }

  void _onSpeechError(dynamic error) {
    final msg = error?.errorMsg?.toString() ?? '$error';
    debugPrint('Assistant: speech error $msg');
    final permanent = msg == 'error_permission' || msg == 'error_language_unavailable';
    if (permanent) {
      _speechReady = false;
      _listenWatchdog?.cancel();
      _error = AppStrings.assistantMicDenied.tr();
      _setState(AssistantState.idle);
      _scheduleWakeRestart(delay: const Duration(seconds: 1));
      return;
    }
    // no_match / timeout / client: نجيب بما ظهر إن وُجد.
    _finishQuestion();
  }

  // ------------------------------------------------------------------ answering

  /// يجيب عن سؤال مكتوب أو منطوق، ويقرأ الإجابة بصوت عالٍ.
  Future<void> ask(String question) async {
    final q = question.trim();
    if (q.isEmpty) return;
    _error = null;
    messages.add(AssistantMessageModel(text: q, isUser: true));

    final lang = _lang == 'ar' ? 'ar' : 'en';
    if (_entriesLang != lang || _entries.isEmpty) {
      try {
        _entries = HelpRepo.visibleEntries(await HelpRepo.load(lang));
        _entriesLang = lang;
      } catch (e) {
        debugPrint('Assistant: failed to load help: $e');
      }
    }
    final result = HelpRepo.match(q, _entries);
    final AssistantMessageModel reply;
    if (result.best != null) {
      reply = AssistantMessageModel(
        text: _answerText(result.best!, lang),
        isUser: false,
        entry: result.best,
      );
    } else {
      reply = AssistantMessageModel(
        text: result.suggestions.isEmpty
            ? AppStrings.assistantNoTopics.tr()
            : AppStrings.assistantNotSure.tr(),
        isUser: false,
        suggestions: result.suggestions,
      );
    }
    messages.add(reply);
    notifyListeners();
    await _speak(reply.text);
  }

  /// اختيار موضوع مقترح (chip) يعرض إجابته مباشرة.
  Future<void> answerWithEntry(HelpEntryModel entry) async {
    messages.add(AssistantMessageModel(text: entry.title, isUser: true));
    final reply = AssistantMessageModel(
        text: _answerText(entry, _lang == 'ar' ? 'ar' : 'en'), isUser: false, entry: entry);
    messages.add(reply);
    notifyListeners();
    await _speak(reply.text);
  }

  /// نص الإجابة: ثابت، أو قالب يُملأ من بيانات حساب المستخدم (US1/US2).
  String _answerText(HelpEntryModel entry, String lang) {
    if (!UserDataRepo.hasPlaceholders(entry.answer)) return entry.answer;
    return UserDataRepo.fill(entry.answer, UserDataRepo.values(lang)) ??
        entry.noData ??
        AppStrings.assistantNoData.tr();
  }

  Future<void> _speak(String text) async {
    await _ensureTts();
    if (!_ttsReady) {
      _setState(AssistantState.idle);
      _scheduleWakeRestart();
      return;
    }
    if (_speech.isListening) await _speech.cancel();
    _floatingTimer?.cancel();
    soundLevel.value = 0;
    _setState(AssistantState.speaking);
    // حماية: لو لم يصل حدث انتهاء الكلام لا نبقى عالقين (فلا يعود الاستماع للعبارة).
    // رقم الجملة الحالية: لو بدأت إجابة جديدة أثناء الكلام لا تنهيها القديمة.
    final gen = ++_speakGen;
    _speakWatchdog?.cancel();
    _speakWatchdog = Timer(Duration(milliseconds: 3000 + text.length * 110),
        () => gen == _speakGen ? _onSpeakDone() : null);
    try {
      // كل قطعة عربية/إنجليزية بصوتها، وإلا يتخطى الصوت الإنجليزي الكلمات العربية.
      for (final segment in VoicePicker.split(text, _lang == 'ar' ? 'ar' : 'en')) {
        if (gen != _speakGen) break; // أُوقف الكلام أو بدأت إجابة أخرى
        await _applyVoice(segment.lang);
        await _tts.speak(segment.text); // awaitSpeakCompletion: يرجع بعد انتهاء القطعة
      }
    } catch (e) {
      debugPrint('Assistant: speak failed: $e');
    }
    if (gen == _speakGen) _onSpeakDone();
  }

  /// صوت رجالي للغة [lang]؛ للعربي نفضّل المصري (ar-EG) لو مثبت.
  Future<void> _applyVoice(String lang) async {
    var choice = _voiceByLang[lang];
    if (choice == null) {
      List<dynamic> voices = const [];
      try {
        final v = await _tts.getVoices;
        if (v is List) voices = v;
      } catch (e) {
        debugPrint('Assistant: cannot list voices: $e');
      }
      choice = VoicePicker.pick(voices, lang, region: lang == 'ar' ? arabicRegion : null);
      _voiceByLang[lang] = choice;
      debugPrint('Assistant: voice for $lang = $choice');
    }
    await _tts.setLanguage(choice.language);
    if (choice.voice != null) await _tts.setVoice(choice.voice!);
    await _tts.setPitch(choice.pitch);
  }

  Future<void> stopSpeaking() async {
    _speakGen++; // يوقف باقي القطع
    try {
      await _tts.stop();
    } catch (_) {}
    _onSpeakDone();
  }

  void _onSpeakDone() {
    if (_state != AssistantState.speaking) return;
    _speakWatchdog?.cancel();
    _setState(AssistantState.idle);
    // يبقى الرد ظاهراً لحظات ليقرأه المستخدم أو يضغط "فتح".
    _armFloatingHide(const Duration(seconds: 8));
    _scheduleWakeRestart(delay: const Duration(milliseconds: 600));
  }

  // --------------------------------------------------------------- navigation

  /// زر "Open": ينتقل للشاشة المرتبطة بالمدخل.
  void openEntry(BuildContext context, HelpEntryModel entry) {
    final route = entry.route;
    if (route == null) return;
    final params = {...entry.params, 'lang': _lang};
    if (_floatingVisible) hideFloating();
    try {
      if (_tabRoutes.contains(route)) {
        context.goNamed(route, pathParameters: params, extra: entry.extra);
      } else {
        context.pushNamed(route, pathParameters: params, extra: entry.extra);
      }
    } catch (e) {
      debugPrint('Assistant: cannot open route $route: $e');
    }
  }

  void clearConversation() {
    messages.clear();
    _error = null;
    notifyListeners();
  }

  void _setState(AssistantState s) {
    if (_state == s) return;
    _state = s;
    notifyListeners();
  }
}
