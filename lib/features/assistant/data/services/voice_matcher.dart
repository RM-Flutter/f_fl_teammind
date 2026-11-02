import 'dart:math' as math;

/// بصمة صوت المستخدم لعبارة التنشيط: عدة تسجيلات وحد قبول محسوب منها.
class VoiceprintModel {
  final List<List<List<double>>> templates;
  final double threshold;

  const VoiceprintModel({required this.templates, required this.threshold});

  Map<String, dynamic> toJson() => {'templates': templates, 'threshold': threshold};

  factory VoiceprintModel.fromJson(Map<String, dynamic> json) => VoiceprintModel(
        templates: (json['templates'] as List)
            .map((t) => (t as List)
                .map((f) => (f as List).map((v) => (v as num).toDouble()).toList())
                .toList())
            .toList(),
        threshold: (json['threshold'] as num).toDouble(),
      );

  /// أقل مسافة بين [features] وأي تسجيل محفوظ.
  double distanceTo(List<List<double>> features) {
    var best = double.infinity;
    for (final t in templates) {
      best = math.min(best, VoiceMatcher.distance(features, t));
    }
    return best;
  }

  /// المسافة لكل تسجيل محفوظ.
  List<double> distancesTo(List<List<double>> features) =>
      [for (final t in templates) VoiceMatcher.distance(features, t)];

  /// عدد التسجيلات المطلوب أن تشبهها الجملة: 2 من 3. تشابه تسجيل واحد فقط
  /// كان يفتح المساعد أحياناً من كلام عادي.
  int get requiredVotes => templates.length >= 3 ? 2 : 1;

  bool matches(List<List<double>> features) =>
      distancesTo(features).where((d) => d <= threshold).length >= requiredVotes;
}

abstract class VoiceMatcher {
  /// نسبة الطول المسموحة بين الجملة والتسجيل المحفوظ.
  static const double maxLengthRatio = 1.7;

  /// Dynamic Time Warping بين تسلسلين من الإطارات، مقسوم على طول المسار.
  static double distance(List<List<double>> a, List<List<double>> b) {
    final n = a.length, m = b.length;
    if (n == 0 || m == 0) return double.infinity;
    final ratio = n > m ? n / m : m / n;
    if (ratio > maxLengthRatio) return double.infinity;
    final band = math.max((n - m).abs(), (math.max(n, m) * 0.3).ceil());
    const inf = double.infinity;
    var prev = List<double>.filled(m + 1, inf);
    prev[0] = 0;
    for (var i = 1; i <= n; i++) {
      final cur = List<double>.filled(m + 1, inf);
      final lo = math.max(1, i - band), hi = math.min(m, i + band);
      for (var j = lo; j <= hi; j++) {
        final c = _frameDistance(a[i - 1], b[j - 1]);
        cur[j] = c + math.min(prev[j - 1], math.min(prev[j], cur[j - 1]));
      }
      prev = cur;
    }
    return prev[m] / (n + m);
  }

  static double _frameDistance(List<double> x, List<double> y) {
    var s = 0.0;
    for (var i = 0; i < x.length; i++) {
      final d = x[i] - y[i];
      s += d * d;
    }
    return math.sqrt(s);
  }

  /// يبني البصمة من تسجيلات المستخدم، أو null لو التسجيلات غير متسقة
  /// (مثلاً قال كلاماً مختلفاً في كل مرة).
  static VoiceprintModel? enroll(List<List<List<double>>> samples) {
    if (samples.length < 2) return null;
    final pairs = <double>[];
    for (var i = 0; i < samples.length; i++) {
      for (var j = i + 1; j < samples.length; j++) {
        final d = distance(samples[i], samples[j]);
        if (d.isInfinite) return null;
        pairs.add(d);
      }
    }
    final maxPair = pairs.reduce(math.max);
    final meanPair = pairs.reduce((a, b) => a + b) / pairs.length;
    return VoiceprintModel(
      templates: samples,
      threshold: math.max(maxPair * 1.5, meanPair * 1.8),
    );
  }
}
