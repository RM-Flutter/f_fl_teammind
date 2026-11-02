import 'dart:math' as math;

/// استخراج بصمة صوتية (MFCC) من عينات صوت 16kHz أحادية. بدون أي مكتبة خارجية.
abstract class VoiceFeatures {
  static const int sampleRate = 16000;
  static const int frameLength = 400; // 25ms
  static const int hop = 160; // 10ms
  static const int fftSize = 512;
  static const int numFilters = 26;
  static const int numCoeffs = 12;
  static const int minFrames = 10;

  static final List<double> _window = List.generate(
      frameLength, (i) => 0.54 - 0.46 * math.cos(2 * math.pi * i / (frameLength - 1)));
  static final List<List<double>> _filterBank = _buildFilterBank();
  static final List<List<double>> _dct = List.generate(
      numCoeffs,
      (k) => List.generate(numFilters,
          (n) => math.cos(math.pi * (k + 1) * (n + 0.5) / numFilters)));

  static double _mel(double hz) => 2595 * math.log(1 + hz / 700) / math.ln10;
  static double _hz(double mel) => 700 * (math.pow(10, mel / 2595) - 1);

  static List<List<double>> _buildFilterBank() {
    final maxMel = _mel(sampleRate / 2);
    final points = List.generate(numFilters + 2, (i) {
      final hz = _hz(maxMel * i / (numFilters + 1));
      return ((fftSize + 1) * hz / sampleRate).floor();
    });
    final bins = fftSize ~/ 2 + 1;
    return List.generate(numFilters, (m) {
      final f = List<double>.filled(bins, 0);
      final l = points[m], c = points[m + 1], r = points[m + 2];
      for (var k = l; k < c && k < bins; k++) {
        if (c > l) f[k] = (k - l) / (c - l);
      }
      for (var k = c; k < r && k < bins; k++) {
        if (r > c) f[k] = (r - k) / (r - c);
      }
      return f;
    });
  }

  /// FFT تكراري radix-2 في المكان (الطول قوة 2).
  static void _fft(List<double> re, List<double> im) {
    final n = re.length;
    for (var i = 1, j = 0; i < n; i++) {
      var bit = n >> 1;
      for (; j & bit != 0; bit >>= 1) {
        j ^= bit;
      }
      j ^= bit;
      if (i < j) {
        final tr = re[i];
        re[i] = re[j];
        re[j] = tr;
        final ti = im[i];
        im[i] = im[j];
        im[j] = ti;
      }
    }
    for (var len = 2; len <= n; len <<= 1) {
      final ang = -2 * math.pi / len;
      final wr = math.cos(ang), wi = math.sin(ang);
      for (var i = 0; i < n; i += len) {
        var cr = 1.0, ci = 0.0;
        for (var k = 0; k < len ~/ 2; k++) {
          final a = i + k, b = i + k + len ~/ 2;
          final xr = re[b] * cr - im[b] * ci;
          final xi = re[b] * ci + im[b] * cr;
          re[b] = re[a] - xr;
          im[b] = im[a] - xi;
          re[a] += xr;
          im[a] += xi;
          final nr = cr * wr - ci * wi;
          ci = cr * wi + ci * wr;
          cr = nr;
        }
      }
    }
  }

  /// يرجّع قائمة إطارات، كل إطار [numCoeffs] معاملات، بعد تطبيع المتوسط والتباين
  /// (CMVN) على الجملة كلها لتقليل أثر الميكروفون وارتفاع الصوت.
  static List<List<double>> extract(List<double> samples) {
    if (samples.length < frameLength + hop * (minFrames - 1)) return const [];
    final emphasized = List<double>.filled(samples.length, 0);
    emphasized[0] = samples[0];
    for (var i = 1; i < samples.length; i++) {
      emphasized[i] = samples[i] - 0.97 * samples[i - 1];
    }
    final frames = <List<double>>[];
    final re = List<double>.filled(fftSize, 0);
    final im = List<double>.filled(fftSize, 0);
    for (var start = 0; start + frameLength <= emphasized.length; start += hop) {
      for (var i = 0; i < fftSize; i++) {
        re[i] = i < frameLength ? emphasized[start + i] * _window[i] : 0;
        im[i] = 0;
      }
      _fft(re, im);
      final bins = fftSize ~/ 2 + 1;
      final power = List<double>.generate(bins, (k) => re[k] * re[k] + im[k] * im[k]);
      final logMel = List<double>.generate(numFilters, (m) {
        var e = 0.0;
        final f = _filterBank[m];
        for (var k = 0; k < bins; k++) {
          e += f[k] * power[k];
        }
        return math.log(math.max(e, 1e-10));
      });
      frames.add(List<double>.generate(numCoeffs, (k) {
        var s = 0.0;
        for (var n = 0; n < numFilters; n++) {
          s += _dct[k][n] * logMel[n];
        }
        return s;
      }));
    }
    _normalize(frames);
    return frames;
  }

  static void _normalize(List<List<double>> frames) {
    final n = frames.length;
    for (var k = 0; k < numCoeffs; k++) {
      var mean = 0.0;
      for (final f in frames) {
        mean += f[k];
      }
      mean /= n;
      var v = 0.0;
      for (final f in frames) {
        v += (f[k] - mean) * (f[k] - mean);
      }
      final std = math.sqrt(v / n) + 1e-6;
      for (final f in frames) {
        f[k] = (f[k] - mean) / std;
      }
    }
  }
}
