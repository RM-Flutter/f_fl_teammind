// Stub implementation for web platform
import 'dart:io';
import 'dart:typed_data';

class Interpreter {
  Interpreter._();
  
  static Future<Interpreter> fromAsset(String assetPath) {
    throw UnsupportedError('tflite_flutter is not supported on web platform');
  }

  static Interpreter fromFile(File modelFile) {
    throw UnsupportedError('tflite_flutter is not supported on web platform');
  }

  static Interpreter fromBuffer(Uint8List buffer) {
    throw UnsupportedError('tflite_flutter is not supported on web platform');
  }
  
  void run(List<List<List<List<double>>>> input, List<List<double>> output) {
    throw UnsupportedError('tflite_flutter is not supported on web platform');
  }
  
  void close() {
    // No-op for stub
  }
}

