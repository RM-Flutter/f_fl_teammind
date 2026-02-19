import 'package:dio/dio.dart';

/// No-op on web (no dart:io). Real implementation in dio_adapter_reset.dart for VM.
void resetDioAdapter(Dio dio) {}
