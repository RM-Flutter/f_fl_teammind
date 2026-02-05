// Conditional import: only import tflite on mobile platforms
export 'tflite_flutter_stub.dart'
    if (dart.library.io) 'tflite_flutter_mobile.dart';

